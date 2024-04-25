import 'package:firechat/common/utils/error.dart';
import 'package:firechat/common/widgets/loader.dart';
import 'package:firechat/features/select_contacts/controller/select_contact_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectContactScreen extends ConsumerWidget {
  static const String routeName = '/select-contact-screen';
  const SelectContactScreen({super.key});

  void selectContact(
      WidgetRef ref, Contact selectedContact, BuildContext context) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Contact'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),
      body: ref.watch(getContactsProvider).when(
          data: (contactList) {
            return ListView.builder(
              itemBuilder: (context, index) {
                final contact = contactList[index];

                return InkWell(
                  onTap: () => selectContact(ref, contact, context),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(
                        contact.displayName,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      leading: contact.photo == null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                              radius: 30,
                            )
                          : CircleAvatar(
                              backgroundImage: MemoryImage(contact.photo!),
                              radius: 30,
                            ),
                    ),
                  ),
                );
              },
              itemCount: contactList.length,
            );
          },
          error: (e, trace) => ErrorScreen(
                error: e.toString(),
              ),
          loading: () => const Loader()),
    );
  }
}
