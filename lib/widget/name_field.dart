import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final FocusNode focusNode;
  final TextCapitalization textCapitalization;

  NameField(this.controller, this.hint, this.focusNode,
      {Key key, this.textCapitalization = TextCapitalization.none})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      textCapitalization: textCapitalization,
      style: TextStyle(
        color: AppColors.TEXT,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: hint,
        border: new OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(AppSizes.BORDER_RADIUS),
          ),
        ),
        filled: true,
        hintStyle: new TextStyle(color: Color(0x61ffffff)),
        fillColor: Color(0xff3e4b77),
      ),
    );
  }
}
