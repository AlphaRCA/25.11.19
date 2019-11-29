import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';

class HeaderText extends StatelessWidget {
  final String _text;
  final Color color;
  final EdgeInsetsGeometry padding;

  const HeaderText(
    this._text, {
    Key key,
    this.color,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        _text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color ?? AppColors.TEXT,
          fontWeight: FontWeight.bold,
          fontSize: 25.36,
        ),
      ),
    );
  }
}
