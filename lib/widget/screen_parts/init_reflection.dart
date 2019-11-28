import 'package:flutter/material.dart';
import 'package:hold/bloc/conversation_creation_bloc.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/conversation.dart';
import 'package:hold/storage/editable_ui_text.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:hold/widget/header_text.dart';

import '../../conversation_creation_screen.dart';
import 'invite_action.dart';

class InitReflection extends StatelessWidget {
  final OnCreationSuccess moveToReflectionList;

  const InitReflection(
    this.moveToReflectionList, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, EditableUIText>>(
        future: StorageProvider().getUITexts([
          EditableUIText.HOMEPAGE_ACTION_STATEMENT,
          EditableUIText.HOMEPAGE_DESCRIPTOR,
          EditableUIText.HOMEPAGE_ACTION1_TITLE,
          EditableUIText.HOMEPAGE_ACTION1_SUBTITLE,
          EditableUIText.HOMEPAGE_ACTION2_TITLE,
          EditableUIText.HOMEPAGE_ACTION2_SUBTITLE
        ]),
        initialData: EditableUIText.predefined,
        builder:
            (BuildContext ctxt, AsyncSnapshot<Map<int, EditableUIText>> data) {
          Map<int, EditableUIText> mapData =
              data.data ?? EditableUIText.predefined;
          GlobalKey containerKey = new GlobalKey();
          return Stack(
            key: containerKey,
            children: <Widget>[
              Positioned(
                top: 40.0,
                left: 16.0,
                right: 16.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    HeaderText(
                      (mapData[EditableUIText.HOMEPAGE_ACTION_STATEMENT]).text,
                      padding: EdgeInsets.only(top: 16.0),
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      (mapData[EditableUIText.HOMEPAGE_DESCRIPTOR]).text,
                      style: TextStyle(
                        color: AppColors.SEARCH_FIELD_TEXT,
                        fontSize: 12.68,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: InviteAction(
                                mapData[EditableUIText.HOMEPAGE_ACTION1_TITLE]
                                    .text,
                                mapData[EditableUIText
                                        .HOMEPAGE_ACTION1_SUBTITLE]
                                    .text,
                                AppColors.INVITE_QUESTION_REFLECTION,
                                (height, width, offset) async {
                              _eventStartConversation("Express");
                              _openConversationScreen(context, ReflectionType.B,
                                  height, width, offset);
                            }, new GlobalKey(), containerKey),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: InviteAction(
                                  mapData[EditableUIText.HOMEPAGE_ACTION2_TITLE]
                                      .text,
                                  mapData[EditableUIText
                                          .HOMEPAGE_ACTION2_SUBTITLE]
                                      .text,
                                  AppColors.INVITE_THOUGHT_REFLECTION,
                                  (height, width, offset) async {
                            _eventStartConversation("Question");
                            _openConversationScreen(context, ReflectionType.A,
                                height, width, offset);
                          }, new GlobalKey(), containerKey))
                        ],
                      ),
                    ],
                  )),
            ],
          );
        });
  }

  void _eventStartConversation(value) {
    MixPanelProvider()
        .trackEvent("Start Conversation", {"Conversation Type": value});
  }

  void _openConversationScreen(
      BuildContext context, ReflectionType type, height, width, offset) async {
    ConversationCreationBloc bloc = new ConversationCreationBloc(type: type);
    bool result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ConversationCreationScreen(
              bloc,
              initialHeight: height,
              initialWidth: width,
              offset: offset,
            )));
    if (result != null && result) {
      moveToReflectionList(
          bloc.conversation.cardNumber, bloc.conversation.title);
    }
  }
}

typedef void OnCreationSuccess(int createdReflectionId, String title);
