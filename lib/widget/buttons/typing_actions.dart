import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/constants/app_styles.dart';

class TypingActions extends StatelessWidget {
  final VoidCallback showKeyboard;
  final VoidCallback showVoiceRecognition;
  final VoidCallback saveAction;
  final ButtonOptions buttonOptions;
  final Color activeItemColor;

  const TypingActions(
    this.showKeyboard,
    this.showVoiceRecognition,
    this.saveAction,
    this.activeItemColor, {
    Key key,
    this.buttonOptions = ButtonOptions.initial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("current typing actions state is $buttonOptions");
    String leftButtonText, rightButtonText;
    VoidCallback leftAction, rightAction;
    switch (buttonOptions) {
      case ButtonOptions.initial:
        leftButtonText = "SPEAK";
        rightButtonText = "WRITE";
        leftAction = showVoiceRecognition;
        rightAction = showKeyboard;
        break;
      case ButtonOptions.keyboardAndProgress:
        leftButtonText = "WRITE";
        rightButtonText = "NEXT";
        leftAction = showKeyboard;
        rightAction = saveAction;
        break;
      case ButtonOptions.voice:
        leftButtonText = "SPEAK";
        rightButtonText = "NEXT";
        leftAction = showVoiceRecognition;
        break;
      case ButtonOptions.voiceAndProgress:
        rightAction = saveAction;
        leftButtonText = "SPEAK";
        rightButtonText = "NEXT";
        leftAction = showVoiceRecognition;
        break;
      case ButtonOptions.keyboard:
        leftButtonText = "WRITE";
        rightButtonText = "NEXT";
        leftAction = showKeyboard;
        break;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: AppColors.BOTTOM_BAR_ACTIVE_BG,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.BORDER_RADIUS))),
          child: SizedBox.expand(
            child: FlatButton(
              textColor: AppColors.BOTTOM_BAR_ACTIVE_TEXT,
              padding: EdgeInsets.all(0.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                        leftButtonText == "SPEAK"
                            ? Icons.mic_none
                            : Icons.text_fields,
                        color: AppColors.ORANGE_BUTTON_TEXT),
                  ),
                  Expanded(
                    child: Text(
                      leftButtonText,
                      textAlign: TextAlign.center,
                      style: AppStyles.BOTTOM_BUTTON,
                    ),
                  )
                ],
              ),
              onPressed: () {
                leftAction();
              },
            ),
          ),
        )),
        SizedBox(
          width: 1.0,
          child: Container(
            color: Color(0xffDDDEE3),
          ),
        ),
        Expanded(
            child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(AppSizes.BORDER_RADIUS))),
                child: SizedBox.expand()),
            Opacity(
              opacity: rightAction == null ? 0.38 : 1.0,
              child: Container(
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                    color: rightButtonText == "WRITE"
                        ? AppColors.BOTTOM_BAR_ACTIVE_BG
                        : activeItemColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(AppSizes.BORDER_RADIUS))),
                child: SizedBox.expand(
                  child: FlatButton(
                    textColor: rightAction == null
                        ? AppColors.BOTTOM_BAR_INACTIVE_TEXT
                        : AppColors.BOTTOM_BAR_ACTIVE_TEXT,
                    padding: EdgeInsets.all(0.0),
                    child: rightButtonText == "WRITE"
                        ? Row(children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.text_fields,
                                  color: AppColors.ORANGE_BUTTON_TEXT),
                            ),
                            Expanded(
                              child: Text(
                                rightButtonText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ORANGE_BUTTON_TEXT),
                              ),
                            ),
                          ])
                        : Text(
                            rightButtonText,
                            textAlign: TextAlign.center,
                            style: AppStyles.BOTTOM_BUTTON,
                          ),
                    onPressed: rightAction,
                  ),
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }
}

enum ButtonOptions {
  initial,
  voice,
  keyboard,
  voiceAndProgress,
  keyboardAndProgress
}
