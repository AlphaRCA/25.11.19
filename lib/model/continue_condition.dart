import 'package:hold/model/played_item.dart';

class ContinueCondition {
  final int conversationId;
  final int reflectionId;
  final bool isFullCollection;

  ContinueCondition(
      {this.conversationId, this.reflectionId, this.isFullCollection = false});

  bool canPlay(PlayedItem item, bool isContinuous) {
    print(
        "let's check if it can be played. Condition is ($conversationId, $reflectionId, $isFullCollection). "
        "Checked item is ${item.toString()}. IsContinuous $isContinuous");
    if (isContinuous) {
      return true;
    } else {
      if (isFullCollection) {
        return true;
      } else {
        if (conversationId != null &&
            conversationId == item.conversationCardId) {
          return true;
        } else {
          if (item.reflectionId != null && item.reflectionId == reflectionId) {
            return true;
          } else {
            return false;
          }
        }
      }
    }
  }
}
