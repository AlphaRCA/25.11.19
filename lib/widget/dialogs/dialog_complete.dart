import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/widget/dialogs/dialog_button_painted.dart';
import 'package:hold/widget/dialogs/dialog_container.dart';

class DialogComplete extends StatelessWidget {
  final FutureFunction addToCollection;
  final String conversationTitle;

  const DialogComplete(
    this.conversationTitle,
    this.addToCollection, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogContainer(
      title: "Add to collection",
      mainText:
          "You have developed '$conversationTitle'. Would you like to add this to a collection?",
      titleIcon: Icons.done_outline,
      buttons: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: FlatButton(
              textColor: AppColors.DIALOG_INACTIVE_TEXT,
              child: Text("NOT NOW"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: DialogButtonPainted(
                //Click Add to Collection Button
                text: "ADD TO COLLECTION",
                onPressed: () async {
                  await addToCollection();
                  Navigator.of(context).pop();
                }),
          ),
        ],
      ),
    );
  }
}

typedef Future<void> FutureFunction();
