import 'package:hold/storage/conversation_in_storage.dart';
import 'package:intl/intl.dart';

class ConversationWidgetContent {
  final int cardNumber;
  final DateTime created;
  final String title;
  final String shortText;
  final bool isFinished;

  ConversationWidgetContent(this.cardNumber, this.created, this.title,
      this.shortText, this.isFinished);

  ConversationWidgetContent.fromStorage(ConversationInStorage mainData)
      : cardNumber = mainData.cardNumber,
        created = mainData.created,
        isFinished = mainData.positiveMood != null,
        title = mainData.title,
        shortText = mainData.firstText;

  getDate() {
    return DateFormat("dd.MM.yy").format(created);
  }

  String getNumberDateText() {
    return "Conversation n.$cardNumber - ${getDate()}";
  }

  String getTitle() {
    return (title == null || title.isEmpty)
        ? !isFinished ? "Incomplete" : "Untitled"
        : title;
  }
}
