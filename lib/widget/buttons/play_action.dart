import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/play_controller.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/played_item.dart';

class PlayAction extends StatelessWidget {
  final PlayController playController;
  final int conversationId;

  const PlayAction(
    this.playController,
    this.conversationId, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayedItem>(
        stream: playController.activeItem,
        initialData: PlayedItem.initial,
        builder: (BuildContext context, AsyncSnapshot<PlayedItem> data) {
          bool isPlaying = data.data.isPlayed &&
              data.data.conversationCardId == conversationId;
          return GestureDetector(
            onTap: () {
              print("GESTURE ACTION $isPlaying");
              if (isPlaying) {
                playController.pauseVoice();
              } else {
                print("let's play full conversation with id $conversationId");
                playController.playConversation(conversationId);
              }
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(18.0),
                color: AppColors.PLAY_CONTAINER_BACKGROUND,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: isPlaying
                        ? SvgPicture.asset(
                            'assets/material_icons/rounded/av/pause.svg',
                            color: Colors.black87,
                          )
                        : SvgPicture.asset(
                            'assets/material_icons/rounded/av/play_arrow.svg',
                            color: Colors.black87,
                          ),
                  ),
                  Expanded(
                    child: Text(
                      isPlaying
                          ? "PAUSE CONVERSATION"
                          : "LISTEN TO CONVERSATION",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 40.0,
                  )
                ],
              ),
            ),
          );
        });
  }
}
