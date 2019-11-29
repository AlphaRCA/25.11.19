import 'package:hold/model/conversation_for_review.dart';
import 'package:hold/model/played_item.dart';
import 'package:hold/model/reflection.dart';
import 'package:hold/storage/conversation_in_storage.dart';
import 'package:hold/storage/storage_provider.dart';

class CollectionFullView {
  final int id;
  final bool autoCreated;
  final DateTime created;
  String title;
  List<dynamic> shortContent; //ConversationInStorage or AdditionalReflection
  Map<int, ConversationForReview> content = new Map();
  List<PlayedItem> _playedItems;

  bool _isLoadingRequired = false;

  CollectionFullView(
    this.id,
    this.autoCreated,
    this.created, {
    this.title,
    this.shortContent,
  });

  bool get isLoadingRequired {
    return _isLoadingRequired;
  }

  Future loadData() async {
    _playedItems = new List();
    _playedItems.add(new PlayedItem(title));
    for (int i = 0; i < shortContent.length; i++) {
      if (shortContent[i] is ConversationInStorage) {
        int cardNum = (shortContent[i] as ConversationInStorage).cardNumber;
        if (!content.containsKey(cardNum)) {
          content[cardNum] =
              await StorageProvider().getConversationByCardNumber(cardNum);
        }
        _playedItems.addAll(content[cardNum].formTextListForVoiceFunction());
      } else {
        Reflection additionalReflection = shortContent[i];
        _playedItems.add(new PlayedItem(additionalReflection.myText,
            title: additionalReflection.title,
            reflectionId: additionalReflection.id));
      }
    }
  }

  Future<List<PlayedItem>> getItemsForPlayer() async {
    if (_playedItems == null) {
      loadData();
    }
    return _playedItems;
  }

  ConversationForReview getFullReflectionForList(int index) {
    var shortItem = shortContent[index];
    if (shortItem is ConversationInStorage) {
      return content[shortItem.cardNumber];
    } else {
      return null;
    }
  }
}
