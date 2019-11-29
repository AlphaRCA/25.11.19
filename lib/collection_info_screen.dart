import 'package:coach_marks/TutorialOverlayUtil.dart';
import 'package:coach_marks/WidgetData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/conversation_selection_screen.dart';
import 'package:hold/model/collection_full_view.dart';
import 'package:hold/model/played_item.dart';
import 'package:hold/model/reflection.dart';
import 'package:hold/rename_screen.dart';
import 'package:hold/storage/conversation_in_storage.dart';
import 'package:hold/storage/editable_ui_question.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:hold/widget/buttons/appbar_back.dart';
import 'package:hold/widget/buttons/bottom_button_in_stack.dart';
import 'package:hold/widget/buttons/circular_play_progress.dart';
import 'package:hold/widget/buttons/typing_actions.dart';
import 'package:hold/widget/conversation_playable_view.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';
import 'package:hold/widget/screen_parts/playable_text.dart';
import 'package:hold/widget/screen_parts/question_input_field.dart';
import 'package:hold/widget/screen_parts/question_tabs.dart';
import 'package:hold/widget/stick_position.dart';

import 'bloc/collection_info_bloc.dart';
import 'constants/app_colors.dart';
import 'constants/app_styles.dart';

class CollectionInfoScreen extends StatefulWidget {
  final CollectionInfoBloc bloc;
  final InfoScreenState initialScreenState;

  const CollectionInfoScreen(
    this.bloc, {
    Key key,
    this.initialScreenState,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CollectionInfoScreenState();
  }
}

class _CollectionInfoScreenState extends State<CollectionInfoScreen> {
  static const OPTION_DELETE = "Delete collection";
  static const OPTION_ADD = "Add conversations";
  static const OPTION_RENAME = "Rename collection";
  static const MENU_OPTIONS = [OPTION_RENAME, OPTION_DELETE, OPTION_ADD];
  static const LARGE_BAR_HEIGHT = 300.0;
  static const SMALL_BAR_HEIGHT = 40.0;
  static const SPACE_BELOW_APPBAR_ELEMENTS = 24.0;
  static const OVERFLOWED_SWITCH_HEIGHT = 48.0;

  InfoScreenState screenState;
  ScrollController controller = new ScrollController();
  ScrollController singleChildScrollController = new ScrollController();
  ScrollController listView1ScrollController =
      new ScrollController(initialScrollOffset: 0);
  ScrollController listView2ScrollController =
      new ScrollController(initialScrollOffset: 0);
  bool _isExpandedView = false;
  bool _hasExpandedControls = true;
  bool _isContinuousPlay = true;
  bool _showButton = true;
  bool isScrollingButton = false;

  EditableUIQuestion _answeredQuestion;
  String _answer;
  ButtonOptions _keyboardState = ButtonOptions.initial;
  BuildContext introductionContext;

  double sectionTitlePosition = 337.0;

  static double defaultOverflowebSwitchTopPosition =
      LARGE_BAR_HEIGHT - OVERFLOWED_SWITCH_HEIGHT / 2;
  double overflowebSwitchTopPosition = defaultOverflowebSwitchTopPosition;
  double overflowebSwitchTopOpacity = 1.0;

  final GlobalKey _appBarKey = new GlobalKey();
  final GlobalKey<TextInputFieldState> inputFieldKey = new GlobalKey();
  final GlobalKey<CircularPlayProgressState> _playButtonStack = new GlobalKey();
  final GlobalKey _playButtonKey = new GlobalKey();
  final GlobalKey _reviewButtonKey = new GlobalKey();
  final GlobalKey _reviewSectionTitleKey = new GlobalKey();
  final GlobalKey _reviewSectionKey = new GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldStateKey = new GlobalKey();

  @override
  void initState() {
    if (widget.bloc.collectionId < 0) {
      screenState = InfoScreenState.actionsUnavailable;
    } else if (widget.initialScreenState == null) {
      screenState = InfoScreenState.initial;
    } else {
      screenState = widget.initialScreenState;
    }
    _loadContinuousPlay();
    myScroll();
    SchedulerBinding.instance.addPostFrameCallback(_createCoach);
    SchedulerBinding.instance.addPostFrameCallback(_setAppBarHeight);

    if (widget.initialScreenState == InfoScreenState.reviewQuestionSelection) {
      SchedulerBinding.instance.addPostFrameCallback((duration) {
        Future.delayed(Duration(milliseconds: 100), () {
          _scrollToBottom(new Duration(seconds: 1));
        });
      });
    }
    super.initState();
    _showCoachMark();

    controller.addListener(_scrollListener);
  }

  Future _loadContinuousPlay() async {
    _isContinuousPlay = await PreferencesProvider().getContinuousSetting();
    if (mounted) setState(() {});
  }

  void _setAppBarHeight(Duration duration) {
    final appBarBox = _appBarKey.currentContext.findRenderObject() as RenderBox;
    defaultOverflowebSwitchTopPosition =
        appBarBox.size.height - OVERFLOWED_SWITCH_HEIGHT / 2;
    overflowebSwitchTopPosition = defaultOverflowebSwitchTopPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldStateKey,
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            controller: controller,
            slivers: <Widget>[
              SliverAppBar(
                leading: AppBarBack(),
                elevation: 6,
                centerTitle: true,
                pinned: true,
                title: StreamBuilder<String>(
                  stream: widget.bloc.collectionTitle,
                  initialData: "Loading...",
                  builder: (BuildContext ctxt, AsyncSnapshot<String> data) {
                    return Text(data.data);
                  },
                ),
                actions: screenState == InfoScreenState.actionsUnavailable
                    ? null
                    : <Widget>[
                        PopupMenuButton<String>(
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
                      ],
                expandedHeight: _hasExpandedControls ? LARGE_BAR_HEIGHT : 0,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(
                      !_hasExpandedControls || overflowebSwitchTopPosition < 130
                          ? 80
                          : 0),
                  child:
                      !_hasExpandedControls || overflowebSwitchTopPosition < 130
                          ? AnimatedOpacity(
                              opacity: !_hasExpandedControls ||
                                      overflowebSwitchTopPosition < 120
                                  ? 1
                                  : 0,
                              duration: Duration(milliseconds: 600),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColors.TEXT.withOpacity(0.12),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: _getShortPlay(),
                              ),
                            )
                          : Container(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  key: _appBarKey,
                  background: Stack(
                    fit: StackFit.expand,
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Container(
                        child:
                            _hasExpandedControls ? _getLongPlay() : Container(),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  controller: singleChildScrollController,
                  reverse:
                      screenState == InfoScreenState.reviewQuestionSelection ||
                          screenState == InfoScreenState.completeable,
                  child: Column(
                    children: <Widget>[
                      _hasExpandedControls
                          ? SizedBox(
                              height: OVERFLOWED_SWITCH_HEIGHT / 2 +
                                  SPACE_BELOW_APPBAR_ELEMENTS,
                            )
                          : Container(),
                      StreamBuilder<CollectionFullView>(
                        stream: widget.bloc.collectionData,
                        initialData: new CollectionFullView(
                          0,
                          false,
                          DateTime.now(),
                          shortContent: new List(),
                        ),
                        builder: (BuildContext ctxt,
                            AsyncSnapshot<CollectionFullView> data) {
                          List<dynamic> list = data.data.shortContent;
                          if (_isExpandedView) {
                            List<Widget> extendedItems = widget.bloc
                                .getFullWidgetList(context, _expandControls);
                            return Container(
                              child: ListView.builder(
                                  controller: listView1ScrollController,
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: extendedItems.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return extendedItems[index];
                                  }),
                            );
                          } else {
                            //widget.bloc.formShortKeys();
                            return ListView.builder(
                                controller: listView2ScrollController,
                                padding: EdgeInsets.only(bottom: 16.0),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: list.length,
                                itemBuilder: (BuildContext context, int index) {
                                  int voiceIndex = index + 1;
                                  if (list[index] is ConversationInStorage) {
                                    var reflectionPlayableView =
                                        ConversationPlayableView(
                                      list[index],
                                      widget.bloc,
                                      _expandViews,
                                      isInsideAuto:
                                          widget.bloc.collectionId < 0,
                                    );
                                    return reflectionPlayableView;
                                  } else {
                                    return _getAdditionalReflection(
                                        list[index], voiceIndex);
                                  }
                                });
                          }
                        },
                      ),
                      screenState == InfoScreenState.reviewQuestionSelection ||
                              screenState == InfoScreenState.completeable
                          ? Padding(
                              key: _reviewSectionTitleKey,
                              padding: EdgeInsets.fromLTRB(24, 24.0, 16, 16),
                              child: Text(
                                "How do you want to review this collection?",
                                style: TextStyle(
                                  color: AppColors.TEXT_EF,
                                  fontSize: 21.17,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            )
                          : Container(),
                      screenState == InfoScreenState.reviewQuestionSelection ||
                              screenState == InfoScreenState.completeable
                          ? QuestionTabs(
                              StorageProvider().getCollectionQuestions(),
                              PreferencesProvider()
                                  .getHighestCollectionReflectionLevel(),
                              _onCreateAnswer,
                              _showInfo,
                              key: _reviewSectionKey,
                            )
                          : screenState == InfoScreenState.reviewInProgress
                              ? TextInputField(
                                  _answeredQuestion,
                                  _onAnswerTextEntered,
                                  _onKeyboardInputStarted,
                                  _onMakeAnswerSaveAvailable,
                                  fieldTitle: _answeredQuestion.title,
                                  closeAction: _cancelAnswering,
                                  background:
                                      AppColors.COLLECTION_REFLECTION_BG,
                                  key: inputFieldKey,
                                )
                              : Container(),
                      SizedBox(
                        height: screenState == InfoScreenState.initial
                            ? AppSizes.BOTTOM_BUTTON_SIZE - 8
                            : screenState == InfoScreenState.reviewInProgress ||
                                    screenState == InfoScreenState.completeable
                                ? AppSizes.BOTTOM_BUTTON_SIZE + 8
                                : 16.0,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: AppSizes.BOTTOM_BUTTON_SIZE,
            child: screenState == InfoScreenState.initial && _showButton
                ? BottomButtonInStack(
                    "REVIEW",
                    _showReview,
                    textColor: AppColors.ACTION_LIGHT_TEXT,
                    buttonColor: AppColors.TEXT_EF,
                    key: _reviewButtonKey,
                  )
                : screenState == InfoScreenState.reviewInProgress && _showButton
                    ? TypingActions(
                        _showKeyboard,
                        _showVoice,
                        _saveAnswer,
                        AppColors.BOTTOM_BAR_DISABLED,
                        buttonOptions: _keyboardState,
                      )
                    : screenState == InfoScreenState.completeable && _showButton
                        ? BottomButtonInStack(
                            "COMPLETE",
                            _expandControls,
                            textColor: AppColors.ACTION_LIGHT_TEXT,
                            buttonColor: AppColors.TEXT_EF,
                          )
                        : Container(),
          ),
          _hasExpandedControls ? buildContinuousPlay() : Container(),
        ],
      ),
    );
  }

  _scrollListener() {
    // Math :)
    final double opacityCoefficient = controller.offset / 3000;

    // Scroll direction
    final bool scrollingToTop =
        controller.position.userScrollDirection == ScrollDirection.reverse;

    if (scrollingToTop) {
      setState(() {
        overflowebSwitchTopPosition =
            defaultOverflowebSwitchTopPosition - controller.offset;
        overflowebSwitchTopOpacity =
            getContinuousPlayOpacity(-opacityCoefficient);

        if (controller.offset > LARGE_BAR_HEIGHT / 2)
          overflowebSwitchTopOpacity = 0;
      });
    } else {
      setState(() {
        overflowebSwitchTopPosition =
            defaultOverflowebSwitchTopPosition - controller.offset;

        if (controller.offset < LARGE_BAR_HEIGHT / 2)
          overflowebSwitchTopOpacity =
              getContinuousPlayOpacity(opacityCoefficient);
      });
    }

    if (controller.offset < 0) {
      setState(() {
        overflowebSwitchTopPosition = defaultOverflowebSwitchTopPosition;
        overflowebSwitchTopOpacity = 1;
      });
    }
  }

  double getContinuousPlayOpacity(double coefficient) {
    double opacity = overflowebSwitchTopOpacity;

    opacity += coefficient;

    if (opacity < 0.0) return 0.0;

    if (opacity > 1.0) return 1.0;

    return opacity;
  }

  Widget buildContinuousPlay() {
    return Positioned(
      top: overflowebSwitchTopPosition,
      left: 24,
      right: 24,
      child: Opacity(
        // opacity: overflowebSwitchTopOpacity,
        opacity: 1,
        child: Container(
          padding: EdgeInsets.only(left: 6.0),
          height: OVERFLOWED_SWITCH_HEIGHT,
          decoration: BoxDecoration(
            borderRadius: new BorderRadius.circular(AppSizes.BORDER_RADIUS),
            color: AppColors.WHITE,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2.0,
                spreadRadius: 2.0,
                offset: Offset(0, 4.0),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SwitchListTile(
                  dense: true,
                  title: Text(
                    "Continuous play",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  activeTrackColor: Color(0xffa1b2d3),
                  activeColor: Color(0xff0ed998),
                  value: _isContinuousPlay,
                  onChanged: (value) {
                    widget.bloc.setContinuousPlaySetting(value);
                    setState(() {
                      _isContinuousPlay = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void myScroll() async {
    bool isEnable = screenState == InfoScreenState.initial;
    isEnable = isEnable || screenState == InfoScreenState.reviewInProgress;
    isEnable = isEnable || screenState == InfoScreenState.completeable;

    if (!isEnable) return;
    controller.addListener(() {
      if (controller.position.userScrollDirection == ScrollDirection.reverse) {
        if (!isScrollingButton) {
          isScrollingButton = true;
          hideBottom();
        }
      }
      if (controller.position.userScrollDirection == ScrollDirection.forward) {
        if (isScrollingButton) {
          isScrollingButton = false;
          showBottom();
        }
      }
    });
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

  void _showDialog(String value, BuildContext context) {
    switch (value) {
      case OPTION_DELETE:
        _showDeleteDialog(context);
        break;
      case OPTION_ADD:
        _openAddScreen();
        break;
      case OPTION_RENAME:
        _showRenameScreen(context);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context) async {
    bool result = await DialogLaunchers.showAnimatedDelete(
      context,
      mainText:
          "Are you sure you want to delete '${widget.bloc.collectionTitleFinal}'?",
      yesAction: () {
        widget.bloc.deleteCollection();
      },
      title: "Delete collection",
      titleIcon: Icons.delete_outline,
      noAction: () {},
      toastText: "Collection '${widget.bloc.collectionTitleFinal}' deleted",
    );
    if (result ?? false) Navigator.of(context).pop(true);
  }

  void _showRenameScreen(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RenameScreen(
          "How would you rename \nyour collection?",
          (value) async {
            await widget.bloc.rename(value);
            return widget.bloc.collectionId;
          },
          name: widget.bloc.collectionTitleFinal,
          isCreating: false,
        ),
      ),
    );
  }

  Widget _getLongPlay() {
    return Stack(
      // overflow: Overflow.visible,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: kToolbarHeight * 1.7),
          padding: EdgeInsets.only(top: 16.0, bottom: 36.0),
          decoration: BoxDecoration(
            color: AppColors.APP_BAR,
          ),
          constraints: BoxConstraints.expand(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<PlayedItem>(
                initialData: PlayedItem.initial,
                stream: widget.bloc.activeItem,
                builder: (BuildContext ctxt, AsyncSnapshot<PlayedItem> data) {
                  print("screenPart: ${data.data}");
                  return Text(
                    widget.bloc.getScreenPart(data.data) ?? "Untitled",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 21.13,
                      color: AppColors.TEXT_EF,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder<PlayedItem>(
                      initialData: PlayedItem.initial,
                      stream: widget.bloc.activeItem,
                      builder:
                          (BuildContext ctxt, AsyncSnapshot<PlayedItem> value) {
                        return IconButton(
                          color: Colors.white,
                          disabledColor: Colors.white60,
                          icon: SvgPicture.asset(
                            'assets/material_icons/rounded/av/fast_rewind.svg',
                            color: Colors.white,
                          ),
                          onPressed: value.data.isPlayed
                              ? widget.bloc.playPreviousConversation
                              : null,
                        );
                      }),
                  SizedBox(
                    width: 24,
                  ),
                  CircularPlayProgress(
                    widget.bloc,
                    size: 56.0,
                    key: _playButtonStack,
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  StreamBuilder<PlayedItem>(
                      initialData: PlayedItem.initial,
                      stream: widget.bloc.activeItem,
                      builder:
                          (BuildContext ctxt, AsyncSnapshot<PlayedItem> value) {
                        return IconButton(
                          color: Colors.white,
                          disabledColor: Colors.white60,
                          icon: SvgPicture.asset(
                            'assets/material_icons/rounded/av/fast_forward.svg',
                            color: Colors.white,
                          ),
                          onPressed:
                              value.data.isPlayed ? widget.bloc.playNext : null,
                        );
                      }),
                ],
              ),
              widget.bloc.collectionId < 0
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(top: 12.0),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: GestureDetector(
                          onTap: _openAddScreen,
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: new BorderRadius.circular(18.0),
                              color: AppColors.PLAY_CONTAINER_BACKGROUND,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "ADD CONVERSATIONS",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
            ],
          ),
        ),
      ],
    );
  }

  Widget _getShortPlay() {
    return Container(
      color: AppColors.APP_BAR,
      padding: EdgeInsets.fromLTRB(24.0, 12.0, 16.0, 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: CircularPlayProgress(widget.bloc),
            margin: EdgeInsets.only(right: 16.0),
          ),
          Expanded(
            child: StreamBuilder<PlayedItem>(
              stream: widget.bloc.activeItem,
              initialData: PlayedItem.initial,
              builder: (BuildContext ctxt, AsyncSnapshot<PlayedItem> data) {
                print("shortPlay data: ${data.toString()}");
                return Text(
                  widget.bloc.getScreenPart(data.data),
                  style: AppStyles.GENERAL_TEXT,
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
          IconButton(
            color: Color(0x8afafafa),
            icon: Icon(Icons.expand_more),
            onPressed: _expandControls,
          )
        ],
      ),
    );
  }

  void _openAddScreen() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ConversationSelectionScreen(
              collectionId: widget.bloc.collectionId,
            )));
    _expandControls();
    widget.bloc.reloadData();
  }

  void _showReview() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox containerRenderBox =
          _reviewSectionTitleKey.currentContext.findRenderObject();
      sectionTitlePosition = containerRenderBox.localToGlobal(Offset.zero).dy;
      _showReviewCoach();
    });
    setState(() {
      _showButton = true;
      screenState = InfoScreenState.reviewQuestionSelection;
    });
    _shrinkControls();
    _scrollToBottom(new Duration(seconds: 1));
  }

  void _scrollToBottom(Duration timeStamp) {
    Future.delayed(Duration(milliseconds: 100), () {
      if (controller.hasClients)
        controller.animateTo(controller.position.maxScrollExtent,
            duration: AppSizes.ANIMATION_DURATION,
            curve: AppSizes.ANIMATION_TYPE);

      if (singleChildScrollController.hasClients)
        singleChildScrollController.animateTo(
            singleChildScrollController.position.maxScrollExtent,
            duration: AppSizes.ANIMATION_DURATION,
            curve: AppSizes.ANIMATION_TYPE);

      if (listView1ScrollController.hasClients)
        listView1ScrollController.animateTo(
            listView1ScrollController.position.maxScrollExtent,
            duration: AppSizes.ANIMATION_DURATION,
            curve: AppSizes.ANIMATION_TYPE);

      if (listView2ScrollController.hasClients)
        listView2ScrollController.animateTo(
            listView2ScrollController.position.maxScrollExtent,
            duration: AppSizes.ANIMATION_DURATION,
            curve: AppSizes.ANIMATION_TYPE);
    });
  }

  void _onCreateAnswer(EditableUIQuestion question) {
    _answeredQuestion = question;
    setState(() {
      _showButton = true;
      _keyboardState = ButtonOptions.initial;
      screenState = InfoScreenState.reviewInProgress;
    });
  }

  void _showInfo(String questionTitle, String longDescription, int level) {
    if (screenState == InfoScreenState.reviewQuestionSelection) {
    } else {}
    DialogLaunchers.showInfo(context, questionTitle, longDescription);
  }

  void _cancelAnswering() async {
    DialogLaunchers.showAnimatedDelete(
      context,
      title: "Delete section",
      mainText: "Are you sure you want to delete this part of this collection?",
      yesAction: () {
        widget.bloc.deleteCollection();
        _answeredQuestion = null;
        setState(() {
          screenState = InfoScreenState.initial;
        });
      },
      titleIcon: Icons.delete_outline,
      noAction: () {},
      toastText: "Part of the collection deleted",
    );
  }

  void _onAnswerTextEntered(String value) {
    _answer = value;
  }

  void _onKeyboardInputStarted() {
    setState(() {
      _keyboardState = ButtonOptions.voice;
    });
  }

  void _onMakeAnswerSaveAvailable() {
    if (_keyboardState == ButtonOptions.keyboard) {
      setState(() {
        _keyboardState = ButtonOptions.keyboardAndProgress;
      });
    } else if (_keyboardState == ButtonOptions.voice) {
      setState(() {
        _keyboardState = ButtonOptions.voiceAndProgress;
      });
    }
  }

  void _expandControls() {
    setState(() {
      _hasExpandedControls = true;
      _isExpandedView = false;
      screenState = InfoScreenState.initial;
    });
  }

  void _shrinkControls() {
    setState(() {
      _hasExpandedControls = false;
    });
  }

  Future _saveAnswer() async {
    Reflection reflection = new Reflection(0, _answeredQuestion.title,
        _answeredQuestion.level, _answeredQuestion.id);
    reflection.myText = _answer;
    MixPanelProvider().trackEvent("Review Collection", {
      "Click Next Review Tool": DateTime.now().toIso8601String(),
      "Title Review Tool": _answeredQuestion.title,
      "Stage Review Tool": _answeredQuestion.subtitle
    });
    await widget.bloc.saveAnswer(reflection);
    setState(() {
      screenState = InfoScreenState.completeable;
    });
  }

  void _showKeyboard() {
    setState(() {
      _keyboardState = ButtonOptions.voice;
    });
    inputFieldKey.currentState.showKeyboard();
  }

  Future _showVoice() async {
    if (await inputFieldKey.currentState.showVoice())
      setState(() {
        _keyboardState = ButtonOptions.keyboard;
      });
  }

  @override
  void dispose() {
    widget.bloc.destroy();
    controller.removeListener(() {});
    controller.dispose();
    super.dispose();
  }

  void _expandViews() {
    setState(() {
      _isExpandedView = true;
      _hasExpandedControls = false;
    });
  }

  Widget _getAdditionalReflection(listItem, int voiceIndex) {
    Reflection additional = listItem;
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: PlayableText(
        additional.toPlayedText(),
        widget.bloc,
        title: additional.title,
        backgroundColor: AppColors.COLLECTION_REFLECTION_BG,
        textColor: AppColors.COLLECTION_REFLECTION_TEXT,
        stick: StickPosition.center,
      ),
    );
  }

  void _createCoach(Duration timestamp) {
    final RenderBox containerRenderBox =
        _playButtonStack.currentContext.findRenderObject();
    final containerPosition = containerRenderBox.localToGlobal(Offset.zero).dy;

    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'playButton',
      enableHolesAnimation: false,
      bgColor: Colors.black.withOpacity(0.75),
      // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        hideOverlayEntryIfExists();
        if (screenState == InfoScreenState.initial) {
          Future.delayed(
              Duration(seconds: 1),
              () => setState(() {
                    showOverlayEntry(tagName: 'review');
                  }));
        }
      },
      widgetsData: <WidgetData>[
        WidgetData(
            key: _playButtonKey,
            isEnabled: false,
            padding: 0,
            shape: WidgetShape.Oval),
      ],
      description: Stack(
        children: <Widget>[
          Positioned(
            top: _hasExpandedControls ? containerPosition : SMALL_BAR_HEIGHT,
            right: 0,
            left: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.QUESTION_BUTTON_BG, width: 1.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: SvgPicture.asset(
                            'assets/material_icons/rounded/av/play_arrow.svg',
                            color: AppColors.QUESTION_BUTTON_BG,
                          ),
                        ),
                      ),
                    ),
                  ),
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
                    'Tap here to start listening to all\nthe conversations in this \ncollection.',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'review',
      enableHolesAnimation: false,
      bgColor: Colors.black.withOpacity(0.75),
      // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveFirstInCollectionCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[
        WidgetData(
            key: _reviewButtonKey,
            isEnabled: false,
            padding: 0,
            shape: WidgetShape.TopRRect),
      ],
      description: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Center(
                child: Container(
                  margin: EdgeInsets.only(bottom: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Tap here to review your collection',
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
        ],
      ),
    );
    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'reviewSection',
      enableHolesAnimation: false,
      bgColor: Colors.black.withOpacity(0.75),
      // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveFirstReviewCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[
        WidgetData(
          key: _reviewSectionKey,
          isEnabled: false,
          padding: 40,
          shape: WidgetShape.Rect,
        ),
        WidgetData(
          key: _reviewSectionTitleKey,
          isEnabled: false,
          padding: 16,
          shape: WidgetShape.StretchedVRRect,
        ),
      ],
      description: Stack(
        children: <Widget>[
          Positioned(
            top: sectionTitlePosition - 167,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Text(
                    'By scrolling right below you can see '
                    'different ways to review your collection.',
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
        ],
      ),
    );
  }

  void _showCoachMark() async {
    if (!await PreferencesProvider().getFirstInCollectionCoachMark()) {
      Future.delayed(
          Duration(seconds: 1),
          () => setState(() {
                showOverlayEntry(tagName: 'playButton');
              }));
    }
  }

  void _showReviewCoach() async {
    if (!await PreferencesProvider().getFirstReviewCoachMark()) {
      showOverlayEntry(tagName: 'reviewSection');
    }
  }
}

enum InfoScreenState {
  initial,
  reviewQuestionSelection,
  reviewInProgress,
  completeable,
  actionsUnavailable
}
