import 'dart:async';

import 'package:hold/model/conversation_widget_content.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:rxdart/rxdart.dart';

class ConversationSearchBloc {
  static const SEARCH_THRESHOLD = 1;

  String lastSearch;

  bool isLoading = false;

  BehaviorSubject<List<ConversationWidgetContent>> _reflectionListController =
      new BehaviorSubject();
  Stream<List<ConversationWidgetContent>> get reflectionList =>
      _reflectionListController.stream;

  ConversationSearchBloc() {
    _loadAllReflections();
  }

  Future search(String text, {bool updateFlag = false}) {
    print("SEARCH CALLED with $text $updateFlag");
    if (_isSearch(text) && (lastSearch != text || updateFlag)) {
      lastSearch = text;
      print("LOAD SEARCH");
      return _loadSearchedReflections(text);
    } else {
      if (_isSearch(lastSearch) || updateFlag) {
        lastSearch = text ?? "";
        print("LOAD ALL");
        return _loadAllReflections();
      }
    }
    return Future.value(null);
  }

  bool _isSearch(String text) {
    return text != null && text.length >= SEARCH_THRESHOLD;
  }

  Future _loadSearchedReflections(String search) async {
    List<ConversationWidgetContent> searchResult =
        await StorageProvider().getSearchedReflections(search);
    print("LOADING search result for $search");
    _reflectionListController.add(searchResult);
  }

  Future _loadAllReflections() async {
    isLoading = true;

    _reflectionListController.add(await StorageProvider().getReflectionList());

    isLoading = false;
  }
}
