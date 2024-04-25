import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firechat/common/repositories/common_firebase_storage_repositories.dart';
import 'package:firechat/common/utils/utils.dart';
import 'package:firechat/models/group.dart';
import 'package:firechat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final groupRepositoryProvider = Provider((ref) => GroupRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref));

class GroupRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  GroupRepository(
      {required this.firestore, required this.auth, required this.ref});

  void createGroup(BuildContext context, String name, File profilePic,
      List<Contact> selectedContact) async {
    try {
      List<String> uids = [];
      for (int i = 0; i < selectedContact.length; i++) {}

      // List<Contact> contacts = [];
      // if (await FlutterContacts.requestPermission()) {
      //   contacts = await FlutterContacts.getContacts(withProperties: true);
      // }
      //List<String> uidWhoCanSee = [];
      var userSnapshot = await firestore.collection('users').get();
      for (var document in userSnapshot.docs) {
        var userDataFirebase = UserModel.fromMap(document.data());

        for (var i = 0; i < selectedContact.length; i++) {
          if (selectedContact[i].phones.isNotEmpty) {
            if (selectedContact[i].phones[0].normalizedNumber ==
                userDataFirebase.phoneNumber) {
              uids.add(selectedContact[i].id);
              print(selectedContact[i].id);   
            }
          }
        }
      }
      var groupId = const Uuid().v1();

      String profileUrl = await ref
          .read(commonFirebaseStorageRepositoriesProvider)
          .storeFileToFirebase('group/$groupId', profilePic);

      GroupModel group = GroupModel(
          name: name,
          senderId: auth.currentUser!.uid,
          groupId: groupId,
          lastMessage: '',
          groupPic: profileUrl,
          memberUid: [auth.currentUser!.uid, ...uids]);

      await firestore.collection('groups').doc(groupId).set(group.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
