class ChatContact {
  final String name;
  final String profilePic;
  final String lastMessage;
  final DateTime timeSent;
  final String contactId;
  ChatContact({
    required this.name,
    required this.profilePic,
    required this.lastMessage,
    required this.timeSent,
    required this.contactId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'lastMessage': lastMessage,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'contactId': contactId,
    };
  }

  factory ChatContact.fromMap(Map<String, dynamic> map) {
    return ChatContact(
      name: map['name'] as String,
      profilePic: map['profilePic'] as String,
      lastMessage: map['lastMessage'] as String,
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent'] as int),
      contactId: map['contactId'] as String,
    );
  }
}
