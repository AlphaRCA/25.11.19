import 'dart:async';

import 'package:flutter_driver/flutter_driver.dart';

import 'main_test_screen.dart';
import 'test_screen.dart';
import 'utils.dart';

class ReflectionCreationTestScreen extends TestScreen {
  static const pageCount = 16;
  final _prevButtonFinder = find.text('PREVIOUS');
  final _nextButtonFinder = find.text('NEXT');
  final _continueButtonFinder = find.text('CONTINUE');
  final _backButtonFinder = find.byTooltip('Back');
  final _completeButtonFinder = find.text('COMPLETE');
  final _writeButtonFinder = find.text('WRITE');
  final _speakButtonFinder = find.text('SPEAK');
  final _inputField = find.byType("TextInputField");
  final _thoughtInvite = find.text("What do you want to talk about?");
  final _questionInvite =
      find.text("What question would you ask yourself about this?");
  final _answerInvite = find.text("How would you answer to your question?");

  ReflectionCreationTestScreen(FlutterDriver driver) : super(driver);

  @override
  Future<bool> isReady({Duration timeout}) async {
    return await voiceVisible & await writeVisible;
  }

  Future<bool> get writeVisible {
    return widgetExists(driver, _writeButtonFinder);
  }

  Future<bool> get voiceVisible {
    return widgetExists(driver, _speakButtonFinder);
  }

  Future inputText(String text) async {
    await driver.tap(_inputField);
    await driver.enterText(text);
  }

  Future<bool> get questionFieldInviteVisible =>
      widgetExists(driver, _questionInvite);
  Future<bool> get thoughtFieldInviteVisible =>
      widgetExists(driver, _thoughtInvite);
  Future<bool> get answerFieldInviteVisible =>
      widgetExists(driver, _answerInvite);

  Future selectQuestionField() => driver.tap(_questionInvite);
  Future selectThoughtField() => driver.tap(_thoughtInvite);
  Future selectAnswerField() => driver.tap(_answerInvite);

  Future<bool> get continueVisible {
    return widgetExists(driver, _continueButtonFinder);
  }

  Future<bool> get nextVisible {
    return widgetExists(driver, _nextButtonFinder);
  }

  Future<bool> get previousVisible {
    return widgetExists(driver, _prevButtonFinder);
  }

  Future<bool> get backVisible {
    return widgetExists(driver, _backButtonFinder);
  }

  Future<bool> get completeVisible {
    return widgetExists(driver, _completeButtonFinder);
  }

  Future<MainTestScreen> tapCompleteButton() async {
    await driver.tap(_completeButtonFinder);

    return new MainTestScreen(driver);
  }

  Future<MainTestScreen> tapBackButton() async {
    await driver.tap(_backButtonFinder);
    return new MainTestScreen(driver);
  }

  Future<Null> tapContinueButton() async {
    return await driver.tap(_continueButtonFinder);
  }

  Future<Null> tapNextButton() async {
    return await driver.tap(_nextButtonFinder);
  }

  Future<Null> tapPreviousButton() async {
    return await driver.tap(_prevButtonFinder);
  }

  Future<bool> findPageNumber(int pageNumber) async {
    return widgetExists(driver, find.text("$pageNumber/$pageCount"));
  }
}
