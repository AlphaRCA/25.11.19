import 'package:flutter/material.dart';
import 'package:hold/bloc/conversation_creation_bloc.dart';
import 'package:hold/bloc/conversation_full_bloc.dart';
import 'package:hold/bloc/play_controller.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/conversation_for_review.dart';
import 'package:hold/storage/conversation_content.dart';
import 'package:hold/widget/animation_parts/scale_route.dart';
import 'package:hold/widget/buttons/bottom_button_in_stack.dart';
import 'package:hold/widget/buttons/play_action.dart';
import 'package:hold/widget/constructors/conversation_constructor.dart';

import '../../conversation_creation_screen.dart';
import '../../reflecting_further_screen.dart';

class ConversationInCollectionConstructor extends ConversationConstructor {
  final ConversationForReview content;
  final int initialVoiceIndex;
  final PlayController playController;
  final VoidCallback _shrinkReflections;
  int playableIndex, textPartIndex;
  List<int> voiceKeys;

  ConversationInCollectionConstructor(
      this.playController,
      this.content,
      this.initialVoiceIndex,
      this.textPartIndex,
      this._shrinkReflections,
      double screenWidth)
      : super(playController, screenWidth);

  Widget _getConversationTitle() {
    return Padding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          textPartIndex <= 1
              ? Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    color: Color(0x8afafafa),
                    onPressed: _shrinkReflections,
                    icon: Icon(Icons.close),
                  ),
                )
              : Container(),
          SizedBox(
            height: 64,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              content.getNumberDateText(),
              style: TextStyle(fontSize: 14, color: AppColors.BOTTOM_SHEET_BG),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              content.mainConversation.title,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.TITLE_WHITE),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 32.0),
            child: PlayAction(
              playController,
              content.mainConversation.cardNumber,
            ),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
    );
  }

  void formParts(BuildContext context) {
    voiceKeys = new List();
    playableIndex = initialVoiceIndex ?? 1;
    finishedParts.add(
      Container(
        color: AppColors.APP_BAR,
        child: _getConversationTitle(),
      ),
    );
    voiceKeys.add(textPartIndex++);
    playableIndex++;
    for (ConversationContent innerContent in content.mainConversation.content) {
      finishedParts.add(
        Container(
          color: AppColors.APP_BAR,
          child: getFinishedItem(playableIndex, content.mainConversation.type,
              innerContent.getPlayedItem()),
        ),
      );
      voiceKeys.add(textPartIndex++);
      playableIndex++;
    }

    finishedParts.add(Container(
      color: AppColors.APP_BAR,
      child: getMoodTitle(),
    ));
    finishedParts.add(
      Container(
        color: AppColors.APP_BAR,
        child: getMoodResult(content.mainConversation.positiveMood, 40),
      ),
    );

    if (content.additionals != null && content.additionals.length > 0) {
      for (int i = 0; i < content.additionals.length; i++) {
        finishedParts
            .add(getFinishedAdditional(content.additionals[i].toPlayedText()));
        voiceKeys.add(textPartIndex);
        textPartIndex++;
        playableIndex++;
      }

      finishedParts.add(_getConversationButton(context));
    } else {
      finishedParts.add(_getConversationButton(context));
    }
  }

  Widget _getConversationButton(context) {
    final GlobalKey buttonKey = new GlobalKey();
    return Container(
      color: AppColors.APP_BAR,
      padding: EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 32.0),
      margin: EdgeInsets.only(bottom: 8.0),
      child: BottomButtonInStack(
        "REFLECT ON THIS CONVERSATION",
        () {
          RenderBox renderBox = buttonKey.currentContext.findRenderObject();
          _openConversationScreen(
              context,
              content.mainConversation,
              buttonKey.currentContext.size.width,
              buttonKey.currentContext.size.height,
              renderBox.localToGlobal(Offset.zero));
        },
        textColor: AppColors.ACTION_LIGHT_TEXT,
        buttonColor: AppColors.TEXT_EF,
        rounded: true,
        key: buttonKey,
      ),
    );
  }

  void _openConversationScreen(
      BuildContext context,
      content,
      double clickedItemWidth,
      double clickedItemHeight,
      Offset clickedItemOffset) async {
    bool result;
    if (content.isFinished) {
      ConversationFullBloc blocInside =
          new ConversationFullBloc(content.cardNumber);
      result = await Navigator.of(context)
          .push(ScaleRoute(page: ReflectingFurtherScreen(blocInside)));
    } else {
      ConversationCreationBloc blocInside = new ConversationCreationBloc(
          unfinishedCardNumber: content.cardNumber);
      result = await Navigator.of(context).push(ScaleRoute(
          page: ConversationCreationScreen(
        blocInside,
        offset: clickedItemOffset,
        initialWidth: clickedItemWidth,
        initialHeight: clickedItemHeight,
        initialColor: AppColors.ORANGE_BUTTON_BACKGROUND,
      )));
    }
    print("RESULT AFTER Reflection open: $result");
  }
}
