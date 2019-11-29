import 'package:flutter_driver/src/driver/driver.dart';

import 'reflection_creation_test_screen.dart';
import 'test_screen.dart';
import 'utils.dart';

class MainTestScreen extends TestScreen {
  final _profileButtonFinder = find.byTooltip('profile');
  final _libraryButtonFinder = find.byTooltip("library");
  final _homeButtonFinder = find.byTooltip("home");

  final _thoughtOptionFinder = find.text("EXPRESS");
  final _questionOptionFinder = find.text("QUESTION");

  final _emotionLogTitle = find.text("EMOTION LOG");
  final _searchInputField = find.byType("TextField");
  final _recentConversationsListTitle = find.text("RECENT CONVERSATIONS");

  final _reflectTab = find.text("REFLECT");
  final _reviewTab = find.text("REVIEW");

  final _createCollectionButton = find.text("Create collection");
  final _autoCollectionMostReflected = find.text("Most reflected on");
  final _autoCollectionIncompete = find.text("Incomplete conversations");
  final _autoCollectionPositive = find.text("Positive conversations");
  final _autoCollection6Months = find.text("6 month ago");

  MainTestScreen(FlutterDriver driver) : super(driver);

  Future<bool> isHomeReady({Duration timeout}) async {
    return await widgetExists(driver, _thoughtOptionFinder, timeout: timeout) &
        await widgetExists(driver, _questionOptionFinder, timeout: timeout) &
        await widgetExists(driver, _profileButtonFinder, timeout: timeout) &
        await widgetExists(driver, _libraryButtonFinder, timeout: timeout);
  }

  Future<bool> isLibraryReflectReady({Duration timeout}) async {
    return await widgetExists(driver, _homeButtonFinder, timeout: timeout) &
        await widgetExists(driver, _emotionLogTitle, timeout: timeout) &
        await widgetExists(driver, _searchInputField, timeout: timeout);
  }

  Future<bool> isLibraryReviewReady({Duration timeout}) async {
    return await widgetExists(driver, _homeButtonFinder, timeout: timeout) &
        await widgetExists(driver, _createCollectionButton, timeout: timeout) &
        await widgetExists(driver, _autoCollectionIncompete, timeout: timeout) &
        await widgetExists(driver, _autoCollectionMostReflected,
            timeout: timeout);
  }

  Future<bool> isProfileReady({Duration timeout}) {
    return widgetExists(driver, _homeButtonFinder,
        timeout: timeout); //TODO modify after profile will be ready
  }

  Future tapProfileButton() {
    return driver.tap(_profileButtonFinder);
  }

  Future tapHomeButton() {
    return driver.tap(_homeButtonFinder);
  }

  Future tapLibraryButton() {
    return driver.tap(_libraryButtonFinder);
  }

  Future<ReflectionCreationTestScreen> tapThoughtInvite() async {
    await driver.tap(_thoughtOptionFinder);
    return new ReflectionCreationTestScreen(driver);
  }

  Future tapQuestionInvite() {
    return driver.tap(_questionOptionFinder);
  }

  @override
  Future<bool> isReady({Duration timeout}) {
    return isHomeReady(timeout: timeout);
  }

  Future changeToReflectTab() async {
    return driver.tap(_reflectTab);
  }

  Future changeToReviewTab() async {
    return driver.tap(_reviewTab);
  }
}
