import 'package:hold/model/conversation.dart';
import 'package:hold/model/played_item.dart';
import 'package:hold/model/reflection.dart';
import 'package:hold/storage/conversation_content.dart';
import 'package:intl/intl.dart';

class ConversationForReview {
  final Conversation mainConversation;
  List<Reflection> additionals;

  ConversationForReview(this.mainConversation, this.additionals);

  void addReflection(Reflection reflection) {
    additionals.add(reflection);
  }

  getDate() {
    return DateFormat("dd.MM.yy").format(mainConversation.created);
  }

  String getNumberDateText() {
    return "Conversation n.${mainConversation.cardNumber} - ${getDate()}";
  }

  List<PlayedItem> formTextListForVoiceFunction() {
    if (mainConversation.isFinished) {
      return _formFinishedTextList();
    } else {
      return _formUnfinishedTextList();
    }
  }

  List<PlayedItem> _formUnfinishedTextList() {
    List<PlayedItem> result = new List();
    result.add(new PlayedItem(mainConversation.getTitle(),
        conversationCardId: mainConversation.cardNumber));
    if (mainConversation.content.length > 0) {
      for (ConversationContent content in mainConversation.content) {
        result.add(new PlayedItem(content.text,
            conversationCardId: content.cardNumber,
            inConversationContentId: content.id));
      }
    }
    return result;
  }

  List<PlayedItem> _formFinishedTextList() {
    List<PlayedItem> result = _formUnfinishedTextList();
    if (additionals != null && additionals.length > 0) {
      for (Reflection additionalReflection in additionals) {
        result.add(new PlayedItem(additionalReflection.myText,
            title: additionalReflection.title,
            conversationCardId: mainConversation.cardNumber,
            reflectionId: additionalReflection.id));
      }
    }
    return result;
  }
}
