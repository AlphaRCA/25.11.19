import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/constants/app_styles.dart';

class BottomButtonInStack extends StatelessWidget {
  final Color buttonColor;
  final Color textColor;
  final String text;
  final bool rounded;
  final VoidCallback action;

  const BottomButtonInStack(
    this.text,
    this.action, {
    Key key,
    this.rounded = false,
    this.buttonColor = AppColors.ORANGE_BUTTON_BACKGROUND,
    this.textColor = AppColors.ORANGE_BUTTON_TEXT,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.BOTTOM_BUTTON_SIZE,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: rounded
            ? BorderRadius.all(Radius.circular(AppSizes.BORDER_RADIUS))
            : BorderRadius.only(
                topLeft: Radius.circular(AppSizes.BORDER_RADIUS),
                topRight: Radius.circular(AppSizes.BORDER_RADIUS),
              ),
      ),
      child: SizedBox.expand(
        child: FlatButton(
          textColor: textColor,
          padding: EdgeInsets.all(0.0),
          child: Text(
            text,
            style: AppStyles.BOTTOM_BUTTON,
          ),
          onPressed: action,
        ),
      ),
    );
  }
}
