import 'dart:io';

import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:firechat/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
void showSnackBar({required BuildContext context, required String content}) {
  scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(content: Text(content)));
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return video;
}

Future<GiphyGif?> pickGif(BuildContext context) async {
  //9CxfmWVVIav0JsboS7ZsTUy04pm81gy4
  GiphyGif? gif;
  try {
    gif = await Giphy.getGif(
      context: context,
      apiKey: "9CxfmWVVIav0JsboS7ZsTUy04pm81gy4",
    );
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return gif;
}
