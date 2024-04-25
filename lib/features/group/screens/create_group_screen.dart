import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firechat/common/utils/colors.dart';
import 'package:firechat/common/utils/utils.dart';
import 'package:firechat/features/group/controller/group_controller.dart';
import 'package:firechat/features/group/widgets/select_contacts_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-group-screen';
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController groupController = TextEditingController();
  File? image;

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void createGroup() {
    if (groupController.text.toString().isNotEmpty && image != null) {
      ref.read(groupControllerProvider).createGroup(context,
          groupController.text.trim(), image!, ref.read(selectedGroupContacts));
      ref.read(selectedGroupContacts.notifier).update((state) => []);
    Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Group',
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Stack(
              children: [
                image == null
                    ? const CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                        radius: 64,
                      )
                    : CircleAvatar(
                        backgroundImage: FileImage(image!),
                        radius: 64,
                      ),
                Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                        onPressed: selectImage, icon: Icon(Icons.add_a_photo))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: TextField(
                controller: groupController,
                decoration: const InputDecoration(
                  hintText: 'Enter Group Name',
                ),
              ),
            ),
            const Text(
              'Select Contacts',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            SelectContactGroups(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        backgroundColor: tabColor,
        child: Icon(Icons.done),
      ),
    );
  }
}
