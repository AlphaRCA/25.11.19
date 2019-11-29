import 'package:flutter/material.dart';
import 'package:hold/bloc/collection_selection_bloc.dart';
import 'package:hold/model/collection_short_data.dart';
import 'package:hold/rename_screen.dart';
import 'package:hold/widget/buttons/appbar_back.dart';
import 'package:hold/widget/buttons/bottom_button_in_stack.dart';
import 'package:hold/widget/buttons/collection_action.dart';
import 'package:hold/widget/collection_addable.dart';

import 'constants/app_colors.dart';

class CollectionSelectionScreen extends StatefulWidget {
  final int reflectionIdToAdd;

  const CollectionSelectionScreen(
    this.reflectionIdToAdd, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CollectionSelectionScreenState();
  }
}

class _CollectionSelectionScreenState extends State<CollectionSelectionScreen> {
  CollectionSelectionBloc bloc;

  @override
  void initState() {
    bloc = new CollectionSelectionBloc(widget.reflectionIdToAdd);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: AppBarBack(),
          title: Text("Select collection"),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    CollectionAction("Add to new collection", () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RenameScreen(
                              "How would you name \nyour new collection?",
                              bloc.createCollection)));
                    }),
                    StreamBuilder<List<CollectionShortData>>(
                      stream: bloc.collectionList,
                      initialData: List(),
                      builder: (BuildContext ctxt,
                          AsyncSnapshot<List<CollectionShortData>> data) {
                        List<CollectionShortData> list = data.data;
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (BuildContext context, int index) {
                              return CollectionAddable(list[index], () {
                                bloc.addCollection(list[index].collectionId);
                              }, () {
                                bloc.removeCollection(list[index].collectionId);
                              },
                                  bloc.inCollectionConversations
                                      .contains(list[index].collectionId));
                            });
                      },
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomButtonInStack(
                "DONE",
                () async {
                  Navigator.of(context).pop();
                },
                textColor: AppColors.ACTION_LIGHT_TEXT,
                buttonColor: AppColors.TEXT_EF,
              ),
            )
          ],
        ));
  }
}
