import 'package:hold/model/reflection.dart';
import 'package:hold/storage/conversation_in_storage.dart';

class GraphValue {
  final int value;
  final int cardNumber;

  GraphValue(this.value, this.cardNumber);

  GraphValue.fromMap(Map map)
      : value = map[ConversationInStorage.COLUMN_POSITIVE],
        cardNumber = map[Reflection.COLUMN_CARD_NUMBER];
}
