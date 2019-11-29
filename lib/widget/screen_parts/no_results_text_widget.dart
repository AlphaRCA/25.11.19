import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';

class NoResultTextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No results",
        style: TextStyle(
            color: AppColors.TEXT, fontSize: 21.1, fontWeight: FontWeight.bold),
      ),
    );
  }
}
