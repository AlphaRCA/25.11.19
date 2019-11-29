import 'package:flutter/material.dart';
import 'package:hold/bloc/collection_info_bloc.dart';
import 'package:hold/bloc/conversation_full_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/reflecting_further_screen.dart';
import 'package:hold/storage/conversation_in_storage.dart';
import 'package:hold/widget/animation_parts/scale_route.dart';
import 'package:hold/widget/buttons/circular_play_progress.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';

import '../collection_selection_screen.dart';

class ConversationPlayableView extends StatelessWidget {
  static const REMOVE = "Remove from this collection";
  static const ADD_TO_COLLECTION = "Add to another collection";
  static const REVIEW = "View conversation";
  static const REFLECT = "Reflect on this conversation";

  final ConversationInStorage content;
  final CollectionInfoBloc bloc;
  final VoidCallback showFullView;
  final List<String> menuOptions;

  const ConversationPlayableView(this.content, this.bloc, this.showFullView,
      {Key key, bool isInsideAuto = false})
      : this.menuOptions = isInsideAuto
            ? const [ADD_TO_COLLECTION, REVIEW, REFLECT]
            : const [REMOVE, ADD_TO_COLLECTION, REVIEW, REFLECT],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onTap: showFullView,
        child: Container(
          padding: EdgeInsets.all(16.0),
          color: AppColors.REFLECTION_LIST_BG,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
                child: CircularPlayProgress(
                  bloc,
                  conversationId: content.cardNumber,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      content.title.length > 0 ? content.title : "Incomplete",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.TEXT_EF,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    Text(
                      content.firstText,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.COLLECTION_SUBTITLE),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  _showDialog(value, context);
                },
                itemBuilder: (BuildContext context) {
                  return menuOptions.map((String choice) {
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
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(String variant, BuildContext context) {
    switch (variant) {
      case REFLECT:
        _openReflectionScreen(context);
        break;
      case ADD_TO_COLLECTION:
        _openCollectionSelection(context);
        break;
      case REVIEW:
        showFullView();
        break;
      case REMOVE:
        _showDeleteDialog(context);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    DialogLaunchers.showAnimatedDelete(
      context,
      mainText:
          "Are you sure you want to remove '${content.title}' from this collection?",
      yesAction: () {
        bloc.removeConversation(content.cardNumber);
      },
      title: "Remove conversation",
      titleIcon: Icons.delete_outline,
      toastText: "${content.title} removed from collection",
    );
  }

  void _openReflectionScreen(BuildContext context) {
    ConversationFullBloc reflectionBloc =
        new ConversationFullBloc(content.cardNumber);
    Navigator.of(context)
        .push(ScaleRoute(page: ReflectingFurtherScreen(reflectionBloc)));
  }

  Future _openCollectionSelection(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CollectionSelectionScreen(content.cardNumber)));
  }
}
