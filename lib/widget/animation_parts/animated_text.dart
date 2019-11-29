import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/storage/editable_ui_text.dart';

class AnimatedText extends StatefulWidget {
  final Stream<EditableUIText> collectionText;
  AnimatedText(this.collectionText);

  @override
  State<StatefulWidget> createState() {
    return _AnimatedTextState();
  }
}

class _AnimatedTextState extends State<AnimatedText> {
  String text = "";
  StreamSubscription _textUpdater;

  @override
  void initState() {
    super.initState();
    _textUpdater = widget.collectionText.listen(_onTextChange);
  }

  @override
  void dispose() {
    _textUpdater.cancel();
    _textUpdater = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(child: child, opacity: animation);
      },
      child: Text(
        text,
        //key: ValueKey<String>(text),
        style: TextStyle(
            color: AppColors.TEXT, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _onTextChange(EditableUIText event) {
    setState(() {
      text = event.text;
    });
  }
}
