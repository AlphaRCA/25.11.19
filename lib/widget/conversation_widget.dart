import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/conversation_creation_bloc.dart';
import 'package:hold/bloc/conversation_full_bloc.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/notification_bloc.dart';
import 'package:hold/bloc/recent_activity_bloc.dart';
import 'package:hold/collection_selection_screen.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/conversation_widget_content.dart';
import 'package:hold/reflecting_further_screen.dart';
import 'package:hold/rename_screen.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:hold/utils/hightlighted_text_util.dart';
import 'package:hold/widget/dialogs/dialog_compete_it.dart';

import '../conversation_creation_screen.dart';
import 'animation_parts/scale_route.dart';
import 'launchers/dialog_launchers.dart';

class ConversationWidget extends StatelessWidget {
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

  final ConversationWidgetContent content;
  final RecentActivityBloc bloc;
  final int selectedId;
  final GlobalKey outerContainerKey;

  TextStyle positiveHighlightMatch = TextStyle(
    backgroundColor: AppColors.DARK_BACKGROUND.withOpacity(.54),
  );

  ConversationWidget(
    this.content,
    this.bloc,
    this.selectedId,
    this.outerContainerKey, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String search = bloc.lastSearch ?? "";
    search = search.toLowerCase();
    bool isTitleHighlighted =
        search.isNotEmpty && content.getTitle().toLowerCase().contains(search);
    bool isTextHighlighted =
        search.isNotEmpty && content.shortText.toLowerCase().contains(search);

    String highlighted = "";
    if (isTitleHighlighted || isTextHighlighted) {
      String textToHighlight =
          isTitleHighlighted ? content.getTitle() : content.shortText;
      int divider1 = textToHighlight.toLowerCase().indexOf(search);
      int divider2 = divider1 + search.length;
      highlighted = textToHighlight.substring(divider1, divider2);
    }
    GlobalKey globalKey = new GlobalKey();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        key: globalKey,
        onTap: () {
          _openReflectionScreen(context, globalKey);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
          color: AppColors.REFLECTION_LIST_BG,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 24.0,
                      child: !content.isFinished
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
                                  content.getNumberDateText(),
                                  style: TextStyle(
                                      color: AppColors.REFLECTION_SUBTITLE),
                                ),
                              ],
                            )
                          : Text(
                              content.getNumberDateText(),
                              style: TextStyle(
                                  color: AppColors.REFLECTION_SUBTITLE),
                            ),
                    ),
                    RichText(
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
                          _getTitle(content),
                          highlighted,
                          positiveHighlightMatch,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    RichText(
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
                          content.shortText,
                          highlighted,
                          positiveHighlightMatch,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    _showDialog(value, context);
                  },
                  itemBuilder: (BuildContext context) {
                    return MENU_OPTIONS.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(
                          choice,
                          style: TextStyle(color: AppColors.TEXT),
                        ),
                      );
                    }).toList();
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.REFLECTION_ICON,
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

  void _showDialog(String variant, BuildContext context) {
    switch (variant) {
      case DELETE:
        _showDeleteDialog(context);
        break;
      case RENAME:
        _showRenameScreen(context);
        break;
      case ADD_TO_COLLECTION:
        _showSelectionCollectionScreen(context);
        break;
      case SET_A_REMINDER:
        _showReminderDialog(context);
        break;
    }
  }

  void _openReflectionScreen(BuildContext context, GlobalKey globalKey) async {
    MixPanelProvider().trackEvent("REFLECT", {
      "Open Conversation": DateTime.now().toIso8601String(),
    });
    final RenderBox containerRenderBox = context.findRenderObject();
    if (content.isFinished) {
      ConversationFullBloc blocInside =
          new ConversationFullBloc(content.cardNumber);
      await Navigator.of(context).push(ScaleRoute(
          page: ReflectingFurtherScreen(
        blocInside,
        initialHeight: containerRenderBox.size.height,
        initialWidth: containerRenderBox.size.width,
        offset: containerRenderBox.localToGlobal(Offset.zero),
      )));
    } else {
      await DialogLaunchers.showDialog(
          context: context, dialog: DialogCompleteIt());
      ConversationCreationBloc blocInside = new ConversationCreationBloc(
          unfinishedCardNumber: content.cardNumber);
      await Navigator.of(context).push(ScaleRoute(
        page: ConversationCreationScreen(
          blocInside,
          initialHeight: globalKey.currentContext.size.height,
          initialWidth: globalKey.currentContext.size.width,
          offset: containerRenderBox.localToGlobal(Offset.zero),
        ),
      ));
    }
    bloc.updateList();
  }

  void _showDeleteDialog(BuildContext context) {
    MixPanelProvider().trackEvent("CONVERSATION", {
      "Pageview Delete Section Conversation Popup":
          DateTime.now().toIso8601String(),
    });
    DialogLaunchers.showAnimatedDelete(
      context,
      title: "Delete conversation",
      mainText: "Are you sure you want to delete this conversation?",
      yesAction: () {
        MixPanelProvider().trackEvent("CONVERSATION", {
          "Click Delete Section Conversation Button Yes":
              DateTime.now().toIso8601String(),
        });
        bloc.deleteReflection(content.cardNumber);
      },
      noAction: () {
        MixPanelProvider().trackEvent("CONVERSATION", {
          "Click Delete Section Conversation Button No":
              DateTime.now().toIso8601String(),
        });
      },
      titleIcon: Icons.delete_outline,
      toastText: "'${content.getTitle()}' deleted",
    );
  }

  void _showRenameScreen(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RenameScreen(
              "How would you rename \nyour conversation?",
              (value) async {
                if (value != null) {
                  await StorageProvider()
                      .updateConversationName(value, content.cardNumber);
                  bloc.updateList();
                }
              },
              name: content.title,
              isCreating: false,
            )));
  }

  void _showSelectionCollectionScreen(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CollectionSelectionScreen(content.cardNumber)));
  }

  void _showReminderDialog(BuildContext context) async {
    NotificationBloc bloc = new NotificationBloc();
    await bloc.initReminderItem(content.cardNumber, content.getTitle());
    await DialogLaunchers.showReminderDialog(context, bloc);
  }
}
