import 'package:hold/model/played_item.dart';

class ConversationContent {
  static const TABLE_NAME = "r_content";
  static const COLUMN_CARD_NUMBER = "card_num";
  static const COLUMN_ID = "id";
  static const COLUMN_TEXT = "text";
  static const COLUMNS = [
    COLUMN_ID,
    COLUMN_CARD_NUMBER,
    COLUMN_TEXT,
  ];

  static const CREATE_EXPRESSION = '''
            create table $TABLE_NAME ( 
              $COLUMN_ID integer primary key autoincrement, 
              $COLUMN_CARD_NUMBER integer not null,
              $COLUMN_TEXT text)
            ''';

  String text;
  int id;
  final int _cardNumber;

  ConversationContent(this._cardNumber, {this.text = ""}) : id = 0;

  ConversationContent.fromMap(Map<String, dynamic> map)
      : id = map[COLUMN_ID],
        _cardNumber = map[COLUMN_CARD_NUMBER],
        text = map[COLUMN_TEXT];

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_CARD_NUMBER: _cardNumber,
      COLUMN_TEXT: text,
    };
    if (id != 0) {
      map[COLUMN_ID] = id;
    }
    return map;
  }

  int get cardNumber => _cardNumber;

  PlayedItem getPlayedItem() {
    return PlayedItem(text,
        conversationCardId: cardNumber, inConversationContentId: id);
  }
}
