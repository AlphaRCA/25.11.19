import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hold/bloc/play_text_provider.dart';
import 'package:mockito/mockito.dart';

class MockFlutterTts extends Mock implements FlutterTts {}

main() {
  PlayTextProvider provider;
  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/shared_preferences',
  );

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return new Map();
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
  const sentence1 = "When I was young ";
  const sentence2 = "I can not say, that it was far";
  const sentence3 = "I played and swimed and was happy";
  const sentence4 = "Once upon a time";
  const sentence5 = "There lived a king";
  MockFlutterTts tts;

  setUpAll(() {});

  test("Text with 3 sentences causes play state to be played then stopped",
      () async {
    tts = new MockFlutterTts();
    provider = new PlayTextProvider(tts: tts);
    await provider.initialized;
    VoidCallback callback =
        verify(tts.setCompletionHandler(captureAny)).captured.single;
    when(tts.speak(any)).thenAnswer((_) {
      Future.delayed(Duration(milliseconds: 1)).then((_) {
        callback();
      });
      return Future.value(1);
    });
    provider.speak(sentence1 + ". " + sentence2 + ". " + sentence3);
    List<bool> rightOrder = [false, true, false];
    expectLater(provider.playState, emitsInOrder(rightOrder));
  });

  test(
      "next call to play a sentence is executed after finishing of the previous call",
      () async {
    tts = new MockFlutterTts();
    provider = new PlayTextProvider(tts: tts);
    await provider.initialized;
    VoidCallback callback =
        verify(tts.setCompletionHandler(captureAny)).captured.single;
    when(tts.speak(any)).thenAnswer((_) {
      Future.delayed(Duration(milliseconds: 1)).then((_) {
        callback();
      });
      return Future.value(1);
    });
    provider.speak(sentence1 + ". " + sentence2 + ". " + sentence3);
    verify(tts.speak(argThat(contains(sentence1))));
    await Future.delayed(Duration(milliseconds: 1));
    verify(tts.speak(argThat(contains(sentence2))));
    await Future.delayed(Duration(milliseconds: 1));
    verify(tts.speak(argThat(contains(sentence3))));
  });

  test("after pause there is no calls to tts except stop", () async {
    tts = new MockFlutterTts();
    provider = new PlayTextProvider(tts: tts);
    await provider.initialized;
    VoidCallback callback =
        verify(tts.setCompletionHandler(captureAny)).captured.single;
    when(tts.speak(any)).thenAnswer((_) {
      Future.delayed(Duration(milliseconds: 1)).then((_) {
        callback();
      });
      return Future.value(1);
    });
    provider.speak(sentence1 + ". " + sentence2 + ". " + sentence3);
    verify(tts.speak(argThat(contains(sentence1))));
    provider.pause();
    verifyNever(tts.speak(any));
  });

  test("after pause then play on first sentence 3 sentences will be played",
      () async {
    tts = new MockFlutterTts();
    provider = new PlayTextProvider(tts: tts);
    await provider.initialized;
    VoidCallback callback =
        verify(tts.setCompletionHandler(captureAny)).captured.single;
    when(tts.speak(any)).thenAnswer((_) {
      Future.delayed(Duration(milliseconds: 1)).then((_) {
        callback();
      });
      return Future.value(1);
    });
    provider.speak(sentence1 + ". " + sentence2 + ". " + sentence3);
    verify(tts.speak(argThat(contains(sentence1))));
    provider.pause();
    provider.resume();
    verify(tts.speak(argThat(contains(sentence1))));
    await Future.delayed(Duration(milliseconds: 1));
    verify(tts.speak(argThat(contains(sentence2))));
    await Future.delayed(Duration(milliseconds: 1));
    verify(tts.speak(argThat(contains(sentence3))));
  });

  test("after pause on second sentence 2 sentence will be played", () async {
    tts = new MockFlutterTts();
    provider = new PlayTextProvider(tts: tts);
    await provider.initialized;
    VoidCallback callback =
        verify(tts.setCompletionHandler(captureAny)).captured.single;
    when(tts.speak(any)).thenAnswer((_) {
      Future.delayed(Duration(milliseconds: 1)).then((_) {
        callback();
      });
      return Future.value(1);
    });
    provider.speak(sentence1 + ". " + sentence2 + ". " + sentence3);
    verify(tts.speak(argThat(contains(sentence1))));
    await Future.delayed(Duration(milliseconds: 1));
    verify(tts.speak(argThat(contains(sentence2))));
    provider.pause();
    provider.resume();
    verify(tts.speak(argThat(contains(sentence2))));
    await Future.delayed(Duration(milliseconds: 1));
    verify(tts.speak(argThat(contains(sentence3))));
  });

  test("after pause on third sentence 3 sentence will be played", () async {
    tts = new MockFlutterTts();
    provider = new PlayTextProvider(tts: tts);
    await provider.initialized;
    VoidCallback callback =
        verify(tts.setCompletionHandler(captureAny)).captured.single;
    when(tts.speak(any)).thenAnswer((_) {
      Future.delayed(Duration(milliseconds: 1)).then((_) {
        callback();
      });
      return Future.value(1);
    });
    provider.speak(sentence1 + ". " + sentence2 + ". " + sentence3);
    verify(tts.speak(argThat(contains(sentence1))));
    await Future.delayed(Duration(milliseconds: 1));
    verify(tts.speak(argThat(contains(sentence2))));
    await Future.delayed(Duration(milliseconds: 1));
    verify(tts.speak(argThat(contains(sentence3))));
    provider.pause();
    provider.resume();
    verify(tts.speak(argThat(contains(sentence3))));
  });

  test(
      ("if after playing all sentences there will be new text it will be "
          "played with all inner sentences"), () async {
    tts = new MockFlutterTts();
    provider = new PlayTextProvider(tts: tts);
    await provider.initialized;
    VoidCallback callback =
        verify(tts.setCompletionHandler(captureAny)).captured.single;
    when(tts.speak(any)).thenAnswer((_) {
      Future.delayed(Duration(milliseconds: 1)).then((_) {
        callback();
      });
      return Future.value(1);
    });
    provider.speak(sentence1 + ". " + sentence2 + ". " + sentence3);
    verify(tts.speak(argThat(contains(sentence1))));
    await Future.delayed(Duration(milliseconds: 3));

    provider.speak(sentence4 + ". " + sentence5);
    verify(tts.speak(argThat(contains(sentence4))));
    await Future.delayed(Duration(milliseconds: 1));
    verify(tts.speak(argThat(contains(sentence5))));
  });
}
