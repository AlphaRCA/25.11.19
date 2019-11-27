import 'package:hold/model/played_item.dart';
import 'package:hold/storage/conversation_content.dart';

class Conversation {
  final int cardNumber;
  final DateTime _created;
  final ReflectionType type;
  String title = "";
  List<ConversationContent> content = new List();
  int positiveMood;

  Conversation(this.cardNumber, this.type, {DateTime created})
      : this._created = created ?? DateTime.now();

  DateTime get created => _created;

  bool get isFinished => positiveMood != null;

  List<PlayedItem> formTextListForVoiceFunction() {
    List<PlayedItem> allText = new List();
    allText.add(PlayedItem(getTitle(), conversationCardId: cardNumber));
    for (ConversationContent item in content) {
      allText.add(item.getPlayedItem());
    }
    return allText;
  }

  String getTitle() {
    return title.isEmpty
        ? positiveMood == null ? "Incomplete" : "Untitled"
        : title;
  }

  String getFirstText() {
    if (content.length > 0)
      return content[0].text;
    else
      return "";
  }
}

enum ReflectionType { A, B }
