import 'dart:async';

import 'package:hold/model/collection_short_data.dart';
import 'package:hold/storage/storage_provider.dart';

class CollectionSelectionBloc {
  StreamController<List<CollectionShortData>> _collectionListController =
      new StreamController();
  Stream<List<CollectionShortData>> get collectionList =>
      _collectionListController.stream;

  List<int> inCollectionConversations;

  final int conversationId;
  List<int> collectionIds = new List();

  CollectionSelectionBloc(this.conversationId) {
    loadData();
  }

  Future loadData() async {
    List<CollectionShortData> loadedData =
        await StorageProvider().getSavedCollections();
    inCollectionConversations =
        await StorageProvider().getAssociatedCollections(conversationId);
    print("LOADING DATA ${inCollectionConversations.length}");
    _collectionListController.add(loadedData);
  }

  void addCollection(int collectionID) {
    collectionIds.add(collectionID);
    StorageProvider().addConversationToCollection(collectionID, conversationId);
  }

  void removeCollection(int collectionID) {
    collectionIds.remove(collectionID);
    StorageProvider().deleteCollectionContent(collectionID, conversationId);
  }

  Future<int> createCollection(String newName) async {
    int collectionId = await StorageProvider().createCollection();
    await StorageProvider().updateCollectionName(newName, collectionId);
    loadData();
    return collectionId;
  }
}
