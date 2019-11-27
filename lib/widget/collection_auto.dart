import 'package:flutter/material.dart';
import 'package:hold/bloc/collection_info_bloc.dart';
import 'package:hold/bloc/collections_list_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/collection_short_data.dart';

import '../collection_info_screen.dart';

class CollectionAuto extends StatelessWidget {
  final CollectionShortData content;
  final CollectionsListBloc bloc;

  const CollectionAuto(
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
          _openCollectionViewScreen(context);
        },
        child: Container(
          padding: EdgeInsets.all(16.0),
          color: AppColors.REFLECTION_LIST_BG,
          child: Column(
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
        ),
      ),
    );
  }

  void _openCollectionViewScreen(BuildContext context) async {
    CollectionInfoBloc infoBloc = new CollectionInfoBloc(content.collectionId);
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CollectionInfoScreen(infoBloc)));
    bloc.reloadCollections();
  }
}
