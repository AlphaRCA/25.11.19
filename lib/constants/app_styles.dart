import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  static const GENERAL_TEXT = TextStyle(color: AppColors.TEXT, fontSize: 14);

  // AppBar Text Styles
  static const APPBAR_TITLE_TEXT = TextStyle(
    fontSize: 21.13,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.25,
    fontFamily: "Cabin",
  );

  static const LARGER_TEXT = TextStyle(
      color: AppColors.TEXT, fontSize: 16, fontWeight: FontWeight.bold);
  static const BOTTOM_BUTTON = TextStyle(
    color: AppColors.BOTTOM_ACTION_TEXT,
    fontSize: 14.7,
    fontWeight: FontWeight.bold,
  );

  static const PROFILE_TEXT = TextStyle(
    color: AppColors.TEXT_EF,
    fontSize: 17.25,
    fontWeight: FontWeight.normal,
  );
}
