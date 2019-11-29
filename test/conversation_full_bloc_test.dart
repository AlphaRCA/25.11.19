import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hold/bloc/conversation_full_bloc.dart';
import 'package:hold/bloc/play_text_provider.dart';
import 'package:hold/model/conversation.dart';
import 'package:hold/model/conversation_for_review.dart';
import 'package:hold/model/reflection.dart';
import 'package:hold/storage/conversation_content.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

class MockPlayTextProvider extends Mock implements PlayTextProvider {}

class MockStorageProvider extends Mock implements StorageProvider {}

main() {
  MockStorageProvider storageProvider = new MockStorageProvider();
  MockPlayTextProvider voiceProvider = new MockPlayTextProvider();

  ConversationForReview screenThought, screenQuestion, screenAdditionals;
  setUpAll(() {
    Conversation originalThoughtReflection =
        new Conversation(1, ReflectionType.A);
    originalThoughtReflection.title = "Laziness";
    originalThoughtReflection.content.add(new ConversationContent(1,
        text: "The original album version of “My Reflection” "
            "is lushly intoxicating from the outset, so poignant are the acoustic "
            "piano chords played by Rayel himself. Just as the listener becomes "
            "fully seduced by that melody, Rayel lays down superbly distorted horns "
            "and a bouncy, quivering bassline that’s dripping in acid. "
            "The forward-driving percussion quickly sets the stage for Hewitt’s "
            "imposing vocals, and off she goes. Hewitt’s voice is a slightly "
            "lower register than is found in abundance on saccharine-sweet songs "
            "so prevalent today, though she can also hit the high notes with aplomb. "));
    originalThoughtReflection.content
        .add(new ConversationContent(1, text: "What is 2 + 2?"));
    originalThoughtReflection.content
        .add(new ConversationContent(1, text: "4"));
    originalThoughtReflection.positiveMood = 80;

    Conversation originalTopicReflection =
        new Conversation(2, ReflectionType.B);
    originalTopicReflection.title = "Sleeping";
    originalTopicReflection.content
        .add(new ConversationContent(2, text: "Why do we need to sleep?"));
    originalTopicReflection.content.add(new ConversationContent(2,
        text: "Because we are humans and have human body..."));
    originalTopicReflection.content.add(
        new ConversationContent(2, text: "I am tired and unhappy about it"));
    originalTopicReflection.positiveMood = 40;

    screenThought =
        new ConversationForReview(originalThoughtReflection, List());
    screenQuestion = new ConversationForReview(originalTopicReflection, List());

    Reflection reflection1 = new Reflection(2, "ADVICE", 1, 1);
    reflection1.myText = "some more words about the theme";
    Reflection reflection2 = new Reflection(2, "EMPATHISE", 1, 2);
    reflection2.myText = "super word that will be unforgettable";
    screenAdditionals = new ConversationForReview(
        originalThoughtReflection, [reflection1, reflection2]);
  });

  test(
      "emits the same ReflectionScreenContent and page title "
      "as received from storage", () async {
    when(storageProvider.getTitle(any))
        .thenAnswer((_) => Future.value(screenThought.mainConversation.title));
    when(storageProvider.getConversationByCardNumber(any))
        .thenAnswer((_) => Future.value(screenThought));
    when(storageProvider.initializationDone)
        .thenAnswer((_) => Future.value(true));
    ConversationFullBloc bloc =
        new ConversationFullBloc(1, ptp: voiceProvider, sp: storageProvider);

    String title = await bloc.title;
    expect(title, equals(screenThought.mainConversation.title));

    await bloc.loadComplete;
    expectLater(bloc.reflection, emits(screenThought));
  });

  test("after play command on question plays question then answer and thought",
      () async {
    when(storageProvider.getTitle(any))
        .thenAnswer((_) => Future.value(screenQuestion.mainConversation.title));
    when(storageProvider.getConversationByCardNumber(any))
        .thenAnswer((_) => Future.value(screenQuestion));
    when(storageProvider.initializationDone)
        .thenAnswer((_) => Future.value(true));

    BehaviorSubject<bool> playState = new BehaviorSubject();
    when(voiceProvider.playState).thenAnswer((_) => playState.stream);
    when(voiceProvider.speak(any)).thenAnswer((_) {
      playState.add(true);
      Future.delayed(Duration(milliseconds: 1)).then((_) {
        playState.add(false);
      });
      return Future.value(null);
    });
    when(voiceProvider.pause()).thenAnswer((_) {
      playState.add(false);
      return Future.value(null);
    });
    when(voiceProvider.resume()).thenAnswer((_) {
      playState.add(true);
      Future.delayed(Duration(milliseconds: 1)).then((_) {
        playState.add(false);
      });
      return Future.value(null);
    });

    ConversationFullBloc bloc =
        new ConversationFullBloc(1, ptp: voiceProvider, sp: storageProvider);

    String title = await bloc.title;
    expect(title, equals(screenQuestion.mainConversation.title));
    await bloc.loadComplete;

    //bloc.voiceFrom(0, true);
    await Future.delayed(Duration(milliseconds: 1));
    expect(verify(voiceProvider.speak(captureAny)).captured.single,
        screenQuestion.mainConversation.title);
    await Future.delayed(Duration(milliseconds: 1));
    expect(verify(voiceProvider.speak(captureAny)).captured.single,
        screenQuestion.mainConversation.content[0]);
    await Future.delayed(Duration(milliseconds: 2));
    expect(verify(voiceProvider.speak(captureAny)).captured.single,
        screenQuestion.mainConversation.content[1]);
    await Future.delayed(Duration(milliseconds: 2));
    expect(verify(voiceProvider.speak(captureAny)).captured.single,
        screenQuestion.mainConversation.content[2]);
  });

  test(
      "after play command on topic with 2 additions plays topic, then "
      "additional question, then answer, then additional question, then answer",
      () async {
    when(storageProvider.getTitle(any)).thenAnswer(
        (_) => Future.value(screenAdditionals.mainConversation.title));
    when(storageProvider.getConversationByCardNumber(any))
        .thenAnswer((_) => Future.value(screenAdditionals));
    when(storageProvider.initializationDone)
        .thenAnswer((_) => Future.value(true));

    BehaviorSubject<bool> playState = new BehaviorSubject();
    when(voiceProvider.playState).thenAnswer((_) => playState.stream);
    when(voiceProvider.speak(any)).thenAnswer((_) {
      playState.add(true);
      Future.delayed(Duration(milliseconds: 1)).then((_) {
        playState.add(false);
      });
      return Future.value(null);
    });
    when(voiceProvider.pause()).thenAnswer((_) {
      playState.add(false);
      return Future.value(null);
    });
    when(voiceProvider.resume()).thenAnswer((_) {
      playState.add(true);
      Future.delayed(Duration(milliseconds: 1)).then((_) {
        playState.add(false);
      });
      return Future.value(null);
    });

    ConversationFullBloc bloc =
        new ConversationFullBloc(2, ptp: voiceProvider, sp: storageProvider);
    await bloc.loadComplete;

    //bloc.voiceFrom(0, true);
    await Future.delayed(Duration(milliseconds: 1));
    expect(verify(voiceProvider.speak(captureAny)).captured.single,
        screenAdditionals.mainConversation.title);
    await Future.delayed(Duration(milliseconds: 1));
    expect(verify(voiceProvider.speak(captureAny)).captured.single,
        screenAdditionals.mainConversation.content[0]);
    await Future.delayed(Duration(milliseconds: 1));
    expect(verify(voiceProvider.speak(captureAny)).captured.single,
        screenAdditionals.mainConversation.content[1]);
    await Future.delayed(Duration(milliseconds: 1));
    expect(verify(voiceProvider.speak(captureAny)).captured.single,
        screenAdditionals.mainConversation.content[2]);
    await Future.delayed(Duration(milliseconds: 1));
    expect(verify(voiceProvider.speak(captureAny)).captured.single,
        screenAdditionals.additionals[0].title);
    await Future.delayed(Duration(milliseconds: 1));
    expect(verify(voiceProvider.speak(captureAny)).captured.single,
        screenAdditionals.additionals[0].myText);
    await Future.delayed(Duration(milliseconds: 1));
    expect(verify(voiceProvider.speak(captureAny)).captured.single,
        screenAdditionals.additionals[1].title);
    await Future.delayed(Duration(milliseconds: 2));
    expect(verify(voiceProvider.speak(captureAny)).captured.single,
        screenAdditionals.additionals[1].myText);
  });

  test("after pause sends stop to PlayTextProvider", () {});

  test("after resume sends resume to playTextProvider", () {});
}
