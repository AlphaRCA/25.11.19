import 'dart:async';

import 'package:flutter_driver/flutter_driver.dart';

import 'main_test_screen.dart';
import 'test_screen.dart';
import 'utils.dart';

class OnboardingTestScreen extends TestScreen {
  final _bottomButton = find.byType('BottomButton');
  final _headerText = find.byType('HeaderText');
  final _onboardingText = find.byType('OnboardingText');

  OnboardingTestScreen(FlutterDriver driver) : super(driver);

  @override
  Future<bool> isReady({Duration timeout}) =>
      widgetExists(driver, _bottomButton, timeout: timeout);

  Future<MainTestScreen> tapUnderstand() async {
    await driver.tap(_bottomButton);

    return new MainTestScreen(driver);
  }

  Future tapNext() {
    return driver.tap(_bottomButton);
  }

  Future<bool> pageIsReady({Duration timeout}) async {
    bool result = await widgetExists(driver, _bottomButton, timeout: timeout);
    result &= await widgetExists(driver, _headerText, timeout: timeout);
    result &= await widgetExists(driver, _onboardingText, timeout: timeout);
    return result;
  }

  Future<bool> firstPageIsReady({Duration timeout}) async {
    return await widgetExists(driver, find.text("Talk with yourself"),
            timeout: timeout) &
        await pageIsReady(timeout: timeout);
  }

  Future<bool> secondPageIsReady({Duration timeout}) async {
    return await widgetExists(
            driver, find.text("Build on your own conversations"),
            timeout: timeout) &
        await pageIsReady(timeout: timeout);
  }

  Future<bool> thirdPageIsReady({Duration timeout}) async {
    return await widgetExists(
            driver, find.text("A personal space no one can access"),
            timeout: timeout) &
        await pageIsReady(timeout: timeout);
  }

  Future<bool> forthPageIsReady({Duration timeout}) async {
    return await widgetExists(driver, find.text("Hold is not a crisis service"),
            timeout: timeout) &
        await pageIsReady(timeout: timeout);
  }
}
