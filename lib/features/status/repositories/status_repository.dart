import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firechat/common/repositories/common_firebase_storage_repositories.dart';
import 'package:firechat/common/utils/utils.dart';
import 'package:firechat/main.dart';
import 'package:firechat/models/status_model.dart';
import 'package:firechat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final statusRepositoryProvider = Provider(
  (ref) => StatusRepositories(
    firestore: FirebaseFirestore.instance,
    ref: ref,
    auth: FirebaseAuth.instance,
  ),
);

class StatusRepositories {
  final FirebaseFirestore firestore;
  final ProviderRef ref;
  final FirebaseAuth auth;

  StatusRepositories({
    required this.firestore,
    required this.ref,
    required this.auth,
  });

  void uploadStatus({
    required String username,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
    required BuildContext context,
  }) async {
    try {
      var statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;
      String imageurl = await ref
          .read(commonFirebaseStorageRepositoriesProvider)
          .storeFileToFirebase(
            '/status/$statusId$uid',
            statusImage,
          );
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      List<String> uidWhoCanSee = [];
      var usersFromDb = await firestore.collection('users').get();
      for (var document in usersFromDb.docs) {
        var userDataFirebase = UserModel.fromMap(document.data());

        for (var i = 0; i < contacts.length; i++) {
          if (contacts[i].phones.isNotEmpty) {
            if (contacts[i].phones[0].normalizedNumber ==
                userDataFirebase.phoneNumber) {
              uidWhoCanSee.add(userDataFirebase.uid);
            }
            // var userDataFirebase = await firestore
            //     .collection('users')
            //     .where(
            //       'phoneNumber',
            //       isEqualTo: contacts[i].phones[0].normalizedNumber,
            //     )
            //     .get();

            // if (userDataFirebase.docs.isNotEmpty) {
            // var userData = UserModel.fromMap(userDataFirebase.docs[0].data());

            //}
          }
        }
      }

      List<String> statusImageUrls = [];
      var statusesSnapshot = await firestore
          .collection('status')
          .where(
            'uid',
            isEqualTo: auth.currentUser!.uid,
          )
          .get();

      if (statusesSnapshot.docs.isNotEmpty) {
        var status = Status.fromMap(statusesSnapshot.docs[0].data());
        statusImageUrls = status.photoUrl;
        statusImageUrls.add(imageurl);
        await firestore
            .collection('status')
            .doc(statusesSnapshot.docs[0].id)
            .update({
          'photoUrl': statusImageUrls,
        });
        return;
      } else {
        statusImageUrls = [imageurl];
      }

      Status status = Status(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        whoCanSee: uidWhoCanSee,
      );

      await firestore.collection('status').doc(statusId).set(status.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statusData = [];
    try {
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      //List<String> uidWhoCanSee = [];
      var statusSnapshot = await firestore
          .collection('status')
          .where(
            'createdAt',
            isGreaterThan: DateTime.now().subtract(
              Duration(
                hours: 24,
              ),
            ).millisecondsSinceEpoch,
          )
          .get();
      for (var document in statusSnapshot.docs) {
        var statusDataFirebase = Status.fromMap(document.data());

        for (var i = 0; i < contacts.length; i++) {
          if (contacts[i].phones.isNotEmpty) {
            if (contacts[i].phones[0].normalizedNumber ==
                statusDataFirebase.phoneNumber) {
              if (statusDataFirebase.whoCanSee
                  .contains(auth.currentUser!.uid)) {
                statusData.add(statusDataFirebase);
              }
            }
          }
        }
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
    return statusData;
  }
}
