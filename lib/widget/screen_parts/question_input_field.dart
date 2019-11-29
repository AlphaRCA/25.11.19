import 'dart:async';
import 'dart:io';

import 'package:coach_marks/TutorialOverlayUtil.dart';
import 'package:coach_marks/WidgetData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/storage/editable_ui_question.dart';
import 'package:hold/widget/constructors/text_voice_state.dart';
import 'package:hold/widget/dialogs/dialog_no_internet.dart';
import 'package:hold/widget/dictate_button.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';
import 'package:hold/widget/stick_container.dart';
import 'package:hold/widget/stick_position.dart';

class TextInputField extends StatefulWidget {
  final String fieldTitle;
  final VoidCallback closeAction;
  final VoidCallback keyboardInputStarted;
  final VoidCallback makeNextAvailable;
  final ValueChanged<String> textEntered;
  final StickPosition stickPosition;
  final Color background;
  final EditableUIQuestion question;
  final bool hasToShowLabel;
  final double predefinedHeight;

  const TextInputField(
    this.question,
    this.textEntered,
    this.keyboardInputStarted,
    this.makeNextAvailable, {
    this.fieldTitle,
    this.closeAction,
    this.hasToShowLabel = true,
    this.stickPosition = StickPosition.center,
    Key key,
    this.background,
    this.predefinedHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TextInputFieldState();
  }
}

class TextInputFieldState extends State<TextInputField> with TextVoiceState {
  DictateButton dictateButton;
  StreamSubscription _dictateSubscription, _dictate2Subscription;
  bool _dictationVisible = false;
  final FocusNode focusNode = new FocusNode();
  String acceptedText;
  bool _isLabelVisible = false;
  bool isProgrammedCommand = false;
  bool isInformationVisible = true;

  final GlobalKey _infoIcon = GlobalKey();

  static const textFieldPadding = EdgeInsets.all(8.0);
  static const textFieldTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 21.1,
    color: AppColors.QUESTION_TITLE_ACTIVE_TEXT,
  );
  double _fontSize = textFieldTextStyle.fontSize;
  final GlobalKey _textFieldKey = GlobalKey();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(_createCoach);
    dictateButton = new DictateButton(_onDictateStarted);
    _dictateSubscription = dictateButton.textStream.listen(_addRecognizedText);
    _dictate2Subscription =
        dictateButton.finalTextStream.listen(_onDictateResult);
    focusNode.addListener(_onKeyboardFocus);
    super.initState();
    _showCoachMark();
  }

  @override
  void dispose() {
    _dictateSubscription.cancel();
    _dictateSubscription = null;
    _dictate2Subscription.cancel();
    _dictate2Subscription = null;
    super.dispose();
  }

  void _onTextChanged() {
    _updateTextInput();
  }

  void _updateTextInput() {
    // calculate width of text using text painter
    final textLength = textController.text.length;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: textController.text,
        style: textFieldTextStyle,
      ),
    );
    textPainter.layout();

    var fontSize = _fontSize;

    if (textLength > 80 && fontSize >= 15.0) {
      fontSize -= 0.1;
      textPainter.text = TextSpan(
        text: textController.text,
        style: textFieldTextStyle.copyWith(fontSize: fontSize),
      );
      textPainter.layout();
    } else if (textLength <= 80 && fontSize <= 21.1) {
      fontSize += 0.3;
      textPainter.text = TextSpan(
        text: textController.text,
        style: textFieldTextStyle.copyWith(fontSize: fontSize),
      );
    }
    setState(() {
      _fontSize = fontSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StickContainer(
      Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widget.fieldTitle == null
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              AppSizes.CARD_PADDING - 8,
                              AppSizes.CARD_PADDING - 12,
                              AppSizes.CARD_PADDING - 8,
                              0,
                            ),
                            child: Text(
                              widget.fieldTitle.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12.67,
                                color: AppColors.QUESTION_TITLE_ACTIVE_TEXT,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.close,
                            color: AppColors.INPUT_BUTTONS_COLOR,
                          ),
                          onPressed: widget.closeAction,
                        )
                      ],
                    ),
              widget.hasToShowLabel && _isLabelVisible
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.CARD_PADDING - 8,
                        0,
                        AppSizes.CARD_PADDING - 8,
                        16,
                      ),
                      child: Text(
                        widget.question.description,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          color: AppColors.QUESTION_ACTIVE_TEXT,
                        ),
                      ),
                    )
                  : Container(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.CARD_PADDING - 8,
                    0,
                    AppSizes.CARD_PADDING - 8,
                    0,
                  ),
                  child: TextField(
                    key: _textFieldKey,
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      hintText: widget.question.description,
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21.1,
                        color: AppColors.QUESTION_ACTIVE_TEXT.withOpacity(0.38),
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    controller: textController,
                    maxLines: 8,
                    textCapitalization: TextCapitalization.sentences,
                    focusNode: focusNode,
                    onChanged: onTextEntered,
                    onEditingComplete: () {
                      widget.textEntered(textController.text);
                    },
                    style: textFieldTextStyle.copyWith(fontSize: _fontSize),
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ),
              _dictationVisible
                  ? Container(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[dictateButton],
                      ),
                    )
                  : Container(),
            ],
          ),
          isInformationVisible
              ? Positioned(
                  bottom: 4,
                  left: 4,
                  child: IconButton(
                    key: _infoIcon,
                    color: AppColors.INFORMATION_ICON.withOpacity(0.54),
                    icon: Icon(Icons.info_outline),
                    onPressed: _showInfo,
                  ),
                )
              : Container()
        ],
      ),
      position: widget.stickPosition,
      background: widget.background,
      heightLimited:
          widget.predefinedHeight ?? MediaQuery.of(context).size.height * 0.45,
    );
    // }));
  }

  void _addRecognizedText(String event) {
    //acceptedText += event + " ";
    textController.text = acceptedText + event + " ";
    _updateTextInput();
    widget.textEntered(acceptedText + event + " ");
    widget.makeNextAvailable();
  }

  Future<bool> showVoice() async {
    if (await _isInternetAvailable()) {
      isProgrammedCommand = true;
      focusNode.unfocus();
      setState(() {
        _dictationVisible = true;
      });
      return true;
    } else {
      _showDialogUnavailable();
      return false;
    }
  }

  Future<bool> _isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  void _showDialogUnavailable() {
    DialogLaunchers.showDialog(context: context, dialog: DialogNoInternet());
  }

  void showKeyboard() {
    isProgrammedCommand = true;
    focusNode.requestFocus();
    setState(() {
      _dictationVisible = false;
    });
  }

  void onTextEntered(String value) {
    showKeyboard();

    _onTextChanged();
    print("textEntered: $value");
    widget.textEntered(value);
    if (value == null || value.length == 0) {
      setState(() {
        _isLabelVisible = false;
      });
      return;
    } else {
      setState(() {
        _isLabelVisible = true;
      });
    }

    widget.makeNextAvailable();
  }

  void clear() {
    textController.text = "";
    setState(() {
      _isLabelVisible = false;
    });
  }

  void unfocus() {
    focusNode.unfocus();
  }

  void _onKeyboardFocus() {
    print("focus event");
    if (!isProgrammedCommand) widget.keyboardInputStarted();
    isProgrammedCommand = false;
  }

  void _onDictateStarted() {
    acceptedText = textController.text;
  }

  void _onDictateResult(String event) {
    if (!_isSign(event[event.trim().length - 1])) {
      acceptedText += event + ". ";
      _updateTextInput();
    }
    textController.text = acceptedText;
  }

  bool _isSign(String acceptedText) {
    print("checking '$acceptedText'");
    return [".", ",", "!", "?", ";", ":"].contains(acceptedText);
  }

  void _showInfo() {
    DialogLaunchers.showInfo(
        context, widget.question.title, widget.question.information);
  }

  _createCoach(Duration timestamp) {
    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'input',
      bgColor: Colors.black.withOpacity(0.75),
      // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveFirstQuestionCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[],
      description: Center(
        child: Text(
          'These questions are guides to help\nyou consider what to say, you are free\nto write what you want.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              height: 1.5,
              fontSize: 18,
              fontFamily: 'Cabin',
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none),
        ),
      ),
    );
  }

  void _showCoachMark() async {
    if (widget.stickPosition != StickPosition.center &&
        !await PreferencesProvider().getFirstQuestionCoachMark())
      showOverlayEntry(tagName: 'input');
  }
}
