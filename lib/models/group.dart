class GroupModel {
  final String name;
  final String senderId;
  final String groupId;
  final String lastMessage;
  final String groupPic;
  final List<String> memberUid;

  GroupModel({required this.name, required this.senderId, required this.groupId, required this.lastMessage, required this.groupPic, required this.memberUid});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'senderId': senderId,
      'groupId': groupId,
      'lastMessage': lastMessage,
      'groupPic': groupPic,
      'memberUid': memberUid,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      name: map['name'] as String,
      senderId: map['senderId'] as String,
      groupId: map['groupId'] as String,
      lastMessage: map['lastMessage'] as String,
      groupPic: map['groupPic'] as String,
      memberUid: List<String>.from(map['memberUid'] as List<String>),
    );
  }

}
