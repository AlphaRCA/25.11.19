import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';

class OnboardingText extends StatelessWidget {
  final String text;
  final Color color;

  const OnboardingText(
    this.text, {
    Key key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style:
          TextStyle(color: color ?? AppColors.ONBOARDING_TEXT, fontSize: 15.0),
    );
  }
}
