import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hold/bloc/onboarding_bloc.dart';
import 'package:hold/onboarding_screen.dart';
import 'package:mockito/mockito.dart';

class MockOnboardingBloc extends Mock implements OnboardingBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Onboarding Screen has bottom button and can change pages on next',
      (WidgetTester tester) async {
    binding.window.physicalSizeTestValue = Size(800, 480);
    binding.window.devicePixelRatioTestValue = 1.0;
    MockNavigatorObserver navigatorObserver = new MockNavigatorObserver();
    MockOnboardingBloc bloc = new MockOnboardingBloc();
    await tester.pumpWidget(MaterialApp(
      home: OnboardingScreen(
        bloc: bloc,
      ),
      navigatorObservers: [navigatorObserver],
    ));

    Finder backButton = find.byKey(Key("back"));
    Finder nextButton = find.byKey(Key("next"));

    expect(find.text('Talk with yourself'), findsOneWidget);
    expect(backButton, findsNothing);
    expect(nextButton, findsOneWidget);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(find.text('Build on your own conversations'), findsOneWidget);
    expect(backButton, findsOneWidget);
    expect(nextButton, findsOneWidget);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(find.text('A personal space no one can access'), findsOneWidget);
    expect(backButton, findsOneWidget);
    expect(nextButton, findsOneWidget);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(find.text('Hold is not a crisis service'), findsOneWidget);
    expect(backButton, findsOneWidget);
    expect(nextButton, findsOneWidget);

    await tester.tap(nextButton);
    verify(bloc.acceptAndStart()).called(1);
    verify(navigatorObserver.didPush(any, any));
  });
}
