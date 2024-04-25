import 'package:firechat/common/utils/error.dart';
import 'package:firechat/common/widgets/loader.dart';
import 'package:firechat/features/chat/widgets/contact_list.dart';
import 'package:firechat/features/select_contacts/controller/select_contact_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedGroupContacts = StateProvider<List<Contact>>((ref) => []);

class SelectContactGroups extends ConsumerStatefulWidget {
  const SelectContactGroups({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectContactGroupsState();
}

class _SelectContactGroupsState extends ConsumerState<SelectContactGroups> {
  List<int> selectedContactsIndex = [];
  void selectContact(int index, Contact contact) {
    if (selectedContactsIndex.contains(index)) {
      selectedContactsIndex.removeAt(index);
    } else {
      selectedContactsIndex.add(index);
    }
    setState(() {
      ref
          .read(selectedGroupContacts.notifier)
          .update((state) => [...state, contact]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getContactsProvider).when(
        data: (contactList) => Expanded(
                child: ListView.builder(
              itemCount: contactList.length,
              itemBuilder: (context, index) {
                final contact = contactList[index];
                return InkWell(
                  onTap: () => selectContact(index, contact),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        contact.displayName,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      trailing
                      : selectedContactsIndex.contains(index)
                          ? Icon(Icons.done)
                          : null,
                    ),
                  ),
                );
              },
            )),
        error: (e, trace) => ErrorScreen(error: e.toString()),
        loading: () => const Loader());
  }
}
