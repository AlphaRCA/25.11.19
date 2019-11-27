import 'package:coach_marks/TutorialOverlayUtil.dart';
import 'package:coach_marks/WidgetData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hold/bloc/collections_list_bloc.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/conversation_selection_screen.dart';
import 'package:hold/model/collection_short_data.dart';
import 'package:hold/widget/animation_parts/animated_text.dart';
import 'package:hold/widget/buttons/collection_action.dart';
import 'package:hold/widget/collection_auto.dart';
import 'package:hold/widget/collection_short_view.dart';
import 'package:hold/widget/white_text.dart';

class LibraryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LibraryPageState();
  }
}

class _LibraryPageState extends State<LibraryPage> {
  final CollectionsListBloc bloc = new CollectionsListBloc();

  final GlobalKey _one = GlobalKey();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(_createCoach);
    super.initState();
    MixPanelProvider().trackEvent("COLLECTIONS", {
      "Pageview Conversations Browsing Collection":
          DateTime.now().toIso8601String(),
    });
    _showCoachMark();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: AnimatedText(bloc.collectionText),
          ),
          CollectionAction(
            "Create collection",
            _openCollectionCreation,
          ),
          StreamBuilder<List<CollectionShortData>>(
            stream: bloc.userCollections,
            initialData: List(),
            builder: (BuildContext context,
                AsyncSnapshot<List<CollectionShortData>> data) {
              List<CollectionShortData> list = data.data;
              if (list.length == 0) return Container();
              return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: list.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0)
                      return Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 12.0),
                        child: WhiteText(
                          "RECENT COLLECTIONS",
                          paddingLeft: 16.0,
                        ),
                      );
                    return CollectionShortView(
                      list[index - 1],
                      bloc,
                    );
                  });
            },
          ),
          SizedBox(
            height: 32.0,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: WhiteText(
              "COLLECTIONS MADE FOR YOU",
              paddingLeft: 16.0,
            ),
          ),
          StreamBuilder<List<CollectionShortData>>(
            stream: bloc.autoCollections,
            initialData: List(),
            builder: (BuildContext context,
                AsyncSnapshot<List<CollectionShortData>> data) {
              List<CollectionShortData> list = data.data;
              return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CollectionAuto(list[index], bloc);
                  });
            },
          ),
        ],
      ),
    );
  }

  void _openCollectionCreation() async {
    MixPanelProvider().trackEvent("COLLECTIONS", {
      "Click Create Collection Button": DateTime.now().toIso8601String(),
    });
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ConversationSelectionScreen()));
    bloc.reloadCollections();
  }

  void _createCoach(Duration timestamp) {
    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'collection',
      bgColor: Colors.black.withOpacity(
          0.75), // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveFirstInReviewCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[
        WidgetData(key: _one, isEnabled: false, padding: 0)
      ],
      description: Stack(
        children: <Widget>[
          Center(
            child: Text(
              'In this section you can \ncreate collections of your \nconversations and review \nthem all together',
              textAlign: TextAlign.center,
              textScaleFactor: 1,
              softWrap: true,
              style: TextStyle(
                color: Colors.white,
                height: 1.5,
                fontSize: 18,
                fontFamily: 'Cabin',
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCoachMark() async {
    if (!await PreferencesProvider().getFirstInReviewCoachMark()) {
      Future.delayed(
          Duration(seconds: 2),
          () => setState(() {
                showOverlayEntry(tagName: 'collection');
              }));
    }
  }
}
