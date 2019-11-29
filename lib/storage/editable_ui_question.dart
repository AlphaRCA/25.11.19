class EditableUIQuestion {
  static const TABLE_NAME = "question";

  static const COLUMN_ID = "id";
  static const COLUMN_TITLE = "main_text";
  static const COLUMN_SUBTITLE = "subtitle";
  static const COLUMN_DESCRIPTION = "description";
  static const COLUMN_INFO = "info";
  static const COLUMN_IS_CONVERSATION = "reflection";
  static const COLUMN_LEVEL = "level";
  static const COLUMNS = [
    COLUMN_ID,
    COLUMN_TITLE,
    COLUMN_SUBTITLE,
    COLUMN_DESCRIPTION,
    COLUMN_INFO,
    COLUMN_LEVEL
  ];

  static const CREATE_EXPRESSION = '''
            create table $TABLE_NAME ( 
              $COLUMN_ID integer primary key autoincrement, 
              $COLUMN_IS_CONVERSATION int not null,
              $COLUMN_LEVEL int,
              $COLUMN_TITLE text,
              $COLUMN_DESCRIPTION text,
              $COLUMN_INFO text,
              $COLUMN_SUBTITLE text)
            ''';

  final int id;
  final String title;
  final String subtitle;
  final String description;
  final String information;
  final int level;

  const EditableUIQuestion(this.id, this.title, this.description,
      this.information, this.subtitle, this.level);

  Map<String, dynamic> toMap(bool isReflection) {
    var map = <String, dynamic>{
      COLUMN_IS_CONVERSATION: isReflection ? 1 : 0,
      COLUMN_TITLE: title ?? "",
      COLUMN_SUBTITLE: subtitle,
      COLUMN_DESCRIPTION: description ?? "",
      COLUMN_INFO: information ?? "",
      COLUMN_LEVEL: level ?? 1,
    };
    if (id != 0) {
      map[COLUMN_ID] = id;
    }
    return map;
  }

  EditableUIQuestion.fromMap(Map<String, dynamic> map)
      : id = map[COLUMN_ID],
        title = map[COLUMN_TITLE] ?? "",
        description = map[COLUMN_DESCRIPTION] ?? "",
        information = map[COLUMN_INFO] ?? "",
        subtitle = map[COLUMN_SUBTITLE],
        level = map[COLUMN_LEVEL];

  static const List<EditableUIQuestion> PREDEFINED_FOR_REFLECTION = [
    EditableUIQuestion(
        1,
        "Narrate",
        "What stimulated you to write this particular conversation?",
        "Welcome to Tier 1! At this stage you should feel supported, these "
            "questions are designed to introduce you to a set of tools that "
            "have the potential to improve your sense of self-reflection. This "
            "tool helps to bring clarity to your reflection. Using it can "
            "bring direction and order to what you have written and can "
            "highlight the way in which your writing is connected to your life.",
        "Stage 1",
        1),
    EditableUIQuestion(
        2,
        "Describe",
        "Describe, with several carefully chosen details, the person/people involved in this conversation",
        "Welcome to Stage 1! At this stage you should feel supported, these questions are designed to introduce you to a set of tools that have the potential to improve your sense of self-reflection. This tool helps to make your reflection more vivid. Thinking about the detail and specific parts of what you have already written more carefully, reveals your experiences and the meanings and emotions you associate with those experiences.",
        "Stage 2",
        2),
    EditableUIQuestion(
        3,
        "Examine",
        "Write one fact that is related to this conversation",
        "Welcome to Stage 1! At this stage you should feel supported, these questions are designed to introduce you to a set of tools that have the potential to improve your sense of self-reflection. This tool helps you create more objective understanding. Through considering the facts and information you will be able to examine the layers of information that you are constantly processing. This will encourage you to analyse what effect your situations, thoughts and feelings, are having on you and your life.",
        "Stage 3",
        3),
  ];

  static const List<EditableUIQuestion> PREDEFINED_FOR_COLLECTION = [
    EditableUIQuestion(
        5,
        "Place",
        "Identify and describe a place that connects your conversations together",
        "Identifying patterns in your reflections allows you to identify patterns in your life, your lifestyle and yourself. Considering these patterns allows you to consider what might be occupying your thoughts, emotions and behaviours on a subconscious level. Developing the geographical details of your reflections will help you build a vivid picture of your reflections, memories, ideas and ambitions.",
        "Pattern - Stage 1",
        1),
    EditableUIQuestion(
        6,
        "Emotions",
        "What were you feeling when you wrote these conversations?",
        "Identifying meanings in your reflections allows you to identify meaning in your life. Considering the meaning in the reflections helps you to see how situations, emotions, yourself and other people all contribute to your perception of something being meaningful in your life. Reviewing the emotional content of your reflections will help you uncover the meaning of the feelings that accompany situations and how your emotions, or attempts to cover your emotions, influence all the various situations in your life.",
        "Meaning - Stage 2",
        2),
    EditableUIQuestion(
        7,
        "Questions",
        "Describe a pattern you notice in the questions you ask yourself",
        "Identifying how you are thinking in your reflections allows you to identify how you think in your day-to-day life. Considering the frequency, completeness and detail of your thoughts allows you to consider how you can develop and maintain useful and healthy thought processes. Assessing the questions you ask yourself is not easy, but if you can consciously improve the quality of questions you ask yourself your self-reflection practice will deepen and improve.",
        "Thinking - Stage 3",
        3),
  ];
}
