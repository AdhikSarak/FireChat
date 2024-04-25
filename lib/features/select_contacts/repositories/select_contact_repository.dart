import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firechat/common/utils/utils.dart';
import 'package:firechat/features/chat/screens/mobile_chat_screen.dart';
import 'package:firechat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectContactRepositoryProvider = Provider((ref) =>
    SelectContactRepository(firebaseFirestore: FirebaseFirestore.instance));

class SelectContactRepository {
  final FirebaseFirestore firebaseFirestore;

  SelectContactRepository({required this.firebaseFirestore});

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firebaseFirestore.collection('users').get();
      bool isFound = false;

      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNumber = selectedContact.phones[0].number;
        selectedPhoneNumber = selectedPhoneNumber.replaceAll(' ', '');
        selectedPhoneNumber = selectedPhoneNumber.replaceAll('-', '');
        if (!selectedPhoneNumber.startsWith('+91')) {
          selectedPhoneNumber = selectedPhoneNumber.replaceFirst('', '+91');
        }

        if (selectedPhoneNumber == userData.phoneNumber) {
          isFound = true;
          Navigator.pushNamed(context, MobileChatScreen.routeName,
              arguments: {
                'name': selectedContact.displayName,
                'uid': userData.uid,
                'pic': userData.profilePic,
              });
        }
      }
      if (!isFound) {
        showSnackBar(
            context: context, content: 'This number is not using FireChat');
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
