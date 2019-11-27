import 'dart:convert';

import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/storage/editable_ui_question.dart';
import 'package:hold/storage/editable_ui_request.dart';
import 'package:hold/storage/editable_ui_text.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:http/http.dart' as http;

class UITextUpdater {
  static const _SERVER_ADDRESS = "https://hold.new-staging.springsapps.com";

  final http.Client client;

  UITextUpdater() : client = new http.Client() {
    _doUpdate();
  }

  Future<int> _getLastUpdateInt() async {
    try {
      http.Response response =
          await client.get(_SERVER_ADDRESS + "/api/last-changes-timestamp");
      if (response.statusCode != 200) return 0;
      return int.parse(response.body);
    } catch (e) {
      return 0;
    }
  }

  Future _doUpdate() async {
    int updateStamp = await _getLastUpdateInt();
    int savedStamp = await StorageProvider().getSavedUiTimestamp();
    if (updateStamp > savedStamp) {
      List<EditableUIText> uiTexts = await _loadFirstPageTexts(updateStamp);
      List<EditableUIText> libraryText = await _loadLibraryText(updateStamp);
      if (libraryText != null) uiTexts.addAll(libraryText);
      if (uiTexts != null && uiTexts.length > 0) {
        await StorageProvider().saveUiText(uiTexts);
        print("texts SAVE SUCCESS");
      }

      List<EditableUIRequest> reflectionRequests =
          await _loadReflectionRequests(updateStamp);
      if (reflectionRequests != null && reflectionRequests.length > 0) {
        await StorageProvider().saveUiRequests(reflectionRequests);
        print("requests SAVE SUCCESS");
      }

      await StorageProvider().clearUiQuestions();

      List<EditableUIQuestion> reflectionQuestions =
          await _loadReflectionQuestions(updateStamp);
      if (reflectionQuestions != null && reflectionQuestions.length > 0) {
        await StorageProvider().saveUiQuestions(reflectionQuestions, true);
      }

      List<EditableUIQuestion> collectionQuestions =
          await _loadCollectionQuestions(updateStamp);
      if (collectionQuestions != null && collectionQuestions.length > 0) {
        await StorageProvider().saveUiQuestions(collectionQuestions, false);
      }

      await _saveTiming();
    }
  }

  Future<List<EditableUIText>> _loadFirstPageTexts(int timestamp) async {
    http.Response response =
        await client.get(_SERVER_ADDRESS + "/api/home-page");
    //  "general_heading": "1",
    //  "general_heading_text": "2",
    //  "button_1_heading": "3",
    //  "button_1_text": "4",
    //  "button_2_heading": "5",
    //  "button_2_text": "6"
    if (response.statusCode != 200) return new List();
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    List<EditableUIText> texts = new List();
    texts.add(new EditableUIText(EditableUIText.HOMEPAGE_ACTION_STATEMENT,
        jsonData["general_heading"], timestamp));
    texts.add(new EditableUIText(EditableUIText.HOMEPAGE_DESCRIPTOR,
        jsonData["general_heading_text"], timestamp));
    texts.add(new EditableUIText(EditableUIText.HOMEPAGE_ACTION1_TITLE,
        jsonData["button_1_heading"], timestamp));
    texts.add(new EditableUIText(EditableUIText.HOMEPAGE_ACTION1_SUBTITLE,
        jsonData["button_1_text"], timestamp));
    texts.add(new EditableUIText(EditableUIText.HOMEPAGE_ACTION2_TITLE,
        jsonData["button_2_heading"], timestamp));
    texts.add(new EditableUIText(EditableUIText.HOMEPAGE_ACTION2_SUBTITLE,
        jsonData["button_2_text"], timestamp));
    return texts;
  }

  Future<List<EditableUIText>> _loadLibraryText(int timestamp) async {
    http.Response response =
        await client.get(_SERVER_ADDRESS + "/api/main-texts");
    if (response.statusCode != 200) return null;

    List<EditableUIText> result = new List();
    List<dynamic> json = jsonDecode(response.body);
    for (var jsonData in json) {
      //{
      //    "question_number": 1,
      //    "question_text": "<p>test 1 edit</p>"
      //  },
      final String text = jsonData["question_text"];
      result.add(
          new EditableUIText(EditableUIText.LIBRARY_ACTION, text, timestamp));
    }
    return result;
  }

  Future<List<EditableUIRequest>> _loadReflectionRequests(int timestamp) async {
    http.Response response =
        await client.get(_SERVER_ADDRESS + "/api/conversations");
    if (response.statusCode != 200) return null;

    List<EditableUIRequest> texts = new List();
    List<dynamic> json = jsonDecode(response.body);
    for (var jsonData in json) {
      //{
      //    "id": 46,
      //    "stage": "B",
      //    "question": "SPRINGS TEST",
      //    "information": "test",
      //    "tab_number": 2,
      //    "tab_title": "B"
      //  }
      EditableUIRequest question = new EditableUIRequest(
          jsonData["tab_title"] + jsonData["stage"],
          jsonData["question"],
          jsonData["information"],
          timestamp);
      texts.add(question);
    }
    return texts;
  }

  Future<List<EditableUIQuestion>> _loadReflectionQuestions(
      int timestamp) async {
    http.Response response =
        await client.get(_SERVER_ADDRESS + "/api/reflects?is_questions=true");
    if (response.statusCode != 200) return null;

    List<EditableUIQuestion> texts = new List();
    List<dynamic> json = jsonDecode(response.body);
    print("response ${response.body}");
    for (var jsonData in json) {
      //{
      //    "id": 6,
      //    "title": "Narrate",
      //    "total_questions": 4,
      //    "questions": [
      //      {
      //        "id": 2,
      //        "tier": "R1",
      //        "question": "What stimulated you to write this particular conversation?",
      //        "information": "Welcome to Tier 1! At this stage you should feel supported, these questions are designed to introduce you to a set of tools that have the potential to improve your sense of self-reflection. This tool helps to bring clarity to your reflection. Using it can bring direction and order to what you have written and can highlight the way in which your writing is connected to your life."
      //      },
      //    ]
      //  },
      final String title = jsonData["title"];
      List<dynamic> questions = jsonData["questions"];
      for (Map jsonQuestion in questions) {
        int level = int.parse(jsonQuestion["stage"].toString().substring(1));
        EditableUIQuestion question = new EditableUIQuestion(
            jsonQuestion["id"],
            title,
            jsonQuestion["question"],
            jsonQuestion["information"],
            null,
            level);
        texts.add(question);
      }
    }
    return texts;
  }

  Future<List<EditableUIQuestion>> _loadCollectionQuestions(
      int timestamp) async {
    http.Response response = await client.get(_SERVER_ADDRESS + "/api/reviews");
    if (response.statusCode != 200) return null;

    List<EditableUIQuestion> texts = new List();
    List<dynamic> json = jsonDecode(response.body);
    for (var jsonData in json) {
      //{
      //    "tier": "C1",
      //    "question_number": 2,
      //    "title": "Emotions",
      //    "question": "What were you feeling when you wrote these conversations?",
      //    "information": "Identifying meanings in your reflections allows you to identify meaning in your life. Considering the meaning in the reflections helps you to see how situations, emotions, yourself and other people all contribute to your perception of something being meaningful in your life. Reviewing the emotional content of your reflections will help you uncover the meaning of the feelings that accompany situations and how your emotions, or attempts to cover your emotions, influence all the various situations in your life.",
      //    "subtitle": "Meaning - Stage 1"
      //  },
      int level = int.parse(jsonData["tier"].toString().substring(1));
      EditableUIQuestion question = new EditableUIQuestion(
          -jsonData["question_number"],
          jsonData["title"],
          jsonData["question"],
          jsonData["information"],
          jsonData["subtitle"],
          level);
      texts.add(question);
    }
    return texts;
  }

  Future _saveTiming() async {
    http.Response response = await client.get(_SERVER_ADDRESS + "/api/timing");
    if (response.statusCode != 200) return;

    int timeResult = int.parse(response.body);
    print("TIME FROM SERVER is $timeResult");
    await PreferencesProvider().saveQuestionRotationInterval(timeResult);
  }
}
