import 'package:hold/model/collection_full_view.dart';

class CollectionInStorage {
  static const TABLE_NAME = "collection";

  static const COLUMN_ID = "id";
  static const COLUMN_TITLE = "title";
  static const COLUMN_CREATED = "created";
  static const COLUMNS = [
    COLUMN_ID,
    COLUMN_TITLE,
    COLUMN_CREATED,
  ];

  static const CREATE_EXPRESSION = '''
            create table $TABLE_NAME ( 
              $COLUMN_ID integer primary key autoincrement, 
              $COLUMN_TITLE text not null,
              $COLUMN_CREATED integer not null)
            ''';

  final int id;
  final String title;
  final DateTime creationDate;

  CollectionInStorage.fromCollection(CollectionFullView fullView)
      : id = fullView.id,
        title = fullView.title,
        creationDate = fullView.created;

  CollectionInStorage.blank()
      : id = null,
        title = "",
        creationDate = DateTime.now();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_TITLE: title,
      COLUMN_CREATED: creationDate.millisecondsSinceEpoch
    };
    if (id != null) {
      map[COLUMN_ID] = id;
    }
    return map;
  }

  CollectionInStorage.fromMap(Map<String, dynamic> map)
      : id = map[COLUMN_ID],
        title = map[COLUMN_TITLE],
        creationDate = DateTime.fromMicrosecondsSinceEpoch(map[COLUMN_CREATED]);
}
