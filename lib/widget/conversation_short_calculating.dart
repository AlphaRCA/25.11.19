import 'package:flutter/material.dart';
import 'package:hold/bloc/recent_activity_bloc.dart';
import 'package:hold/model/conversation_widget_content.dart';
import 'package:hold/widget/conversation_widget.dart';
import 'package:hold/widget/dual_scroll_controller.dart';

class ConversationShortCalculating extends StatefulWidget {
  final ConversationWidgetContent content;
  final RecentActivityBloc bloc;
  final DualScrollController controller;
  final int selectedId;
  final GlobalKey outerContainerKey;

  const ConversationShortCalculating(
    this.content,
    this.bloc,
    this.controller,
    this.selectedId,
    this.outerContainerKey, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConversationShortCalculatingState();
  }
}

class _ConversationShortCalculatingState
    extends State<ConversationShortCalculating> {
  static const RENAME = "Rename";
  static const DELETE = "Delete";
  static const ADD_TO_COLLECTION = "Add to collection";
  static const SET_A_REMINDER = "Set a reminder for this";
  static const MENU_OPTIONS = [
    RENAME,
    DELETE,
    ADD_TO_COLLECTION,
    SET_A_REMINDER,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(Duration timeStamp) {
    final RenderBox renderBoxRed = context.findRenderObject() as RenderBox;
    final sizeRed = renderBoxRed.size;
    print("SIZE of Red: $sizeRed");
    widget.controller.setListItemSize(sizeRed.height);
  }

  @override
  Widget build(BuildContext context) {
    return ConversationWidget(widget.content, widget.bloc, widget.selectedId,
        widget.outerContainerKey);
  }
}
