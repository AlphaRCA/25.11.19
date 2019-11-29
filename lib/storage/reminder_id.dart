class ReminderId {
  int id;
  final int reminderId;
  final bool isRepeating;
  final DateTime flushTime;
  final String title;
  final int payload;

  static const TABLE_NAME = "reminder_id";
  static const COLUMN_ID = "id";
  static const COLUMN_REMINDER_ID = "reminder_id";
  static const COLUMN_REPEATING = "is_repeating";
  static const COLUMN_FLUSH = "flush_datetime";
  static const COLUMN_TITLE = "title";
  static const COLUMN_PAYLOAD = "payload";
  static const COLUMNS = [
    COLUMN_ID,
    COLUMN_REMINDER_ID,
    COLUMN_TITLE,
    COLUMN_REPEATING,
    COLUMN_PAYLOAD,
    COLUMN_FLUSH
  ];

  ReminderId(this.reminderId, this.title, this.isRepeating, this.flushTime,
      this.payload);

  static const CREATE_EXPRESSION = '''
            create table $TABLE_NAME ( 
              $COLUMN_ID integer primary key autoincrement, 
              $COLUMN_REMINDER_ID int,
              $COLUMN_TITLE text,
              $COLUMN_REPEATING int not null,
              $COLUMN_PAYLOAD text,
              $COLUMN_FLUSH int)
            ''';

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_REMINDER_ID: reminderId,
      COLUMN_TITLE: title,
      COLUMN_REPEATING: isRepeating ? 1 : 0,
      COLUMN_PAYLOAD: payload.toString(),
      COLUMN_FLUSH: flushTime.millisecondsSinceEpoch
    };
    if (id != null) {
      map[COLUMN_ID] = id;
    }
    return map;
  }

  ReminderId.fromMap(Map<String, dynamic> map)
      : id = map[COLUMN_ID],
        reminderId = map[COLUMN_REMINDER_ID],
        title = map[COLUMN_TITLE],
        isRepeating = map[COLUMN_REPEATING] > 0,
        payload = int.parse(map[COLUMN_PAYLOAD]),
        flushTime = DateTime.fromMillisecondsSinceEpoch(map[COLUMN_FLUSH]);

  @override
  String toString() {
    return 'ReminderId{id: $id, reminderId: $reminderId, isRepeating: $isRepeating, flushTime: $flushTime, title: $title, payload: $payload}';
  }


}
