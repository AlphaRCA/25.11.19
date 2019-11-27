import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';

class DialogView extends StatelessWidget {
  final String title, mainText;
  final IconData titleIcon;
  final Widget buttons;

  const DialogView({
    Key key,
    @required this.title,
    @required this.mainText,
    @required this.titleIcon,
    @required this.buttons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(AppSizes.BORDER_RADIUS)),
          color: AppColors.DIALOG_BG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(AppSizes.BORDER_RADIUS),
                topLeft: Radius.circular(AppSizes.BORDER_RADIUS),
              ),
              color: AppColors.ORANGE_BUTTON_BACKGROUND,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(18.0),
                child: Icon(
                  titleIcon,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.ORANGE_BUTTON_BACKGROUND,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ICON_HALO,
                        spreadRadius:
                            4.0, // has the effect of extending the shadow
                      ),
                      BoxShadow(
                        color: AppColors.ICON_HALO,
                        spreadRadius:
                            16.0, // has the effect of extending the shadow
                      ),
                      BoxShadow(
                        color: AppColors.ICON_HALO,
                        spreadRadius:
                            24.0, // has the effect of extending the shadow
                      ),
                    ]),
              ),
            ),
          ),
          title == null
              ? Container()
              : SizedBox(
                  height: 16,
                ),
          title == null
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColors.DIALOG_TEXT,
                      fontSize: 21.13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              mainText,
              style: TextStyle(
                color: AppColors.DIALOG_TEXT,
                fontSize: 17.25,
              ),
            ),
          ),
          SizedBox(
            height: 24.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: buttons,
          ),
        ],
      ),
    );
  }
}
