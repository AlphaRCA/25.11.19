import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hold/model/conversation.dart';
import 'package:hold/model/conversation_widget_content.dart';
import 'package:hold/storage/conversation_content.dart';

//to run this test: in terminal execute "flutter run command_line_test/storage_provider_test.dart" (there should be a connected phone)
main() {
  /*TestWidgetsFlutterBinding.ensureInitialized();

  StorageProvider storageProvider;
  Conversation originalQuestionReflection, originalThoughtReflection;

  setUpAll(() async {
    storageProvider =
        new StorageProvider(dbFilePath: await getDatabasesPath() + "/test.db");
    await storageProvider.initializationDone;
  });

  // Delete the database so every test run starts with a fresh database
  tearDownAll(() async {
    await deleteDatabase((await getDatabasesPath()) + "/test.db");
  });

  group("saved data can be loaded correctly", () {
    test(
        "Reflection with thought is saved and then, when loaded, "
        "it has the same data", () async {
      int cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      originalThoughtReflection = _generateThoughtReflection(cardNumber);
      storageProvider.updateConversation(originalThoughtReflection);

      ConversationForReview screenContent = await storageProvider
          .getConversationByCardNumber(originalThoughtReflection.cardNumber);
      expect(screenContent.additionals.length, equals(0));
      expect(screenContent.mainConversation.title,
          equals(originalThoughtReflection.title));
      expect(screenContent.mainConversation.type, equals(ReflectionType.A));
      expect(screenContent.mainConversation.thought,
          equals(originalThoughtReflection.thought));
      expect(screenContent.mainConversation.question,
          equals(originalThoughtReflection.question));
      expect(screenContent.mainConversation.answer,
          equals(originalThoughtReflection.answer));
      expect(screenContent.mainConversation.positiveMood,
          equals(originalThoughtReflection.positiveMood));
    });

    test(
        "Reflection with question is saved and then, when loaded, "
        "it has the same data", () async {
      int cardNumber = await storageProvider.insertReflection(ReflectionType.B);
      originalQuestionReflection = _generateQuestionReflection(cardNumber);

      await storageProvider.updateConversation(originalQuestionReflection);
      ConversationForReview screenContent = await storageProvider
          .getConversationByCardNumber(originalQuestionReflection.cardNumber);
      expect(screenContent.additionals.length, equals(0));
      expect(screenContent.mainConversation.positiveMood,
          equals(originalQuestionReflection.positiveMood));
      expect(screenContent.mainConversation.title,
          equals(originalQuestionReflection.title));
      expect(screenContent.mainConversation.type, equals(ReflectionType.B));
      expect(screenContent.mainConversation.question,
          equals(originalQuestionReflection.question));
      expect(screenContent.mainConversation.answer,
          equals(originalQuestionReflection.answer));
      expect(screenContent.mainConversation.thought,
          equals(originalQuestionReflection.thought));
    });

    test(
        "After saving two reflections reflection widget data is loaded with "
        "two values and appropriate data", () async {
      List<ReflectionWidgetContent> widgetsContent =
          await storageProvider.getReflectionList();
      expect(widgetsContent.length, equals(2));

      expect(widgetsContent[0].cardNumber,
          equals(originalQuestionReflection.cardNumber));
      expect(widgetsContent[0].getTitle(),
          equals(originalQuestionReflection.title));
      expect(widgetsContent[0].shortText,
          equals(originalQuestionReflection.question));

      expect(widgetsContent[1].cardNumber,
          equals(originalThoughtReflection.cardNumber));
      expect(widgetsContent[1].getTitle(),
          equals(originalThoughtReflection.title));
      expect(widgetsContent[1].shortText,
          equals(originalThoughtReflection.thought));
    });

    test(
        "After adding 2 more reflections to one card, screen data for this "
        "card has all the information from all these reflections", () async {
      Reflection reflection1 =
          new Reflection(originalQuestionReflection.cardNumber, "ADVICE");
      reflection1.myText = "some more words about the theme";
      await storageProvider.insertAdditional(reflection1);
      Reflection reflection2 =
          new Reflection(originalQuestionReflection.cardNumber, "EMPATHISE");
      reflection2.myText = "super word that will be unforgettable";
      await storageProvider.insertAdditional(reflection2);

      ConversationForReview screenContent = await storageProvider
          .getConversationByCardNumber(originalQuestionReflection.cardNumber);
      expect(screenContent.mainConversation.positiveMood,
          equals(originalQuestionReflection.positiveMood));
      expect(screenContent.mainConversation.title,
          equals(originalQuestionReflection.title));
      expect(screenContent.mainConversation.type, equals(ReflectionType.B));
      expect(screenContent.mainConversation.question,
          equals(originalQuestionReflection.question));
      expect(screenContent.mainConversation.answer,
          equals(originalQuestionReflection.answer));
      expect(screenContent.mainConversation.thought,
          equals(originalQuestionReflection.thought));

      expect(screenContent.additionals.length, equals(2));
      print(
          "additionals order is ${screenContent.additionals[0].myText} -> ${screenContent.additionals[1].myText}");
      expect(screenContent.additionals[0].myText, equals(reflection1.myText));
      expect(screenContent.additionals[1].myText, equals(reflection2.myText));
    });

    test(
        "Mood graph values for saved reflections come in right order and have "
        "correct length", () async {
      List<GraphValue> graphValues =
          await storageProvider.getPositiveGraphValues();
      expect(graphValues.length, equals(2));

      expect(graphValues[0].cardNumber, equals(2));
      expect(graphValues[1].cardNumber, equals(1));
      expect(graphValues[0].value,
          equals(originalQuestionReflection.positiveMood));
      expect(
          graphValues[1].value, equals(originalThoughtReflection.positiveMood));
    });
  });

  group("export/import", () {
    test("with no data in database export gives error", () {});

    test(
        "export with only one thought reflection in the database saves it to file "
        "without errors and have correct fields",
        () {});

    test(
        "export with only one topic reflection in the database saves it to file "
        "without error and have correct fields",
        () {});

    test(
        "export with some reflections and some additional data saves all to file",
        () {});

    test("import saved data restores all data from file", () {});
  });

  group("search", () {
    String wordInTitle = "1234";
    String wordInQuestion = "4321";
    String wordInAnswer = "7777";
    String wordInThought = "8888";
    String wordInAdditional = "5555";
    String wordInMultiplePlaces = "4444";
    Conversation withWordInTitle,
        withWordInTitle2,
        withWordInTitle3,
        withWordInTitle4;
    Conversation withWordInQuestion,
        withWordInQuestion2,
        withWordInQuestion3,
        withWordInQuestion4;
    Conversation withWordInAnswer,
        withWordInAnswer2,
        withWordInAnswer3,
        withWordInAnswer4;
    Conversation withWordInThought,
        withWordInThought2,
        withWordInThought3,
        withWordInThought4;
    Conversation withWordInMultiplePlaces;
    Reflection reflection1, reflection2, reflection3, reflection4;

    setUpAll(() async {
      int cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInTitle = _generateReflection(cardNumber);
      withWordInTitle.title = wordInTitle;
      await storageProvider.updateConversation(withWordInTitle);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInTitle2 = _generateReflection(cardNumber);
      withWordInTitle2.title += wordInTitle;
      await storageProvider.updateConversation(withWordInTitle2);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInTitle3 = _generateReflection(cardNumber);
      withWordInTitle3.title = wordInTitle + withWordInTitle3.title;
      await storageProvider.updateConversation(withWordInTitle3);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInTitle4 = _generateReflection(cardNumber);
      int divideIndex = (withWordInTitle4.title.length / 2).floor();
      withWordInTitle4.title =
          withWordInTitle4.title.substring(0, divideIndex) +
              wordInTitle +
              withWordInTitle4.title.substring(divideIndex);
      await storageProvider.updateConversation(withWordInTitle4);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInQuestion = _generateReflection(cardNumber);
      withWordInQuestion.question = wordInQuestion;
      await storageProvider.updateConversation(withWordInQuestion);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInQuestion2 = _generateReflection(cardNumber);
      withWordInQuestion2.question += wordInQuestion;
      await storageProvider.updateConversation(withWordInQuestion2);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInQuestion3 = _generateReflection(cardNumber);
      withWordInQuestion3.question =
          wordInQuestion + withWordInQuestion3.question;
      await storageProvider.updateConversation(withWordInQuestion3);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInQuestion4 = _generateReflection(cardNumber);
      divideIndex = (withWordInQuestion4.question.length / 2).floor();
      withWordInQuestion4.question =
          withWordInQuestion4.question.substring(0, divideIndex) +
              wordInQuestion +
              withWordInQuestion4.question.substring(divideIndex);
      await storageProvider.updateConversation(withWordInQuestion4);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInAnswer = _generateReflection(cardNumber);
      withWordInAnswer.answer = wordInAnswer;
      await storageProvider.updateConversation(withWordInAnswer);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInAnswer2 = _generateReflection(cardNumber);
      withWordInAnswer2.answer += wordInAnswer;
      await storageProvider.updateConversation(withWordInAnswer2);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInAnswer3 = _generateReflection(cardNumber);
      withWordInAnswer3.answer = wordInAnswer + withWordInAnswer3.answer;
      await storageProvider.updateConversation(withWordInAnswer3);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInAnswer4 = _generateReflection(cardNumber);
      divideIndex = (withWordInAnswer4.answer.length / 2).floor();
      withWordInAnswer4.answer =
          withWordInAnswer4.answer.substring(0, divideIndex) +
              wordInAnswer +
              withWordInAnswer4.answer.substring(divideIndex);
      await storageProvider.updateConversation(withWordInAnswer4);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInThought = _generateReflection(cardNumber);
      withWordInThought.thought = wordInThought;
      await storageProvider.updateConversation(withWordInThought);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInThought2 = _generateReflection(cardNumber);
      withWordInThought2.thought += wordInThought;
      await storageProvider.updateConversation(withWordInThought2);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInThought3 = _generateReflection(cardNumber);
      withWordInThought3.thought = wordInThought + withWordInThought3.thought;
      await storageProvider.updateConversation(withWordInThought3);

      cardNumber = await storageProvider.insertReflection(ReflectionType.A);
      withWordInThought4 = _generateReflection(cardNumber);
      divideIndex = (withWordInThought4.thought.length / 2).floor();
      withWordInThought4.thought =
          withWordInThought4.thought.substring(0, divideIndex) +
              wordInThought +
              withWordInThought4.thought.substring(divideIndex);
      await storageProvider.updateConversation(withWordInThought4);

      reflection1 =
          new Reflection(withWordInTitle.cardNumber, getRandomString());
      reflection1.myText = wordInAdditional + getRandomString();
      await storageProvider.insertAdditional(reflection1);

      reflection2 =
          new Reflection(withWordInTitle2.cardNumber, getRandomString());
      reflection2.myText = getRandomString() + wordInAdditional;
      await storageProvider.insertAdditional(reflection2);

      reflection3 =
          new Reflection(withWordInTitle3.cardNumber, getRandomString());
      reflection3.myText =
          getRandomString() + wordInAdditional + getRandomString();
      await storageProvider.insertAdditional(reflection3);

      reflection4 =
          new Reflection(withWordInTitle4.cardNumber, getRandomString());
      reflection4.myText = wordInAdditional;
      await storageProvider.insertAdditional(reflection4);

      cardNumber = await storageProvider.insertReflection(ReflectionType.B);
      withWordInMultiplePlaces = _generateReflection(cardNumber);
      divideIndex = (withWordInMultiplePlaces.thought.length / 2).floor();
      withWordInMultiplePlaces.thought =
          withWordInMultiplePlaces.thought.substring(0, divideIndex) +
              wordInMultiplePlaces +
              withWordInMultiplePlaces.thought.substring(divideIndex);
      withWordInMultiplePlaces.question += wordInMultiplePlaces;
      withWordInMultiplePlaces.answer =
          wordInMultiplePlaces + withWordInMultiplePlaces.answer;
      await storageProvider.updateConversation(withWordInMultiplePlaces);
      Reflection reflection5 = new Reflection(
          withWordInMultiplePlaces.cardNumber, getRandomString());
      reflection5.myText = wordInMultiplePlaces;
      await storageProvider.insertAdditional(reflection5);
    });

    test("search of word in title gives correct result", () async {
      List<ReflectionWidgetContent> searchResult =
          await storageProvider.getSearchedReflections(wordInTitle);
      expect(searchResult.length, equals(4));

      checkShortViewIsFromFullView(
          searchResult[0], withWordInTitle4, withWordInTitle4.thought);
      checkShortViewIsFromFullView(
          searchResult[1], withWordInTitle3, withWordInTitle3.thought);
      checkShortViewIsFromFullView(
          searchResult[2], withWordInTitle2, withWordInTitle2.thought);
      checkShortViewIsFromFullView(
          searchResult[3], withWordInTitle, withWordInTitle.thought);
    });

    test("search of word in thought gives correct result", () async {
      List<ReflectionWidgetContent> searchResult =
          await storageProvider.getSearchedReflections(wordInThought);
      expect(searchResult.length, equals(4));

      checkShortViewIsFromFullView(
          searchResult[0], withWordInThought4, withWordInThought4.thought);
      checkShortViewIsFromFullView(
          searchResult[1], withWordInThought3, withWordInThought3.thought);
      checkShortViewIsFromFullView(
          searchResult[2], withWordInThought2, withWordInThought2.thought);
      checkShortViewIsFromFullView(
          searchResult[3], withWordInThought, withWordInThought.thought);
    });

    test(
        "if word appears in multiple places inside the reflection this reflection appears in result only once",
        () async {
      List<ReflectionWidgetContent> searchResult =
          await storageProvider.getSearchedReflections(wordInMultiplePlaces);
      expect(searchResult.length, equals(1));

      checkShortViewIsFromFullView(searchResult[0], withWordInMultiplePlaces,
          withWordInMultiplePlaces.thought);
    });

    test("search of word in question gives correct result", () async {
      List<ReflectionWidgetContent> searchResult =
          await storageProvider.getSearchedReflections(wordInQuestion);
      expect(searchResult.length, equals(4));

      checkShortViewIsFromFullView(
          searchResult[0], withWordInQuestion4, withWordInQuestion4.question);
      checkShortViewIsFromFullView(
          searchResult[1], withWordInQuestion3, withWordInQuestion3.question);
      checkShortViewIsFromFullView(
          searchResult[2], withWordInQuestion2, withWordInQuestion2.question);
      checkShortViewIsFromFullView(
          searchResult[3], withWordInQuestion, withWordInQuestion.question);
    });

    test("search of word in response gives correct result", () async {
      List<ReflectionWidgetContent> searchResult =
          await storageProvider.getSearchedReflections(wordInAnswer);
      expect(searchResult.length, equals(4));

      checkShortViewIsFromFullView(
          searchResult[0], withWordInAnswer4, withWordInAnswer4.answer);
      checkShortViewIsFromFullView(
          searchResult[1], withWordInAnswer3, withWordInAnswer3.answer);
      checkShortViewIsFromFullView(
          searchResult[2], withWordInAnswer2, withWordInAnswer2.answer);
      checkShortViewIsFromFullView(
          searchResult[3], withWordInAnswer, withWordInAnswer.answer);
    });

    test("search of word in additional reflection gives correct result",
        () async {
      List<ReflectionWidgetContent> searchResult =
          await storageProvider.getSearchedReflections(wordInAdditional);
      expect(searchResult.length, equals(4));

      checkShortViewIsFromFullView(
          searchResult[0], withWordInTitle4, reflection4.myText);
      checkShortViewIsFromFullView(
          searchResult[1], withWordInTitle3, reflection3.myText);
      checkShortViewIsFromFullView(
          searchResult[2], withWordInTitle2, reflection2.myText);
      checkShortViewIsFromFullView(
          searchResult[3], withWordInTitle, reflection1.myText);
    });

    test("search of word without occurancies in database gives zero results",
        () async {
      List<ReflectionWidgetContent> searchResult =
          await storageProvider.getSearchedReflections("9999");
      expect(searchResult.length, equals(0));
    });

    test("search of word on blank dataset gives zero results", () async {
      await storageProvider.clearMyData();
      List<ReflectionWidgetContent> searchResult =
          await storageProvider.getSearchedReflections(wordInAnswer);
      expect(searchResult.length, equals(0));
    });
  });
*/
}

void checkShortViewIsFromFullView(ConversationWidgetContent searchResult,
    Conversation reflection, String contentWithWord) {
  expect(searchResult.cardNumber, equals(reflection.cardNumber));
  expect(searchResult.title, equals(reflection.title));
  expect(searchResult.shortText, equals(contentWithWord));
}

Conversation _generateThoughtReflection(int cardNumber) {
  Conversation originalThoughtReflection =
      new Conversation(cardNumber, ReflectionType.A);
  originalThoughtReflection.title = "Laziness";
  originalThoughtReflection.content.add(new ConversationContent(cardNumber,
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
      .add(new ConversationContent(cardNumber, text: "What is laziness?"));
  originalThoughtReflection.content.add(new ConversationContent(cardNumber,
      text: "No one knows. But money matters"));
  originalThoughtReflection.positiveMood = 80;
  return originalThoughtReflection;
}

Conversation _generateQuestionReflection(int cardNumber) {
  Conversation originalQuestionReflection =
      new Conversation(cardNumber, ReflectionType.B);
  originalQuestionReflection.title = "Lava";
  originalQuestionReflection.content.add(new ConversationContent(cardNumber,
      text: "Money is the key requirement to visit any volcano in the world."));
  originalQuestionReflection.content.add(new ConversationContent(cardNumber,
      text: "How many volcanoes are in the world?"));
  originalQuestionReflection.content
      .add(new ConversationContent(cardNumber, text: "8"));
  originalQuestionReflection.positiveMood = 40;
  return originalQuestionReflection;
}

Conversation _generateReflection(int cardNumber) {
  Conversation reflection = new Conversation(cardNumber, ReflectionType.A);
  reflection.title = getRandomString();
  reflection.content
      .add(new ConversationContent(cardNumber, text: getRandomString()));
  reflection.content
      .add(new ConversationContent(cardNumber, text: getRandomString()));
  reflection.content
      .add(new ConversationContent(cardNumber, text: getRandomString()));
  reflection.positiveMood = Random().nextInt(100);
  return reflection;
}

String getRandomString() {
  int length = Random().nextInt(200);
  return new String.fromCharCodes(
      new List.generate(length, (index) => randomBetween()));
}

int randomBetween() {
  const ASCII_START = 65;
  const ASCII_END = 126;
  double randomDouble = Random().nextDouble();
  if (randomDouble < 0) randomDouble *= -1;
  if (randomDouble > 1) randomDouble = 1 / randomDouble;
  return ((ASCII_END - ASCII_START) * Random().nextDouble()).toInt() +
      ASCII_START;
}
