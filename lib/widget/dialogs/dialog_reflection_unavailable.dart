import 'package:flutter/material.dart';
import 'package:hold/widget/dialogs/dialog_button_painted.dart';
import 'package:hold/widget/dialogs/dialog_container.dart';

class DialogReflectionUnavailable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogContainer(
      title: "This stage is locked",
      mainText:
          "This reflection method will be available once you have used the others more.",
      titleIcon: Icons.https,
      buttons: Align(
        alignment: Alignment.topCenter,
        child: DialogButtonPainted(
          text: "GOT IT",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
