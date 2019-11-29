import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';

class FlatTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onClick;

  const FlatTextButton(
    this.text,
    this.onClick, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      textColor: AppColors.TEXT_EF,
      disabledTextColor: AppColors.DIALOG_REMINDER_TEXT,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17.25,
          fontWeight: FontWeight.normal,
        ),
      ),
      onPressed: onClick,
    );
  }
}
