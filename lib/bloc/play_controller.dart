import 'dart:async';

import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/play_text_provider.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/model/continue_condition.dart';
import 'package:hold/model/played_item.dart';
import 'package:rxdart/rxdart.dart';

class PlayController {
  static const PAUSE_INSIDE_CONVERSATION = Duration(seconds: 1);
  static const PAUSE_BETWEEN_BLOCKS = Duration(seconds: 3);
  static const PAUSE_BETWEEN_COMMANDS = Duration(seconds: 5);

  final PlayTextProvider _playTextProvider;

  Stream<int> get voicePercentage => _playTextProvider.percentage;

  BehaviorSubject<PlayedItem> _activeItemController = new BehaviorSubject();
  Stream<PlayedItem> get activeItem => _activeItemController.stream;

  bool isPaused = true;
  int _innerPointer;
  StreamSubscription _continueToNextSubscription;
  List<PlayedItem> playedItems = new List();
  bool isContinuous;
  int _commandCounter = 0;
  ContinueCondition continueCondition;

  PlayController({PlayTextProvider ptp, this.isContinuous})
      : _playTextProvider = ptp ?? new PlayTextProvider() {
    _continueToNextSubscription =
        _playTextProvider.playState.listen(_playNextPointer);
    if (isContinuous == null) _loadContinuousSetting();
  }

  Future _loadContinuousSetting() async {
    isContinuous = await PreferencesProvider().getContinuousSetting();
  }

  void _playNextPointer(bool playIsActive) async {
    MixPanelProvider().trackEvent("COLLECTION", {
      playIsActive
          ? "Click Play Collection Button"
          : "Click Pause Collection Button": DateTime.now().toIso8601String()
    });
    bool canPlayNext = false;
    if (_innerPointer != null && (_innerPointer + 1) < playedItems.length) {
      canPlayNext = continueCondition.canPlay(
          playedItems[_innerPointer + 1], isContinuous);
      print("canPlayNext=$canPlayNext");
      print(
          "condition is ${continueCondition.toString()}, isContinuous = $isContinuous");
    } else {
      print("no more items");
    }
    if (!playIsActive &&
        !isPaused &&
        (_innerPointer + 1) < playedItems.length &&
        canPlayNext) {
      _playNextItem();
    } else {
      if (!playIsActive) {
        PlayedItem actualItem =
            (_innerPointer != null && playedItems.length > _innerPointer)
                ? playedItems[_innerPointer]
                : PlayedItem.initial;
        actualItem.isPlayed = false;
        _activeItemController.add(actualItem);
      }
    }
  }

  Future _playNextItem() async {
    _innerPointer++;
    print("let's play next item");
    int commandIdBeforePause = _commandCounter;
    await Future.delayed(_selectPause(
        playedItems[_innerPointer - 1], playedItems[_innerPointer]));
    _voiceFromInnerPointer(_innerPointer, commandIdBeforePause);

    if (commandIdBeforePause < _commandCounter) return;
    PlayedItem actualItem = playedItems[_innerPointer];
    actualItem.isPlayed = true;
    _activeItemController.add(actualItem);
  }

  Duration _selectPause(PlayedItem from, PlayedItem to) {
    if (from.conversationCardId == to.conversationCardId) {
      print("pause in conversation");
      return PAUSE_INSIDE_CONVERSATION;
    } else {
      print("pause between blocks");
      return PAUSE_BETWEEN_BLOCKS;
    }
  }

  void playConversation(int cardNumber) {
    continueCondition = new ContinueCondition(conversationId: cardNumber);
    for (int i = 0; i < playedItems.length; i++) {
      if (playedItems[i].conversationCardId == cardNumber) {
        _voiceFromInnerPointer(i, ++_commandCounter);
        isPaused = false;
        break;
      }
    }
  }

  void playReflection(int reflectionId) {
    continueCondition = new ContinueCondition(reflectionId: reflectionId);
    for (int i = 0; i < playedItems.length; i++) {
      if (playedItems[i].reflectionId == reflectionId) {
        _voiceFromInnerPointer(i, ++_commandCounter);
        isPaused = false;
        break;
      }
    }
  }

  void playCollection() {
    continueCondition = new ContinueCondition(isFullCollection: true);
    _voiceFromInnerPointer(0, ++_commandCounter);
    isPaused = false;
  }

  void playContent(int contentId) {
    print("let's play content with id $contentId");
    continueCondition = new ContinueCondition();
    for (int i = 0; i < playedItems.length; i++) {
      if (playedItems[i].inConversationContentId == contentId) {
        _voiceFromInnerPointer(i, ++_commandCounter);
        isPaused = false;
        break;
      }
    }
  }

  void _voiceFromInnerPointer(int pointer, int commandId) {
    print(
        "new inner poiner will be $pointer, commandId is $commandId, commandCounter is $_commandCounter");
    if (commandId < _commandCounter) return;
    print("command is actual");
    _innerPointer = pointer;

    PlayedItem actualItem = playedItems[_innerPointer];
    actualItem.isPlayed = true;
    print("adding playedItem to stream ${actualItem.toString()}");
    _activeItemController.add(actualItem);

    _playTextProvider.speak(playedItems[pointer].text);
  }

  Future pauseVoice() async {
    print("pause command");
    _commandCounter++;
    isPaused = true;

    if (_innerPointer != null) {
      PlayedItem actualItem = playedItems[_innerPointer];
      actualItem.isPlayed = false;
      print("adding playedItem to stream ${actualItem.toString()}");
      _activeItemController.add(actualItem);
    }

    await _playTextProvider.pause();
  }

  void destroy() {
    _continueToNextSubscription?.cancel();
    _continueToNextSubscription = null;
    pauseVoice();
  }

  void resumeVoice() {
    print("resume command");
    _commandCounter++;
    isPaused = false;
    _playTextProvider.resume();

    PlayedItem actualItem = playedItems[_innerPointer];
    actualItem.isPlayed = true;
    _activeItemController.add(actualItem);
  }

  void setContinuousPlaySetting(bool value) {
    isContinuous = value;
  }

  Future playPreviousConversation() async {
    print("PREVIOUS!!! previous command id is $_commandCounter");
    _commandCounter++;
    isPaused = false;
    await _playTextProvider.pause();
    await Future.delayed(Duration(milliseconds: 500));
    _playByCondition(
        _findPreviousForConversation(continueCondition.conversationId));
  }

  ContinueCondition _findPreviousForConversation(int originalId) {
    int previousIndex = 0;
    for (int i = 0; i < playedItems.length - 1; i++) {
      if (playedItems[i + 1].conversationCardId == originalId) {
        previousIndex = i;
        break;
      }
    }
    if (playedItems[previousIndex].conversationCardId != null) {
      return new ContinueCondition(
          conversationId: playedItems[previousIndex].conversationCardId);
    } else if (playedItems[previousIndex].reflectionId != null) {
      return new ContinueCondition(
          reflectionId: playedItems[previousIndex].reflectionId);
    } else {
      return new ContinueCondition();
    }
  }

  Future playNext() async {
    print("NEXT!!! previous command id is $_commandCounter");
    print("next pointer will be $_innerPointer");
    _commandCounter++;
    isPaused = false;
    await _playTextProvider.pause();
    await Future.delayed(Duration(milliseconds: 500));
    _playByCondition(
        _findNextForConversation(continueCondition.conversationId));
  }

  ContinueCondition _findNextForConversation(int originalId) {
    int nextId = 0;
    int nextIndex = playedItems.length - 1;
    for (int i = 0; i < playedItems.length - 1; i++) {
      nextId = playedItems[i + 1].conversationCardId;
      if (playedItems[i].conversationCardId == originalId &&
          nextId != originalId) {
        break;
      }
    }
    if (playedItems[nextIndex].conversationCardId != null) {
      return new ContinueCondition(
          conversationId: playedItems[nextIndex].conversationCardId);
    } else if (playedItems[nextIndex].reflectionId != null) {
      return new ContinueCondition(
          reflectionId: playedItems[nextIndex].reflectionId);
    } else {
      return new ContinueCondition();
    }
  }

  void _playByCondition(ContinueCondition condition) {
    if (condition.conversationId != null) {
      playConversation(condition.conversationId);
    } else if (condition.reflectionId != null) {
      playReflection(condition.reflectionId);
    } else {
      playCollection();
    }
  }
}
