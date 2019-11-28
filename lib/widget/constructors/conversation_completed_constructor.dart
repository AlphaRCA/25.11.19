import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hold/bloc/conversation_full_bloc.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/conversation_for_review.dart';
import 'package:hold/storage/conversation_content.dart';
import 'package:hold/storage/editable_ui_question.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:hold/widget/buttons/play_action.dart';
import 'package:hold/widget/constructors/conversation_constructor.dart';
import 'package:hold/widget/screen_parts/question_input_field.dart';
import 'package:hold/widget/screen_parts/question_tabs.dart';
import 'package:hold/widget/screen_parts/question_widget.dart';
import 'package:hold/widget/stick_position.dart';

class ConversationCompletedConstructor extends ConversationConstructor {
  final GlobalKey<TextInputFieldState> inputFieldKey = new GlobalKey();
  final ConversationFullBloc bloc;
  final PageController questionController =
      new PageController(viewportFraction: 0.8, initialPage: 1);
  final QuestionInfoAction infoAction;
  final VoidCallback showDeleteAnswerDialog;
  final VoidCallback finish;
  _Step _step;
  StreamSubscription streamSubscription;
  final int initialIndex;

  ConversationCompletedConstructor(this.bloc, this.infoAction, this.finish,
      this.showDeleteAnswerDialog, double screenWidth,
      {this.initialIndex})
      : super(bloc, screenWidth) {
    streamSubscription = bloc.reflection.listen(_fillContent);
    _step = _Step.initial;
    setActiveAction(ActiveActions.reflect);
  }

  void dispose() {
    streamSubscription.cancel();
  }

  void _fillContent(ConversationForReview content) async {
    await _formParts(content);
    generateActualParts(inputFieldKey.currentState);
  }

  void next() async {
    print("next called with step $_step");
    switch (_step) {
      case _Step.initial:
        activePart = _getReflectTitle();
        activePart2 = _getAdditionalQuestions();
        setActiveAction(ActiveActions.nothing);
        break;
      case _Step.reflecting:
        MixPanelProvider().trackEvent("Reflect Conversation", {
          "Click Next Reflect Tool": DateTime.now().toIso8601String(),
          "Title Reflect Tool": bloc.answerInProgress.title,
          "Stage Reflect Tool": "Stage : ${bloc.answerInProgress.level}"
        });
        await bloc.saveAdditional();
        finishedParts
            .add(getFinishedAdditional(bloc.answerInProgress.toPlayedText()));
        activePart = _getReflectTitle();
        activePart2 = _getAdditionalQuestions();
        setActiveAction(ActiveActions.complete);
        break;
      case _Step.ready:
        print("_Step.ready");
        finish();
        break;
    }
    generateActualParts(inputFieldKey.currentState);
  }

  void _formParts(ConversationForReview content) {
    index = initialIndex ?? 1;
    finishedParts = new List();
    finishedParts.add(_getStartingWidget());
    for (ConversationContent contentItem in content.mainConversation.content) {
      finishedParts.add(getAnimatedFinishedItem(
          index++, bloc.initialReflection.type, contentItem.getPlayedItem()));
    }

    finishedParts.add(getMoodTitle());
    finishedParts
        .add(getMoodResult(content.mainConversation.positiveMood, 100));

    if (content.additionals != null && content.additionals.length > 0) {
      for (int i = 0; i < content.additionals.length; i++) {
        finishedParts
            .add(getFinishedAdditional(content.additionals[i].toPlayedText()));
      }
    }
  }

  Widget _getAdditionalQuestions() {
    print("recreating questions");
    return QuestionTabs(
      StorageProvider().getConversationQuestions(),
      PreferencesProvider().getHighestConversationReflectionLevel(),
      _createNewAnswer,
      infoAction,
    );
  }

  void _createNewAnswer(EditableUIQuestion question) {
    print("_createNewAnswer   -------------------------${question}");
    if (question != null) {
      activePart = _getAnswerOnQuestion(question);
      activePart2 = null;
      _step = _Step.reflecting;
      setActiveAction(ActiveActions.initial);
      bloc.startAnswering(question);
      generateActualParts(inputFieldKey.currentState);
    }
  }

  void showQuestionOptions() {
    activePart = _getReflectTitle();
    activePart2 = _getAdditionalQuestions();
    generateActualParts(inputFieldKey.currentState);
    setActiveAction(ActiveActions.nothing);
  }

  Widget _getStartingWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 48.0),
      child: PlayAction(bloc, bloc.cardNumber),
    );
  }

  Widget _getReflectTitle() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Text(
              "How would you like to reflect?",
              style: TextStyle(
                color: AppColors.TEXT_EF,
                fontWeight: FontWeight.bold,
                fontSize: 21.17,
              ),
              textAlign: TextAlign.left,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAnswerOnQuestion(EditableUIQuestion question) {
    print("adding textinput field for answer");
    return Padding(
      padding: EdgeInsets.only(bottom: 16, top: 8.0),
      child: TextInputField(
        question,
        bloc.setAdditionalText,
        () {
          keyboardActivated(inputFieldKey.currentState);
        },
        makeNextAvailable,
        fieldTitle: question.title,
        closeAction: showDeleteAnswerDialog,
        key: inputFieldKey,
        stickPosition: StickPosition.center,
        background: Color(0xffededed),
      ),
    );
  }
}

enum _Step { initial, reflecting, ready }
