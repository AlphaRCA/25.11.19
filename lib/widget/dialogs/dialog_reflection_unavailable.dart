import 'package:flutter/material.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/widget/dialogs/dialog_button_painted.dart';
import 'package:hold/widget/dialogs/dialog_container.dart';

class DialogReflectionUnavailable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MixPanelProvider().trackEvent("CONVERSATION", {
      "Click Method Button": DateTime.now().toIso8601String(),
      "question": "unavailable"
    });
    MixPanelProvider().trackEvent("REFLECT", {
      "Pageview Locked Reflect Tool Pop Up": DateTime.now().toIso8601String(),
    });

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
            MixPanelProvider().trackEvent("REFLECT", {
              "Got IT locked reflect": DateTime.now().toIso8601String(),
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
