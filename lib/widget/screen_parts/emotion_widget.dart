import 'package:coach_marks/TutorialOverlayUtil.dart';
import 'package:coach_marks/WidgetData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/constants/app_colors.dart';

import '../bold_slider_track_shape.dart';
import '../holo_slider_thumb_shape.dart';

class EmotionWidget extends StatefulWidget {
  final ValueChanged<int> listener;
  final int initialValue;

  const EmotionWidget(
    this.listener, {
    Key key,
    this.initialValue = 50,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EmotionWidgetState();
  }
}

class EmotionWidgetState extends State<EmotionWidget> {
  double _currentValue;
  final GlobalKey _moodKey = GlobalKey();

  @override
  void initState() {
    _currentValue = widget.initialValue.roundToDouble();
    SchedulerBinding.instance.addPostFrameCallback(_createCoach);
    super.initState();
    _showCoachMark();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: _moodKey,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Text(
            "How positive or negative did you feel during this conversation?",
            style: TextStyle(
              color: AppColors.TEXT_EF,
              fontSize: 17.25,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
          child: Row(
            children: <Widget>[
              Image.asset(
                "assets/sad.png",
                width: 30.0,
                height: 30.0,
              ),
              Spacer(),
              Image.asset(
                "assets/smile.png",
                width: 30.0,
                height: 30.0,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
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
          height: 40.0,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Positioned(
                top: -12.0,
                left: 16.0,
                right: 16.0,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbColor: AppColors.EMOTION_THUMB,
                    activeTrackColor: AppColors.EMOTION_BAR,
                    inactiveTrackColor: AppColors.EMOTION_BAR,
                    thumbShape: HoloSliderThumbShape(thumbRadius: 8),
                    trackShape: BoldSliderTrackShape(),
                  ),
                  child: Slider(
                    onChanged: (value) {
                      widget.listener(value.round());
                      setState(() {
                        _currentValue = value;
                      });
                    },
                    value: _currentValue,
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

  void _createCoach(Duration timestamp) {
    final RenderBox containerRenderBox =
        _moodKey.currentContext.findRenderObject();
    final containerPosition = containerRenderBox.localToGlobal(Offset.zero).dy;

    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'mood',
      enableHolesAnimation: false,
      bgColor: Colors.black.withOpacity(
          0.75), // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveFirstEmotionCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[
        WidgetData(
            key: _moodKey,
            isEnabled: false,
            padding: 0,
            shape: WidgetShape.StretchedHRRect),
      ],
      description: Stack(
        children: <Widget>[
          Positioned(
            top: containerPosition - containerRenderBox.size.height - 16,
            left: 24,
            right: 24,
            child: Column(
              children: <Widget>[
                Text(
                  'Stating how you feel now, will\nhelp you understand your\nconversation later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      height: 1.5,
                      fontSize: 18,
                      fontFamily: 'Cabin',
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: SvgPicture.asset(
                    'assets/material_icons/rounded/navigation/expand_more.svg',
                    color: Colors.white,
                  ),
                ),
                SvgPicture.asset(
                  'assets/material_icons/rounded/navigation/expand_more.svg',
                  color: Colors.white,
                ),
                SizedBox(height: 24),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showCoachMark() async {
    if (!await PreferencesProvider().getFirstEmotionCoachMark())
      showOverlayEntry(tagName: 'mood');
  }
}
