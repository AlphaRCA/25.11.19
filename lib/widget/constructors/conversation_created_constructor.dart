import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hold/bloc/conversation_creation_bloc.dart';
import 'package:hold/bloc/request_input_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/conversation.dart';
import 'package:hold/model/conversation_for_review.dart';
import 'package:hold/storage/conversation_content.dart';
import 'package:hold/widget/animation_parts/animated_finished_item.dart';
import 'package:hold/widget/animation_parts/animated_initial_input_field.dart';
import 'package:hold/widget/constructors/conversation_constructor.dart';
import 'package:hold/widget/screen_parts/conversation_flow_question.dart';
import 'package:hold/widget/screen_parts/emotion_widget.dart';
import 'package:hold/widget/screen_parts/question_widget.dart';
import 'package:hold/widget/screen_parts/request_input_field.dart';
import 'package:hold/widget/stick_container.dart';
import 'package:hold/widget/stick_position.dart';

import '../white_text.dart';

class ConversationCreatedConstructor extends ConversationConstructor {
  final ConversationCreationBloc bloc;
  final VoidCallback finish, back;
  final QuestionInfoAction infoAction;
  _Step _step;
  final GlobalKey<RequestInputFieldState> inputFieldKey = new GlobalKey();
  final GlobalKey scrollWindow;
  final double initialWidth, initialHeight;
  final Offset initialPosition;
  final Color initialColor;

  ConversationCreatedConstructor(
    this.bloc,
    this.finish,
    this.back,
    this.infoAction,
    this.scrollWindow,
    this.initialHeight,
    this.initialWidth,
    this.initialPosition,
    double screenWidth, {
    this.initialColor,
  }) : super(bloc, screenWidth) {
    index = 1;
    if (bloc.proceeding) {
      _fillContent();
    } else {
      activePart =
          _getInitialInput(_getActualItemCode(bloc.type, index), inputFieldKey);
      _step = _Step.required;
      setActiveAction(ActiveActions.initial);
      generateActualParts(inputFieldKey.currentState);
    }
  }

  Widget _getFlowQuestion() {
    return AnimatedFinishedItem(
      child: ({key}) {
        return ConversationFlowQuestion(
          _showAdditionalQuestion,
          _getActualItemCode(bloc.type, index),
          infoAction,
          getActiveItemColor(index + 1),
          key: key,
        );
      },
      childKey: inputFieldKey,
      animationSetting: StickContainer.getAnimationSetting(
          getPosition(bloc.type, index), screenWidth),
    );
  }

  void cancelInput() {
    _step = _Step.additionalVisible;
    activePart = _getFlowQuestion();
    setActiveAction(ActiveActions.endConversation);

    generateActualParts(inputFieldKey.currentState);
  }

  void next() async {
    print("next called with step $_step");
    switch (_step) {
      case _Step.required:
      case _Step.additionalEditable:
        if (bloc.editedItem == null) return;
        await bloc.finishText();
        finishedParts.add(getFinishedItem(index++, bloc.type,
            bloc.conversation.content.last.getPlayedItem()));
        if (index > 3) {
          _step = _Step.additionalVisible;
          activePart = _getFlowQuestion();
          setActiveAction(ActiveActions.endConversation);
        } else {
          print("NEXT getting input");
          activePart = _getInput();
          setActiveAction(lastTypingAction);
        }
        break;
      case _Step.additionalVisible:
        activePart = _getMoodRequest();
        activePart2 = null;
        _step = _Step.moodVisible;
        setActiveAction(ActiveActions.backOrComplete);
        break;
      case _Step.moodVisible:
        await bloc.saveMood();
        finish();
        break;
      case _Step.ready:
        finish();
        break;
    }
    generateActualParts(inputFieldKey.currentState);
  }

  Widget _getInitialInput(String questionType, GlobalKey key) {
    print("Initial input GlobalKey $key");
    StickPosition stickPosition = getPosition(bloc.type, index);
    RequestInputBloc requestBloc =
        new RequestInputBloc(_getActualItemCode(bloc.type, index));
    return AnimatedInitialInputField(
      RequestInputField(
        requestBloc,
        bloc.setText,
        () {
          keyboardActivated(inputFieldKey.currentState);
        },
        makeNextAvailable,
        key: key,
        index: index,
        stickPosition: stickPosition,
        background: getColor(stickPosition),
        closeAction: back,
      ),
      initialPosition,
      initialHeight,
      backgroundColor: getColor(stickPosition),
      initialColor: initialColor,
      finalStickPosition: stickPosition,
    );
  }

  Widget _getInput() {
    StickPosition stickPosition = getPosition(bloc.type, index);
    return AnimatedFinishedItem(
      key: new GlobalKey(),
      child: ({key}) {
        return _getInputField(key, stickPosition);
      },
      childKey: inputFieldKey,
      animationSetting:
          StickContainer.getAnimationSetting(stickPosition, screenWidth),
    );
  }

  Widget _getInputField(GlobalKey key, StickPosition stickPosition) {
    final RequestInputBloc requestBloc =
        new RequestInputBloc(_getActualItemCode(bloc.type, index));
    Future.delayed(Duration(milliseconds: 300)).then((_) {
      _showLastInputMethod();
    });
    return RequestInputField(
      requestBloc,
      bloc.setText,
      () {
        keyboardActivated(inputFieldKey.currentState);
      },
      makeNextAvailable,
      key: key,
      index: index,
      stickPosition: stickPosition,
      background: getColor(stickPosition),
      closeAction: back,
    );
  }

  Future _formParts() async {
    ConversationForReview content = await bloc.unfinishedContent;
    for (ConversationContent innerContent in content.mainConversation.content) {
      finishedParts.add(getAnimatedFinishedItem(
          index++, bloc.type, innerContent.getPlayedItem()));
    }
    if (content.mainConversation.content.length >= 3) {
      if (content.additionals == null || content.additionals.length == 0) {
        print("no additionals");
        _step = _Step.additionalVisible;
        activePart = _getFlowQuestion();
        setActiveAction(ActiveActions.endConversation);
        return;
      } else {
        int i = content.additionals.length - 1;
        finishedParts.add(
          getFinishedAdditional(content.additionals[i].toPlayedText()),
        );
      }
      activePart = _getMoodRequest();
      setActiveAction(ActiveActions.backOrComplete);
      _step = _Step.moodVisible;
    } else {
      activePart = _getInput();
      _step = _Step.required;
      setActiveAction(ActiveActions.initial);
    }
  }

  void _showAdditionalQuestion() {
    StickPosition stickPosition = getPosition(bloc.type, index);
    activePart = _getInputField(inputFieldKey, stickPosition);
    _step = _Step.additionalEditable;
    generateActualParts(inputFieldKey.currentState);
    setActiveAction(lastTypingAction ?? ActiveActions.initial);
  }

  void _fillContent() async {
    await _formParts();
    generateActualParts(inputFieldKey.currentState);
  }

  Widget _getMoodRequest() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
          child: WhiteText(
            "EMOTION LOG",
            paddingAll: 0.0,
          ),
        ),
        EmotionWidget(
          (value) {
            bloc.setMood(value);
            setActiveAction(ActiveActions.backOrCompleteAvailable);
          },
        ),
      ],
    );
  }

  Color getActiveItemColor(int num) {
    if (bloc.type != ReflectionType.A) {
      if (num % 2 == 0) {
        return AppColors.LIGHT_BACKGROUND;
      } else {
        return AppColors.DARK_BACKGROUND;
      }
    } else {
      if (num % 2 == 0) {
        return AppColors.DARK_BACKGROUND;
      } else {
        return AppColors.LIGHT_BACKGROUND;
      }
    }
  }

  String _getActualItemCode(ReflectionType type, int index) {
    print("_getActualItemCode $type $index");
    List<String> initialOrder, repeatedOrder;
    if (type == ReflectionType.A) {
      initialOrder = ConversationCreationBloc.A_START_ORDER;
      repeatedOrder = ConversationCreationBloc.A_REPEAT_ORDER;
    } else {
      initialOrder = ConversationCreationBloc.B_START_ORDER;
      repeatedOrder = ConversationCreationBloc.B_REPEAT_ORDER;
    }
    int firstArrayLength = initialOrder.length;
    int secondArrayLength = repeatedOrder.length;
    if (index <= firstArrayLength) {
      print(initialOrder[index - 1]);
      return initialOrder[index - 1];
    } else {
      int localIndex = (index - 1 - firstArrayLength) % secondArrayLength;
      print(repeatedOrder[localIndex]);
      return repeatedOrder[localIndex];
    }
  }

  void _showLastInputMethod() {
    if (lastTypingAction == ActiveActions.typeVisible) {
      Future.delayed(Duration(seconds: 1)).then((_) {
        inputFieldKey.currentState.showKeyboard();
      });
    } else if (lastTypingAction == ActiveActions.voiceVisible) {
      Future.delayed(Duration(milliseconds: 500)).then((_) {
        inputFieldKey.currentState.showVoice();
      });
    }
  }
}

enum _Step {
  required,
  additionalVisible,
  additionalEditable,
  moodVisible,
  ready
}
