import 'dart:async';
import 'dart:math';

import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/model/collection_short_data.dart';
import 'package:hold/storage/editable_ui_text.dart';
import 'package:hold/storage/storage_provider.dart';

class CollectionsListBloc {
  StreamController<List<CollectionShortData>> _userCollectionsController =
      new StreamController();
  Stream<List<CollectionShortData>> get userCollections =>
      _userCollectionsController.stream;
  List<CollectionShortData> _loadedCollections;

  StreamController<List<CollectionShortData>> _autoCollectionsController =
      new StreamController();
  Stream<List<CollectionShortData>> get autoCollections =>
      _autoCollectionsController.stream;

  StreamController<EditableUIText> _collectionTextController =
      new StreamController();
  Stream<EditableUIText> get collectionText => _collectionTextController.stream;
  List<EditableUIText> _possibleTexts;
  Timer _textLoader;
  final Random _rnd = new Random();

  CollectionsListBloc() {
    _loadAutoCollections();
    _loadUserCollections();
    _startTextRotation();
  }

  Future _loadAutoCollections() async {
    _autoCollectionsController
        .add(await StorageProvider().getAutoCollections());
  }

  Future _loadUserCollections() async {
    _loadedCollections = await StorageProvider().getSavedCollections();
    _userCollectionsController.add(_loadedCollections);
  }

  Future renameCollection(String newName, int id) async {
    await StorageProvider().updateCollectionName(newName, id);
    await _loadUserCollections();
  }

  Future deleteCollection(int collectionId) async {
    await StorageProvider().deleteCollection(collectionId);
    await _loadUserCollections();
  }

  Future reloadCollections() async {
    await _loadUserCollections();
    await _loadAutoCollections();
  }

  void _startTextRotation() async {
    _possibleTexts =
        await StorageProvider().getAllUITexts(EditableUIText.LIBRARY_ACTION);
    if (_possibleTexts != null) {
      _collectionTextController.add(_possibleTexts[0]);
      if (_possibleTexts.length > 1) {
        int rotationTime =
            await PreferencesProvider().getQuestionRotationInterval();
        _textLoader = Timer.periodic(
            Duration(milliseconds: rotationTime), (Timer t) => _reloadText());
      }
    }
  }

  void dispose() {
    _textLoader?.cancel();
    _textLoader = null;
  }

  void _reloadText() {
    _collectionTextController
        .add(_possibleTexts[_rnd.nextInt(_possibleTexts.length)]);
  }
}
