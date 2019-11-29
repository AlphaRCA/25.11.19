import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/widget/dialogs/dialog_button_painted.dart';
import 'package:hold/widget/dialogs/dialog_container.dart';

class DialogYesNoCancel extends StatelessWidget {
  final VoidCallback yesAction;
  final VoidCallback noAction;
  final VoidCallback cancelAction;
  final String prompt;
  final String title;
  final IconData icon;

  const DialogYesNoCancel(
    this.prompt,
    this.yesAction, {
    Key key,
    this.title,
    this.noAction,
    this.cancelAction,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogContainer(
      titleIcon: icon,
      title: title,
      mainText: prompt,
      buttons: cancelAction == null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  textColor: Color(0xff17213c),
                  child: Text("NO"),
                  onPressed: () {
                    if (noAction != null) noAction();
                    Navigator.of(context).pop(false);
                  },
                ),
                SizedBox(
                  width: 16.0,
                ),
                DialogButtonPainted(
                  text: "YES",
                  onPressed: () async {
                    await yesAction();
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      cancelAction();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "CANCEL",
                      style: TextStyle(
                          color: AppColors.DIALOG_TEXT,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (noAction != null) noAction();
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      "NO",
                      style: TextStyle(
                          color: AppColors.DIALOG_TEXT,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (yesAction != null) yesAction();
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      "YES",
                      style: TextStyle(
                          color: AppColors.DIALOG_TEXT,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
