import 'dart:async';

import 'package:coach_marks/TutorialOverlayUtil.dart';
import 'package:coach_marks/WidgetData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/conversation_full_bloc.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/collection_selection_screen.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/rename_screen.dart';
import 'package:hold/widget/buttons/appbar_back.dart';
import 'package:hold/widget/buttons/bottom_button_in_stack.dart';
import 'package:hold/widget/buttons/typing_actions.dart';
import 'package:hold/widget/constructors/conversation_completed_constructor.dart';
import 'package:hold/widget/constructors/conversation_constructor.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';

import 'bloc/mixpanel_provider.dart';
import 'bloc/notification_bloc.dart';
import 'constants/app_sizes.dart';
import 'main.dart';
import 'model/conversation.dart';
import 'model/conversation_for_review.dart';

class ReflectingFurtherScreen extends StatefulWidget {
  final ConversationFullBloc bloc;
  final double initialWidth, initialHeight;
  final Color initialColor;
  final Offset offset;

  const ReflectingFurtherScreen(
    this.bloc, {
    this.initialWidth,
    this.initialHeight,
    this.offset,
    this.initialColor,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ReflectingFurtherScreenState();
  }
}

class _ReflectingFurtherScreenState extends State<ReflectingFurtherScreen> {
  static const PAUSE_BEFORE_SCROLL = Duration(milliseconds: 200);
  ConversationCompletedConstructor constructor;
  bool firstWidgetBuild = true;
  final GlobalKey<ScaffoldState> scaffoldStateKey = new GlobalKey();

  final GlobalKey appBarBackButtonKey = new GlobalKey();
  final GlobalKey titleTextKey = new GlobalKey();

  ScrollController scrollController;
  ScrollController nestedController = new ScrollController();
  double appBarLeftPadding = 0.0;
  double appBarSubtitleOpacity = 1.0;

  double expandedHeight = 180.0;

  double bottomPadding = 16.0;
  double _playPosition = 244.0;
  double _playButtonHeight = 40.0;

  bool _showButton = true;
  bool isScrollingButton = false;

  final List<String> _appBarActions = [
    "Rename",
    "Delete",
    "Add to collection",
    "Set a reminder for this"
  ];
  final GlobalKey _reflectButtonKey = GlobalKey();
  final GlobalKey _listenKey = GlobalKey();
  final GlobalKey _reflectSection = GlobalKey();
  final GlobalKey _bottomAnchorKey = GlobalKey();
  final GlobalKey _containerKey = new GlobalKey();

  @override
  void initState() {
    MixPanelProvider().trackEvent("REFLECT", {
      "Click Open Conversation": DateTime.now().toIso8601String(),
    });
    constructor = new ConversationCompletedConstructor(
        widget.bloc,
        _showInfo,
        () => Navigator.of(context).pop(),
        _showDeleteAnswerDialog,
        MyApp.screenWidth);
    SchedulerBinding.instance.addPostFrameCallback(_createCoach);

    nestedController.addListener(_myScroll());
    scrollController = new ScrollController();
    scrollController.addListener(_scrollListener);
    super.initState();
    _showCoachMark();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldStateKey,
      backgroundColor: AppColors.REFLECTION_LIST_BG,
      body: Stack(children: <Widget>[
        NestedScrollView(
          controller: scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                leading: AppBarBack(
                  key: appBarBackButtonKey,
                ),
                actions: <Widget>[
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.TEXT_EF.withOpacity(.54),
                    ),
                    onSelected: _selectMenuItem,
                    itemBuilder: (BuildContext context) {
                      return _appBarActions.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(
                            choice,
                            style: TextStyle(color: AppColors.TEXT),
                          ),
                        );
                      }).toList();
                    },
                  )
                ],
                expandedHeight: expandedHeight,
                floating: false,
                pinned: true,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return StreamBuilder<ConversationForReview>(
                      stream: widget.bloc.reflection,
                      initialData: _getBlankReflection(),
                      builder: (BuildContext context,
                          AsyncSnapshot<ConversationForReview> reflectionData) {
                        ConversationForReview content = reflectionData.data;
                        return FlexibleSpaceBar(
                          centerTitle: false,
                          titlePadding: EdgeInsets.only(
                            top: 0.0,
                            left: 0.0,
                            right: 0.0,
                            bottom: 8.0,
                          ),
                          title: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Transform.translate(
                                offset: Offset(0.0, appBarLeftPadding / 2),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Opacity(
                                    opacity: appBarSubtitleOpacity,
                                    child: Text(
                                      content.getNumberDateText(),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            AppColors.TEXT_EF.withOpacity(.54),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 16.0 + appBarLeftPadding, bottom: 8),
                                child: Text(
                                  content.mainConversation.title,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.TITLE_WHITE,
                                  ),
                                  key: titleTextKey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ];
          },
          body: Container(
            constraints: BoxConstraints.expand(),
            key: _containerKey,
            child: StreamBuilder<List<Widget>>(
              stream: constructor.parts,
              initialData: <Widget>[Container()],
              builder:
                  (BuildContext context, AsyncSnapshot<List<Widget>> data) {
                List<Widget> items = [
                  ...data.data,
                  SizedBox(key: _bottomAnchorKey, height: bottomPadding)
                ];
                return ListView.builder(
                  controller: nestedController,
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return items[index];
                  },
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: AppSizes.BOTTOM_BUTTON_SIZE,
          child: StreamBuilder<ActiveActions>(
            stream: constructor.actions,
            initialData: ActiveActions.nothing,
            builder: (BuildContext context, AsyncSnapshot<ActiveActions> data) {
              print("active action is ${data.data}");

              bottomPadding = AppSizes.BOTTOM_BUTTON_SIZE;

              switch (data.data) {
                case ActiveActions.reflect:
                  bottomPadding = AppSizes.BOTTOM_BUTTON_SIZE + 8;
                  return _showButton
                      ? BottomButtonInStack(
                          "REFLECT",
                          _showReflectionQuestions,
                          textColor: AppColors.ACTION_LIGHT_TEXT,
                          buttonColor: AppColors.TEXT_EF,
                          key: _reflectButtonKey,
                        )
                      : new Container();
                case ActiveActions.initial:
                  bottomPadding = AppSizes.BOTTOM_BUTTON_SIZE - 8;
                  return TypingActions(
                    () {
                      constructor.showKeyboard(
                          constructor.inputFieldKey.currentState, true);
                    },
                    () {
                      constructor.showVoice(
                          constructor.inputFieldKey.currentState, true);
                    },
                    constructor.next,
                    AppColors.BOTTOM_BAR_DISABLED,
                    buttonOptions: ButtonOptions.initial,
                  );
                case ActiveActions.typingInProgress:
                  return TypingActions(
                    () {
                      constructor.showKeyboard(
                          constructor.inputFieldKey.currentState, true);
                    },
                    () {
                      constructor.showVoice(
                          constructor.inputFieldKey.currentState, true);
                    },
                    constructor.next,
                    AppColors.BOTTOM_BAR_DISABLED,
                    buttonOptions: ButtonOptions.voiceAndProgress,
                  );
                case ActiveActions.voiceInProgress:
                  return TypingActions(
                    () {
                      constructor.showKeyboard(
                          constructor.inputFieldKey.currentState, true);
                    },
                    () {
                      constructor.showVoice(
                          constructor.inputFieldKey.currentState, true);
                    },
                    constructor.next,
                    AppColors.BOTTOM_BAR_DISABLED,
                    buttonOptions: ButtonOptions.keyboardAndProgress,
                  );
                case ActiveActions.typeVisible:
                  return TypingActions(
                    () {
                      constructor.showKeyboard(
                          constructor.inputFieldKey.currentState, true);
                    },
                    () {
                      constructor.showVoice(
                          constructor.inputFieldKey.currentState, true);
                    },
                    constructor.next,
                    AppColors.BOTTOM_BAR_DISABLED,
                    buttonOptions: ButtonOptions.voice,
                  );
                case ActiveActions.voiceVisible:
                  return TypingActions(
                    () {
                      constructor.showKeyboard(
                          constructor.inputFieldKey.currentState, true);
                    },
                    () {
                      constructor.showVoice(
                          constructor.inputFieldKey.currentState, true);
                    },
                    constructor.next,
                    AppColors.BOTTOM_BAR_DISABLED,
                    buttonOptions: ButtonOptions.keyboard,
                  );
                case ActiveActions.complete:
                  bottomPadding = AppSizes.BOTTOM_BUTTON_SIZE + 8;
                  return BottomButtonInStack(
                    "COMPLETE",
                    () {
                      Navigator.of(context).pop();
                    },
                    textColor: AppColors.ACTION_LIGHT_TEXT,
                    buttonColor: AppColors.TEXT_EF,
                  );
                case ActiveActions.nothing:
                  bottomPadding = 16.0;
                  return Container();
                default:
                  bottomPadding = AppSizes.BOTTOM_BUTTON_SIZE + 8;
                  return Container();
              }
            },
          ),
        ),
        Positioned(
          top: _playPosition + 16,
          left: 24,
          right: 24,
          child: Container(
            key: _listenKey,
            height: _playButtonHeight,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Container(),
          key: _reflectSection,
        ),
      ]),
    );
  }

  @override
  void dispose() {
    constructor.dispose();
    widget.bloc.destroy();
    nestedController.removeListener(_myScroll());
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void showBottom() {
    setState(() {
      _showButton = true;
    });
  }

  void hideBottom() {
    setState(() {
      _showButton = false;
    });
  }

  _scrollListener() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Boxes
    final appBarBackButtonBox =
        appBarBackButtonKey.currentContext.findRenderObject() as RenderBox;
    final titleTextBox =
        titleTextKey.currentContext.findRenderObject() as RenderBox;

    // Sizes
    final double appBarBackButtonWidth = appBarBackButtonBox.size.width;
    final double titleTextWidth = titleTextBox.size.width;

    // Positions
    final double scrollOffset = scrollController.offset;
    final double scrollStopPostion = expandedHeight - kToolbarHeight;

    final double leftSidePositionOnCenter =
        ((screenWidth / 2) - (titleTextWidth / 2)) - appBarBackButtonWidth / 2;

    // Scroll direction
    final bool scrollingToTop = scrollController.position.userScrollDirection ==
        ScrollDirection.reverse;

    // Math :)
    final double paddingCoefficient =
        scrollOffset * (leftSidePositionOnCenter / scrollStopPostion);
    final double opacityCoefficient = scrollOffset / 1000;

    debugPrint("padding $appBarLeftPadding");

    if (scrollingToTop) {
      if (appBarLeftPadding <= leftSidePositionOnCenter &&
          scrollOffset <= scrollStopPostion) {
        appBarLeftPadding = paddingCoefficient;

        if (scrollOffset >= 0 && scrollOffset <= expandedHeight / 3) {
          appBarSubtitleOpacity = getAppBarSubtitleOpacity(-opacityCoefficient);
          debugPrint(
              "ReflectingFurtherScreen: Scroll direction - top | appBarSubtitleOpacity - $appBarSubtitleOpacity");
        } else {
          appBarSubtitleOpacity = 0.0;
        }
      }
    } else {
      if (scrollOffset <= scrollStopPostion) {
        appBarLeftPadding = paddingCoefficient;

        if (scrollOffset <= expandedHeight / 3) {
          appBarSubtitleOpacity = getAppBarSubtitleOpacity(opacityCoefficient);
          debugPrint(
              "ReflectingFurtherScreen: Scroll direction - bottom | appBarSubtitleOpacity - $appBarSubtitleOpacity");
        }
      }
    }

    if (scrollOffset >= scrollStopPostion &&
        appBarLeftPadding != leftSidePositionOnCenter) {
      appBarLeftPadding = leftSidePositionOnCenter;
      appBarSubtitleOpacity = 0.0;
    }

    if (scrollOffset <= 0.0) {
      appBarLeftPadding = 0.0;
      appBarSubtitleOpacity = 1.0;
    }
  }

  _myScroll() {
    nestedController.addListener(() {
      // synchronize two scolls
      scrollController.jumpTo(nestedController.offset);

      if (nestedController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingButton) {
          isScrollingButton = true;
          hideBottom();
        }
      }
      if (nestedController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingButton) {
          isScrollingButton = false;
          showBottom();
        }
      }
    });
  }

  double getAppBarSubtitleOpacity(double coefficient) {
    double opacity = appBarSubtitleOpacity;

    opacity += coefficient;

    if (opacity < 0.0) return 0.0;

    if (opacity > 1.0) return 1.0;

    return opacity;
  }

  void _showDeleteAnswerDialog() {
    MixPanelProvider().trackEvent("REFLECT",
        {"Delete Section Reflect Pop Up": DateTime.now().toIso8601String()});
    DialogLaunchers.showAnimatedDelete(
      context,
      title: "Delete section",
      mainText:
          "Are you sure you want to delete this part of your conversation?",
      yesAction: () {
        MixPanelProvider().trackEvent("CONVERSATION", {
          "Click Delete Section": DateTime.now().toIso8601String(),
          "button": "yes"
        });
        constructor.showQuestionOptions();
      },
      titleIcon: Icons.delete_outline,
      noAction: () {
        MixPanelProvider().trackEvent("CONVERSATION", {
          "Click Delete Section": DateTime.now().toIso8601String(),
          "button": "no"
        });
      },
      toastText: "Part of the conversation deleted",
    );
  }

  void _showReflectionQuestions() {
    constructor.next();
    _showReflectionSectionCoach();
    _scrollToBottom(new Duration(seconds: 2));
  }

  ConversationForReview _getBlankReflection() {
    return new ConversationForReview(
        new Conversation(widget.bloc.cardNumber, ReflectionType.A), new List());
  }

  void _showInfo(String questionTitle, String longDescription, int level) {
    MixPanelProvider().trackEvent(
        "REFLECT", {"Info Icon Tier ": level, "Title": questionTitle});
    DialogLaunchers.showInfo(context, questionTitle, longDescription);
  }

  void _selectMenuItem(String value) {
    switch (value) {
      case "Rename":
        _showRenameScreen(context, widget.bloc.reflectionTitle);
        break;
      case "Delete":
        _showDeleteReflectionDialog();
        break;
      case "Set a reminder for this":
        _showReminderDialog();
        break;
      case "Add to collection":
        _showCollectionSelectionScreen();
        break;
    }
  }

  void _showDeleteReflectionDialog() {
    MixPanelProvider().trackEvent("REFLECT", {
      "Pageview Delete Conversation Pop Up": DateTime.now().toIso8601String()
    });
    DialogLaunchers.showAnimatedDelete(context,
        title: "Delete conversation",
        titleIcon: Icons.delete_outline,
        toastText: "'${widget.bloc.reflectionTitle}' deleted",
        mainText: "Are you sure you want to delete this conversation?",
        yesAction: () async {
      MixPanelProvider().trackEvent("REFLECT", {
        "Click Delete Conversation Button Yes": DateTime.now().toIso8601String()
      });
      await widget.bloc.deleteReflection();
      Navigator.of(context).pop(true);
    }, noAction: () {
      MixPanelProvider().trackEvent("REFLECT", {
        "Click Delete Conversation Button No": DateTime.now().toIso8601String()
      });
    });
  }

  void _showRenameScreen(BuildContext context, String oldName) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RenameScreen(
              "How would you rename \nyour conversation?",
              (value) async {
                if (value != null) {
                  widget.bloc.renameReflection(value);
                  return widget.bloc.cardNumber;
                }
                return null;
              },
              name: oldName,
              isCreating: false,
            )));
  }

  void _showReminderDialog() async {
    NotificationBloc bloc = new NotificationBloc();
    await bloc.initReminderItem(widget.bloc.initialReflection.cardNumber,
        widget.bloc.initialReflection.getTitle());
    await DialogLaunchers.showReminderDialog(context, bloc);
  }

  void _showCollectionSelectionScreen() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            CollectionSelectionScreen(widget.bloc.cardNumber)));
  }

  void _scrollToBottom(Duration timeStamp) {
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients)
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: AppSizes.ANIMATION_DURATION,
            curve: AppSizes.ANIMATION_TYPE);

      if (nestedController.hasClients)
        nestedController.animateTo(nestedController.position.viewportDimension,
            duration: AppSizes.ANIMATION_DURATION,
            curve: AppSizes.ANIMATION_TYPE);
    });
  }

  void _createCoach(Duration timestamp) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final RenderBox containerRenderBox =
        _reflectSection.currentContext.findRenderObject();
    final _reflectSectionPosition =
        containerRenderBox.localToGlobal(Offset.zero).dy;

    final RenderBox playRenderBox =
        _containerKey.currentContext.findRenderObject();
    _playPosition =
        playRenderBox.localToGlobal(Offset.zero).dy + statusBarHeight;

    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'reflect',
      enableHolesAnimation: false,
      bgColor: Colors.black.withOpacity(0.75),
      // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveFirstConversationCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[
        WidgetData(
            key: _listenKey,
            isEnabled: false,
            padding: 0,
            shape: WidgetShape.RRect),
        WidgetData(
            key: _reflectButtonKey,
            isEnabled: false,
            padding: 0,
            shape: WidgetShape.TopRRect),
      ],
      description: Stack(
        children: <Widget>[
          Positioned(
            top: _playPosition + _playButtonHeight + 16,
            left: 0,
            right: 0,
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
                  'Listen to your full conversation\nhere',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.5,
                    fontSize: 18,
                    fontFamily: 'Cabin',
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: <Widget>[
                Text(
                  'Tap here to add your reflections'
                  '\nto what you have said.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.5,
                    fontSize: 18,
                    fontFamily: 'Cabin',
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: SvgPicture.asset(
                    'assets/material_icons/rounded/navigation/expand_more.svg',
                    color: Colors.white,
                  ),
                ),
                SvgPicture.asset(
                  'assets/material_icons/rounded/navigation/expand_more.svg',
                  color: Colors.white,
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'reflectSection',
      enableHolesAnimation: false,
      bgColor: Colors.black.withOpacity(0.75),
      // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveFirstReflectCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[
        WidgetData(
          key: _reflectSection,
          isEnabled: false,
          padding: 0,
          shape: WidgetShape.TopRRect,
        ),
      ],
      description: Stack(
        children: <Widget>[
          Positioned(
            top: _reflectSectionPosition - 148,
            left: 24,
            right: 24,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Text(
                      'By scrolling right below you can see '
                      'different ways to reflect your collection.',
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
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: SvgPicture.asset(
                      'assets/material_icons/rounded/navigation/expand_more.svg',
                      color: Colors.white,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/material_icons/rounded/navigation/expand_more.svg',
                    color: Colors.white,
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCoachMark() async {
    if (!await PreferencesProvider().getFirstConversationCoachMark()) {
      Future.delayed(
          Duration(seconds: 1),
          () => setState(() {
                showOverlayEntry(tagName: 'reflect');
              }));
    }
  }

  void _showReflectionSectionCoach() async {
    if (!await PreferencesProvider().getFirstReflectCoachMark())
      showOverlayEntry(tagName: 'reflectSection');
  }
}
