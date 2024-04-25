import 'package:firechat/common/enums/message_enum.dart';
import 'package:firechat/common/utils/colors.dart';
import 'package:firechat/features/chat/widgets/display_image_text_gif.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

class SenderMessageCard extends StatelessWidget {
  final String message;
  final String time;
  final MessageEnum type;
  final GestureDragUpdateCallback? onLeftSwipe;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;
  final bool isSeen;
  const SenderMessageCard(
      {super.key,
      required this.message,
      required this.time,
      required this.type,
      required this.onLeftSwipe,
      required this.repliedText,
      required this.username,
      required this.repliedMessageType,
      required this.isSeen});

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;
    return SwipeTo(
      onRightSwipe: onLeftSwipe,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            color: messageColor,
            margin: const EdgeInsets.all(15),
            child: Stack(
              children: [
                Padding(
                  padding: type == MessageEnum.text
                      ? const EdgeInsets.only(
                          left: 15,
                          right: 30,
                          top: 5,
                          bottom: 25,
                        )
                      : const EdgeInsets.only(
                          left: 8,
                          top: 8,
                          right: 8,
                          bottom: 25,
                        ),
                  child: DisplayImageTextGif(
                    type: type,
                    message: message,
                  ),
                ),
                Positioned(
                    bottom: 4,
                    right: 30,
                    child: Row(
                      children: [
                        Column(children: [
                          if (isReplying) ...[
                            Text(
                              username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: backgroundColor.withOpacity(0.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              child: DisplayImageTextGif(
                                type: repliedMessageType,
                                message: repliedText,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
                          DisplayImageTextGif(
                            type: type,
                            message: message,
                          ),
                        ]),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
    // return SwipeTo(
    //   onLeftSwipe: onLeftSwipe,
    //   child: child
    // );
  }
}
