import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/request_input_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/storage/editable_ui_request.dart';
import 'package:hold/widget/screen_parts/question_widget.dart';

class ConversationFlowQuestion extends StatefulWidget {
  final VoidCallback action;
  final String uiRequestKey;
  final QuestionInfoAction infoAction;
  final background;

  const ConversationFlowQuestion(
      this.action, this.uiRequestKey, this.infoAction, this.background,
      {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConversationFlowQuestionState();
  }
}

class _ConversationFlowQuestionState extends State<ConversationFlowQuestion> {
  RequestInputBloc bloc;
  String text = "";
  String info = "";
  int count = 1;
  StreamSubscription _updateTextSubscription;

  @override
  void initState() {
    bloc = new RequestInputBloc(widget.uiRequestKey);
    super.initState();
    print("ConversationFlowQuestion is used");
    _updateTextSubscription = bloc.question.listen(_onQuestionUpdate);
  }

  @override
  void dispose() {
    print("ConversationFlowQuestion is disposed");
    _updateTextSubscription.cancel();
    _updateTextSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("text inside ConversationFlowQuestion $text");
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: GestureDetector(
          onTap: widget.action,
          child: ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: AppSizes.QUESTION_CARD_HEIGHT * 0.6,
              maxHeight: AppSizes.QUESTION_CARD_HEIGHT * 0.8,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: widget.background,
                borderRadius:
                    BorderRadius.all(Radius.circular(AppSizes.BORDER_RADIUS)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: new BoxConstraints(
                      maxHeight: 120,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.CARD_PADDING),
                      child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                                child: child, opacity: animation);
                          },
                          child: AutoSizeText(
                            text ?? "",
                            //key: ValueKey<int>(count),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 21.1,
                              color: AppColors.TEXT_IN_REFLECTION
                                  .withOpacity(0.38),
                            ),
                          )),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 8.0, right: 24.0, bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            color: AppColors.QUESTION_ACTIVE_TEXT,
                          ),
                          onPressed: () {
                            widget.infoAction(text, info, 0);
                          },
                        ),
                        SvgPicture.asset(
                          'assets/material_icons/rounded/action/trending_flat.svg',
                          color: AppColors.QUESTION_ACTIVE_TEXT,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void _onQuestionUpdate(EditableUIRequest event) {
    setState(() {
      text = event.text;
      info = event.info;
    });
  }
}
