import 'package:flutter/material.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/widget/dialogs/dialog_button_painted.dart';
import 'package:hold/widget/dialogs/dialog_container.dart';

class DialogNoInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MixPanelProvider().trackEvent("CONVERSATION", {
      "Pageview Offline Pop Up": DateTime.now().toIso8601String(),
    });
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
            MixPanelProvider().trackEvent("CONVERSATION", {
              "Click Got It Offline Button": DateTime.now().toIso8601String(),
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
