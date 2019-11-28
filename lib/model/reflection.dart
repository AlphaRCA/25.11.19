import 'package:hold/model/played_item.dart';

class Reflection {
  static const TABLE_NAME = "reflection_additional";

  static const COLUMN_ID = "id";
  static const COLUMN_CARD_NUMBER = "card_num";
  static const COLUMN_CREATED = "created";
  static const COLUMN_QUESTION = "question";
  static const COLUMN_QUESTION_LEVEL = "level";
  static const COLUMN_RESPONSE = "response";
  static const COLUMN_QUESTION_ID = "question_id";
  static const COLUMNS = [
    COLUMN_ID,
    COLUMN_CARD_NUMBER,
    COLUMN_CREATED,
    COLUMN_QUESTION,
    COLUMN_QUESTION_ID,
    COLUMN_QUESTION_LEVEL,
    COLUMN_RESPONSE,
  ];

  static const CREATE_EXPRESSION = '''
            create table $TABLE_NAME ( 
              $COLUMN_ID integer primary key autoincrement, 
              $COLUMN_CARD_NUMBER integer not null,
              $COLUMN_QUESTION_ID integer,
              $COLUMN_CREATED int not null,
              $COLUMN_QUESTION text,
              $COLUMN_QUESTION_LEVEL integer,
              $COLUMN_RESPONSE text)
            ''';

  int id;
  final int cardNumber;
  final int questionId;
  final int level;
  final String title;
  String myText;
  final DateTime created;

  Reflection(this.cardNumber, this.title, this.level, this.questionId)
      : this.created = DateTime.now();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_CARD_NUMBER: cardNumber,
      COLUMN_CREATED: created.millisecondsSinceEpoch,
      COLUMN_QUESTION: title,
      COLUMN_QUESTION_LEVEL: level,
      COLUMN_QUESTION_ID: questionId,
      COLUMN_RESPONSE: myText,
    };
    if (id != null) {
      map[COLUMN_ID] = id;
    }
    return map;
  }

  Reflection.fromMap(Map<String, dynamic> map)
      : id = map[COLUMN_ID],
        cardNumber = map[COLUMN_CARD_NUMBER],
        questionId = map[COLUMN_QUESTION_ID],
        created = DateTime.fromMillisecondsSinceEpoch(map[COLUMN_CREATED]),
        title = map[COLUMN_QUESTION],
        level = map[COLUMN_QUESTION_LEVEL],
        myText = map[COLUMN_RESPONSE];

  Reflection.forCollection(this.title, this.level, this.questionId)
      : cardNumber = 0,
        created = DateTime.now();

  bool hasTitle() {
    return title != null && title.isNotEmpty;
  }

  bool hasText() {
    return myText != null && myText.isNotEmpty;
  }

  PlayedItem toPlayedText() {
    return new PlayedItem(myText,
        conversationCardId: cardNumber, reflectionId: id, title: title);
  }

  @override
  String toString() {
    return 'Reflection{id: $id, cardNumber: $cardNumber, questionId: $questionId, level: $level, title: $title, myText: $myText, created: $created}';
  }


}
