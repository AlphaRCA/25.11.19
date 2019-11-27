import 'package:hold/storage/editable_ui_question.dart';

class EditableUIRequest {
  static const TABLE_NAME = "request";

  static const COLUMN_ID = "uid";
  static const COLUMN_TEXT = "downloaded_text";
  static const COLUMN_INFO = "info";
  static const COLUMN_LAST_UPDATE = "last_update";
  static const COLUMNS = [
    COLUMN_ID,
    COLUMN_TEXT,
    COLUMN_INFO,
    COLUMN_LAST_UPDATE,
  ];

  static const CREATE_EXPRESSION = '''
            create table $TABLE_NAME ( 
              id integer primary key autoincrement, 
              $COLUMN_ID text not null,
              $COLUMN_TEXT text not null,
              $COLUMN_INFO text,
              $COLUMN_LAST_UPDATE integer)
            ''';

  final String uiID;
  final String text;
  final String info;
  final int lastUpdateTimestamp;

  const EditableUIRequest(
      this.uiID, this.text, this.info, this.lastUpdateTimestamp);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_ID: uiID,
      COLUMN_TEXT: text,
      COLUMN_INFO: info,
      COLUMN_LAST_UPDATE: lastUpdateTimestamp,
    };
    return map;
  }

  EditableUIRequest.fromMap(Map<String, dynamic> map)
      : uiID = map[COLUMN_ID],
        text = map[COLUMN_TEXT],
        info = map[COLUMN_INFO],
        lastUpdateTimestamp = map[COLUMN_LAST_UPDATE];

  static const Map<String, EditableUIRequest> predefined = {
    "AA": EditableUIRequest(
        "AA",
        "What would you like to ask yourself?",
        "When you ask yourself a question you are privately reflecting on what it is you would like to talk about. It is an effective way of getting to the core of what is on your mind and empowering yourself to openly think/talk about you and your life. This is an opportunity to ask yourself anything you wish – you are giving yourself the freedom to express yourself, the freedom to think and talk about yourself and your life.",
        0),
    "AB": EditableUIRequest(
        "AB",
        "Answer your question",
        "This is your space to answer the question you have asked yourself. Listen to what the question is asking you and consider the way the question makes you feel – enjoy making your answer as descriptive and complete as possible.",
        0),
    "AC": EditableUIRequest(
        "AC",
        "Expand your conversation – ask yourself a question about the emotions in this situation",
        "This new question should help you expand what it is you are already talking about. Through focusing on a detail of the conversation you are having with yourself; you will consider the topic/theme in your life in more detail. Expanding your question through focusing on your emotions will allow you to ask a question that encourages you to express your feelings more fully",
        0),
    "AD": EditableUIRequest(
        "AD",
        "At this point in the conversation, considering all that you have said - what would you like to ask yourself now?",
        "This is your space to consider all that you have said so far in this conversation. Consider what you have recorded and now step out again and ask yourself a new question. This is an opportunity to ask yourself anything you wish – you are giving yourself the freedom to express yourself, the freedom to think and talk about yourself and your life.",
        0),
    "AE": EditableUIRequest(
        "AE",
        "Write what you are thinking about at this exact moment",
        "This is your space to release what is getting cramped in your mind and to let your flow of thoughts spread out. Allow yourself to record whatever thoughts come to mind.",
        0),
    "AF": EditableUIRequest(
        "AF",
        "Build on what you have said – ask yourself a question that encourages you to express your emotions fully",
        "This question should help you elaborate on what it is you are already talking about. Through developing and describing a detail of the conversation you are having with yourself; you will consider the topic/theme in your life in more detail. Evolving your conversation through focusing on your emotions will allow you to ask a question that encourages you to express your feelings more fully.",
        0),
    "BA": EditableUIRequest(
        "BA",
        "What would you like to ask yourself?",
        "When you ask yourself a question you are privately reflecting on what it is you would like to talk about. It is an effective way of getting to the core of what is on your mind and empowering yourself to openly think/talk about you and your life. This is an opportunity to ask yourself anything you wish – you are giving yourself the freedom to express yourself, the freedom to think and talk about yourself and your life.",
        0),
    "BB": EditableUIRequest(
        "BB",
        "Answer your question",
        "This is your space to answer the question you have asked yourself. Listen to what the question is asking you and consider the way the question makes you feel – enjoy making your answer as descriptive and complete as possible.",
        0),
    "BC": EditableUIRequest(
        "BC",
        "Expand your conversation – ask yourself a question about the emotions in this situation",
        "This new question should help you expand what it is you are already talking about. Through focusing on a detail of the conversation you are having with yourself; you will consider the topic/theme in your life in more detail. Expanding your question through focusing on your emotions will allow you to ask a question that encourages you to express your feelings more fully",
        0),
    "BD": EditableUIRequest(
        "BD",
        "At this point in the conversation, considering all that you have said - what would you like to ask yourself now?",
        "This is your space to consider all that you have said so far in this conversation. Consider what you have recorded and now step out again and ask yourself a new question. This is an opportunity to ask yourself anything you wish – you are giving yourself the freedom to express yourself, the freedom to think and talk about yourself and your life.",
        0),
    "BE": EditableUIRequest(
        "BE",
        "Write what you are thinking about at this exact moment",
        "This is your space to release what is getting cramped in your mind and to let your flow of thoughts spread out. Allow yourself to record whatever thoughts come to mind.",
        0),
    "BF": EditableUIRequest(
        "BF",
        "Build on what you have said – ask yourself a question that encourages you to express your emotions fully",
        "This question should help you elaborate on what it is you are already talking about. Through developing and describing a detail of the conversation you are having with yourself; you will consider the topic/theme in your life in more detail. Evolving your conversation through focusing on your emotions will allow you to ask a question that encourages you to express your feelings more fully.",
        0),
  };

  EditableUIQuestion toQuestion() {
    return EditableUIQuestion(1, "", text, info, "", 1);
  }
}
