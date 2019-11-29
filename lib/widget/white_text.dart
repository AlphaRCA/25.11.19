import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';

class WhiteText extends StatelessWidget {
  final String text;
  final double paddingLeft;
  final double paddingTop;
  final double paddingAll;

  const WhiteText(
    this.text, {
    Key key,
    this.paddingLeft = 8.0,
    this.paddingTop = 4.0,
    this.paddingAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: paddingAll == null
          ? EdgeInsets.symmetric(horizontal: paddingLeft, vertical: paddingTop)
          : EdgeInsets.all(paddingAll),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14.7, color: AppColors.TEXT),
      ),
    );
  }
}
