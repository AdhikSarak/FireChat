import 'package:firechat/common/widgets/loader.dart';
import 'package:firechat/features/auth/controller/auth_controller.dart';
import 'package:firechat/features/chat/widgets/bottom_chat_field.dart';
import 'package:firechat/features/chat/widgets/chat_list.dart';
import 'package:firechat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileChatScreen extends ConsumerWidget {
  final String name;
  final String uid;
  final String profilePic;
  const MobileChatScreen(
      {super.key,
      required this.name,
      required this.uid,
      required this.profilePic});
  static const String routeName = '/mobile-chat-screen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          // leading: CircleAvatar(
          //   backgroundImage: NetworkImage(profilePic),
          //),
          title: StreamBuilder<UserModel>(
              stream: ref.read(authControllerProvider).userDataById(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data!.profilePic),
                      ),
                    ),
                    
                    Column(
                      children: [
                        Text(name),
                        snapshot.data!.isOnline ? 
                        const Text('online',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                          ),
                        )
                        : SizedBox(height: 0,),
                      ],
                    ),
                  ],
                );
              })),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              receiverUserId: uid,
            ),
          ),
          BottomChatField(
            receiverUserId: uid,
          ),
        ],
      )
    );
  }
}
