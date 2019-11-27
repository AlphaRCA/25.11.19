import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hold/widget/screen_parts/emotion_result_widget.dart';
import 'package:hold/widget/screen_parts/emotion_widget.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    binding.window.physicalSizeTestValue = Size(320, 240);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  testWidgets(
      'should have expression descriptions shown and value equal to initial',
      (WidgetTester tester) async {
    final ValueChanged<int> listener = (value) {
      print("value $value");
    };
    await tester
        .pumpWidget(MaterialApp(home: Scaffold(body: EmotionWidget(listener))));
    expect(find.text("NEGATIVE"), findsOneWidget);
    expect(find.text("POSITIVE"), findsOneWidget);
    expect(
        find.text(
            "How positive or negative did you feel during this conversation?"),
        findsOneWidget);

    expect(find.byType(Slider), findsOneWidget);
    Slider innerSlider = find.byType(Slider).evaluate().first.widget;
    expect(innerSlider.value, equals(50.0));
  });

  testWidgets(
      'should have expression descriptions shown and value equal to initial in final widget',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: Scaffold(body: EmotionResultWidget(10,40))));
    expect(find.text("NEGATIVE"), findsOneWidget);
    expect(find.text("POSITIVE"), findsOneWidget);
    expect(find.text("How positive or negative you felt."), findsOneWidget);

    expect(find.byType(Slider), findsOneWidget);
    Slider innerSlider = find.byType(Slider).evaluate().first.widget;
    expect(innerSlider.value, equals(10.0));
  });

  /*testWidgets("should call listener function on slide",
      (WidgetTester tester) async {
    final Key sliderKey = GlobalKey(debugLabel: 'A');
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ExpressionWidget(
      mockListener,
      "assets/sad.png",
      "assets/smile.png",
      "NEGATIVE",
      "POSITIVE",
      key: sliderKey,
    ))));

    expect(find.byType(Slider), findsOneWidget);
    Slider innerSlider = find.byType(Slider).evaluate().first.widget;
    expect(innerSlider.value, equals(10.0));

    final Offset center = tester.getCenter(find.byType(Slider));
    final TestGesture gesture = await tester.startGesture(center);

    await gesture.moveBy(const Offset(1.0, 0.0));

    expect(innerSlider.value, greaterThan(10));

    await gesture.up();
  });*/
}
