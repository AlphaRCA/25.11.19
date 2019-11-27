import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/initial_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:native_mixpanel/native_mixpanel.dart';

class MockMixpanel extends Mock implements Mixpanel {}

class MockPreferenceProvider extends Mock implements PreferencesProvider {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    binding.window.physicalSizeTestValue = Size(320, 240);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  testWidgets('Initial Screen is shown for about a second',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    MockNavigatorObserver navigatorObserver = new MockNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
      home: InitialScreen(),
      navigatorObservers: [navigatorObserver],
    ));

    expect(find.text('Your time to talk with yourself'), findsOneWidget);
    await tester.pump(Duration(seconds: 5));
    verify(navigatorObserver.didPush(any, any));
  });
}
