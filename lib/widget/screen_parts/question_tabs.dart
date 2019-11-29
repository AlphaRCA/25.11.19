import 'package:flutter/material.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/storage/editable_ui_question.dart';
import 'package:hold/widget/screen_parts/question_widget.dart';

class QuestionTabs extends StatefulWidget {
  final Future<List<EditableUIQuestion>> questions;
  final Future<int> questionLevel;
  final QuestionTapAction onCreateAnswer;
  final QuestionInfoAction infoAction;

  QuestionTabs(
    this.questions,
    this.questionLevel,
    this.onCreateAnswer,
    this.infoAction, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return QuestionTabsState();
  }
}

class QuestionTabsState extends State<QuestionTabs> {
  final PageController questionController =
      new PageController(viewportFraction: 0.85);
  int actualLevel = 1;
  List<EditableUIQuestion> questions = new List();

  @override
  void initState() {
    super.initState();
    _waitForFutures();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> questionWidgets = _formQuestions(questions, actualLevel);
    return questions.length == 0
        ? Container()
        : SizedBox(
            height: AppSizes.QUESTION_CARD_HEIGHT,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              scrollDirection: Axis.horizontal,
              children: questionWidgets,
            ),
          );
  }

  List<Widget> _formQuestions(List<EditableUIQuestion> uiQuestions, int level) {
    List<Widget> result = new List();
    for (var i = 0; i < uiQuestions.length; i++) {
      EditableUIQuestion question = uiQuestions[i];

      bool active = question.level <= level;
      result.add(
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: double.infinity,
          padding: i < uiQuestions.length - 1
              ? EdgeInsets.only(right: 16.0)
              : EdgeInsets.zero,
          child: QuestionWidget(
            question,
            widget.infoAction,
            widget.onCreateAnswer,
            active: active,
          ),
        ),
      );
    }
    return result;
  }

  void _waitForFutures() async {
    actualLevel = await widget.questionLevel;
    questions = await widget.questions;
    setState(() {});
  }
}
