import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_driver/src/driver/driver.dart';

import 'main_test_screen.dart';
import 'onboarding_test_screen.dart';
import 'test_screen.dart';
import 'utils.dart';

class InitialTestScreen extends TestScreen {
  final _titleTextFinder = find.text('Your time to talk with yourself');

  InitialTestScreen(FlutterDriver driver) : super(driver);

  @override
  Future<bool> isReady({Duration timeout}) =>
      widgetExists(driver, _titleTextFinder, timeout: timeout);

  Future<TestScreen> waitTransitionHappened() async {
    await Future.delayed(Duration(seconds: 1));
    SerializableFinder onboardingItem = find.text("Talk with yourself");
    if (await widgetExists(driver, onboardingItem)) {
      return OnboardingTestScreen(driver);
    } else {
      return MainTestScreen(driver);
    }
  }
}
