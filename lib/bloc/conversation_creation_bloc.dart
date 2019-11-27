import 'package:hold/bloc/play_controller.dart';
import 'package:hold/bloc/play_text_provider.dart';
import 'package:hold/model/conversation.dart';
import 'package:hold/model/conversation_for_review.dart';
import 'package:hold/model/played_item.dart';
import 'package:hold/model/reflection.dart';
import 'package:hold/storage/conversation_content.dart';
import 'package:hold/storage/storage_provider.dart';

import 'mixpanel_provider.dart';

class ConversationCreationBloc extends PlayController {
  Future<int> cardNumber;
  Future<ConversationForReview> unfinishedContent;

  Conversation conversation;
  Reflection additional;
  ConversationContent editedItem;

  StorageProvider storageProvider;

  final bool proceeding;
  ReflectionType type;
  static const List<String> A_START_ORDER = [
    "AA",
    "AB",
    "AC",
    "AB",
  ];
  static const List<String> A_REPEAT_ORDER = [
    "AD",
    "AB",
    "AC",
    "AB",
  ];
  static const List<String> B_START_ORDER = [
    "BE",
    "BF",
    "BB",
    "BC",
  ];
  static const List<String> B_REPEAT_ORDER = [
    "BB",
    "BD",
    "BB",
    "BC",
  ];

  ConversationCreationBloc(
      {this.type,
      int unfinishedCardNumber,
      PlayTextProvider ptp,
      StorageProvider sp})
      : proceeding = unfinishedCardNumber != null,
        super(ptp: ptp, isContinuous: false) {
    storageProvider = sp ?? StorageProvider();
    if (unfinishedCardNumber == null) {
      cardNumber = storageProvider.insertConversation(type).then((value) {
        conversation = new Conversation(value, type);
        return value;
      });
      playedItems = new List();
      playedItems.add(PlayedItem("Incomplete"));
    } else {
      cardNumber = Future.value(unfinishedCardNumber);
      unfinishedContent =
          storageProvider.getConversationByCardNumber(unfinishedCardNumber);
      unfinishedContent.then((value) {
        print("unfinished reflection is received from database");
        if (value != null) {
          playedItems = value.formTextListForVoiceFunction();
          conversation = value.mainConversation;
          type = conversation.type;
          print("reflection data is $conversation");
        }
      });
    }
  }

  void setText(String text) {
    if (editedItem == null)
      editedItem = new ConversationContent(conversation.cardNumber);
    editedItem.text = text;
  }

  Future finishText() async {
    editedItem.id = await storageProvider.addConversationContent(editedItem);
    conversation.content.add(editedItem);
    if (conversation.content.length == 1) {
      storageProvider.updateConversation(conversation);
    }
    playedItems.add(PlayedItem(editedItem.text,
        conversationCardId: conversation.cardNumber,
        inConversationContentId: editedItem.id));
    editedItem = null;
  }

  Future saveMood() async {
    MixPanelProvider().trackEvent("CONVERSATION", {
      "Slide Emotion Scale": DateTime.now().toIso8601String(),
      "value": conversation.positiveMood
    });
    await storageProvider.updateConversation(conversation);
  }

  void setMood(int value) {
    conversation.positiveMood = value;
  }

  Future<int> setTitle(String title) async {
    MixPanelProvider().trackEvent("CONVERSATION",
        {"Click Done Name Button": DateTime.now().toIso8601String()});
    MixPanelProvider()
        .trackEvent("CONVERSATION", {"Name fielt": title.isNotEmpty});
    conversation.title = title;
    await storageProvider.updateConversation(conversation);
    return conversation.cardNumber;
  }

  Future deleteConversation() {
    return storageProvider.deleteConversation(conversation.cardNumber);
  }
}
