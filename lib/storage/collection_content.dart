class CollectionContent {
  static const TABLE_NAME = "collection_content";

  static const COLUMN_ID = "id";
  static const COLUMN_COLLECTION_ID = "collection_id";
  static const COLUMN_CONVERSATION_ID = "reflection_id";
  static const COLUMN_REFLECTION_ID = "additional_id";
  static const COLUMNS = [
    COLUMN_ID,
    COLUMN_COLLECTION_ID,
    COLUMN_CONVERSATION_ID,
    COLUMN_REFLECTION_ID
  ];

  static const CREATE_EXPRESSION = '''
            create table $TABLE_NAME ( 
              $COLUMN_ID integer primary key autoincrement, 
              $COLUMN_COLLECTION_ID integer not null,
              $COLUMN_CONVERSATION_ID integer,
              $COLUMN_REFLECTION_ID integer)
            ''';

  final int id;
  final int collectionId;
  final int reflectionId;
  final int additionalReflectionId;

  CollectionContent(this.id, this.collectionId, this.reflectionId,
      this.additionalReflectionId);

  CollectionContent.fromReflection(this.collectionId, this.reflectionId)
      : additionalReflectionId = null,
        id = null;

  CollectionContent.fromAdditional(
      this.collectionId, this.additionalReflectionId)
      : reflectionId = null,
        id = null;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_COLLECTION_ID: collectionId,
      COLUMN_CONVERSATION_ID: reflectionId,
      COLUMN_REFLECTION_ID: additionalReflectionId,
    };
    return map;
  }

  CollectionContent.fromMap(Map<String, dynamic> map)
      : id = map[COLUMN_ID],
        collectionId = map[COLUMN_COLLECTION_ID],
        reflectionId = map[COLUMN_CONVERSATION_ID],
        additionalReflectionId = map[COLUMN_REFLECTION_ID];
}
