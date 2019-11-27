class EditableUIText {
  static const TABLE_NAME = "editable_ui";

  static const COLUMN_INNER_ID = "id";
  static const COLUMN_VISIBLE_ID = "v_id";
  static const COLUMN_TEXT = "downloaded_text";
  static const COLUMN_LAST_UPDATE = "last_update";
  static const COLUMNS = [
    COLUMN_VISIBLE_ID,
    COLUMN_TEXT,
    COLUMN_LAST_UPDATE,
  ];

  static const CREATE_EXPRESSION = '''
            create table $TABLE_NAME ( 
              $COLUMN_INNER_ID integer primary key autoincrement, 
              $COLUMN_VISIBLE_ID integer,
              $COLUMN_TEXT text not null,
              $COLUMN_LAST_UPDATE integer)
            ''';

  final int uiID;
  final String text;
  final int lastUpdateTimestamp;

  const EditableUIText(this.uiID, this.text, this.lastUpdateTimestamp);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_VISIBLE_ID: uiID,
      COLUMN_TEXT: text,
      COLUMN_LAST_UPDATE: lastUpdateTimestamp,
    };
    return map;
  }

  EditableUIText.fromMap(Map<String, dynamic> map)
      : uiID = map[COLUMN_VISIBLE_ID],
        text = map[COLUMN_TEXT],
        lastUpdateTimestamp = map[COLUMN_LAST_UPDATE];

  static const HOMEPAGE_ACTION_STATEMENT = 1;
  static const HOMEPAGE_DESCRIPTOR = 2;
  static const HOMEPAGE_ACTION1_TITLE = 3;
  static const HOMEPAGE_ACTION1_SUBTITLE = 4;
  static const HOMEPAGE_ACTION2_TITLE = 5;
  static const HOMEPAGE_ACTION2_SUBTITLE = 6;
  static const LIBRARY_ACTION = 7;

  static const Map<int, EditableUIText> predefined = {
    HOMEPAGE_ACTION_STATEMENT:
        EditableUIText(HOMEPAGE_ACTION_STATEMENT, "Chat with yourself", 0),
    HOMEPAGE_DESCRIPTOR: EditableUIText(
        HOMEPAGE_DESCRIPTOR,
        "Take hold of your thoughts by having a conversation with "
        "yourself, choose how you would like to start:",
        0),
    HOMEPAGE_ACTION1_TITLE:
        EditableUIText(HOMEPAGE_ACTION1_TITLE, "EXPRESS", 0),
    HOMEPAGE_ACTION1_SUBTITLE:
        EditableUIText(HOMEPAGE_ACTION1_SUBTITLE, "Say what's on your mind", 0),
    HOMEPAGE_ACTION2_TITLE:
        EditableUIText(HOMEPAGE_ACTION2_TITLE, "QUESTION", 0),
    HOMEPAGE_ACTION2_SUBTITLE: EditableUIText(
        HOMEPAGE_ACTION2_SUBTITLE, "Create a question for yourself", 0),
    LIBRARY_ACTION: EditableUIText(
        LIBRARY_ACTION,
        "Can you choose conversations based on the same topic to create a collection?",
        0),
  };
}
