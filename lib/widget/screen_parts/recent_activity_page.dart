import 'dart:async';

import 'package:coach_marks/TutorialOverlayUtil.dart';
import 'package:coach_marks/WidgetData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/bloc/recent_activity_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/widget/dual_scroll_controller.dart';
import 'package:hold/widget/endless_horizontal_graph.dart';
import 'package:hold/widget/screen_parts/search_widget.dart';

import 'mood_graph.dart';
import 'recent_activity_list.dart';

class RecentActivityPage extends StatefulWidget {
  final VoidCallback onCreateFirstConversation;
  final GlobalKey containerKey;

  RecentActivityPage(
    this.containerKey, {
    this.onCreateFirstConversation,
  });

  @override
  State<StatefulWidget> createState() {
    return _RecentActivityPageState();
  }
}

class _RecentActivityPageState extends State<RecentActivityPage> {
  final RecentActivityBloc bloc = new RecentActivityBloc();
  final DualScrollController dualScrollController = new DualScrollController(
      initialGraphOffset: MoodGraph.graphInitialOffset,
      graphItemSize: EndlessHorizontalGraphState.CIRCLE_SIZE +
          EndlessHorizontalGraphState.HORIZONTAL_PADDING * 2);
  StreamSubscription listSizeSubscription;
  String searchValue = "";

  bool _searchIsActive = false;
  bool _keyboardIsShown = false;
  int listSize = 0;
  double moodGraphPosition = MoodGraph.HEIGHT +
      MoodGraph.PADDING +
      EndlessHorizontalGraphState.GRAPH_HEIGHT;

  Widget _moodGraph, _reflectionList;
  GlobalKey<RecentActivityListState> _reflectionListKey = new GlobalKey();
  final GlobalKey _moodGraphKey = new GlobalKey();

  @override
  void initState() {
    _moodGraph = Container(
      key: _moodGraphKey,
      padding: EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
        color: AppColors.EMOTION_LOG_BG,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black26,
        //     blurRadius: 4,
        //     offset: Offset(0, 6.0),
        //   )
        // ],
      ),
      child: MoodGraph(
        bloc,
        dualScrollController,
        _onSelectItem,
      ),
    );
    _reflectionList = RecentActivityList(
      bloc,
      dualScrollController,
      widget.containerKey,
      key: _reflectionListKey,
      onCreateFirstConversation: widget.onCreateFirstConversation,
    );
    listSizeSubscription = bloc.reflectionList.listen(_setListSize);
    SchedulerBinding.instance.addPostFrameCallback(_createCoach);
    super.initState();
    _showCoachMark();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SearchWidget(
          _onSearch,
          onFocus: _onKeyboardAppeared,
          onSearchStarted: _onSearchStarted,
          onSearchCancel: _onSearchCancel,
        ),
        _keyboardIsShown && !_searchIsActive
            ? Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _moodGraph,
                      _reflectionList,
                    ],
                  ),
                ),
              )
            : _searchIsActive && searchValue.isNotEmpty
                ? Container()
                : _moodGraph,
        _keyboardIsShown && !_searchIsActive
            ? Container()
            : Expanded(
                child: NotificationListener(
                  onNotification: dualScrollController.onListScroll,
                  child: _reflectionList,
                ),
              ),
      ],
    );
  }

  @override
  void dispose() {
    listSizeSubscription.cancel();
    dualScrollController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    setState(() {
      searchValue = value;
    });
    bloc.search(value, updateFlag: true);
  }

  void _onSearchStarted() {
    setState(() {
      _searchIsActive = true;
    });
    _reflectionListKey.currentState.setIsSearchResult(true);
  }

  void _onSearchCancel() {
    setState(() {
      _searchIsActive = false;
    });
    _reflectionListKey.currentState.setIsSearchResult(false);
  }

  void _onKeyboardAppeared(bool value) {
    setState(() {
      _keyboardIsShown = value;
    });
  }

  void _onSelectItem(int id) {
    _reflectionListKey.currentState.selectItem(id);
  }

  void _createCoach(Duration timestamp) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox containerRenderBox =
          _moodGraphKey.currentContext.findRenderObject();
      moodGraphPosition = containerRenderBox.localToGlobal(Offset.zero).dy;
    });

    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'mood',
      enableHolesAnimation: false,
      bgColor: Colors.black.withOpacity(0.75),
      // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveTwoConversationsCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[
        WidgetData(
            key: _moodGraphKey,
            isEnabled: false,
            padding: 0,
            shape: WidgetShape.StretchedVRRect),
      ],
      description: Stack(
        children: <Widget>[
          Positioned(
            top: (moodGraphPosition < 200 ? 224 : moodGraphPosition) +
                MoodGraph.HEIGHT +
                MoodGraph.PADDING * 2,
            left: 24,
            right: 24,
            child: Column(
              children: <Widget>[
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: SvgPicture.asset(
                    'assets/material_icons/rounded/navigation/expand_less.svg',
                    color: Colors.white,
                  ),
                ),
                SvgPicture.asset(
                  'assets/material_icons/rounded/navigation/expand_less.svg',
                  color: Colors.white,
                ),
                SizedBox(height: 24),
                Text(
                  'You can see here how you felt\nwhen you wrote a conversation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      height: 1.5,
                      fontSize: 18,
                      fontFamily: 'Cabin',
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setListSize(List data) async {
    listSize = data.length;
    MixPanelProvider().trackPeopleProperties(
        {"# Conversations in Reflect": "${listSize}"});
    _showCoachMark();
  }

  void _showCoachMark() async {
    if (!await PreferencesProvider().getTwoConversationsCoachMark() &&
        listSize >= 2)
      Future.delayed(
          Duration(seconds: 1),
          () => setState(() {
                showOverlayEntry(tagName: 'mood');
              }));
  }
}
