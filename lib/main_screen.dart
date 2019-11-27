import 'package:coach_marks/TutorialOverlayUtil.dart';
import 'package:coach_marks/WidgetData.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/utils/notification_manager.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:hold/utils/dispose_primary_fucus.util.dart';
import 'package:hold/widget/dialogs/dialog_was_it_helpful.dart';
import 'package:hold/widget/dialogs/dialog_yes_no_cancel.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';
import 'package:hold/widget/screen_parts/init_reflection.dart';
import 'package:hold/widget/screen_parts/library_page.dart';
import 'package:hold/widget/screen_parts/profile_page.dart';
import 'package:hold/widget/screen_parts/recent_activity_page.dart';

import 'bloc/mixpanel_provider.dart';
import 'bloc/notification_bloc.dart';
import 'constants/app_colors.dart';
import 'constants/app_sizes.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final PageController pageController = new PageController(initialPage: 1);
  TabController tabController;
  int _activePage = 1;

  final GlobalKey profileKey = GlobalKey();
  final GlobalKey libraryKey = GlobalKey();
  final GlobalKey buttonKey = GlobalKey();
  final GlobalKey rightTabsKey = GlobalKey();

  static const _PAGES_LENGTH = 3;

  Map<int, GlobalKey<FlipCardState>> cardKeys = {};

  NotificationManager notificationManager;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(_createCoach);
    super.initState();
    _showCoachMark();
    pageController.addListener(_onPageChange);

    tabController = new TabController(length: 2, vsync: this, initialIndex: 0);
    tabController.addListener(_onTabChange);

    for (int i = 0; i < _PAGES_LENGTH; i++) {
      GlobalKey<FlipCardState> key = GlobalKey<FlipCardState>();
      setState(() {
        cardKeys[i] = key;
      });
    }

    Future.delayed(Duration(milliseconds: 500), () {
      cardKeys[_activePage].currentState.toggleCard();
    });

    notificationManager = NotificationManager();
    notificationManager.context = context;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: _activePage == 1
            ? IconButton(
                icon: Icon(Icons.account_circle, key: profileKey),
                color: AppColors.ONBOARDING_BACK,
                onPressed: () {
                  MixPanelProvider().trackEvent("HOME",
                      {"Click Say Profile": DateTime.now().toIso8601String()});
                  _showPrevScreen();
                },
                tooltip: "profile",
              )
            : _activePage == 2
                ? IconButton(
                    icon: SvgPicture.asset(
                      'assets/material_icons/rounded/action/home.svg',
                      color: AppColors.ONBOARDING_BACK,
                    ),
                    onPressed: () {
                      MixPanelProvider().trackEvent("HOME",
                          {"Click Say Home": DateTime.now().toIso8601String()});
                      _showPrevScreen();
                    },
                    tooltip: "home",
                  )
                : IconButton(
                    icon: SvgPicture.asset(
                      'assets/material_icons/rounded/action/home.svg',
                      color: AppColors.TRANSPARENT,
                    ),
                    disabledColor: AppColors.TRANSPARENT,
                    onPressed: null,
                  ),
        actions: <Widget>[
          _activePage == 1
              ? InkWell(
                  key: libraryKey,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Image.asset(
                      "assets/subscriptions.png",
                      color: Colors.white,
                    ),
                  ),
                  onTap: _showNextScreen,
                )
              : _activePage == 0
                  ? IconButton(
                      icon: SvgPicture.asset(
                        'assets/material_icons/rounded/action/home.svg',
                        color: AppColors.ONBOARDING_BACK,
                      ),
                      onPressed: _showNextScreen,
                      tooltip: "home",
                    )
                  : IconButton(
                      icon: SvgPicture.asset(
                        'assets/material_icons/rounded/action/home.svg',
                        color: AppColors.TRANSPARENT,
                      ),
                      disabledColor: AppColors.TRANSPARENT,
                      onPressed: null,
                    ),
        ],
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 6.0,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _activePage == 0
                    ? "Profile"
                    : _activePage == 1 ? " " : "Conversations",
                style: TextStyle(color: AppColors.TEXT),
              ),
            ),
            Spacer(),
            Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (var i = 0; i < _PAGES_LENGTH; i++) getCircleBar(i)
                ]),
            SizedBox(
              height: 8,
            )
          ],
        ),
        bottom: _activePage == 2
            ? TabBar(
                indicatorColor: AppColors.ORANGE_BUTTON_BACKGROUND,
                controller: tabController,
                tabs: <Widget>[
                  Tab(
                    text: "REFLECT",
                  ),
                  Tab(
                    text: "REVIEW",
                  ),
                ],
              )
            : null,
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: _onPageChanged,
        children: <Widget>[
          _profilePage(),
          _mainPage(),
          _libraryPage(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    pageController.dispose();
    super.dispose();
  }

  Widget _mainPage() {
    return InitReflection(_onCreationSuccess);
  }

  Widget _profilePage() {
    return ProfilePage();
  }

  Widget _libraryPage() {
    return NotificationListener<OverscrollNotification>(
      onNotification: (overscroll) {
        if (overscroll is OverscrollNotification &&
            overscroll.overscroll != 0 &&
            overscroll.dragDetails != null) {
          if (overscroll.overscroll < -10 &&
              overscroll.dragDetails.delta.dx > 1) {
            pageController.animateToPage(
              1,
              curve: AppSizes.ANIMATION_TYPE,
              duration: AppSizes.PAGE_ANIMATION_DURATION,
            );
          }
        }
        return true;
      },
      child: TabBarView(
        key: rightTabsKey,
        controller: tabController,
        children: <Widget>[
          RecentActivityPage(
            rightTabsKey,
            onCreateFirstConversation: _showPrevScreen,
          ),
          LibraryPage(),
        ],
      ),
    );
  }

  void _onPageChange() {
    disposePrimaryFocus(context);
  }

  void _onPageChanged(int page) {
    setState(() {
      _activePage = pageController.page.round();
    });

    for (var i = 0; i < _PAGES_LENGTH; i++) {
      if (cardKeys[i].currentState != null &&
          !cardKeys[i].currentState.isFront) {
        cardKeys[i].currentState.toggleCard();
      }
    }

    final cardKey = cardKeys[page];
    cardKey.currentState.toggleCard();
  }

  void _onTabChange() {
    disposePrimaryFocus(context);
  }

  void _showPrevScreen() {
    pageController.previousPage(
      duration: AppSizes.PAGE_ANIMATION_DURATION,
      curve: AppSizes.ANIMATION_TYPE,
    );
  }

  void _showNextScreen() {
    pageController.nextPage(
        duration: AppSizes.PAGE_ANIMATION_DURATION,
        curve: AppSizes.ANIMATION_TYPE);
  }

  void _showCoachMark() async {
    if (!await PreferencesProvider().getMainScreenCoachMark()) {
      Future.delayed(
          Duration(seconds: 2),
          () => setState(() {
                showOverlayEntry(tagName: 'home');
              }));
    }
  }

  void _onCreationSuccess(int createdReflectionId, String title) async {
    _showNextScreen();
    tabController.animateTo(0);
    bool hasReminder = (await StorageProvider()
            .getReminderForCard(createdReflectionId, title)) !=
        null;
    if (!hasReminder &&
        await PreferencesProvider().getAllNotificationsEnabled() &&
        await PreferencesProvider().getMyNotificationsEnabled()) {
      if (await StorageProvider().getCompletedConversationCount() % 3 == 0) {
        bool dialogResult;
        MixPanelProvider().trackEvent("REFLECT", {
          "Pageview Come Back Pop Up": DateTime.now().toIso8601String(),
        });
        await DialogLaunchers.showDialog(
          context: context,
          dialog: DialogYesNoCancel(
            "Do you want to remind yourself to come back to this?",
            () {
              MixPanelProvider().trackEvent("REFLECT", {
                "Click Yes Come Back Button": DateTime.now().toIso8601String(),
              });
              dialogResult = true;
            },
            noAction: () {
              MixPanelProvider().trackEvent("REFLECT", {
                "Click No Come Back Button": DateTime.now().toIso8601String(),
              });
              dialogResult = false;
            },
            title: "Come back to this?",
            icon: Icons.alarm,
          ),
        );
        if (dialogResult ?? false)
          await _showReminderDialog(createdReflectionId, title);
      }
    }
    if (await StorageProvider().getCompletedConversationCount() % 5 == 0) {
      DialogWasItHelpful dialog = new DialogWasItHelpful();
      await Future.delayed(Duration(seconds: 3));
      dialog.showQuestion(context);
    }
  }

  Future _showReminderDialog(int cardNumber, String title) async {
    NotificationBloc bloc = new NotificationBloc();
    await bloc.initReminderItem(cardNumber, title);
    await DialogLaunchers.showReminderDialog(context, bloc);
  }

  Widget getCircleBar(int i) {
    return FlipCard(
      key: cardKeys[i],
      flipOnTouch: false,
      speed: 300,
      direction: FlipDirection.HORIZONTAL,
      front: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        height: 8,
        width: 8,
        decoration: BoxDecoration(
          color: AppColors.TEXT.withOpacity(0.34),
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
      ),
      back: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        height: 8,
        width: 8,
        decoration: BoxDecoration(
          color: AppColors.TEXT,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
      ),
    );
  }

  void _createCoach(Duration timeStamp) {
    final RenderBox containerRenderBox =
        libraryKey.currentContext.findRenderObject();
    final libraryKeyPosition = containerRenderBox.localToGlobal(Offset.zero).dy;

    final RenderBox playRenderBox =
        profileKey.currentContext.findRenderObject();
    final profileKeyPosition = playRenderBox.localToGlobal(Offset.zero).dy;

    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'home',
      bgColor: Colors.black.withOpacity(
          0.75), // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveMainScreenCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[],
      description: Stack(
        children: <Widget>[
          Positioned(
            top: profileKeyPosition,
            left: 16,
            right: 16,
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.account_circle,
                  color: AppColors.QUESTION_BUTTON_BG,
                  size: 24,
                ),
              ],
            ),
          ),
          Positioned(
            top: libraryKeyPosition + 16,
            left: 16,
            right: 16,
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  "icons/subscriptions.svg",
                  color: AppColors.QUESTION_BUTTON_BG,
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              'Tap these icons or swipe left '
              '\nand right to see different areas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  height: 1.5,
                  fontSize: 18,
                  fontFamily: 'Cabin',
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none),
            ),
          ),
          Positioned(
            bottom: 64,
            left: 16,
            right: 16,
            child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/material_icons/rounded/navigation/chevron_left.svg',
                    color: Colors.white.withOpacity(0.52),
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: SvgPicture.asset(
                      'assets/material_icons/rounded/navigation/chevron_left.svg',
                      color: Colors.white,
                      height: 20,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    width: 52,
                    height: 76,
                    child: SvgPicture.asset(
                      "icons/pointer.svg",
                      semanticsLabel: 'pointer',
                      height: 76,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: SvgPicture.asset(
                      'assets/material_icons/rounded/navigation/chevron_right.svg',
                      color: Colors.white,
                      height: 20,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/material_icons/rounded/navigation/chevron_right.svg',
                    color: Colors.white.withOpacity(0.52),
                    height: 20,
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
