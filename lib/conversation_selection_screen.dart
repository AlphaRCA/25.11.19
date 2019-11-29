import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/select_conversation_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/conversation_widget_content.dart';
import 'package:hold/rename_screen.dart';
import 'package:hold/widget/buttons/appbar_back.dart';
import 'package:hold/widget/conversation_for_collection_creation.dart';
import 'package:hold/widget/screen_parts/no_results_text_widget.dart';
import 'package:hold/widget/screen_parts/search_widget.dart';
import 'package:oktoast/oktoast.dart';

import 'widget/buttons/bottom_button.dart';
import 'widget/dialogs/general_toast.dart';

class ConversationSelectionScreen extends StatefulWidget {
  final int collectionId;

  const ConversationSelectionScreen({Key key, this.collectionId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConversationSelectionScreenState();
  }
}

class _ConversationSelectionScreenState
    extends State<ConversationSelectionScreen> {
  SelectConversationBloc bloc;
  bool _searchIsActive = false;
  String searchValue = "";

  @override
  void initState() {
    bloc = new SelectConversationBloc(collectionId: widget.collectionId);
    super.initState();
  }

  void _onSearch(String value) {
    bloc.search(value, updateFlag: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBack(),
        title: Text(
          "Add conversations",
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomButton(
        "DONE",
        () {
          _saveCollection(context);
        },
        buttonColor: AppColors.BOTTOM_ACTION_BG,
        textColor: AppColors.BOTTOM_ACTION_TEXT,
      ),
      body: Column(
        children: <Widget>[
          SearchWidget(_onSearch, onFocus: _onKeyboardAppeared),
          Expanded(
              child: FutureBuilder<List<int>>(
            future: bloc.existedCollectionIds,
            initialData: List(),
            builder: (BuildContext context, AsyncSnapshot<List<int>> data) {
              List<int> alreadySelected = data.data;

              return StreamBuilder<List<ConversationWidgetContent>>(
                initialData: new List(),
                stream: bloc.reflectionList,
                builder: (BuildContext context,
                    AsyncSnapshot<List<ConversationWidgetContent>> snapshot) {
                  List<ConversationWidgetContent> data = snapshot.data;

                  // If no data and search is not active then showing the label with text 'No results'
                  if (data.length <= 0 && !bloc.isLoading) {
                    return NoResultTextWidget();
                  }

                  if (bloc.isLoading) {
                    return SpinKitRipple(
                      color: AppColors.ORANGE_BUTTON_BACKGROUND,
                      size: 100.0,
                    );
                  }

                  return ListView(
                    children: <Widget>[
                      _searchIsActive
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 24.0),
                              child: Text(
                                "Select the conversations you want to add to your collection:",
                                style: TextStyle(
                                  color: AppColors.TEXT,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                      for (var item in data)
                        ConversationForCollectionCreation(
                          item,
                          (int cardNumber, bool isSelected) {
                            bloc.selectReflection(cardNumber, isSelected);
                            _onSelect(item, isSelected);
                          },
                          isSelected:
                              alreadySelected.contains(item.cardNumber) ||
                                  bloc.isSelectedReflection(item.cardNumber),
                          highlightString: bloc.lastSearch ?? "",
                        )
                    ],
                  );
                },
              );
            },
          ))
        ],
      ),
    );
  }

  void _onSelect(ConversationWidgetContent conversation, bool isSelected) {
    showToastWidget(
      GeneralToast(
        "'${conversation.getTitle()}' ${isSelected ? 'added' : 'deleted'}",
        image: isSelected
            ? SvgPicture.asset(
                'assets/material_icons/rounded/av/playlist_add.svg',
                color: Colors.white,
              )
            : SvgPicture.asset(
                'assets/material_icons/rounded/action/delete_outline.svg',
                color: Colors.white,
              ),
      ),
      duration: Duration(seconds: 2),
    );
  }

  void _saveCollection(BuildContext context) async {
    await bloc.saveCollection();
    if (widget.collectionId == null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RenameScreen(
            "How would you name \nyour new collection?",
            _onSave,
          ),
        ),
      );
    }
    Navigator.of(context).pop(true);
  }

  Future<int> _onSave(String collectionName) {
    Future.delayed(Duration(microseconds: 500), () {
      showToastWidget(
        GeneralToast(
          "'$collectionName' created",
          iconData: Icons.done_outline,
        ),
        duration: Duration(seconds: 2),
      );
    });

    return bloc.saveCollectionName(collectionName);
  }

  void _onKeyboardAppeared(bool value) {
    print("keyboard appearence state is $value");
    setState(() {
      _searchIsActive = value;
    });
  }
}
