import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';

class ToastView extends StatelessWidget {
  final String text;
  final IconData iconData;
  final Widget image;

  const ToastView(
    this.text, {
    Key key,
    this.iconData,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 22.0),
      width: 160,
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(AppSizes.BORDER_RADIUS)),
          color: AppColors.ORANGE_BUTTON_BACKGROUND,
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 20.0, // has the effect of softening the shadow
              spreadRadius: 5.0, // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                0.0, // vertical, move down 10
              ),
            )
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            child: iconData != null
                ? Icon(
                    iconData,
                    color: Colors.white,
                  )
                : image,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.ORANGE_BUTTON_BACKGROUND,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ICON_HALO,
                    spreadRadius: 4.0, // has the effect of extending the shadow
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
          SizedBox(
            height: 24.0,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.fade,
            style: TextStyle(
                color: AppColors.DIALOG_TEXT,
                fontFamily: 'Cabin',
                fontWeight: FontWeight.w700,
                fontSize: 21.0),
          ),
        ],
      ),
    );
  }
}
