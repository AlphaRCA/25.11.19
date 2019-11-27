import 'dart:async';

import 'package:hold/bloc/conversation_search_bloc.dart';
import 'package:hold/storage/storage_provider.dart';

class SelectConversationBloc extends ConversationSearchBloc {
  List<int> _selectedReflectionIds = new List();
  List<int> _unselectedReflectionIds = new List();
  int collectionId;
  Future<List<int>> existedCollectionIds;

  SelectConversationBloc({this.collectionId}) : super() {
    if (collectionId != null) {
      existedCollectionIds =
          StorageProvider().getCollectionConversationIds(collectionId);
    }
  }

  void selectReflection(int cardNumber, bool newState) {
    if (newState) {
      if (_unselectedReflectionIds.contains(cardNumber)) {
        _unselectedReflectionIds.remove(cardNumber);
      } else {
        _selectedReflectionIds.add(cardNumber);
      }
    } else {
      if (_selectedReflectionIds.contains(cardNumber)) {
        _selectedReflectionIds.remove(cardNumber);
      } else {
        _unselectedReflectionIds.add(cardNumber);
      }
    }
  }

  bool isSelectedReflection(int cardNumber) =>
      _selectedReflectionIds.contains(cardNumber);

  Future saveCollection() async {
    if (collectionId == null) {
      collectionId = await StorageProvider().createCollection();
    } else {
      for (int id in _unselectedReflectionIds) {
        await StorageProvider().deleteCollectionContent(collectionId, id);
      }
    }
    for (int reflectionId in _selectedReflectionIds) {
      await StorageProvider()
          .addConversationToCollection(collectionId, reflectionId);
    }
  }

  Future<int> saveCollectionName(String newName) async {
    if (collectionId != null)
      await StorageProvider().updateCollectionName(newName, collectionId);
    return collectionId;
  }
}
