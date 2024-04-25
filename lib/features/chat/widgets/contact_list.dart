import 'package:firechat/common/utils/colors.dart';
import 'package:firechat/common/widgets/loader.dart';
import 'package:firechat/features/chat/controller/chat_controller.dart';
import 'package:firechat/features/chat/screens/mobile_chat_screen.dart';
import 'package:firechat/models/chat_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ContactList extends ConsumerWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: StreamBuilder<List<ChatContact>>(
        stream: ref.watch(chatControllerProvider).chatContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var chatContactData = snapshot.data![index];
              print(chatContactData.name);
              print(chatContactData.contactId);
              print(chatContactData.profilePic);
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,      
                        MobileChatScreen.routeName,
                        arguments: {
                          'name': chatContactData.name,
                          'uid': chatContactData.contactId,
                          'profilePic': chatContactData.profilePic,
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text(
                          chatContactData.name,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            chatContactData.lastMessage,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(chatContactData.profilePic),
                          radius: 30,
                        ),
                        trailing: Text(
                            DateFormat.Hm().format(chatContactData.timeSent)),
                      ),
                    ),
                  ),
                  const Divider(color: dividerColor, indent: 85,)
                ],
              );
            },
          );
        },
      ),
    );
  }
}
