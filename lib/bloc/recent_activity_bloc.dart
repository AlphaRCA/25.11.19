import 'dart:async';

import 'package:hold/bloc/conversation_search_bloc.dart';
import 'package:hold/storage/graph_value.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:rxdart/rxdart.dart';

class RecentActivityBloc extends ConversationSearchBloc {
  BehaviorSubject<List<GraphValue>> _graphController = new BehaviorSubject();
  Stream<List<GraphValue>> get graph => _graphController.stream;

  final StorageProvider _storageProvider = StorageProvider();

  RecentActivityBloc() : super() {
    _updateGraph();
  }

  Future deleteReflection(int cardNumber) async {
    await _storageProvider.deleteConversation(cardNumber);
    updateList();
  }

  Future updateList() async {
    search(lastSearch, updateFlag: true);
    _updateGraph();
  }

  Future _updateGraph() async {
    List<GraphValue> graphValues =
        await _storageProvider.getPositiveGraphValues();
    _graphController.add(graphValues);
  }
}
