import 'dart:async';

import 'package:hold/bloc/play_controller.dart';
import 'package:hold/bloc/play_text_provider.dart';
import 'package:hold/model/conversation.dart';
import 'package:hold/model/conversation_for_review.dart';
import 'package:hold/model/played_item.dart';
import 'package:hold/model/reflection.dart';
import 'package:hold/storage/editable_ui_question.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:rxdart/rxdart.dart';

class ConversationFullBloc extends PlayController {
  final BehaviorSubject<ConversationForReview> _reflectionController =
      new BehaviorSubject();
  Stream<ConversationForReview> get reflection => _reflectionController.stream;

  ConversationForReview _reflection;
  Conversation get initialReflection => _reflection.mainConversation;
  List<Reflection> get additionals => _reflection.additionals;
  String get reflectionTitle => _reflection.mainConversation.getTitle();

  final Future<String> title;
  Future loadComplete;

  Reflection answerInProgress;

  final int cardNumber;
  final StorageProvider _storageProvider;

  ConversationFullBloc(this.cardNumber,
      {PlayTextProvider ptp, StorageProvider sp})
      : _storageProvider = sp ?? StorageProvider(),
        title = (sp ?? StorageProvider()).getTitle(cardNumber),
        super(ptp: ptp, isContinuous: false) {
    loadComplete = _loadSavedDataForReflection();
  }

  Future _loadSavedDataForReflection() async {
    await _storageProvider.initializationDone;
    _reflection =
        await StorageProvider().getConversationByCardNumber(cardNumber);
    _reflectionController.add(_reflection);
    playedItems = _reflection.formTextListForVoiceFunction();
  }

  void startAnswering(EditableUIQuestion question) {
    answerInProgress = new Reflection(_reflection.mainConversation.cardNumber,
        question.title, question.level, question.id);
  }

  void setAdditionalText(String text) {
    if (answerInProgress != null) {
      answerInProgress.myText = text;
    }
  }

  Future<int> saveAdditional() async {
    answerInProgress.id = await _storageProvider
        .insertReflectionForConversation(answerInProgress);
    playedItems.add(PlayedItem(answerInProgress.myText,
        title: answerInProgress.title,
        conversationCardId: answerInProgress.cardNumber,
        inConversationContentId: answerInProgress.id));
    _reflection.additionals.add(answerInProgress);
    return answerInProgress.id;
  }

  Future deleteReflection() async {
    await _storageProvider.deleteConversation(cardNumber);
  }

  void renameReflection(String value) async {
    await StorageProvider().updateConversationName(value, cardNumber);
    _reflection.mainConversation.title = value;
    _reflectionController.add(_reflection);
  }
}
