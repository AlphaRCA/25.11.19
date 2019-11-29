import 'package:flutter/material.dart';

abstract class TextVoiceState {
  void showKeyboard();
  Future<bool> showVoice();
  void clear();
  final TextEditingController textController = new TextEditingController();
}
