import 'package:firebase_auth/firebase_auth.dart';
import 'package:firechat/common/enums/message_enum.dart';
import 'package:firechat/common/providers/message_reply_provider.dart';
import 'package:firechat/common/widgets/loader.dart';
import 'package:firechat/features/chat/controller/chat_controller.dart';
import 'package:firechat/features/chat/widgets/message_reply_preview.dart';
import 'package:firechat/features/chat/widgets/my_message_card.dart';
import 'package:firechat/features/chat/widgets/sender_message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;
  const ChatList({required this.receiverUserId, super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  void onMessageSwipe(
    String message,
    bool isMe,
    MessageEnum messageEnum,
  ) {
    ref
        .read(replyMessageProvider.notifier)
        .update((state) => ReplyMessage(message, isMe, messageEnum));
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          ref.read(chatControllerProvider).chatMessages(widget.receiverUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        SchedulerBinding.instance.addPostFrameCallback((_) {
          messageController.jumpTo(messageController.position.maxScrollExtent);
        });
        return ListView.builder(
          controller: messageController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var messageData = snapshot.data![index];
            var timeSent = DateFormat.Hm().format(messageData.timeSent);
            if (!messageData.isSeen &&
                messageData.receiverId ==
                    FirebaseAuth.instance.currentUser!.uid) {
              ref.read(chatControllerProvider).setChatMessageSeen(
                  context, messageData.receiverId, messageData.messageId);
            }
            if (messageData.senderId ==
                FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: messageData.text,
                time: timeSent,
                type: messageData.type,
                onLeftSwipe: (details) =>
                    onMessageSwipe(messageData.text, true, messageData.type),
                repliedText: messageData.repliedMessage,
                username: messageData.repliedTo,
                repliedMessageType: messageData.repliedMessageType,
                isSeen: messageData.isSeen,
              );
              //return MyMessageCard(message: message, time: time, type: type, onLeftSwipe: onLeftSwipe, repliedText: repliedText, username: username, repliedMessageType: repliedMessageType, isSeen: isSeen)
            }
            return SenderMessageCard(
                message: messageData.text,
                time: timeSent,
                type: messageData.type,
                onLeftSwipe: (details) =>
                    onMessageSwipe(messageData.text, false, messageData.type),
                repliedText: messageData.repliedMessage,
                username: widget.receiverUserId,
                repliedMessageType: messageData.repliedMessageType,
                isSeen: true);
          },
        );
      },
    );
  }
}
