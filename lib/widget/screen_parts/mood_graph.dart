import 'package:flutter/material.dart';
import 'package:hold/bloc/recent_activity_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_styles.dart';
import 'package:hold/widget/dual_scroll_controller.dart';
import 'package:hold/widget/endless_horizontal_graph.dart';
import 'package:hold/widget/white_text.dart';

class MoodGraph extends StatelessWidget {
  static const HEIGHT = 125.0;
  static const FACE_HEIGHT = 20.0;
  static const FACE_PADDING = 8.0;
  static const PADDING = 16.0;
  static const BOTTOM_START = 15.0;
  final RecentActivityBloc bloc;
  final DualScrollController controller;
  final ValueChanged<int> selectedItemChanged;

  const MoodGraph(
    this.bloc,
    this.controller,
    this.selectedItemChanged, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: HEIGHT,
      decoration: BoxDecoration(
        color: AppColors.EMOTION_LOG_BG,
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            height: EndlessHorizontalGraphState.GRAPH_HEIGHT +
                EndlessHorizontalGraphState.CIRCLE_SIZE +
                BOTTOM_START * 2,
            left: 0,
            right: 0,
            child: EndlessHorizontalGraph(
              bloc,
              controller,
              selectedItemChanged,
              bottomGraphOffset: BOTTOM_START,
            ),
          ),
          /*Positioned(
            bottom: 0,
            right: 0,
            top: 0,
            width: PADDING + FACE_HEIGHT + FACE_PADDING,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.EMOTION_LOG_BG,
              ),
            ),
          ),*/
          Positioned(
            top: 0,
            left: PADDING,
            child: WhiteText(
              "EMOTION LOG",
              paddingAll: 0,
            ),
          ),
          Positioned(
            bottom: BOTTOM_START,
            left: PADDING,
            right: PADDING + FACE_HEIGHT + FACE_PADDING,
            child: Container(
              color: AppColors.EMOTION_LOG_LINE,
              height: 1.0,
            ),
          ),
          Positioned(
            bottom: BOTTOM_START,
            right: PADDING,
            child: Image.asset(
              "assets/sad.png",
              height: FACE_HEIGHT,
            ),
          ),
          Positioned(
            bottom: BOTTOM_START + EndlessHorizontalGraphState.GRAPH_HEIGHT / 2,
            left: PADDING,
            right: PADDING,
            child: Container(
              color: AppColors.EMOTION_LOG_CENTRAL_LINE,
              height: 1.0,
            ),
          ),
          Positioned(
            bottom: BOTTOM_START + EndlessHorizontalGraphState.GRAPH_HEIGHT,
            left: PADDING,
            right: PADDING + FACE_HEIGHT + FACE_PADDING,
            child: Container(
              color: AppColors.EMOTION_LOG_LINE,
              height: 1.0,
            ),
          ),
          Positioned(
            bottom: BOTTOM_START +
                EndlessHorizontalGraphState.GRAPH_HEIGHT -
                FACE_HEIGHT,
            right: PADDING,
            child: Image.asset(
              "assets/smile.png",
              height: FACE_HEIGHT,
            ),
          ),
        ],
      ),
    );
  }

  static double get graphInitialOffset => PADDING + FACE_HEIGHT + FACE_PADDING;
}
