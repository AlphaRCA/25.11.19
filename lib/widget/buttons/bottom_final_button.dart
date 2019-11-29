import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/constants/app_styles.dart';

class BottomFinalButton extends StatelessWidget {
  final VoidCallback action;
  final String text;

  const BottomFinalButton(
    this.text,
    this.action, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.BORDER_RADIUS),
          topRight: Radius.circular(AppSizes.BORDER_RADIUS),
        ),
      ),
      child: SizedBox.expand(
        child: FlatButton(
          textColor: action == null
              ? AppColors.BOTTOM_BAR_INACTIVE_TEXT
              : AppColors.BOTTOM_BAR_ACTIVE_TEXT,
          color: action == null
              ? AppColors.BOTTOM_BAR_DISABLED
              : AppColors.BOTTOM_BAR_ACTIVE_BG,
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
