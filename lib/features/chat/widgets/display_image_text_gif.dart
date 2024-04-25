import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firechat/common/enums/message_enum.dart';
import 'package:firechat/features/chat/widgets/video_player_item.dart';
import 'package:flutter/material.dart';

class DisplayImageTextGif extends StatelessWidget {
  final MessageEnum type;
  final String message;
  const DisplayImageTextGif(
      {super.key, required this.type, required this.message});

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();
    return type == MessageEnum.text
        ? Text(
            message,
            style: TextStyle(
              fontSize: 16,
            ),
          )
        : type == MessageEnum.image
            ? CachedNetworkImage(
                imageUrl: message,
              )
            : type == MessageEnum.audio
                ? StatefulBuilder(
                    builder: (context, setState) {
                      return IconButton(
                        constraints: BoxConstraints(
                          minWidth: 100,
                        ),
                        onPressed: () async {
                          if (isPlaying) {
                            await audioPlayer.pause();
                            setState(() {
                              isPlaying = false;
                            });
                          } else {
                            await audioPlayer.play(UrlSource(message));
                            setState(() {
                              isPlaying = true;
                            });
                          }
                        },
                        icon: isPlaying ? Icon(Icons.pause_circle) : Icon(Icons.play_circle),
                      );
                    },
                  )
                : type == MessageEnum.video
                    ? VideoPlayerItem(videoUrl: message)
                    : CachedNetworkImage(imageUrl: message);
  }
}
