import 'package:flutter/material.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/utils/dispose_primary_fucus.util.dart';
import 'package:hold/widget/buttons/bottom_button.dart';
import 'package:hold/widget/name_field.dart';

class RenameScreen extends StatefulWidget {
  //final ReflectionCreationBloc bloc;
  final NameResultHandler onSave;
  final String name;
  final String question;
  final String subtitle;
  final bool isCreating;

  RenameScreen(
    this.question,
    this.onSave, {
    Key key,
    this.name = "Untitled",
    this.subtitle = "",
    this.isCreating = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RenameScreenState();
  }
}

class _RenameScreenState extends State<RenameScreen> {
  final TextEditingController controller = new TextEditingController();
  final FocusNode focusNode = new FocusNode();
  bool _withKeyboard = true;
  Widget _nameField;

  @override
  void initState() {
    MixPanelProvider().trackEvent("CONVERSATION",
        {"surePageview Name Conversation": DateTime.now().toIso8601String()});

    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
    focusNode.addListener(_onKeyboardAppearanceChanged);

    controller.text = widget.name != "Untitled" ? widget.name : null;
    _nameField = NameField(
      controller,
      "Untitled",
      focusNode,
      textCapitalization: TextCapitalization.sentences,
    );

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.removeListener(_onKeyboardAppearanceChanged);
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          disposePrimaryFocus(context);
        },
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 16,
              bottom: 16,
              left: 16,
              right: 16,
              child: _withKeyboard
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        widget.isCreating
                            ? Expanded(
                                flex: 1,
                                child: InkWell(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: 60.0,
                                      height: 60.0,
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xff3e4b77),
                                      ),
                                      child: Icon(
                                        Icons.done_outline,
                                        color:
                                            AppColors.ORANGE_BUTTON_BACKGROUND,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        Expanded(
                          flex: 1,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.bottomLeft,
                            child: widget.subtitle.isNotEmpty
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        widget.question,
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: AppColors.TEXT_EF,
                                          fontSize: 21.13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        widget.subtitle,
                                        style: TextStyle(
                                          color: AppColors.TEXT_EF,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )
                                    ],
                                  )
                                : Text(
                                    widget.question,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: AppColors.TEXT_EF,
                                      fontSize: 21.13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.only(top: 32),
                            child: _nameField,
                          ),
                        ),
                        SizedBox(
                          height: 32,
                        ),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        widget.isCreating
                            ? Expanded(
                                flex: 2,
                                child: InkWell(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: 60.0,
                                      height: 60.0,
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xff3e4b77),
                                      ),
                                      child: Icon(
                                        Icons.done_outline,
                                        color:
                                            AppColors.ORANGE_BUTTON_BACKGROUND,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        Expanded(
                          flex: 2,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.bottomLeft,
                            child: widget.subtitle.isNotEmpty
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        widget.question,
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: AppColors.TEXT_EF,
                                          fontSize: 21.13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        widget.subtitle,
                                        style: TextStyle(
                                          color: AppColors.TEXT,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )
                                    ],
                                  )
                                : Text(
                                    widget.question,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: AppColors.TEXT_EF,
                                      fontSize: 21.13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: EdgeInsets.only(top: 32),
                            child: _nameField,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(),
                        )
                      ],
                    ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomButton(
                "DONE",
                () async {
                  if (focusNode.hasFocus) {
                    focusNode.unfocus();
                    setState(() {
                      _withKeyboard = false;
                    });
                  }
                  MixPanelProvider().trackEvent("COLLECTIONS",
                      {"Input field": controller.text.isNotEmpty});

                  MixPanelProvider().trackEvent("COLLECTIONS",
                      {"Click Save Collection Button": controller.text.isNotEmpty});

                  int result = await widget.onSave(
                    controller.text.isNotEmpty ? controller.text : "Untitled",
                  );
                  Navigator.of(context).pop(result);
                },
                buttonColor: AppColors.BOTTOM_ACTION_BG,
                textColor: AppColors.BOTTOM_ACTION_TEXT,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onKeyboardAppearanceChanged() {
    setState(() {
      _withKeyboard = focusNode.hasFocus;
    });
  }

  void _afterBuild(Duration timeStamp) {
    focusNode.requestFocus();
  }
}

typedef Future<int> NameResultHandler(String newName);
