import 'dart:io';

import 'package:firechat/common/utils/colors.dart';
import 'package:firechat/common/utils/utils.dart';
import 'package:firechat/features/auth/controller/auth_controller.dart';
import 'package:firechat/features/chat/widgets/contact_list.dart';
import 'package:firechat/features/group/screens/create_group_screen.dart';
import 'package:firechat/features/select_contacts/screens/select_contact_screen.dart';
import 'package:firechat/features/status/screens/confirm_status_screen.dart';
import 'package:firechat/features/status/screens/status_contacts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({super.key});

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search),
            ),
            PopupMenuButton(
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text(
                          'Create Group',
                        ),
                        onTap: () =>
                          Future(
                            () => Navigator.pushNamed(
                                context, CreateGroupScreen.routeName),
                          ),
                      ),
                    ]),
          ],
          title: Text('FireChat'),
          bottom: TabBar(
              controller: tabController,
              //indicatorColor: tabColor,
              indicatorWeight: 4,
              //labelColor: tabColor,
              tabs: [
                Tab(
                  text: 'Status',
                ),
                Tab(
                  text: 'Chats',
                ),
                Tab(
                  text: 'Calls',
                ),
              ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (tabController.index == 1) {
              Navigator.pushNamed(context, SelectContactScreen.routeName);
            } else {
              print('Started');
              File? pickedImage = await pickImageFromGallery(context);
              if (pickedImage != null) {
                print('Sending');
                Navigator.pushNamed(
                  context,
                  ConfirmStatusScreen.routeName,
                  arguments: pickedImage,
                );
              }
            }
          },
          backgroundColor: tabColor,
          child: const Icon(Icons.comment),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            StatusContactScreen(),
            ContactList(),
            const Text('Calls'),
          ],
        ),
      ),
    );
  }
}
