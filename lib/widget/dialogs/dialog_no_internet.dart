import 'package:flutter/material.dart';
import 'package:hold/widget/dialogs/dialog_button_painted.dart';
import 'package:hold/widget/dialogs/dialog_container.dart';

class DialogNoInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogContainer(
      title: "Dictation is not available offline",
      mainText:
          "Unfortunately, you can only dictate text while you are online.",
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
