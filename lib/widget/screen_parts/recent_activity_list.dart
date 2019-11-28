import 'package:flutter/material.dart';
import 'package:hold/bloc/recent_activity_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/conversation_widget_content.dart';
import 'package:hold/widget/conversation_short_calculating.dart';
import 'package:hold/widget/conversation_widget.dart';
import 'package:hold/widget/dual_scroll_controller.dart';
import 'package:hold/widget/screen_parts/no_results_text_widget.dart';
import 'package:hold/widget/white_text.dart';

import '../buttons/bottom_button_in_stack.dart';

class RecentActivityList extends StatefulWidget {
  final RecentActivityBloc bloc;
  final DualScrollController controller;
  final VoidCallback onCreateFirstConversation;
  final GlobalKey outerContainerKey;

  RecentActivityList(
    this.bloc,
    this.controller,
    this.outerContainerKey, {
    Key key,
    this.onCreateFirstConversation,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RecentActivityListState();
  }
}

class RecentActivityListState extends State<RecentActivityList> {
  bool _isSearchResult = false;
  int _selectedId = 0;

  final GlobalKey _listViewKey = GlobalKey();
  final GlobalKey _listTitleKey = GlobalKey();

  RenderBox _listViewBox;
  RenderBox _listTitleBox;

  double listViewHeight = 0;
  double listViewBottomOffset = 0;

  void selectItem(int id) {
    setState(() {
      _selectedId = id;
    });

    calculateListBottomOffset();
  }

  void setIsSearchResult(bool value) {
    setState(() {
      _isSearchResult = value;
    });
  }

  void calculateListBottomOffset() {
    if (_listViewBox == null)
      _listViewBox =
          _listViewKey.currentContext.findRenderObject() as RenderBox;

    if (_listTitleBox == null)
      _listTitleBox =
          _listTitleKey.currentContext.findRenderObject() as RenderBox;

    widget.controller.setListTitleHeight(_listTitleBox.size.height);

    setState(() {
      listViewHeight = _listViewBox.size.height;
      listViewBottomOffset = listViewHeight - widget.controller.listItemHeight;
    });
  }

  @override
  void initState() {
    super.initState();

    widget.controller.listController.addListener(() {
      calculateListBottomOffset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConversationWidgetContent>>(
      stream: widget.bloc.reflectionList,
      initialData: new List(),
      builder: (BuildContext context,
          AsyncSnapshot<List<ConversationWidgetContent>> snapshot) {
        List<ConversationWidgetContent> list = snapshot.data;
        if (list.length == 0) {
          return _isSearchResult
              ? NoResultTextWidget()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        "In this section you can go back to all your previous conversations.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.TEXT,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        "You can read or listen to them and add new reflections.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.TEXT,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Spacer(),
                    BottomButtonInStack(
                      "START YOUR FIRST CONVERSATION",
                      widget.onCreateFirstConversation,
                      textColor: AppColors.ACTION_LIGHT_TEXT,
                      buttonColor: AppColors.TEXT_EF,
                    )
                  ],
                );
        }
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ListView.builder(
              key: _listViewKey,
              physics: ClampingScrollPhysics(),
              controller: widget.controller.listController,
              itemCount: list.length + 2,
              itemBuilder: (BuildContext ctxt, int index) {
                if (index == list.length + 1) {
                  if (_isSearchResult) return Container();
                }
                if (index == 0) {
                  if (_isSearchResult)
                    return Container();
                  else
                    return Padding(
                      key: _listTitleKey,
                      padding: EdgeInsets.only(left: 16, top: 24, bottom: 12.0),
                      child: WhiteText(
                        "RECENT CONVERSATIONS",
                        paddingAll: 0,
                      ),
                    );
                }
                if (index == 1) {
                  return ConversationShortCalculating(list[0], widget.bloc,
                      widget.controller, _selectedId, widget.outerContainerKey);
                }

                if (index > list.length) {
                  return SizedBox(
                    height: listViewHeight > widget.controller.listItemHeight
                        ? listViewBottomOffset
                        : widget.controller.listItemHeight * 3,
                  );
                }

                return ConversationWidget(list[index - 1], widget.bloc,
                    _selectedId, widget.outerContainerKey);
              },
            ),
            Container(
              height: 8.0,
              decoration: BoxDecoration(
                color: AppColors.EMOTION_LOG_BG,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 4,
                    offset: Offset(0, 6.0),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
