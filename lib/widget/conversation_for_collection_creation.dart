import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/conversation_widget_content.dart';
import 'package:hold/utils/hightlighted_text_util.dart';

class ConversationForCollectionCreation extends StatefulWidget {
  final ConversationWidgetContent content;
  final OnConversationSelection onSelect;
  final bool isSelected;
  final String highlightString;

  const ConversationForCollectionCreation(this.content, this.onSelect,
      {Key key, this.isSelected = false, this.highlightString = ""})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ReflectionForCollectionState();
  }
}

class _ReflectionForCollectionState
    extends State<ConversationForCollectionCreation> {
  bool isSelected;

  TextStyle positiveHighlightMatch = TextStyle(
    backgroundColor: AppColors.DARK_BACKGROUND.withOpacity(.54),
  );

  @override
  void initState() {
    isSelected = widget.isSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onTap: _setSelectionState,
        child: Container(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
          color: isSelected
              ? AppColors.REFLECTION_LIST_SELECTED_BG
              : AppColors.REFLECTION_LIST_BG,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  !widget.content.isFinished
                      ? Row(
                          children: <Widget>[
                            SvgPicture.asset(
                              'assets/material_icons/rounded/content/report.svg',
                              color: Color(0xffFACDC9),
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              widget.content.getNumberDateText(),
                              style: TextStyle(
                                  color: AppColors.REFLECTION_SUBTITLE),
                            ),
                          ],
                        )
                      : Text(
                          widget.content.getNumberDateText(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.REFLECTION_SUBTITLE,
                          ),
                        ),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: _setSelectionState,
                      icon: isSelected
                          ? Icon(
                              Icons.done_outline,
                              color: AppColors.ORANGE_BUTTON_BACKGROUND,
                            )
                          : SvgPicture.asset(
                              'assets/material_icons/rounded/content/add.svg',
                              height: 14.0,
                              color: AppColors.REFLECTION_ICON,
                            ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: RichText(
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                  text: TextSpan(
                    style: TextStyle(
                      color: AppColors.TEXT_EF,
                      fontFamily: "Cabin",
                      fontWeight: FontWeight.bold,
                      fontSize: 25.36,
                    ),
                    children: hightlightedText(
                      _getTitle(widget.content),
                      widget.highlightString,
                      positiveHighlightMatch,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                    style: TextStyle(
                      color: AppColors.TITLE_WHITE,
                      fontFamily: "Cabin",
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                    children: hightlightedText(
                      widget.content.shortText,
                      widget.highlightString,
                      positiveHighlightMatch,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle(ConversationWidgetContent content) {
    if (!content.isFinished && content.getTitle() == "Untitled") {
      return "Incomplete";
    }

    return content.getTitle();
  }

  void _setSelectionState() {
    widget.onSelect(widget.content.cardNumber, !isSelected);
    setState(() {
      isSelected = !isSelected;
    });
  }
}

typedef OnConversationSelection(int cardNum, bool selectionState);
