// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:firechat/common/enums/message_enum.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;
  final MessageEnum repliedMessageType;
  final String repliedTo;
  final String repliedMessage;
  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
    required this.repliedMessageType,
    required this.repliedTo,
    required this.repliedMessage,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': type.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'isSeen': isSeen,
      'repliedMessageType': repliedMessageType.type,
      'repliedTo': repliedTo,
      'repliedMessage': repliedMessage,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      text: map['text'] as String,
      type: (map['type'] as String).toEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent'] as int),
      messageId: map['messageId'] as String,
      isSeen: map['isSeen'] as bool,
      repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
      repliedTo: map['repliedTo'] as String,
      repliedMessage: map['repliedMessage'] as String,
    );
  }
}
