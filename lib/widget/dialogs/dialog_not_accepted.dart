import 'package:flutter/material.dart';
import 'package:hold/widget/dialogs/dialog_button_painted.dart';
import 'package:hold/widget/dialogs/dialog_container.dart';

class DialogNotAccepted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogContainer(
      title: "It is impossible to proceed",
      mainText:
          "You cannot proceed until terms of service and privacy policy will be accepted. Please return to the third screen.",
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
