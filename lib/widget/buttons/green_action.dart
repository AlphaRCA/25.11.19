import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';

class GreenAction extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GreenAction(
    this.text,
    this.onPressed, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: new BorderRadius.circular(18.0),
            color: AppColors.PLAY_CONTAINER_BACKGROUND,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                text.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.7,
                    color: AppColors.BOTTOM_BAR_ACTIVE_TEXT),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
