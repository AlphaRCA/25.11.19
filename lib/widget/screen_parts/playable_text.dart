import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/play_controller.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/played_item.dart';
import 'package:hold/widget/stick_container.dart';
import 'package:hold/widget/stick_position.dart';

class PlayableText extends StatefulWidget {
  final PlayedItem data;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color borderColor;
  final double textScale;
  final PlayController bloc;
  final StickPosition stick;
  final String title;

  const PlayableText(
    this.data,
    this.bloc, {
    Key key,
    this.backgroundColor = AppColors.ACTION_LIGHT,
    this.textColor = AppColors.ACTION_LIGHT_TEXT,
    this.iconColor = AppColors.ACTION_LIGHT_TEXT,
    this.borderColor = AppColors.ACTION_LIGHT_BORDER,
    this.textScale = 1.0,
    this.stick = StickPosition.left,
    this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayableTextState();
  }
}

class _PlayableTextState extends State<PlayableText> {
  @override
  Widget build(BuildContext context) {
    return StickContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          widget.title == null
              ? Container()
              : Padding(
                  padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                  child: Text(
                    widget.title.toUpperCase(),
                    textScaleFactor: widget.textScale,
                    style: TextStyle(
                      color: widget.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.67,
                    ),
                  ),
                ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: Text(
              widget.data.text,
              textScaleFactor: widget.textScale,
              style: TextStyle(
                color: widget.textColor,
                fontSize: 15.0,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(-4, 4),
            child: StreamBuilder<PlayedItem>(
              stream: widget.bloc.activeItem,
              initialData: PlayedItem.initial,
              builder:
                  (BuildContext context, AsyncSnapshot<PlayedItem> playState) {
                if (playState.data.isIdentical(widget.data)) {
                  return Row(
                    children: <Widget>[
                      StreamBuilder<PlayedItem>(
                        initialData: PlayedItem.initial,
                        stream: widget.bloc.activeItem,
                        builder: (BuildContext context,
                            AsyncSnapshot<PlayedItem> playState) {
                          print(
                              "playState update ${playState.data.toString()}");
                          return Row(
                            children: <Widget>[
                              IconButton(
                                icon: playState.data.isPlayed
                                    ? SvgPicture.asset(
                                        'assets/material_icons/rounded/av/pause_circle_outline.svg',
                                        color: widget.iconColor,
                                      )
                                    : SvgPicture.asset(
                                        'assets/material_icons/rounded/av/play_circle_outline.svg',
                                        color: widget.iconColor,
                                      ),
                                onPressed:
                                    playState.data.isPlayed ? _pause : _resume,
                              ),
                              StreamBuilder<int>(
                                initialData: 0,
                                stream: widget.bloc.voicePercentage,
                                builder: (BuildContext context,
                                    AsyncSnapshot<int> percent) {
                                  print("actual percent: ${percent.data}");

                                  if (playState.data.isPlayed ||
                                      percent.data.roundToDouble() < 100) {
                                    return SliderTheme(
                                      data: SliderThemeData(
                                        disabledActiveTrackColor:
                                            AppColors.SECONDARY_700,
                                        disabledInactiveTrackColor: AppColors
                                            .SECONDARY_700
                                            .withOpacity(0.24),
                                        trackHeight: 4,
                                        thumbShape: RoundSliderThumbShape(
                                          disabledThumbRadius: 0,
                                        ),
                                      ),
                                      child: Slider(
                                        onChanged: null,
                                        min: 0.0,
                                        max: 100.0,
                                        value: percent.data.roundToDouble(),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: <Widget>[
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/material_icons/rounded/av/play_circle_outline.svg',
                          color: widget.iconColor,
                        ),
                        onPressed: _play,
                      )
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
      position: widget.stick,
      background: widget.backgroundColor,
    );
  }

  void _play() {
    if (widget.data.reflectionId == null) {
      widget.bloc.playContent(widget.data.inConversationContentId);
    } else {
      widget.bloc.playReflection(widget.data.reflectionId);
    }
  }

  void _pause() {
    widget.bloc.pauseVoice();
  }

  void _resume() {
    widget.bloc.resumeVoice();
  }
}
