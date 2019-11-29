import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/widget/dialogs/dialog_view.dart';
import 'package:hold/widget/dialogs/toast_view.dart';

import 'dialog_button_painted.dart';

class AnimatedYesNoDialog extends StatefulWidget {
  final String title, mainText;
  final IconData titleIcon;
  final String toastText;
  final VoidCallback yesAction, noAction;

  const AnimatedYesNoDialog({
    Key key,
    @required this.title,
    @required this.mainText,
    @required this.titleIcon,
    @required this.yesAction,
    @required this.toastText,
    this.noAction,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AnimatedYesNoDialogState();
  }
}

class _AnimatedYesNoDialogState extends State<AnimatedYesNoDialog> {
  Widget child;

  @override
  void initState() {
    child = DialogView(
      title: widget.title,
      mainText: widget.mainText,
      titleIcon: widget.titleIcon,
      buttons: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton(
            textColor: Color(0xff17213c),
            child: Text("NO"),
            onPressed: () {
              if (widget.noAction != null) widget.noAction();
              Navigator.of(context).pop(false);
            },
          ),
          SizedBox(
            width: 16.0,
          ),
          DialogButtonPainted(
            text: "YES",
            onPressed: () {
              widget.yesAction();
              setState(() {
                child = Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ToastView(
                      widget.toastText,
                      iconData: widget.titleIcon,
                    )
                  ],
                );
              });
              Future.delayed(const Duration(seconds: 2)).then((_) {
                Navigator.of(context).pop(true);
              });
            },
          )
        ],
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.TRANSPARENT,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 0),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SizeTransition(child: child, sizeFactor: animation);
        },
        child: child,
      ),
    );
  }
}
