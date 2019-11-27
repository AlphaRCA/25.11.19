import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/widget/dialogs/toast_view.dart';

class GeneralToast extends StatelessWidget {
  final String text;
  final IconData iconData;
  final Widget image;

  const GeneralToast(
    this.text, {
    Key key,
    this.iconData,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.DIALOG_FADE,
      constraints: BoxConstraints.expand(),
      child: Center(
        child: ToastView(
          text,
          iconData: iconData,
          image: image,
        ),
      ),
    );
  }
}
