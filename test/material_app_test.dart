import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hold/main.dart';
import 'package:hold/main_screen.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    binding.window.physicalSizeTestValue = Size(320, 240);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  testWidgets('should build material app with home page',
      (WidgetTester tester) async {
    //arrange
    await tester.pumpWidget(MyApp(MainScreen()));
    MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
    var expectedTitle = "HOLD";

    //assert
    expect(materialApp.title, expectedTitle);
    tester.pump(Duration(seconds: 2));
  });
}
