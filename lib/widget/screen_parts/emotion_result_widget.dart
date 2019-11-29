import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/widget/bold_slider_track_shape.dart';

class EmotionResultWidget extends StatelessWidget {
  final int value;
  final double height;

  const EmotionResultWidget(
    this.value, this.height,{
    Key key,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          child: Text(
            "How positive or negative you felt.",
            style: TextStyle(
              color: AppColors.TEXT_EF,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "NEGATIVE",
                  style: TextStyle(
                    color: AppColors.EMOTION_VARIANTS_TEXT,
                    fontSize: 10,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "POSITIVE",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.EMOTION_VARIANTS_TEXT,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: height,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Positioned(
                top: -12.0,
                left: 16.0,
                right: 16.0,
                child: SliderTheme(
                  data: SliderThemeData(
                    disabledThumbColor: AppColors.EMOTION_THUMB,
                    disabledActiveTrackColor: AppColors.EMOTION_BAR_FINISHED,
                    disabledInactiveTrackColor: AppColors.EMOTION_BAR_FINISHED,
                    thumbShape: RoundSliderThumbShape(disabledThumbRadius: 8),
                    trackShape: BoldSliderTrackShape(),
                  ),
                  child: Slider(
                    onChanged: null,
                    value: value != null ? value.roundToDouble() : 0,
                    min: 0,
                    max: 100,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
