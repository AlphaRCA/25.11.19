import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/model/collection_full_view.dart';
import 'package:hold/model/collection_short_data.dart';
import 'package:hold/model/conversation.dart';
import 'package:hold/model/conversation_for_review.dart';
import 'package:hold/model/conversation_widget_content.dart';
import 'package:hold/model/reflection.dart';
import 'package:hold/model/reminder.dart';
import 'package:hold/storage/collection_content.dart';
import 'package:hold/storage/collection_in_storage.dart';
import 'package:hold/storage/conversation_content.dart';
import 'package:hold/storage/conversation_in_storage.dart';
import 'package:hold/storage/editable_ui_question.dart';
import 'package:hold/storage/editable_ui_request.dart';
import 'package:hold/storage/editable_ui_text.dart';
import 'package:hold/storage/graph_value.dart';
import 'package:hold/storage/reminder_id.dart';
import 'package:hold/widget/dialogs/toast_tier_unlocked.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class StorageProvider {
  static const INCOMPLETE_ID = -2;
  static const MOST_REFLECTED_ID = -1;
  static const POSITIVE_ID = -3;
  static const OLD_6_ID = -4;
  static const _EXPORT_DIVIDER = "-----";

  Database db;
  Future _initialized;

  Future get initializationDone => _initialized;

  static StorageProvider _instance;

  factory StorageProvider({String dbFilePath}) {
    if (_instance == null) {
      _instance = new StorageProvider._internal(dbFilePath);
    }
    return _instance;
  }

  StorageProvider._internal(String dbFilePath) {
    _initialized = _openDbFile(dbFilePath);
  }

  Future _openDbFile(String dbPath) async {
    print("filepath is $dbPath");
    if (dbPath == null) {
      var databasesPath = await getDatabasesPath();
      dbPath = join(databasesPath, "db");
      // Make sure the directory exists
      try {
        await Directory(databasesPath).create(recursive: true);
      } catch (_) {}
    }

    db = await openDatabase(dbPath,
        version: 6, onCreate: _onDbCreate, onUpgrade: _onDbUpgrade);
  }

  Future<int> insertConversation(ReflectionType type) async {
    await _initialized;
    ConversationInStorage mainData = ConversationInStorage.blank(type);
    return await db.insert(ConversationInStorage.TABLE_NAME, mainData.toMap());
  }

  Future updateConversation(final Conversation conversation,
      {Database availableDb}) async {
    ConversationInStorage storedReflection =
        ConversationInStorage.formConversation(conversation);
    if (conversation.content.length > 0) {
      storedReflection.firstText = conversation.content.first.text;
    }
    Database database = availableDb ?? db;
    await database.update(
        ConversationInStorage.TABLE_NAME, storedReflection.toMap(),
        where: "${ConversationInStorage.COLUMN_CARD_NUMBER} = ?",
        whereArgs: [conversation.cardNumber]);
  }

  Future<int> insertReflectionForConversation(
      final Reflection reflection) async {
    await _initialized;
    int id = await db.insert(Reflection.TABLE_NAME, reflection.toMap());
    if (reflection.level < 4 &&
        await PreferencesProvider().getHighestConversationReflectionLevel() ==
            reflection.level) {
      await _checkLevel(reflection.level + 1, 1);
    }
    return id;
  }

  Future clearMyData() async {
    await db.delete(ConversationInStorage.TABLE_NAME);
    await db.delete(ConversationContent.TABLE_NAME);
    await db.delete(Reflection.TABLE_NAME);
    await db.delete(CollectionInStorage.TABLE_NAME);
    await db.delete(CollectionContent.TABLE_NAME);
    await db.delete(Reminder.TABLE_NAME);
  }

  Future<String> exportToFile() async {
    String result = await _exportConversations();
    result += _EXPORT_DIVIDER;
    result += await _exportConversationContent();
    result += _EXPORT_DIVIDER;
    result += await _exportAdditionalReflections();
    result += _EXPORT_DIVIDER;
    result += await _exportActualReminders();
    result += _EXPORT_DIVIDER;
    result += await _exportCollections();
    result += _EXPORT_DIVIDER;
    result += await _exportCollectionContent();
    return result;
  }

  Future<String> _exportConversations() async {
    List<Map<String, dynamic>> reflectionsJson = await db.query(
        ConversationInStorage.TABLE_NAME,
        columns: ConversationInStorage.COLUMNS);
    return jsonEncode(reflectionsJson);
  }

  Future<String> _exportConversationContent() async {
    List<Map<String, dynamic>> reflectionsJson = await db.query(
        ConversationContent.TABLE_NAME,
        columns: ConversationContent.COLUMNS);
    return jsonEncode(reflectionsJson);
  }

  Future<String> _exportAdditionalReflections() async {
    List<Map<String, dynamic>> list =
        await db.query(Reflection.TABLE_NAME, columns: Reflection.COLUMNS);
    return jsonEncode(list);
  }

  Future<String> _exportActualReminders() async {
    List<Map<String, dynamic>> list =
        await db.query(Reminder.TABLE_NAME, columns: Reminder.COLUMNS);
    return jsonEncode(list);
  }

  Future<String> _exportCollections() async {
    List<Map<String, dynamic>> list = await db.query(
        CollectionInStorage.TABLE_NAME,
        columns: CollectionInStorage.COLUMNS);
    return jsonEncode(list);
  }

  Future<String> _exportCollectionContent() async {
    List<Map<String, dynamic>> list = await db.query(
        CollectionContent.TABLE_NAME,
        columns: CollectionContent.COLUMNS);
    return jsonEncode(list);
  }

  Future<String> importFromFile(String fileContent) async {
    // returns error description if data exist inside database, otherwise ""
    List<String> parts = fileContent.split(_EXPORT_DIVIDER);
    if (parts.length < 5) return "file format is incorrect";

    List<dynamic> parsedJsonConversations = json.decode(parts[0]);
    if (parsedJsonConversations != null && parsedJsonConversations.length > 0) {
      List<ConversationInStorage> reflections = parsedJsonConversations
          .map((item) => new ConversationInStorage.fromMap(item))
          .toList();
      for (ConversationInStorage reflection in reflections) {
        if (reflection == null) continue; //there is an error
        await db.insert(ConversationInStorage.TABLE_NAME, reflection.toMap());
      }
    }

    List<dynamic> parsedJsonConversationContent = json.decode(parts[1]);
    if (parsedJsonConversationContent != null &&
        parsedJsonConversationContent.length > 0) {
      List<ConversationContent> reflections = parsedJsonConversationContent
          .map((item) => new ConversationContent.fromMap(item))
          .toList();
      for (ConversationContent reflection in reflections) {
        if (reflection == null) continue; //there is an error
        await db.insert(ConversationContent.TABLE_NAME, reflection.toMap());
      }
    }

    List<dynamic> parsedJsonAdditionals = json.decode(parts[2]);
    if (parsedJsonAdditionals != null && parsedJsonAdditionals.length > 0) {
      List<Reflection> additionalReflections = parsedJsonAdditionals
          .map((item) => new Reflection.fromMap(item))
          .toList();
      for (Reflection additional in additionalReflections) {
        if (additional == null) continue; //there is an error
        await db.insert(Reflection.TABLE_NAME, additional.toMap());
      }
    }

    List<dynamic> parsedJsonReminders = json.decode(parts[3]);
    if (parsedJsonReminders != null && parsedJsonReminders.length > 0) {
      List<Reminder> reminders = parsedJsonReminders
          .map((item) => new Reminder.fromMap(item, ""))
          .toList();
      for (Reminder reminder in reminders) {
        if (reminder == null) continue; //there is an error
        await db.insert(Reminder.TABLE_NAME, reminder.toMap());
      }
    }

    List<dynamic> parsedJsonCollections = json.decode(parts[4]);
    if (parsedJsonCollections != null && parsedJsonCollections.length > 0) {
      List<CollectionInStorage> collections = parsedJsonCollections
          .map((item) => new CollectionInStorage.fromMap(item))
          .toList();
      for (CollectionInStorage collection in collections) {
        if (collection == null) continue; //there is an error
        await db.insert(CollectionInStorage.TABLE_NAME, collection.toMap());
      }
    }

    List<dynamic> parsedJsonCollectionContent = json.decode(parts[5]);
    if (parsedJsonCollectionContent != null &&
        parsedJsonCollectionContent.length > 0) {
      List<CollectionContent> content = parsedJsonCollectionContent
          .map((item) => new CollectionContent.fromMap(item))
          .toList();
      for (CollectionContent singleContent in content) {
        if (singleContent == null) continue; //there is an error
        await db.insert(CollectionContent.TABLE_NAME, singleContent.toMap());
      }
    }
    return "";
  }

  Future<List<ConversationWidgetContent>> getReflectionList() async {
    await _initialized;
    List<ConversationWidgetContent> list = new List();
    List<Map> maps = await db.query(ConversationInStorage.TABLE_NAME,
        columns: ConversationInStorage.COLUMNS,
        orderBy:
            "${ConversationInStorage.COLUMN_CARD_NUMBER} DESC"); //TODO add limit
    if (maps.length > 0) {
      for (Map map in maps) {
        ConversationWidgetContent widgetData =
            ConversationWidgetContent.fromStorage(
                ConversationInStorage.fromMap(map));
        list.add(widgetData);
      }
    }
    return list;
  }

  Future<ConversationForReview> getConversationByCardNumber(
      int cardNumber) async {
    List<Map> maps = await db.query(
      ConversationInStorage.TABLE_NAME,
      columns: ConversationInStorage.COLUMNS,
      where: ConversationInStorage.COLUMN_CARD_NUMBER + " = ?",
      whereArgs: [cardNumber],
      orderBy: ConversationInStorage.COLUMN_CARD_NUMBER + " DESC",
    );
    if (maps == null || maps.length == 0) {
      print("WARNING! No data in database");
      return null;
    }
    ConversationInStorage storedConversation =
        ConversationInStorage.fromMap(maps[0]);

    List<Map> mapContent = await db.query(
      ConversationContent.TABLE_NAME,
      columns: ConversationContent.COLUMNS,
      where: ConversationContent.COLUMN_CARD_NUMBER + " = $cardNumber",
      orderBy: ConversationContent.COLUMN_ID + " ASC",
    );
    List<ConversationContent> innerContent = new List();
    for (Map map in mapContent) {
      innerContent.add(ConversationContent.fromMap(map));
    }

    Conversation mainReflectionData =
        storedConversation.formFinalReflection(innerContent);

    List<Map> mapAdditionals = await db.query(
      Reflection.TABLE_NAME,
      columns: Reflection.COLUMNS,
      where: Reflection.COLUMN_CARD_NUMBER + " = $cardNumber",
      orderBy: Reflection.COLUMN_CREATED + " ASC",
    );

    List<Reflection> additionals = new List();
    if (mapAdditionals != null && mapAdditionals.length > 0) {
      for (Map map in mapAdditionals) {
        Reflection additionalData = Reflection.fromMap(map);
        additionals.add(additionalData);
      }
    }

    ConversationForReview data =
        new ConversationForReview(mainReflectionData, additionals);
    return data;
  }

  Future<List<ConversationWidgetContent>> getSearchedReflections(
      String search) async {
    Map<int, ConversationWidgetContent> searchResult =
        await _searchOnTitle(search);
    if (searchResult.length > 30) return searchResult.values.toList();

    searchResult
        .addAll(await _searchOnConversationContent(search, searchResult.keys));
    if (searchResult.length > 30) return searchResult.values.toList();

    searchResult.addAll(await _searchOnAdditional(search, searchResult.keys));
    return searchResult.values.toList();
  }

  Future<List<GraphValue>> getPositiveGraphValues() async {
    List<GraphValue> list = new List();
    List<Map> maps = await db.rawQuery(
        "SELECT ${ConversationInStorage.COLUMN_CARD_NUMBER}, "
        "${ConversationInStorage.COLUMN_POSITIVE} FROM ${ConversationInStorage.TABLE_NAME} ORDER BY "
        "${ConversationInStorage.COLUMN_CARD_NUMBER} DESC");
    for (Map map in maps) {
      list.add(GraphValue.fromMap(map));
    }
    return list;
  }

  Future<String> getTitle(int cardNumber) async {
    List<Map> maps = await db.query(ConversationInStorage.TABLE_NAME,
        columns: [ConversationInStorage.COLUMN_TITLE],
        where: ConversationInStorage.COLUMN_CARD_NUMBER + " = $cardNumber",
        orderBy: ConversationInStorage.COLUMN_CARD_NUMBER + " DESC",
        limit: 1);
    if (maps.length > 0)
      return maps[0][ConversationInStorage.COLUMN_TITLE];
    else
      return "";
  }

  Future deleteConversation(int cardNumber) async {
    await db.delete(Reflection.TABLE_NAME,
        where: Reflection.COLUMN_CARD_NUMBER + "=$cardNumber");
    await db.delete(CollectionContent.TABLE_NAME,
        where: CollectionContent.COLUMN_CONVERSATION_ID + "=$cardNumber");
    await db.delete(ConversationInStorage.TABLE_NAME,
        where: ConversationInStorage.COLUMN_CARD_NUMBER + "=$cardNumber");
    await db.delete(ConversationContent.TABLE_NAME,
        where: ConversationContent.COLUMN_CARD_NUMBER + "=$cardNumber");
  }

  Future updateConversationName(String newName, int cardNumber) async {
    await db.update(ConversationInStorage.TABLE_NAME,
        {ConversationInStorage.COLUMN_TITLE: newName},
        where: ConversationInStorage.COLUMN_CARD_NUMBER + "=?",
        whereArgs: [cardNumber]);
  }

  Future<int> createCollection() {
    return db.insert(
        CollectionInStorage.TABLE_NAME, CollectionInStorage.blank().toMap());
  }

  Future giveNameToCollection(int id, String name) {
    return db.update(CollectionInStorage.TABLE_NAME,
        {CollectionInStorage.COLUMN_TITLE: name},
        where: CollectionInStorage.COLUMN_ID + "=?", whereArgs: [id]);
  }

  Future addConversationToCollection(int collectionId, int conversationId) {
    CollectionContent content =
        new CollectionContent.fromReflection(collectionId, conversationId);
    return db.insert(CollectionContent.TABLE_NAME, content.toMap());
  }

  Future addAdditionalReflectionToCollection(
      int collectionId, Reflection unsavedAdditionalReflection) async {
    int additionalReflectionId =
        await insertReflectionForConversation(unsavedAdditionalReflection);
    CollectionContent content = new CollectionContent.fromAdditional(
        collectionId, additionalReflectionId);
    await db.insert(CollectionContent.TABLE_NAME, content.toMap());
    if (unsavedAdditionalReflection.level < 4 &&
        await PreferencesProvider().getHighestCollectionReflectionLevel() ==
            unsavedAdditionalReflection.level) {
      await _checkLevel(unsavedAdditionalReflection.level + 1, 0);
    }
  }

  Future<CollectionShortData> getAutoMostReflectedOn() async {
    //SELECT card_num FROM additional_reflection GROUP BY card_num HAVING COUNT(card_num)>= 3
    List<Map> maps =
        await db.rawQuery("SELECT ${Reflection.COLUMN_CARD_NUMBER} "
            "FROM ${Reflection.TABLE_NAME} "
            "GROUP BY ${Reflection.COLUMN_CARD_NUMBER} "
            "HAVING COUNT(${Reflection.COLUMN_CARD_NUMBER}) >=3 ");
    CollectionShortData mostReflected =
        new CollectionShortData(MOST_REFLECTED_ID, true);
    mostReflected.collectionName = "Most reflected on";
    mostReflected.conversationNumber = maps.length;
    for (Map map in maps) {
      if (map[Reflection.COLUMN_CARD_NUMBER] == 0) {
        mostReflected.conversationNumber -= 1;
        break;
      }
    }
    return mostReflected;
  }

  Future<CollectionFullView> _getFullAutoMostReflectedOn() async {
    CollectionFullView collection =
        new CollectionFullView(MOST_REFLECTED_ID, true, DateTime.now());
    collection.title = "Most reflected on";
    List<Map> mapsOfIds =
        await db.rawQuery("SELECT ${Reflection.COLUMN_CARD_NUMBER} "
            "FROM ${Reflection.TABLE_NAME} "
            "GROUP BY ${Reflection.COLUMN_CARD_NUMBER} "
            "HAVING COUNT(${Reflection.COLUMN_CARD_NUMBER}) >=3");
    return await _formCollection(collection, mapsOfIds);
  }

  Future<CollectionFullView> _formCollection(
      CollectionFullView collection, List<Map> mapsOfIds) async {
    List<int> conversationIdsInside = new List();
    for (Map map in mapsOfIds) {
      conversationIdsInside.add(map[Reflection.COLUMN_CARD_NUMBER]);
    }

    String limitations = _getExcludedString(conversationIdsInside);
    List<Map> conversationMaps = await db.query(
        ConversationInStorage.TABLE_NAME,
        columns: ConversationInStorage.COLUMNS,
        where: "${ConversationInStorage.COLUMN_CARD_NUMBER} IN ($limitations)",
        orderBy: "${ConversationInStorage.COLUMN_CREATED} ASC");
    List<ConversationInStorage> conversationsInside = new List();
    for (Map reflectionMap in conversationMaps) {
      ConversationInStorage reflection =
          ConversationInStorage.fromMap(reflectionMap);
      conversationsInside.add(reflection);
    }

    List<Map> reflectionMaps = await db.query(Reflection.TABLE_NAME,
        columns: Reflection.COLUMNS,
        where:
            "${Reflection.COLUMN_CARD_NUMBER} = 0 AND ${Reflection.COLUMN_ID} IN "
            "(SELECT ${CollectionContent.COLUMN_REFLECTION_ID} "
            "FROM ${CollectionContent.TABLE_NAME} "
            "WHERE ${CollectionContent.COLUMN_COLLECTION_ID} = $MOST_REFLECTED_ID)",
        orderBy: "${Reflection.COLUMN_CREATED} ASC");
    List<Reflection> reflectionsInside = new List();
    for (Map additionalMap in reflectionMaps) {
      Reflection additionalReflection = Reflection.fromMap(additionalMap);
      reflectionsInside.add(additionalReflection);
    }

    collection.shortContent = new List();
    if (conversationsInside.length > 0) {
      if (reflectionsInside.length == 0) {
        collection.shortContent.addAll(conversationsInside);
      } else {
        int reflectionIterator = 0;
        for (int i = 0; i < conversationsInside.length; i++) {
          for (int j = reflectionIterator; j < reflectionsInside.length; j++) {
            if (reflectionsInside[j]
                .created
                .isBefore(conversationsInside[i].created)) {
              collection.shortContent.add(reflectionsInside[j]);
            } else {
              reflectionIterator = j;
              break;
            }
          }
          collection.shortContent.add(conversationsInside[i]);
        }
        collection.shortContent
            .addAll(reflectionsInside.sublist(reflectionIterator));
      }
    } else {
      collection.shortContent.addAll(reflectionsInside);
    }
    return collection;
  }

  Future<CollectionShortData> getAutoUncompleted() async {
    List<Map> maps =
        await db.rawQuery("SELECT ${ConversationInStorage.COLUMN_CARD_NUMBER} "
            "FROM ${ConversationInStorage.TABLE_NAME} "
            "WHERE ${ConversationInStorage.COLUMN_POSITIVE} IS NULL");
    CollectionShortData incomplete =
        new CollectionShortData(INCOMPLETE_ID, true);
    incomplete.collectionName = "Incomplete conversations";
    incomplete.conversationNumber = maps.length;
    return incomplete;
  }

  Future<CollectionFullView> _getFullAutoUncompleted() async {
    CollectionFullView collection =
        new CollectionFullView(INCOMPLETE_ID, true, DateTime.now());
    collection.title = "Incomplete conversations";
    collection.shortContent = new List();
    List<Map> mapsOfIds =
        await db.rawQuery("SELECT ${ConversationInStorage.COLUMN_CARD_NUMBER} "
            "FROM ${ConversationInStorage.TABLE_NAME} "
            "WHERE ${ConversationInStorage.COLUMN_POSITIVE} IS NULL");

    return await _formCollection(collection, mapsOfIds);
  }

  Future<CollectionShortData> getAutoPositive() async {
    List<Map> maps =
        await db.rawQuery("SELECT ${ConversationInStorage.COLUMN_CARD_NUMBER} "
            "FROM ${ConversationInStorage.TABLE_NAME} "
            "WHERE ${ConversationInStorage.COLUMN_POSITIVE} > 75");
    CollectionShortData incomplete = new CollectionShortData(POSITIVE_ID, true);
    incomplete.collectionName = "Positive conversations";
    incomplete.conversationNumber = maps.length;
    return incomplete;
  }

  Future<CollectionFullView> _getFullAutoPositive() async {
    CollectionFullView collection =
        new CollectionFullView(POSITIVE_ID, true, DateTime.now());
    collection.title = "Positive conversations";
    List<Map> mapsOfIds =
        await db.rawQuery("SELECT ${ConversationInStorage.COLUMN_CARD_NUMBER} "
            "FROM ${ConversationInStorage.TABLE_NAME} "
            "WHERE ${ConversationInStorage.COLUMN_POSITIVE} > 75");
    return await _formCollection(collection, mapsOfIds);
  }

  Future<CollectionShortData> getAuto6MonthAgo() async {
    int agoTimestamp =
        DateTime.now().subtract(Duration(days: 6 * 30)).millisecondsSinceEpoch;
    List<Map> maps =
        await db.rawQuery("SELECT ${ConversationInStorage.COLUMN_CARD_NUMBER} "
            "FROM ${ConversationInStorage.TABLE_NAME} "
            "WHERE ${ConversationInStorage.COLUMN_CREATED} < $agoTimestamp");
    CollectionShortData incomplete = new CollectionShortData(OLD_6_ID, true);
    incomplete.collectionName = "6 months ago";
    incomplete.conversationNumber = maps.length;
    return incomplete;
  }

  Future<CollectionFullView> _getFullAuto6MonthAgo() async {
    int agoTimestamp =
        DateTime.now().subtract(Duration(days: 6 * 30)).millisecondsSinceEpoch;
    CollectionFullView collection =
        new CollectionFullView(OLD_6_ID, true, DateTime.now());
    collection.title = "6 months ago";
    List<Map> mapsOfIds =
        await db.rawQuery("SELECT ${ConversationInStorage.COLUMN_CARD_NUMBER} "
            "FROM ${ConversationInStorage.TABLE_NAME} "
            "WHERE ${ConversationInStorage.COLUMN_CREATED} < $agoTimestamp");
    return await _formCollection(collection, mapsOfIds);
  }

  Future<List<CollectionShortData>> getSavedCollections() async {
    //SELECT a.id as id,
    //      a.title as title,
    //      COUNT(b.id) as number
    //	  FROM collection AS a LEFT JOIN
    //      reflection_content AS b ON a.id = b.collection_id GROUP BY a.id
    List<CollectionShortData> result = new List();
    List<Map<String, dynamic>> queryResult = await db.rawQuery('''
      SELECT a.${CollectionInStorage.COLUMN_ID} as id, 
      a.${CollectionInStorage.COLUMN_TITLE} as title, 
      COUNT(b.${CollectionContent.COLUMN_ID}) as number FROM ${CollectionInStorage.TABLE_NAME} AS a LEFT JOIN 
      (SELECT ${CollectionContent.COLUMN_ID}, ${CollectionContent.COLUMN_COLLECTION_ID} 
      FROM ${CollectionContent.TABLE_NAME} WHERE ${CollectionContent.COLUMN_REFLECTION_ID} IS NULL) AS b 
      ON a.${CollectionInStorage.COLUMN_ID} = b.${CollectionContent.COLUMN_COLLECTION_ID} 
      GROUP BY a.${CollectionInStorage.COLUMN_ID}
      ORDER BY a.${CollectionInStorage.COLUMN_CREATED} DESC
    ''');
    for (Map<String, dynamic> map in queryResult) {
      CollectionShortData shortView = new CollectionShortData(map["id"], false);
      shortView.collectionName = map["title"];
      shortView.conversationNumber = map["number"];
      result.add(shortView);
    }
    return result;
  }

  Future<List<CollectionShortData>> getAutoCollections() async {
    List<CollectionShortData> result = new List();
    result.add(await getAutoMostReflectedOn());
    result.add(await getAutoUncompleted());
    result.add(await getAutoPositive());
    result.add(await getAuto6MonthAgo());
    return result;
  }

  Future updateCollectionName(String value, int collectionId) {
    return db.update(CollectionInStorage.TABLE_NAME,
        {CollectionInStorage.COLUMN_TITLE: value},
        where: "${CollectionInStorage.COLUMN_ID} = ?",
        whereArgs: [collectionId]);
  }

  Future deleteCollection(int collectionId) {
    return db.delete(CollectionInStorage.TABLE_NAME,
        where: "${CollectionInStorage.COLUMN_ID} = ?",
        whereArgs: [collectionId]);
  }

  Future<CollectionFullView> getCollection(int id) {
    switch (id) {
      case INCOMPLETE_ID:
        return _getFullAutoUncompleted();
      case MOST_REFLECTED_ID:
        return _getFullAutoMostReflectedOn();
      case POSITIVE_ID:
        return _getFullAutoPositive();
      case OLD_6_ID:
        return _getFullAuto6MonthAgo();
      default:
        print("it is user collection");
        return _getUserCollection(id);
    }
  }

  Future<CollectionFullView> _getUserCollection(int id) async {
    List<Map> collectionMap = await db.query(CollectionInStorage.TABLE_NAME,
        columns: CollectionInStorage.COLUMNS,
        where: "${CollectionInStorage.COLUMN_ID} = ?",
        whereArgs: [id]);
    CollectionInStorage collectionInStorage =
        CollectionInStorage.fromMap(collectionMap[0]);

    List<Map> reflectionMaps = await db.query(ConversationInStorage.TABLE_NAME,
        columns: ConversationInStorage.COLUMNS,
        where: "${ConversationInStorage.COLUMN_CARD_NUMBER} IN "
            "(SELECT ${CollectionContent.COLUMN_CONVERSATION_ID} "
            "FROM ${CollectionContent.TABLE_NAME} "
            "WHERE ${CollectionContent.COLUMN_COLLECTION_ID} = $id)");
    Map<int, ConversationInStorage> shortReflectionsInside = new Map();
    for (Map reflectionMap in reflectionMaps) {
      ConversationInStorage reflection =
          ConversationInStorage.fromMap(reflectionMap);
      shortReflectionsInside[reflection.cardNumber] = reflection;
    }

    List<Map> additionalMaps = await db.query(Reflection.TABLE_NAME,
        columns: Reflection.COLUMNS,
        where:
            "${Reflection.COLUMN_CARD_NUMBER} = 0 AND ${Reflection.COLUMN_ID} IN "
            "(SELECT ${CollectionContent.COLUMN_REFLECTION_ID} "
            "FROM ${CollectionContent.TABLE_NAME} "
            "WHERE ${CollectionContent.COLUMN_COLLECTION_ID} = $id)");
    Map<int, Reflection> additionalReflectionsInside = new Map();
    for (Map additionalMap in additionalMaps) {
      Reflection additionalReflection = Reflection.fromMap(additionalMap);
      additionalReflectionsInside[additionalReflection.id] =
          additionalReflection;
    }

    List<dynamic> collectionContent = new List();
    List<Map> orderMaps = await db.query(
      CollectionContent.TABLE_NAME,
      columns: CollectionContent.COLUMNS,
      where: "${CollectionContent.COLUMN_COLLECTION_ID} = $id",
      orderBy: CollectionContent.COLUMN_ID,
    );
    for (Map map in orderMaps) {
      CollectionContent content = CollectionContent.fromMap(map);
      if (content.additionalReflectionId == null) {
        collectionContent.add(shortReflectionsInside[content.reflectionId]);
      } else {
        collectionContent
            .add(additionalReflectionsInside[content.additionalReflectionId]);
      }
    }

    print(
        "process of building collection view is finishing. Title is '${collectionInStorage.title}'");
    return CollectionFullView(
        collectionInStorage.id, false, collectionInStorage.creationDate,
        title: collectionInStorage.title, shortContent: collectionContent);
  }

  Future<Map<int, ConversationWidgetContent>> _searchOnTitle(
      String search) async {
    Map<int, ConversationWidgetContent> result = new Map();

    List<Map> mainSearch = await db.query(ConversationInStorage.TABLE_NAME,
        columns: ConversationInStorage.COLUMNS,
        where:
            "LOWER(${ConversationInStorage.COLUMN_TITLE}) LIKE '%${search.toLowerCase()}%'",
        orderBy:
            "${ConversationInStorage.COLUMN_CARD_NUMBER} DESC"); //TODO add limit
    if (mainSearch.length > 0) {
      for (Map map in mainSearch) {
        ConversationWidgetContent widgetData =
            ConversationWidgetContent.fromStorage(
                ConversationInStorage.fromMap(map));
        result[widgetData.cardNumber] = widgetData;
      }
    }
    return result;
  }

  Future<Map<int, ConversationWidgetContent>> _searchOnConversationContent(
      String search, Iterable<int> keys) async {
    Map<int, ConversationWidgetContent> result = new Map();

    String excludedIds = _getExcludedString(keys);
    List<Map> mainSearch = await db.query(ConversationContent.TABLE_NAME,
        columns: ConversationContent.COLUMNS,
        where:
            "LOWER(${ConversationContent.COLUMN_TEXT}) LIKE '%${search.toLowerCase()}%' "
            "AND ${ConversationInStorage.COLUMN_CARD_NUMBER} NOT IN ($excludedIds)",
        orderBy: "${ConversationContent.COLUMN_CARD_NUMBER} DESC");
    if (mainSearch.length > 0) {
      for (Map map in mainSearch) {
        ConversationContent content = ConversationContent.fromMap(map);
        ConversationInStorage conversationInStorage =
            await _getConversationInStorage(content.cardNumber);
        ConversationWidgetContent widgetData = new ConversationWidgetContent(
            content.cardNumber,
            conversationInStorage.created,
            conversationInStorage.title,
            content.text,
            conversationInStorage.positiveMood != null);
        result[widgetData.cardNumber] = widgetData;
      }
    }
    return result;
  }

  Future<ConversationInStorage> _getConversationInStorage(int cardNum) async {
    List<Map<String, dynamic>> maps = await db.query(
        ConversationInStorage.TABLE_NAME,
        columns: ConversationInStorage.COLUMNS,
        where: ConversationInStorage.COLUMN_CARD_NUMBER + "=$cardNum");
    if (maps.length > 0) {
      return ConversationInStorage.fromMap(maps[0]);
    }
  }

  Future<Map<int, ConversationWidgetContent>> _searchOnAdditional(
      String search, Iterable<int> keys) async {
    Map<int, ConversationWidgetContent> result = new Map();

    String excludedIds = _getExcludedString(keys);
    List<Map> mainSearch = await db.rawQuery('''
    SELECT a.${ConversationInStorage.COLUMN_CARD_NUMBER} as card_num,
    a.${ConversationInStorage.COLUMN_TITLE} as title,
    a.${ConversationInStorage.COLUMN_CREATED} as created,
    b.${Reflection.COLUMN_RESPONSE} as response
    FROM (SELECT DISTINCT ${Reflection.COLUMN_CARD_NUMBER}, 
    ${Reflection.COLUMN_RESPONSE} 
    FROM ${Reflection.TABLE_NAME} 
    WHERE LOWER(${Reflection.COLUMN_RESPONSE}) LIKE '%${search.toLowerCase()}%' 
    AND ${ConversationInStorage.COLUMN_CARD_NUMBER} NOT IN ($excludedIds)) as b LEFT JOIN ${ConversationInStorage.TABLE_NAME} as a
    ON a.${ConversationInStorage.COLUMN_CARD_NUMBER} = b.${Reflection.COLUMN_CARD_NUMBER}
    ORDER BY a.${ConversationInStorage.COLUMN_CARD_NUMBER} DESC
    ''');
    if (mainSearch.length > 0) {
      for (Map map in mainSearch) {
        ConversationWidgetContent widgetData = ConversationWidgetContent(
            map["card_num"],
            DateTime.fromMillisecondsSinceEpoch(map["created"]),
            map["title"],
            map["response"],
            true);
        result[widgetData.cardNumber] = widgetData;
      }
    }
    return result;
  }

  String _getExcludedString(Iterable<int> keys) {
    if (keys.length == 0) return "";
    String result = "";
    for (int key in keys) {
      result += "$key, ";
    }
    return result.substring(0, result.length - 2);
  }

  Future _onDbCreate(Database db, int version) async {
    await db.execute(ConversationInStorage.CREATE_EXPRESSION);
    await db.execute(ConversationContent.CREATE_EXPRESSION);
    await db.execute(Reflection.CREATE_EXPRESSION);
    await db.execute(EditableUIText.CREATE_EXPRESSION);
    await db.execute(EditableUIRequest.CREATE_EXPRESSION);
    await db.execute(EditableUIQuestion.CREATE_EXPRESSION);
    await db.execute(CollectionInStorage.CREATE_EXPRESSION);
    await db.execute(CollectionContent.CREATE_EXPRESSION);
    await db.execute(Reminder.CREATE_EXPRESSION);
    await db.execute(ReminderId.CREATE_EXPRESSION);
  }

  FutureOr<void> _onDbUpgrade(Database db, int oldVersion, int newVersion) {
    //TODO write update scripts here
  }

  Future<int> addReminder(Reminder editedReminder) {
    return db.insert(Reminder.TABLE_NAME, editedReminder.toMap());
  }

  Future deleteReminder(int id) {
    return db.delete(Reminder.TABLE_NAME, where: "${Reminder.COLUMN_ID} = $id");
  }

  Future<List<Reminder>> getActualReminders() async {
    List<Map> maps = await db.rawQuery(
        "SELECT a.${Reminder.COLUMN_ID} AS ${Reminder.COLUMN_ID}, "
        "a.${Reminder.COLUMN_CARD_NUMBER} AS ${Reminder.COLUMN_CARD_NUMBER}, "
        "b.${ConversationInStorage.COLUMN_TITLE} AS title, "
        "a.${Reminder.COLUMN_TIME} as ${Reminder.COLUMN_TIME}, "
        "a.${Reminder.COLUMN_WEEKDAYS} as ${Reminder.COLUMN_WEEKDAYS}, "
        "a.${Reminder.COLUMN_REPEAT} as ${Reminder.COLUMN_REPEAT}, "
        "a.${Reminder.COLUMN_CREATED} as ${Reminder.COLUMN_CREATED} "
        "FROM ${Reminder.TABLE_NAME} AS a "
        "LEFT JOIN ${ConversationInStorage.TABLE_NAME} AS b "
        "ON a.${Reminder.COLUMN_CARD_NUMBER} = b.${ConversationInStorage.COLUMN_CARD_NUMBER}");
    List<Reminder> reminders = new List();
    for (Map map in maps) {
      reminders.add(Reminder.fromMap(map, map["title"]));
    }
    return reminders;
  }

  Future<int> insertReminderId(ReminderId reminderId) {
    return db.insert(ReminderId.TABLE_NAME, reminderId.toMap());
  }

  Future<List<ReminderId>> getReminderIds(int reminderIndex) async {
    List<Map> maps = await db.query(ReminderId.TABLE_NAME,
        columns: ReminderId.COLUMNS,
        where: "${ReminderId.COLUMN_REMINDER_ID} = ?",
        whereArgs: [reminderIndex]);
    List<ReminderId> result = new List();
    for (Map map in maps) {
      result.add(ReminderId.fromMap(map));
    }
    return result;
  }

  Future clearOldReminders() async {
    await initializationDone;
    List<Map> maps = await db.query(ReminderId.TABLE_NAME,
        distinct: true,
        columns: [ReminderId.COLUMN_REMINDER_ID],
        where:
            "${ReminderId.COLUMN_REPEATING} = 0 AND ${ReminderId.COLUMN_FLUSH} < ?",
        whereArgs: [DateTime.now().millisecondsSinceEpoch]);
    if (maps.length > 0) {
      String ids = "";
      for (Map map in maps) {
        ids += "${map[ReminderId.COLUMN_REMINDER_ID]}, ";
      }
      ids = ids.substring(0, ids.length - 2);
      await db.rawQuery(
          "DELETE FROM ${Reminder.TABLE_NAME} WHERE ${Reminder.COLUMN_ID} in ($ids)");
    }
  }

  Future<List<ReminderId>> getAllReminders() async {
    List<Map> maps =
        await db.query(ReminderId.TABLE_NAME, columns: ReminderId.COLUMNS);
    List<ReminderId> result = new List();
    for (Map map in maps) {
      result.add(ReminderId.fromMap(map));
    }
    return result;
  }

  Future deleteNotificationsForReminder(int id) {
    return db.delete(ReminderId.TABLE_NAME,
        where: "${ReminderId.COLUMN_REMINDER_ID} = $id");
  }

  Future<Reminder> getReminderForCard(int cardNumber, String title) async {
    List<Map> maps = await db.query(Reminder.TABLE_NAME,
        columns: Reminder.COLUMNS,
        where: "${Reminder.COLUMN_CARD_NUMBER} = $cardNumber");
    if (maps.length == 0) {
      return null;
    } else {
      return Reminder.fromMap(maps[0], title);
    }
  }

  Future updateReminder(Reminder editedReminder) {
    return db.update(Reminder.TABLE_NAME, editedReminder.toMap(),
        where: "${Reminder.COLUMN_ID} = ?", whereArgs: [editedReminder.id]);
  }

  Future deleteCollectionContent(int collectionId, int conversationCardNumber) {
    return db.delete(CollectionContent.TABLE_NAME,
        where:
            "${CollectionContent.COLUMN_COLLECTION_ID} = ? AND ${CollectionContent.COLUMN_CONVERSATION_ID} = ?",
        whereArgs: [collectionId, conversationCardNumber]);
  }

  Future<List<int>> getCollectionConversationIds(int collectionId) async {
    List<Map<String, dynamic>> maps = await db.query(
        CollectionContent.TABLE_NAME,
        columns: [CollectionContent.COLUMN_CONVERSATION_ID],
        where: "${CollectionContent.COLUMN_COLLECTION_ID} = ?",
        whereArgs: [collectionId]);
    List<int> result = new List();
    for (Map map in maps) {
      result.add(map[CollectionContent.COLUMN_CONVERSATION_ID]);
    }
    print("already selected are $result");
    return result;
  }

  Future<int> getConversationCount() async {
    await _initialized;
    List<Map> maps = await db.rawQuery(
        "SELECT COUNT(${ConversationInStorage.COLUMN_CARD_NUMBER}) as r_count FROM ${ConversationInStorage.TABLE_NAME}");
    if (maps.length == 0) return 0;
    return maps[0]["r_count"];
  }

  Future<int> getCompletedConversationCount() async {
    await _initialized;
    List<Map> maps = await db.rawQuery(
        "SELECT COUNT(${ConversationInStorage.COLUMN_CARD_NUMBER}) as r_count FROM ${ConversationInStorage.TABLE_NAME} WHERE ${ConversationInStorage.COLUMN_TITLE} != ''");
    if (maps.length == 0) return 0;
    return maps[0]["r_count"];
  }

  // "WHERE ${Reflection.COLUMN_QUESTION_LEVEL} = ${level - 1} "

  Future<int> getCollectionsCount() async {
    await _initialized;
    List<Map> maps = await db.rawQuery(
        "SELECT COUNT(${CollectionInStorage.COLUMN_ID}) as c_count FROM ${CollectionInStorage.TABLE_NAME}");
    if (maps.length == 0) return 0;
    return maps[0]["c_count"];
  }

  Future<int> getReflectionsCount() async {
    await _initialized;
    List<Map> maps = await db.rawQuery(
        "SELECT COUNT(${Reflection.COLUMN_ID}) as a_count FROM ${Reflection.TABLE_NAME}");
    if (maps.length == 0) return 0;
    return maps[0]["a_count"];
  }

  Future<Reminder> getReminderById(int id, String title) async {
    List<Map> maps = await db.query(Reminder.TABLE_NAME,
        columns: Reminder.COLUMNS, where: "${Reminder.COLUMN_ID} = $id");
    if (maps.length == 0) {
      return null;
    } else {
      return Reminder.fromMap(maps[0], title);
    }
  }

  Future<EditableUIText> getUIText(int id) async {
    List<Map> maps = await db.query(EditableUIText.TABLE_NAME,
        columns: EditableUIText.COLUMNS,
        where: "${EditableUIText.COLUMN_VISIBLE_ID} = $id");
    if (maps == null || maps.length == 0) {
      return EditableUIText.predefined[id];
    } else {
      return EditableUIText.fromMap(maps[0]);
    }
  }

  Future<Map<int, EditableUIText>> getUITexts(List<int> ids) async {
    String idsString = _getExcludedString(ids);
    List<Map> maps = await db.query(EditableUIText.TABLE_NAME,
        columns: EditableUIText.COLUMNS,
        where: "${EditableUIText.COLUMN_VISIBLE_ID} IN ($idsString)");
    if (maps == null || maps.length == 0) {
      return null;
    } else {
      Map<int, EditableUIText> result = new Map();
      for (Map map in maps) {
        EditableUIText uiText = EditableUIText.fromMap(map);
        result[uiText.uiID] = uiText;
      }
      return result;
    }
  }

  Future<List<EditableUIText>> getAllUITexts(int id) async {
    List<Map> maps = await db.query(EditableUIText.TABLE_NAME,
        columns: EditableUIText.COLUMNS,
        where: "${EditableUIText.COLUMN_VISIBLE_ID} = $id");
    if (maps == null || maps.length == 0) {
      return null;
    } else {
      List<EditableUIText> result = new List();
      for (Map map in maps) {
        EditableUIText uiText = EditableUIText.fromMap(map);
        result.add(uiText);
      }
      return result;
    }
  }

  Future<int> getSavedUiTimestamp() async {
    await _initialized;
    List<Map> maps = await db.query(EditableUIText.TABLE_NAME,
        distinct: true, columns: [EditableUIText.COLUMN_LAST_UPDATE]);
    if (maps == null || maps.length == 0) {
      return 0;
    } else {
      return maps[0][EditableUIText.COLUMN_LAST_UPDATE];
    }
  }

  Future saveUiText(List<EditableUIText> uiTexts) async {
    await _initialized;
    await db.delete(EditableUIText.TABLE_NAME);
    for (EditableUIText uiText in uiTexts) {
      await db.insert(EditableUIText.TABLE_NAME, uiText.toMap());
    }
  }

  Future<List<EditableUIQuestion>> getCollectionQuestions() async {
    List<EditableUIQuestion> result = new List();
    for (int i = 1; i <= 4; i++) {
      result.addAll((await _getQuestions(false, i)) ?? List());
    }
    if (result.length == 0) {
      return EditableUIQuestion.PREDEFINED_FOR_COLLECTION;
    } else {
      return result;
    }
  }

  Future<List<EditableUIQuestion>> getConversationQuestions() async {
    List<EditableUIQuestion> result = new List();
    for (int i = 1; i <= 4; i++) {
      result.addAll((await _getQuestions(true, i)) ?? List());
    }
    if (result.length == 0) {
      return EditableUIQuestion.PREDEFINED_FOR_REFLECTION;
    } else {
      return result;
    }
  }

  Future<List<EditableUIQuestion>> _getQuestions(
      bool isConversation, int level) async {
    List<Map> maps = await db.query(EditableUIQuestion.TABLE_NAME,
        columns: EditableUIQuestion.COLUMNS,
        where:
            "${EditableUIQuestion.COLUMN_IS_CONVERSATION} =? AND ${EditableUIQuestion.COLUMN_LEVEL} = ?",
        whereArgs: [isConversation ? 1 : 0, level]);
    if (maps == null || maps.length == 0) {
      return null;
    } else {
      List<EditableUIQuestion> questions = new List();
      for (Map map in maps) {
        questions.add(EditableUIQuestion.fromMap(map));
      }
      questions.shuffle();

      return questions;
    }
  }

  Future<EditableUIQuestion> getUIQuestion(
      String title, bool isReflection) async {
    List<Map<String, dynamic>> maps = await db.query(
        EditableUIQuestion.TABLE_NAME,
        columns: EditableUIQuestion.COLUMNS,
        where:
            "${EditableUIQuestion.COLUMN_IS_CONVERSATION}=? AND ${EditableUIQuestion.COLUMN_TITLE}=?",
        whereArgs: [isReflection ? 1 : 0, title],
        orderBy: "RANDOM()",
        limit: 1);
    if (maps != null && maps.length > 0) {
      return EditableUIQuestion.fromMap(maps[0]);
    } else {
      return null;
    }
  }

  Future clearUiQuestions() async {
    await _initialized;
    await db.delete(EditableUIQuestion.TABLE_NAME);
  }

  Future saveUiQuestions(
      List<EditableUIQuestion> questions, bool areReflections) async {
    for (EditableUIQuestion question in questions) {
      Map<String, dynamic> map = question.toMap(areReflections);
      print("MAP: $map");
      await db.insert(EditableUIQuestion.TABLE_NAME, map);
    }
  }

  Future saveUiRequests(List<EditableUIRequest> reflectionRequests) async {
    await _initialized;
    await db.delete(EditableUIRequest.TABLE_NAME);
    for (EditableUIRequest request in reflectionRequests) {
      await db.insert(EditableUIRequest.TABLE_NAME, request.toMap());
    }
  }

  Future<EditableUIRequest> getUIRequest(String key) async {
    List<Map<String, dynamic>> maps = await db.query(
        EditableUIRequest.TABLE_NAME,
        columns: EditableUIRequest.COLUMNS,
        where: "${EditableUIRequest.COLUMN_ID}=?",
        whereArgs: [key],
        orderBy: "RANDOM()",
        limit: 1);
    if (maps != null && maps.length > 0) {
      print("REQUEST: there is a saved value");
      return EditableUIRequest.fromMap(maps[0]);
    } else {
      print("REQUEST: there is no value for key '$key'");
      return EditableUIRequest.predefined[key];
    }
  }

  Future<int> addConversationContent(ConversationContent editedItem) async {
    return db.insert(ConversationContent.TABLE_NAME, editedItem.toMap());
  }

  Future _checkLevel(int level, int isConversation) async {
    String condition = (isConversation == 1) ? "> 0" : "= 0";
    List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT ${Reflection.COLUMN_QUESTION_ID} "
            "FROM ${Reflection.TABLE_NAME} "
            "WHERE ${Reflection.COLUMN_QUESTION_LEVEL} = ${level - 1} "
            "AND ${Reflection.COLUMN_CARD_NUMBER} $condition");
    if (maps != null && maps.length > 0) {
      Map<int, int> answerIds = new Map();
      for (Map map in maps) {
        int id = map[Reflection.COLUMN_QUESTION_ID];
        if (answerIds.containsKey(id)) {
          answerIds[id]++;
        } else {
          answerIds[id] = 1;
        }
      }
      List<int> questionIds = await _getQuestionIds(level, isConversation);
      if (questionIds.length > answerIds.length) {
        return;
      }
      for (int questionId in questionIds) {
        if (answerIds.containsKey(questionId)) {
          if (answerIds[questionId] < (level == 2 ? 2 : 3)) {
            return;
          }
        } else {
          return;
        }
      }

      showToastWidget(
        ToastTierUnlocked(level),
        duration: Duration(seconds: 2),
      );
      print("UNLOCK");
      if (isConversation == 1) {
        await PreferencesProvider().saveHighestConversationLevel(level);
      } else {
        await PreferencesProvider().saveHighestCollectionLevel(level);
      }
    }
  }

  Future<List<int>> _getQuestionIds(int level, int isConversation) async {
    List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT ${EditableUIQuestion.COLUMN_ID} "
        "FROM ${EditableUIQuestion.TABLE_NAME} "
        "WHERE ${EditableUIQuestion.COLUMN_IS_CONVERSATION} = $isConversation AND ${EditableUIQuestion.COLUMN_LEVEL} = ${level - 1}");
    List<int> result = new List();
    if (maps == null || maps.length == 0) {
      List<EditableUIQuestion> questions = isConversation == 1
          ? EditableUIQuestion.PREDEFINED_FOR_REFLECTION
          : EditableUIQuestion.PREDEFINED_FOR_COLLECTION;
      for (EditableUIQuestion question in questions) {
        result.add(question.id);
      }
    } else {
      for (Map map in maps) {
        result.add(map[EditableUIQuestion.COLUMN_ID]);
      }
    }
    return result;
  }

  Future<bool> doesHaveData() async {
    List<Map> conversationMaps =
        await db.query(ConversationInStorage.TABLE_NAME, limit: 1);
    if (conversationMaps != null && conversationMaps.length > 0) return true;

    List<Map> collectionMaps =
        await db.query(CollectionInStorage.TABLE_NAME, limit: 1);
    if (collectionMaps != null && collectionMaps.length > 0) return true;

    List<Map> reflectionMaps = await db.query(Reflection.TABLE_NAME, limit: 1);
    if (reflectionMaps != null && reflectionMaps.length > 0) return true;

    return false;
  }

  Future<List<EditableUIRequest>> getUIRequests(String key) async {
    List<Map<String, dynamic>> maps = await db.query(
      EditableUIRequest.TABLE_NAME,
      columns: EditableUIRequest.COLUMNS,
      where: "${EditableUIRequest.COLUMN_ID}=?",
      whereArgs: [key],
    );
    if (maps != null && maps.length > 0) {
      List<EditableUIRequest> result = new List();
      for (Map map in maps) {
        result.add(EditableUIRequest.fromMap(map));
      }
      return result;
    } else {
      return [EditableUIRequest.predefined[key]];
    }
  }

  Future<bool> hasTheSameReminder(Reminder editedReminder) async {
    List<Map> maps = await db.query(Reminder.TABLE_NAME,
        columns: [Reminder.COLUMN_ID],
        where:
            "${Reminder.COLUMN_REPEAT} = ? AND ${Reminder.COLUMN_TIME} = ? AND ${Reminder.COLUMN_WEEKDAYS} = ?",
        whereArgs: [
          editedReminder.getDatabaseRepeat(),
          editedReminder.getDatabaseTime(),
          editedReminder.getDatabaseWeekdsays(),
        ]);
    if (maps.length == 0) {
      return false;
    } else if (maps.length == 1) {
      int savedId = maps[0][Reminder.COLUMN_ID];
      if (savedId == editedReminder.id)
        return false;
      else
        return true;
    } else {
      return true;
    }
  }

  Future<List<int>> getAssociatedCollections(int conversationId) async {
    print("IN COLLECTION reflection id $conversationId");
    List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT ${CollectionContent.COLUMN_COLLECTION_ID} "
        "FROM ${CollectionContent.TABLE_NAME} "
        "WHERE ${CollectionContent.COLUMN_CONVERSATION_ID} = ?",
        [conversationId]);
    List<int> result = new List();
    if (maps != null && maps.length > 0) {
      for (Map map in maps) {
        print("IN_COLLECTION ${map[CollectionContent.COLUMN_COLLECTION_ID]}");
        result.add(map[CollectionContent.COLUMN_COLLECTION_ID]);
      }
    }
    return result;
  }
}
