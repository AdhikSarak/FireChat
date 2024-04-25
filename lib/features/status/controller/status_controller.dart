import 'dart:io';

import 'package:firechat/features/auth/controller/auth_controller.dart';
import 'package:firechat/features/status/repositories/status_repository.dart';
import 'package:firechat/models/status_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final statusControllerProvider = Provider((ref) {
  final statusRepositories = ref.read(statusRepositoryProvider);
  return StatusController(statusRepositories: statusRepositories, ref: ref);
});

class StatusController {
  final StatusRepositories statusRepositories;
  final ProviderRef ref;

  StatusController({required this.statusRepositories, required this.ref});

  void addStatus(
    File file,
    BuildContext context,
  ) {
    ref.watch(userDataAuthProvider).whenData((value) {
      statusRepositories.uploadStatus(
          username: value!.name,
          profilePic: value.profilePic,
          phoneNumber: value.phoneNumber,
          statusImage: file,
          context: context);
    });
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statuses = await statusRepositories.getStatus(context);
    return statuses;
  }
}
