import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'pom/initial_test_screen.dart';
import 'pom/main_test_screen.dart';
import 'pom/onboarding_test_screen.dart';
import 'pom/reflection_creation_test_screen.dart';
import 'pom/test_screen.dart';

// run test with "flutter driver test_driver/app.dart"
main() {
  FlutterDriver driver;
  InitialTestScreen initialScreen;
  MainTestScreen mainTestScreen;

  setUpAll(() async {
    final String adbPath = '/Users/Lenz/Library/Android/sdk/platform-tools/adb';
    await Process.run(adbPath, [
      'shell',
      'pm',
      'grant',
      'com.plugandplink.plug_and_plink',
      'android.permission.MICROPHONE'
    ]);

    driver = await FlutterDriver.connect();
    initialScreen = new InitialTestScreen(driver);
  });

  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
  });

  test(
      'should show initial screen for 1 second then go to main (or show onboarding and then main)',
      () async {
    expect(await initialScreen.isReady(), isTrue);
    print("initial is ready");
    TestScreen screen = await initialScreen.waitTransitionHappened();

    if (screen is OnboardingTestScreen) {
      expect(await screen.firstPageIsReady(), isTrue);
      await screen.tapNext();
      expect(await screen.secondPageIsReady(), isTrue);
      await screen.tapNext();
      expect(await screen.thirdPageIsReady(), isTrue);
      await screen.tapNext();
      expect(await screen.forthPageIsReady(), isTrue);
      mainTestScreen = await screen.tapUnderstand();
    } else {
      mainTestScreen = screen;
    }
    expect(await mainTestScreen.isReady(), isTrue);
  });

  group('Main screen Test', () {
    test('should change page to profile on profile button click', () async {
      await mainTestScreen.tapProfileButton();
      expect(await mainTestScreen.isProfileReady(), isTrue);
      await mainTestScreen.tapHomeButton();
      expect(await mainTestScreen.isHomeReady(), isTrue);
    });

    test('should change page to library on library button click', () async {
      await mainTestScreen.tapLibraryButton();
      expect(await mainTestScreen.isLibraryReflectReady(), isTrue);
      await mainTestScreen.tapHomeButton();
      expect(await mainTestScreen.isHomeReady(), isTrue);
    });

    test('should start Reflection screen on click on thought inivte', () async {
      ReflectionCreationTestScreen reflectionScreen =
          await mainTestScreen.tapThoughtInvite();
      expect(await reflectionScreen.isReady(), isTrue);

      mainTestScreen = await reflectionScreen.tapBackButton();
      expect(await mainTestScreen.isHomeReady(), isTrue);
    });
  });
}
