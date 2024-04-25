import 'package:firechat/common/providers/message_reply_provider.dart';
import 'package:firechat/features/chat/widgets/display_image_text_gif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

class MessageReplyPreview extends ConsumerWidget {
  const MessageReplyPreview({super.key});

  void cancelReply(WidgetRef ref) {
    ref.read(replyMessageProvider.notifier).update((state) => null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(replyMessageProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft:Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      width: 350,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                messageReply!.isMe ? 'Me' : 'Opposite',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )),
              GestureDetector(
                child: const Icon(Icons.close),
                onTap: () => cancelReply(ref),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          DisplayImageTextGif(
            type: messageReply.messageEnum, 
            message: messageReply.message,
          ),
        ],
      ),
    );
  }
}
