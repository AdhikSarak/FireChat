import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firechat/common/enums/message_enum.dart';
import 'package:firechat/common/providers/message_reply_provider.dart';
import 'package:firechat/common/repositories/common_firebase_storage_repositories.dart';
import 'package:firechat/common/utils/utils.dart';
import 'package:firechat/models/chat_contact.dart';
import 'package:firechat/models/message.dart';
import 'package:firechat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository(
    firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance));

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];

      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);

        contacts.add(ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            lastMessage: chatContact.lastMessage,
            timeSent: chatContact.timeSent,
            contactId: chatContact.contactId));
      }

      return contacts;
    });
  }

  void _saveDataToContactSubCollection(
    UserModel senderUserData,
    UserModel receiverUserData,
    String text,
    DateTime timeSent,
    String receiverUserId,
  ) async {
    var receiverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      lastMessage: text,
      timeSent: timeSent,
      contactId: senderUserData.uid,
    );

    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(receiverChatContact.toMap());

    var senderChatContact = ChatContact(
        name: receiverUserData.name,
        profilePic: receiverUserData.profilePic,
        lastMessage: text,
        timeSent: timeSent,
        contactId: receiverUserData.uid);

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .set(senderChatContact.toMap());
  }

  void _saveMessageToMessageSubCollection({
    required String receiverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required String receiverUsername,
    required MessageEnum messageType,
    required ReplyMessage? replyMessage,
    required String senderUsername,
    required MessageEnum repliedMessageType,
  }) async {
    final message = Message(
        senderId: auth.currentUser!.uid,
        receiverId: receiverUserId,
        text: text,
        type: messageType,
        timeSent: timeSent,
        messageId: messageId,
        isSeen: false,
        repliedMessageType: repliedMessageType,
        repliedTo: replyMessage == null
            ? ''
            : replyMessage.isMe
                ? receiverUsername
                : senderUsername,
        repliedMessage: replyMessage == null ? '' : replyMessage.message);

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required UserModel senderUser,
    required ReplyMessage? replyMessage,
  }) async {
    try {
      print('sending...');
      var timeSent = DateTime.now();
      UserModel receiverUserData;
      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();

      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();
      _saveDataToContactSubCollection(
          senderUser, receiverUserData, text, timeSent, receiverUserId);

      _saveMessageToMessageSubCollection(
        receiverUserId: receiverUserId,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        receiverUsername: receiverUserData.name,
        messageType: MessageEnum.text,
        replyMessage: replyMessage,
        senderUsername: senderUser.name,
        repliedMessageType:
            replyMessage == null ? MessageEnum.text : replyMessage!.messageEnum,
      );
      print('sent Done');
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<List<Message>> getChatStream(String receiverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  void sendFileMessage(
      {required BuildContext context,
      required File file,
      required String receiverUserId,
      required UserModel senderUserData,
      required ProviderRef ref,
      required ReplyMessage? replyMessage,
      required MessageEnum messageEnum}) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoriesProvider)
          .storeFileToFirebase(
              'chat/${messageEnum.type}/${senderUserData.uid}/$receiverUserId/$messageId',
              file);

      UserModel receiverUserData;

      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();

      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📸 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '🎥 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }

      _saveDataToContactSubCollection(
        senderUserData,
        receiverUserData,
        contactMsg,
        timeSent,
        receiverUserId,
      );
      _saveMessageToMessageSubCollection(
        receiverUserId: receiverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        receiverUsername: receiverUserData.name,
        messageType: messageEnum,
        replyMessage: replyMessage,
        senderUsername: senderUserData.name,
        repliedMessageType:
            replyMessage == null ? MessageEnum.text : replyMessage!.messageEnum,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGifMessage({
    required BuildContext context,
    required String url,
    required String receiverUserId,
    required UserModel senderUser,
    required ReplyMessage? replyMessage,
  }) async {
    try {
      print('sending...');
      var timeSent = DateTime.now();
      UserModel receiverUserData;
      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();

      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();
      _saveDataToContactSubCollection(
          senderUser, receiverUserData, 'GIF', timeSent, receiverUserId);

      _saveMessageToMessageSubCollection(
        receiverUserId: receiverUserId,
        text: url,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        receiverUsername: receiverUserData.name,
        messageType: MessageEnum.gif,
        replyMessage: replyMessage,
        senderUsername: senderUser.name,
        repliedMessageType:
            replyMessage == null ? MessageEnum.text : replyMessage!.messageEnum,
      );
      print('sent Done');
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(
    BuildContext context,
    String receiverUserId,
    String messageId,
  ) async {
    try {
      await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .doc(messageId)
        .update({
          'isSeen': true,
        }
        );

    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .update({
          'isSeen': true,
        });
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
