import 'package:flutter/material.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';

import 'dialog_yes_no_cancel.dart';

class DialogWasItHelpful {
  Future<String> selectedQuestion;

  DialogWasItHelpful() {
    selectedQuestion = Future.value(
        "You have created a new conversation, did you find it helpful?"); //TODO load questions from database
  }

  void showQuestion(BuildContext context) async {
    MixPanelProvider().trackEvent("REFLECT", {
      "Pageview Was This Helpful Pop Up": DateTime.now().toIso8601String(),
    });
    String question = await selectedQuestion;
    DialogLaunchers.showDialog(
        context: context,
        dialog: DialogYesNoCancel(
          question,
          () async {
            MixPanelProvider().trackEvent("REFLECT",
                {"Click Yes Helpful Button": DateTime.now().toIso8601String()});
          },
          noAction: () {
            MixPanelProvider().trackEvent("REFLECT",
                {"Click No Helpful Button": DateTime.now().toIso8601String()});
          },
          cancelAction: () {
            MixPanelProvider().trackEvent("REFLECT", {
              "Click Cancel Helpful Button": DateTime.now().toIso8601String()
            });
          },
          title: "Was it Helpful?",
          icon: Icons.done_outline,
        ));
  }
}
