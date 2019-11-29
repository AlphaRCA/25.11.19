class PlayedItem {
  final int conversationCardId;
  final int reflectionId;
  final int inConversationContentId;
  bool isPlayed = false;
  double percent;
  final String text;
  final String title;

  PlayedItem(
    this.text, {
    this.conversationCardId,
    this.reflectionId,
    this.inConversationContentId,
    this.title,
  });

  static final PlayedItem initial = new PlayedItem("");

  bool isIdentical(PlayedItem data) {
    return (reflectionId != null && reflectionId == data.reflectionId) ||
        (conversationCardId == data.conversationCardId &&
            (inConversationContentId != null &&
                inConversationContentId == data.inConversationContentId));
  }

  @override
  String toString() {
    return "isPlayed = $isPlayed, conversationCardId = $conversationCardId, reflectionId = $reflectionId, inConversationContentId=$inConversationContentId";
  }
}
