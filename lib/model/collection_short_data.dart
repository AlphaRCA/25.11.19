class CollectionShortData {
  final int collectionId;
  String collectionName;
  final bool autoCreated;
  int conversationNumber;

  CollectionShortData(this.collectionId, this.autoCreated);

  String getNumberText() {
    if (conversationNumber == 1) {
      return "$conversationNumber conversation";
    } else {
      return "$conversationNumber conversations";
    }
  }

  String getName() {
    if (collectionName == null || collectionName.isEmpty) {
      return "Untitled collection";
    } else {
      return collectionName;
    }
  }
}
