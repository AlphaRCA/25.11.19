import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';

class WeekdaySelector extends StatelessWidget {
  final String value;
  final VoidCallback onClick;
  final bool isSelected;

  const WeekdaySelector(
    this.value,
    this.onClick, {
    Key key,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  isSelected ? AppColors.TEXT : AppColors.DIALOG_REMINDER_TEXT),
        ),
        onTap: onClick,
      ),
    );
  }
}
