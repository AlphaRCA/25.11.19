import 'package:hold/model/conversation.dart';

import 'conversation_content.dart';

class ConversationInStorage {
  static const TABLE_NAME = "reflection_main";

  static const COLUMN_CARD_NUMBER = "card_num";
  static const COLUMN_CREATED = "created";
  static const COLUMN_TITLE = "title";
  static const COLUMN_FIRST_TEXT = "first_text";
  static const COLUMN_POSITIVE = "positive_mark";
  static const COLUMN_TYPE = "reflection_type";
  static const COLUMNS = [
    COLUMN_CARD_NUMBER,
    COLUMN_CREATED,
    COLUMN_TITLE,
    COLUMN_FIRST_TEXT,
    COLUMN_POSITIVE,
    COLUMN_TYPE,
  ];

  static const CREATE_EXPRESSION = '''
            create table $TABLE_NAME ( 
              $COLUMN_CARD_NUMBER integer primary key autoincrement, 
              $COLUMN_CREATED integer not null,
              $COLUMN_TITLE text,
              $COLUMN_FIRST_TEXT text, 
              $COLUMN_TYPE integer not null,
              $COLUMN_POSITIVE integer)
            ''';

  final int cardNumber;
  final DateTime _created;
  final ReflectionType type;
  String title = "";
  String firstText = "";
  int positiveMood;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_CREATED: _created.millisecondsSinceEpoch,
      COLUMN_TITLE: title,
      COLUMN_FIRST_TEXT: firstText,
      COLUMN_POSITIVE: positiveMood,
      COLUMN_TYPE: type == ReflectionType.A ? 1 : 0,
    };
    if (cardNumber != 0) {
      map[COLUMN_CARD_NUMBER] = cardNumber;
    }
    return map;
  }

  ConversationInStorage.blank(this.type)
      : cardNumber = 0,
        this._created = DateTime.now();

  ConversationInStorage.fromMap(Map<String, dynamic> map)
      : cardNumber = map[COLUMN_CARD_NUMBER],
        _created = DateTime.fromMillisecondsSinceEpoch(map[COLUMN_CREATED]),
        title = map[COLUMN_TITLE],
        firstText = map[COLUMN_FIRST_TEXT],
        type = map[COLUMN_TYPE] == 1 ? ReflectionType.A : ReflectionType.B,
        positiveMood = map[COLUMN_POSITIVE];

  Conversation formFinalReflection(List<ConversationContent> content) {
    Conversation result = new Conversation(cardNumber, type, created: _created);
    result.title = title;
    result.content = content;
    result.positiveMood = positiveMood;
    return result;
  }

  ConversationInStorage.formConversation(Conversation reflection)
      : cardNumber = reflection.cardNumber,
        _created = reflection.created,
        type = reflection.type,
        title = reflection.title,
        firstText =
            reflection.content.length > 0 ? reflection.content[0].text : "",
        positiveMood = reflection.positiveMood;

  DateTime get created => _created;
}
