import 'package:flutter/material.dart';
import 'package:hold/bloc/collection_info_bloc.dart';
import 'package:hold/bloc/collections_list_bloc.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/collection_info_screen.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/collection_short_data.dart';
import 'package:hold/rename_screen.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';

import '../conversation_selection_screen.dart';

class CollectionShortView extends StatelessWidget {
  static const RENAME = "Rename collection";
  static const DELETE = "Delete collection";
  static const ADD_TO_COLLECTION = "Add more conversations";
  static const REVIEW = "Review this collection";
  static const MENU_OPTIONS = [
    RENAME,
    DELETE,
    ADD_TO_COLLECTION,
    REVIEW,
  ];

  final CollectionShortData content;
  final CollectionsListBloc bloc;

  const CollectionShortView(
    this.content,
    this.bloc, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          _openCollectionEditScreen(context);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
          color: AppColors.REFLECTION_LIST_BG,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    content.getName(),
                    style: TextStyle(
                      color: AppColors.ORANGE_BUTTON_BACKGROUND,
                      fontWeight: FontWeight.bold,
                      fontSize: 21.13,
                    ),
                  ),
                  Text(
                    content.getNumberText(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.COLLECTION_SUBTITLE),
                    maxLines: 1,
                  ),
                ],
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

  void _showDialog(String variant, BuildContext context) {
    switch (variant) {
      case DELETE:
        _showDeleteDialog(context);
        break;
      case RENAME:
        _showRenameScreen(context);
        break;
      case ADD_TO_COLLECTION:
        _showAddScreen(context);
        break;
      case REVIEW:
        _showFullCollectionWithReviewStep(context);
        break;
    }
  }

  void _openCollectionEditScreen(BuildContext context) async {
    CollectionInfoBloc infoBloc = new CollectionInfoBloc(content.collectionId);
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CollectionInfoScreen(infoBloc)));
    bloc.reloadCollections();
  }

  void _showDeleteDialog(BuildContext context) {
    MixPanelProvider().trackEvent("COLLECTION", {
      "Pageview Delete Collection Popup": DateTime.now().toIso8601String(),
    });
    DialogLaunchers.showAnimatedDelete(
      context,
      title: "Delete collection",
      mainText: "Are you sure you want to delete '${content.getName()}'?",
      yesAction: () {
        MixPanelProvider().trackEvent("COLLECTION", {
          "Click Delete Collection Button Yes":
              DateTime.now().toIso8601String(),
        });
        bloc.deleteCollection(content.collectionId);
      },
      noAction: () {
        MixPanelProvider().trackEvent("COLLECTION", {
          "Click Delete Collection Button No": DateTime.now().toIso8601String(),
        });
      },
      titleIcon: Icons.delete_outline,
      toastText: "Part of the collection deleted",
    );
  }

  void _showRenameScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RenameScreen(
          "How would you rename \nyour collection?",
          (value) async {
            await bloc.renameCollection(value, content.collectionId);
            return content.collectionId;
          },
          name: content.collectionName,
          isCreating: false,
        ),
      ),
    );
  }

  Future _showAddScreen(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ConversationSelectionScreen(
              collectionId: content.collectionId,
            )));
    bloc.reloadCollections();
  }

  void _showFullCollectionWithReviewStep(BuildContext context) {
    CollectionInfoBloc infoBloc = new CollectionInfoBloc(content.collectionId);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CollectionInfoScreen(
              infoBloc,
              initialScreenState: InfoScreenState.reviewQuestionSelection,
            )));
  }
}
