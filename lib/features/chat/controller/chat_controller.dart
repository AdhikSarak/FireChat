import 'dart:io';

import 'package:firechat/common/enums/message_enum.dart';
import 'package:firechat/common/providers/message_reply_provider.dart';
import 'package:firechat/features/auth/controller/auth_controller.dart';
import 'package:firechat/features/chat/repoistories/chat_repository.dart';
import 'package:firechat/models/chat_contact.dart';
import 'package:firechat/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({required this.chatRepository, required this.ref});

  void sendTextMessage(
      BuildContext context, String text, String receiverUserId) {
    final replyMessage = ref.watch(replyMessageProvider);
    ref.read(userDataAuthProvider).whenData((value) {
      chatRepository.sendTextMessage(
          context: context,
          text: text,
          receiverUserId: receiverUserId,
          senderUser: value!,
          replyMessage: replyMessage);
    });
    ref.read(replyMessageProvider.notifier).update((state) => null);
  }

  void sendGifMessage(BuildContext context, String url, String receiverUserId) {
    int gifUrlPartIndex = url.lastIndexOf('-') + 1;
    String gifUrlPart = url.substring(gifUrlPartIndex);
    String newGifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';
    print(newGifUrl);

    final replyMessage = ref.watch(replyMessageProvider);
    ref.read(userDataAuthProvider).whenData((value) {
      chatRepository.sendGifMessage(
        context: context,
        url: newGifUrl,
        receiverUserId: receiverUserId,
        senderUser: value!,
        replyMessage: replyMessage,
      );
    });
    ref.read(replyMessageProvider.notifier).update((state) => null);
  }

  void sendFileMessage(BuildContext context, File file, String receiverUserId,
      MessageEnum messageEnum) {
    final replyMessage = ref.watch(replyMessageProvider);
    ref.read(userDataAuthProvider).whenData((value) {
      chatRepository.sendFileMessage(
        context: context,
        receiverUserId: receiverUserId,
        senderUserData: value!,
        file: file,
        ref: ref,
        messageEnum: messageEnum,
        replyMessage: replyMessage,
      );
    });
    ref.read(replyMessageProvider.notifier).update((state) => null);
  }

  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContacts();
  }

  Stream<List<Message>> chatMessages(String receiverUserId) {
    return chatRepository.getChatStream(receiverUserId);
  }

  void setChatMessageSeen(
    BuildContext context,
    String receiverUserId,
    String messageId,
  ) {
    chatRepository.setChatMessageSeen(context, receiverUserId, messageId);
  }
}
