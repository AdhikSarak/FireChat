import 'package:firechat/common/enums/message_enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReplyMessage {
  final String message;
  final bool isMe;
  final MessageEnum messageEnum;

  ReplyMessage(this.message, this.isMe, this.messageEnum);
}

final replyMessageProvider = StateProvider<ReplyMessage?>((ref) {});
