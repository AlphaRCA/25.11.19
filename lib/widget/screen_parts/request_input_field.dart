import 'dart:async';
import 'dart:io';

import 'package:coach_marks/TutorialOverlayUtil.dart';
import 'package:coach_marks/WidgetData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/bloc/request_input_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/storage/editable_ui_request.dart';
import 'package:hold/widget/constructors/text_voice_state.dart';
import 'package:hold/widget/dialogs/dialog_no_internet.dart';
import 'package:hold/widget/dictate_button.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';
import 'package:hold/widget/stick_container.dart';
import 'package:hold/widget/stick_position.dart';

class RequestInputField extends StatefulWidget {
  final VoidCallback closeAction;
  final VoidCallback keyboardInputStarted;
  final VoidCallback makeNextAvailable;
  final ValueChanged<String> textEntered;
  final StickPosition stickPosition;
  final Color background;
  final RequestInputBloc questionBloc;
  final int index;
  final double fixedHeight;

  const RequestInputField(
    this.questionBloc,
    this.textEntered,
    this.keyboardInputStarted,
    this.makeNextAvailable, {
    this.closeAction,
    this.stickPosition = StickPosition.center,
    Key key,
    this.index = 0,
    this.background,
    this.fixedHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RequestInputFieldState();
  }
}

class RequestInputFieldState extends State<RequestInputField>
    with TextVoiceState {
  DictateButton dictateButton;
  StreamSubscription _dictateSubscription, _dictate2Subscription;
  bool _dictationVisible = false;
  final FocusNode focusNode = new FocusNode();
  String acceptedText;
  bool isProgrammedCommand = false;
  bool isInformationVisible = true;

  final GlobalKey _infoIcon = GlobalKey();

  static const textFieldPadding = EdgeInsets.all(8.0);
  static const textFieldTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 21.1,
    color: AppColors.QUESTION_TITLE_ACTIVE_TEXT,
  );
  final GlobalKey _textFieldKey = GlobalKey();
  double _fontSize = textFieldTextStyle.fontSize;

  String text = "";
  String info = "";
  StreamSubscription _updateTextSubscription;

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
    print("init RequestInputField");
    _updateTextSubscription =
        widget.questionBloc.question.listen(_onQuestionUpdate);
  }

  void _onQuestionUpdate(EditableUIRequest event) {
    print(
        "RequestInputField (UIid ${event.uiID}) let's update text to '${event.text}'");
    setState(() {
      text = event.text ?? "";
      info = event.info ?? "";
    });
  }

  @override
  void dispose() {
    print("dispose RequestInputField");
    _dictateSubscription.cancel();
    _dictateSubscription = null;
    _dictate2Subscription.cancel();
    _dictate2Subscription = null;
    _updateTextSubscription.cancel();
    _updateTextSubscription = null;
    widget.questionBloc.dispose();
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
    print("text inside requestInputField $text");
    return StickContainer(
      Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.CARD_PADDING - 8,
                    0,
                    AppSizes.CARD_PADDING + 16,
                    0,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(child: child, opacity: animation);
                    },
                    child: Container(
                      constraints: BoxConstraints.expand(),
                      child: TextField(
                        key: _textFieldKey,
                        controller: textController,
                        maxLines: 8,
                        textCapitalization: TextCapitalization.sentences,
                        focusNode: focusNode,
                        onChanged: onTextEntered,
                        onEditingComplete: () {
                          widget.textEntered(textController.text);
                        },
                        decoration: new InputDecoration(
                          hintText: text ?? "",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21.1,
                            color: AppColors.QUESTION_ACTIVE_TEXT
                                .withOpacity(0.38),
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: textFieldTextStyle.copyWith(fontSize: _fontSize),
                        keyboardType: TextInputType.multiline,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
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
                  bottom: 2,
                  left: 4,
                  child: IconButton(
                      key: _infoIcon,
                      color: AppColors.INFORMATION_ICON.withOpacity(0.54),
                      icon: Icon(Icons.info_outline),
                      onPressed: () {
                        _showInfo(text, info);
                      }),
                )
              : Container(),
          widget.index > 3
              ? Positioned(
                  top: 2,
                  right: 4,
                  child: IconButton(
                    // key: _closeIcon,
                    color: AppColors.INFORMATION_ICON.withOpacity(0.54),
                    icon: Icon(Icons.close),
                    onPressed: widget.closeAction,
                  ),
                )
              : Container()
        ],
      ),
      position: widget.stickPosition,
      background: widget.background,
      heightLimited:
          widget.fixedHeight ?? MediaQuery.of(context).size.height * 0.45,
    );
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
      widget.questionBloc.stopQuestionRotation();
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
    widget.questionBloc.stopQuestionRotation();
    focusNode.requestFocus();
    setState(() {
      _dictationVisible = false;
    });
  }

  void onTextEntered(String value) {
    _onTextChanged();
    print("textEntered: $value");
    widget.textEntered(value);
    if (value == null || value.length == 0) {
      setState(() {
        isInformationVisible = true;
      });
      return;
    } else {
      setState(() {
        isInformationVisible = false;
      });
    }

    widget.makeNextAvailable();
  }

  void clear() {
    textController.text = "";
    setState(() {
      isInformationVisible = true;
    });
  }

  void unfocus() {
    focusNode.unfocus();
  }

  void _onKeyboardFocus() {
    print("focus event");
    if (!isProgrammedCommand) widget.keyboardInputStarted();
    isProgrammedCommand = false;
    widget.questionBloc.stopQuestionRotation();
  }

  void _onDictateStarted() {
    acceptedText = textController.text;
  }

  void _onDictateResult(String event) {
    if (!_isSign(event[event.trim().length - 1])) {
      textController.text = acceptedText += event + ". ";
      _updateTextInput();
    }
  }

  bool _isSign(String acceptedText) {
    print("checking '$acceptedText'");
    return [".", ",", "!", "?", ";", ":"].contains(acceptedText);
  }

  void _showInfo(String questionTitle, String information) {
    widget.questionBloc.stopQuestionRotation();
    DialogLaunchers.showInfo(context, questionTitle, information);
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
