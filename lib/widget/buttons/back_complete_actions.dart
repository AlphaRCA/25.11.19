import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/constants/app_styles.dart';

class BackCompleteActions extends StatelessWidget {
  final VoidCallback backAction;
  final VoidCallback nextAction;

  const BackCompleteActions(
    this.backAction,
    this.nextAction, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              child: Text(
                "BACK",
                style: AppStyles.BOTTOM_BUTTON,
              ),
              onPressed: backAction,
            ),
          ),
        )),
        SizedBox(
          width: 1.0,
          child: Container(
            width: 1.0,
            color: Color(0xffDDDEE3),
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: nextAction == null
                    ? AppColors.BOTTOM_BAR_DISABLED
                    : AppColors.BOTTOM_BAR_ACTIVE_BG,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(AppSizes.BORDER_RADIUS))),
            child: SizedBox.expand(
              child: FlatButton(
                textColor: nextAction == null
                    ? AppColors.BOTTOM_BAR_INACTIVE_TEXT
                    : AppColors.BOTTOM_BAR_ACTIVE_TEXT,
                padding: EdgeInsets.all(0.0),
                child: Text(
                  "COMPLETE",
                  style: AppStyles.BOTTOM_BUTTON.apply(
                    color: nextAction == null
                        ? AppColors.BOTTOM_BAR_INACTIVE_TEXT
                        : AppColors.BOTTOM_BAR_ACTIVE_TEXT,
                  ),
                ),
                onPressed: nextAction,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
