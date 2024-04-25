import 'package:firechat/common/utils/colors.dart';
import 'package:firechat/common/widgets/loader.dart';
import 'package:firechat/features/status/controller/status_controller.dart';
import 'package:firechat/features/status/screens/status_screen.dart';
import 'package:firechat/models/status_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusContactScreen extends ConsumerWidget {
  const StatusContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Status>>(
        future: ref.read(statusControllerProvider).getStatus(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var statusData = snapshot.data![index];
                print(snapshot.data!.length);
                print(statusData);
                print(statusData.username);
                print(statusData.profilePic);
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, StatusScreen.routeName, arguments: statusData);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                            statusData.username,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(statusData.profilePic),
                            radius: 30,
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      color: dividerColor,
                      indent: 85,
                    )
                  ],
                );
              });
        });
  }
}
