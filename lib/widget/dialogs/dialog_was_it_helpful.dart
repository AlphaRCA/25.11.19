import 'package:flutter/material.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';

import 'dialog_yes_no_cancel.dart';

class DialogWasItHelpful {
  Future<String> selectedQuestion;

  DialogWasItHelpful() {
    selectedQuestion = Future.value(
        "You have created a new conversation, did you find it helpful?"); //TODO load questions from database
  }

  void showQuestion(BuildContext context) async {
    String question = await selectedQuestion;
    DialogLaunchers.showDialog(
        context: context,
        dialog: DialogYesNoCancel(
          question,
          () async {
          },
          noAction: () {
          },
          cancelAction: () {
          },
          title: "Was it Helpful?",
          icon: Icons.done_outline,
        ));
  }
}
