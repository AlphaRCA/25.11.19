import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/play_controller.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/conversation.dart';
import 'package:hold/model/played_item.dart';
import 'package:hold/widget/animation_parts/animated_finished_item.dart';
import 'package:hold/widget/constructors/text_voice_state.dart';
import 'package:hold/widget/screen_parts/emotion_result_widget.dart';
import 'package:hold/widget/screen_parts/playable_text.dart';
import 'package:hold/widget/stick_container.dart';
import 'package:hold/widget/stick_position.dart';

import '../white_text.dart';

class ConversationConstructor {
  int index = 0;
  List<Widget> finishedParts = new List();
  Widget activePart, activePart2;
  final PlayController _playController;
  final double screenWidth;
  ActiveActions lastActiveAction, lastTypingAction;

  final StreamController<List<Widget>> _partsController =
      new StreamController();

  Stream<List<Widget>> get parts => _partsController.stream;

  final StreamController<ActiveActions> _actionsController =
      new StreamController();

  Stream<ActiveActions> get actions => _actionsController.stream;

  ConversationConstructor(this._playController, this.screenWidth);

  void showVoice(TextVoiceState inputStateKey, bool isReflect) async {
    if (await inputStateKey.showVoice()) {
      lastTypingAction = ActiveActions.voiceVisible;

      MixPanelProvider().trackEvent(isReflect ? "REFLECT" : "CONVERSATION", {
        "Click Speak Conversation Button": DateTime.now().toIso8601String()
      });
      print("show voice");
      print("text length is ${inputStateKey.textController.text.length}");
      if (inputStateKey.textController.text.length > 0) {
        setActiveAction(ActiveActions.voiceInProgress);
      } else {
        setActiveAction(ActiveActions.voiceVisible);
      }
    }
  }

  void showKeyboard(TextVoiceState inputStateKey, bool isReflect) {
    MixPanelProvider().trackEvent(isReflect ? "REFLECT" : "CONVERSATION",
        {"Click Write Conversation Button": DateTime.now().toIso8601String()});
    lastTypingAction = ActiveActions.typeVisible;
    print("show keyboard");
    inputStateKey.showKeyboard();
    print("text length is ${inputStateKey.textController.text.length}");
    if (inputStateKey.textController.text.length > 0) {
      setActiveAction(ActiveActions.typingInProgress);
    } else {
      setActiveAction(ActiveActions.typeVisible);
    }
  }

  void makeNextAvailable() {
    print("keyboardInputStarted called");
    if (lastTypingAction == ActiveActions.voiceVisible) {
      setActiveAction(ActiveActions.voiceInProgress);
    } else if (lastTypingAction == ActiveActions.typeVisible) {
      setActiveAction(ActiveActions.typingInProgress);
    }
  }

  void keyboardActivated(TextVoiceState inputStateKey) {
    lastTypingAction = ActiveActions.typeVisible;
    if (inputStateKey.textController.text.length > 0) {
      setActiveAction(ActiveActions.typingInProgress);
    } else {
      setActiveAction(ActiveActions.typeVisible);
    }
  }

  void setActiveAction(ActiveActions action) {
    if (lastActiveAction == action) return;
    lastActiveAction = action;
    _actionsController.add(action);
  }

  Widget getMoodResult(int value, double height) {
    return EmotionResultWidget(value, height);
  }

  Widget getFinishedItem(int index, ReflectionType type, PlayedItem text) {
    StickPosition stickPosition = getPosition(type, index);
    return PlayableText(
      text,
      _playController,
      backgroundColor: getColor(stickPosition),
      textColor: AppColors.TEXT_IN_REFLECTION,
      stick: stickPosition,
    );
  }

  Widget getAnimatedFinishedItem(
      int index, ReflectionType type, PlayedItem text) {
    StickPosition stickPosition = getPosition(type, index);
    return AnimatedFinishedItem(
      animationSetting:
          StickContainer.getAnimationSetting(stickPosition, screenWidth),
      child: ({key}) {
        return PlayableText(
          text,
          _playController,
          backgroundColor: getColor(stickPosition),
          textColor: AppColors.TEXT_IN_REFLECTION,
          stick: stickPosition,
        );
      },
    );
  }

  StickPosition getPosition(ReflectionType type, int index) {
    if (type == ReflectionType.A) {
      if (index % 2 == 0) {
        return StickPosition.right;
      } else {
        return StickPosition.left;
      }
    } else {
      if (index % 2 == 0) {
        return StickPosition.left;
      } else {
        return StickPosition.right;
      }
    }
  }

  Color getColor(StickPosition position) {
    return position == StickPosition.right
        ? AppColors.LIGHT_BACKGROUND
        : AppColors.DARK_BACKGROUND;
  }

  PlayableText getFinishedAdditional(PlayedItem item) {
    return PlayableText(
      item,
      _playController,
      stick: StickPosition.center,
      backgroundColor: AppColors.TEXT_EF,
      iconColor: AppColors.INFORMATION_ICON.withOpacity(0.54),
    );
  }

  Widget getMoodTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
          child: WhiteText(
            "EMOTION LOG",
            paddingAll: 0,
          ),
        ),
      ],
    );
  }

  void generateActualParts(TextVoiceState inputStateKey) {
    inputStateKey?.clear();
    List<Widget> result = new List();
    result.addAll(finishedParts);
    if (activePart != null) result.add(activePart);
    if (activePart2 != null) result.add(activePart2);
    _partsController.add(result);
  }
}

enum ActiveActions {
  initial,
  typingInProgress,
  voiceInProgress,
  typeVisible,
  voiceVisible,
  endConversation,
  backOrComplete,
  backOrCompleteAvailable,
  finish,
  reflect,
  nothing,
  complete
}
