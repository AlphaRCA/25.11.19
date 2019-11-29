import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/play_controller.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/played_item.dart';

class CircularPlayProgress extends StatefulWidget {
  final int conversationId;
  final PlayController bloc;
  final double size;

  const CircularPlayProgress(this.bloc,
      {Key key, this.conversationId, this.size})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CircularPlayProgressState();
  }
}

class CircularPlayProgressState extends State<CircularPlayProgress> {
  double size;
  double progressWidth = 4.0;

  @override
  void initState() {
    size = widget.size ?? 40.0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.conversationId == null) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          _getPlayingProgressWithBuilder(),
          StreamBuilder<PlayedItem>(
            stream: widget.bloc.activeItem,
            initialData: PlayedItem.initial,
            builder:
                (BuildContext context, AsyncSnapshot<PlayedItem> indexData) {
              return Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  _getPlayingProgressWithBuilder(),
                  _getButton(indexData.data.isPlayed)
                ],
              );
            },
          )
        ],
      );
    } else {
      return StreamBuilder<PlayedItem>(
        stream: widget.bloc.activeItem,
        initialData: PlayedItem.initial,
        builder: (BuildContext context, AsyncSnapshot<PlayedItem> indexData) {
          if (indexData.data.conversationCardId == widget.conversationId) {
            return Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                _getPlayingProgressWithBuilder(),
                _getButton(indexData.data.isPlayed)
              ],
            );
          } else {
            return _getButton(false);
          }
        },
      );
    }
  }

  Widget _getButton(bool isPlaying) {
    return Padding(
      padding: EdgeInsets.all(progressWidth - progressWidth / 2),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.0),
        ),
        // padding: EdgeInsets.all(2.0),
        child: SizedBox(
          width: size,
          height: size,
          child: IconButton(
            color: Colors.white,
            icon: isPlaying
                ? SvgPicture.asset(
                    'assets/material_icons/rounded/av/pause.svg',
                    color: Colors.white,
                  )
                : SvgPicture.asset(
                    'assets/material_icons/rounded/av/play_arrow.svg',
                    color: Colors.white,
                  ),
            onPressed: isPlaying ? _pause : _play,
          ),
        ),
      ),
    );
  }

  Widget _getPlayingProgressWithBuilder() {
    return Positioned.fill(
      child: StreamBuilder<int>(
        initialData: 0,
        stream: widget.bloc.voicePercentage,
        builder: (BuildContext ctxt, AsyncSnapshot<int> data) {
          return CircularProgressIndicator(
            strokeWidth: progressWidth,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.ORANGE_BUTTON_BACKGROUND),
            value: data.data / 100,
          );
        },
      ),
    );
  }

  void _pause() {
    widget.bloc.pauseVoice();
  }

  void _play() {
    if (widget.conversationId == null) {
      print("command play collection");
      widget.bloc.playCollection();
    } else {
      print("command play conversation");
      widget.bloc.playConversation(widget.conversationId);
    }
  }
}
