import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/widget/dialogs/dialog_view.dart';

class DialogContainer extends StatelessWidget {
  final String title, mainText;
  final IconData titleIcon;
  final Widget buttons;

  const DialogContainer({
    Key key,
    @required this.title,
    @required this.mainText,
    @required this.titleIcon,
    @required this.buttons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: DialogView(
        title: title,
        mainText: mainText,
        titleIcon: titleIcon,
        buttons: buttons,
      ),
      backgroundColor: AppColors.TRANSPARENT,
    );
  }
}
