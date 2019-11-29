import 'package:flutter_driver/src/driver/driver.dart';

import 'test_screen.dart';
import 'utils.dart';

class ReflectingFurtherTestScreen extends TestScreen {
  final _cancelButtonFinder = find.text('CANCEL');

  ReflectingFurtherTestScreen(FlutterDriver driver) : super(driver);

  @override
  Future<bool> isReady({Duration timeout}) =>
      widgetExists(driver, _cancelButtonFinder, timeout: timeout);

  Future<Null> tapCancelButton() async {
    return await driver.tap(_cancelButtonFinder);
  }
}
