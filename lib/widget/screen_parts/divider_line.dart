import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';

class DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 48,
      thickness: 1,
      color: AppColors.DIVIDER_COLOR,
    );
  }
}
