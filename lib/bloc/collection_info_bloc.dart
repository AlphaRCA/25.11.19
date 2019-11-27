import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hold/bloc/play_controller.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/collection_full_view.dart';
import 'package:hold/model/played_item.dart';
import 'package:hold/model/reflection.dart';
import 'package:hold/storage/conversation_in_storage.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:hold/widget/constructors/conversation_in_collection_constructor.dart';
import 'package:hold/widget/screen_parts/playable_text.dart';
import 'package:hold/widget/stick_position.dart';
import 'package:rxdart/rxdart.dart';

import '../main.dart';
import 'mixpanel_provider.dart';

class CollectionInfoBloc extends PlayController {
  BehaviorSubject<String> _collectionTitleController = new BehaviorSubject();
  Stream<String> get collectionTitle => _collectionTitleController.stream;

  BehaviorSubject<CollectionFullView> _collectionDataController =
      new BehaviorSubject();
  Stream<CollectionFullView> get collectionData =>
      _collectionDataController.stream;

  final int collectionId;
  String collectionTitleFinal;

  CollectionFullView _collection;

  CollectionInfoBloc(this.collectionId) {
    _loadDataFromStorage();
  }

  Future rename(String newName) async {
    await StorageProvider().updateCollectionName(newName, collectionId);
    _collectionTitleController.add(newName);
  }

  void _loadDataFromStorage() async {
    _collection = await StorageProvider().getCollection(collectionId);
    collectionTitleFinal = _collection.title;

    MixPanelProvider().trackEvent("COLLECTION", {
      "Collection size (reflections and additionals)":
          _collection.shortContent.length,
    });
    _collectionTitleController.add(_collection.title);
    _collectionDataController.add(_collection);
    _formTextForVoice(_collection);
  }

  Future _formTextForVoice(CollectionFullView collection) async {
    playedItems.clear();
    playedItems = await collection.getItemsForPlayer();
  }

  Future deleteCollection() {
    return StorageProvider().deleteCollection(collectionId);
  }

  Future removeConversation(int cardNumber) async {
    print("Let's delete $cardNumber");
    await StorageProvider().deleteCollectionContent(collectionId, cardNumber);
    _collection.content.remove(cardNumber);
    for (int i = 0; i < _collection.shortContent.length; i++) {
      if (_collection.shortContent[i] is ConversationInStorage &&
          (_collection.shortContent[i] as ConversationInStorage).cardNumber ==
              cardNumber) {
        _collection.shortContent.removeAt(i);
        break;
      }
    }
    print("Conversation deleted. Update will come soon");
    _collectionDataController.add(_collection);
    _formTextForVoice(_collection);
  }

  String getScreenPart(PlayedItem playedItem) {
    if (playedItem.conversationCardId != null) {
      return _collection.content[playedItem.conversationCardId].mainConversation
          .getTitle();
    } else if (playedItem.reflectionId != null) {
      return playedItem.title;
    } else {
      return "";
    }
  }

  void reloadData() async {
    _collection = await StorageProvider().getCollection(collectionId);
    _collectionDataController.add(_collection);
    _formTextForVoice(_collection);
  }

  Future saveAnswer(Reflection reflection) async {
    await StorageProvider()
        .addAdditionalReflectionToCollection(collectionId, reflection);
    reloadData();
  }

  List<Widget> getFullWidgetList(
      BuildContext context, VoidCallback expandControls) {
    int textPartIndex = 1;
    int playableIndex = 1;
    List<Widget> widgets = new List();
    for (var item in _collection.shortContent) {
      if (item is Reflection) {
        widgets.add(_getAdditionalView(item, playableIndex++));
        textPartIndex += 2;
      } else {
        ConversationInStorage reflectionItem = item as ConversationInStorage;
        ConversationInCollectionConstructor constructor =
            new ConversationInCollectionConstructor(
                this,
                _collection.content[reflectionItem.cardNumber],
                playableIndex,
                textPartIndex,
                expandControls,
                MyApp.screenWidth);
        constructor.formParts(context);
        playableIndex = constructor.playableIndex;
        textPartIndex = constructor.textPartIndex;
        widgets.add(Container(
          color: AppColors.BACKGROUND,
          height: 12.0,
        ));
        widgets.addAll(constructor.finishedParts);
      }
    }
    return widgets;
  }

  Widget _getAdditionalView(Reflection additional, int voiceIndex) {
    return PlayableText(
      additional.toPlayedText(),
      this,
      title: additional.title,
      backgroundColor: AppColors.COLLECTION_REFLECTION_BG,
      textColor: AppColors.COLLECTION_REFLECTION_TEXT,
      stick: StickPosition.center,
    );
  }

  void formShortKeys() {
    _formTextForVoice(_collection);
  }

  void setContinuousPlaySetting(bool value) {
    PreferencesProvider().saveContinuousSetting(value);
    super.setContinuousPlaySetting(value);
  }

  void _onVoiceStateChanges(bool event) {}
}
