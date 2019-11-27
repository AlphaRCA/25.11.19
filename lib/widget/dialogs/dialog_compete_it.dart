import 'package:flutter/material.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/widget/dialogs/dialog_button_painted.dart';
import 'package:hold/widget/dialogs/dialog_container.dart';

class DialogCompleteIt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MixPanelProvider().trackEvent("REFLECT", {
      "Pageview Locked Reflect on Incomplete Pop Up": DateTime.now().toIso8601String(),
    });
    return DialogContainer(
      title: "Complete your conversation",
      mainText:
          "You must complete three entries into this conversation and record "
          "your emotion to move onto reflecting on this.",
      titleIcon: Icons.info_outline,
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
