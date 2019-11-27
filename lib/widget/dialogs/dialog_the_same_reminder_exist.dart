import 'package:flutter/material.dart';
import 'package:hold/widget/dialogs/dialog_button_painted.dart';
import 'package:hold/widget/dialogs/dialog_container.dart';

class DialogTheSameReminderExists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogContainer(
      title: "Unable to save reminder",
      mainText:
          "You've set a reminder with the same time and day already. Please change time or day.",
      titleIcon: Icons.mic,
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
