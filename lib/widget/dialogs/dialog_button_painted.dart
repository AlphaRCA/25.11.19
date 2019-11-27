import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';

class DialogButtonPainted extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const DialogButtonPainted({Key key, @required this.text, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: AppColors.DIALOG_BUTTON_BG,
      textColor: AppColors.DIALOG_BUTTON_TEXT,
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(AppSizes.BORDER_RADIUS)),
      child: Text(
        text,
      ),
      onPressed: onPressed,
    );
  }
}
