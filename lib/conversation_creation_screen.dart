import 'package:coach_marks/TutorialOverlayUtil.dart';
import 'package:coach_marks/WidgetData.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/conversation_creation_bloc.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/notification_bloc.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/model/conversation_widget_content.dart';
import 'package:hold/rename_screen.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:hold/widget/buttons/appbar_back.dart';
import 'package:hold/widget/buttons/back_complete_actions.dart';
import 'package:hold/widget/buttons/bottom_button_in_stack.dart';
import 'package:hold/widget/buttons/typing_actions.dart';
import 'package:hold/widget/constructors/conversation_constructor.dart';
import 'package:hold/widget/constructors/conversation_created_constructor.dart';
import 'package:hold/widget/dialogs/dialog_yes_no_cancel.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';
import 'package:hold/widget/stick_position.dart';

import 'constants/app_colors.dart';
import 'main.dart';
import 'model/reminder.dart';

class ConversationCreationScreen extends StatefulWidget {
  final ConversationCreationBloc bloc;
  final double initialWidth, initialHeight;
  final Color initialColor;
  final Offset offset;

  const ConversationCreationScreen(
    this.bloc, {
    @required this.initialWidth,
    @required this.initialHeight,
    @required this.offset,
    this.initialColor,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConversationCreationScreenState();
  }
}

class _ConversationCreationScreenState
    extends State<ConversationCreationScreen> {
  ConversationCreatedConstructor constructor;
  ScrollController controller = new ScrollController();
  bool firstStepShown = false;
  final GlobalKey _endConversationButtonKey = GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldStateKey = new GlobalKey();
  final GlobalKey _scrollKey = new GlobalKey();

  final facebookAppEvents = FacebookAppEvents();

  // Offset _containerPosition = Offset(0, 0);
  StickPosition stickPosition;
  int dataNumber;

  @override
  void initState() {
    print(
        "during opening this screen the parameters are ${widget.initialWidth}, ${widget.initialHeight}, ${widget.offset}");
    constructor = new ConversationCreatedConstructor(
        widget.bloc,
        _finish,
        _showDeleteAnswerDialog,
        _showInfo,
        _scrollKey,
        widget.initialHeight,
        widget.initialWidth,
        widget.offset,
        MyApp.screenWidth);

    SchedulerBinding.instance.addPostFrameCallback(_createCoach);
    stickPosition = constructor.getPosition(widget.bloc.type, 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: scaffoldStateKey,
          backgroundColor: AppColors.REFLECTION_LIST_BG,
          appBar: AppBar(
            leading: AppBarBack(
              onTap: _onWillPop,
            ),
            centerTitle: true,
            title: FutureBuilder<int>(
              initialData: 0,
              future: widget.bloc.cardNumber,
              builder: (BuildContext context, AsyncSnapshot<int> data) {
                dataNumber = data.data;
                return Text(
                  "Conversation n. ${data.data}",
                  style: TextStyle(color: AppColors.REFLECT_SCREEN_TITLE),
                );
              },
            ),
            actions: <Widget>[
              PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.REFLECT_SCREEN_TITLE,
                  ),
                  onSelected: _showOnMenuResult,
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                          value: "delete",
                          child: Text(
                            "Delete",
                            style: TextStyle(color: AppColors.TEXT),
                          )),
                      PopupMenuItem<String>(
                          value: "reminder",
                          child: Text(
                            "Set a reminder for this",
                            style: TextStyle(color: AppColors.TEXT),
                          ))
                    ];
                  }),
            ],
          ),
          body: Stack(
            children: <Widget>[
              Positioned(
                key: _scrollKey,
                top: 0,
                bottom: AppSizes.BOTTOM_BUTTON_SIZE,
                left: 0,
                right: 0,
                child: StreamBuilder<List<Widget>>(
                  stream: constructor.parts,
                  initialData: <Widget>[Container()],
                  builder:
                      (BuildContext context, AsyncSnapshot<List<Widget>> data) {
                    // WidgetsBinding.instance
                    //     .addPostFrameCallback(_onBuildCompleted);
                    WidgetsBinding.instance
                        .addPostFrameCallback(_scrollToBottom);

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showStepCoach(constructor.index);
                    });
                    if (data.data.length > 1) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        controller: controller,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: data.data,
                        ),
                      );
                    } else {
                      return data.data.first;
                    }
                  },
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
                  builder: (BuildContext context,
                      AsyncSnapshot<ActiveActions> data) {
                    switch (data.data) {
                      case ActiveActions.initial:
                        return TypingActions(
                          () {
                            constructor.showKeyboard(
                                constructor.inputFieldKey.currentState,
                                false,
                                dataNumber);
                          },
                          () {
                            constructor.showVoice(
                                constructor.inputFieldKey.currentState,
                                false,
                                dataNumber);
                          },
                          constructor.next,
                          constructor.getActiveItemColor(constructor.index),
                          buttonOptions: ButtonOptions.initial,
                        );
                      case ActiveActions.typingInProgress:
                        return TypingActions(
                          () {
                            constructor.showKeyboard(
                                constructor.inputFieldKey.currentState,
                                false,
                                dataNumber);
                          },
                          () {
                            constructor.showVoice(
                                constructor.inputFieldKey.currentState,
                                false,
                                dataNumber);
                          },
                          constructor.next,
                          constructor.getActiveItemColor(constructor.index),
                          buttonOptions: ButtonOptions.voiceAndProgress,
                        );
                      case ActiveActions.voiceInProgress:
                        return TypingActions(
                          () {
                            constructor.showKeyboard(
                                constructor.inputFieldKey.currentState,
                                false,
                                dataNumber);
                          },
                          () {
                            constructor.showVoice(
                                constructor.inputFieldKey.currentState,
                                false,
                                dataNumber);
                          },
                          constructor.next,
                          constructor.getActiveItemColor(constructor.index),
                          buttonOptions: ButtonOptions.keyboardAndProgress,
                        );
                      case ActiveActions.typeVisible:
                        return TypingActions(
                          () {
                            constructor.showKeyboard(
                                constructor.inputFieldKey.currentState,
                                false,
                                dataNumber);
                          },
                          () {
                            constructor.showVoice(
                                constructor.inputFieldKey.currentState,
                                false,
                                dataNumber);
                          },
                          constructor.next,
                          constructor.getActiveItemColor(constructor.index),
                          buttonOptions: ButtonOptions.voice,
                        );
                      case ActiveActions.voiceVisible:
                        return TypingActions(
                          () {
                            constructor.showKeyboard(
                                constructor.inputFieldKey.currentState,
                                false,
                                dataNumber);
                          },
                          () {
                            constructor.showVoice(
                                constructor.inputFieldKey.currentState,
                                false,
                                dataNumber);
                          },
                          constructor.next,
                          constructor.getActiveItemColor(constructor.index),
                          buttonOptions: ButtonOptions.keyboard,
                        );
                      case ActiveActions.endConversation:
                        // _getContainerPosition();
                        _showEndConversationCoach();
                        return BottomButtonInStack(
                          "END CONVERSATION",
                          constructor.next,
                          buttonColor: Color(0xffededed),
                          textColor: Color(0xff17213c),
                          key: _endConversationButtonKey,
                        );
                      case ActiveActions.backOrComplete:
                        {
                          print(
                              "backOrComplete-----------------------------------");
                          return BackCompleteActions(
                              constructor.cancelInput, null);
                        }
                      case ActiveActions.backOrCompleteAvailable:
                        {
                          print(
                              "backOrCompleteAvailable-----------------------------------");
                          return BackCompleteActions(
                              constructor.cancelInput, constructor.next);
                        }
                      case ActiveActions.nothing:
                      default:
                        return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }

  void _showOnMenuResult(String value) {
    if (value == "delete") {
      if (widget.bloc.conversation.content.length == 0) {
        deleteConversation();
      } else {
        DialogLaunchers.showAnimatedDelete(context,
            title: "Delete conversation",
            titleIcon: Icons.delete_outline,
            toastText: "'${widget.bloc.conversation.getTitle()}' deleted",
            mainText: "Are you sure you want to delete this conversation?",
            yesAction: () async {
          deleteConversation();
          Navigator.of(context).pop();
        }, noAction: () {});
      }
    } else
      _showReminderDialog();
  }

  void deleteConversation() async {
    await widget.bloc.deleteConversation();
    Navigator.of(context).pop();
  }

  Future _showReminderDialog() async {
    MixPanelProvider().trackIncrement("# Incomplete Conversations");
    NotificationBloc bloc = new NotificationBloc();
    await bloc.initReminderItem(widget.bloc.conversation.cardNumber,
        widget.bloc.conversation.getTitle());
    await DialogLaunchers.showReminderDialog(context, bloc);
  }

  void _showInfo(String questionTitle, String longDescription, int level) {
    DialogLaunchers.showInfo(context, questionTitle, longDescription);
  }

  void _finish() async {
    List<ConversationWidgetContent> data =
        await StorageProvider().getReflectionList();
    if (data != null) {
      int result = await Navigator.of(context).push(CupertinoPageRoute<int>(
          builder: (context) => RenameScreen(
                "You have successfully created \n'Conversation no. ${widget.bloc.conversation.cardNumber}'.",
                widget.bloc.setTitle,
                subtitle: "Please, give it a memorable title.",
              )));
      facebookAppEvents.logEvent(name: 'Completeconversation');
      if (result != null) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<bool> _onWillPop() async {
    Reminder reminderForThisCard = await StorageProvider()
        .getReminderForCard(widget.bloc.conversation.cardNumber, "");
    if (reminderForThisCard == null) {
      await _showLeaveDialog();
      return false;
    }
    return true;
  }

  Future _showLeaveDialog() async {
    print(
        "_showLeaveDialog ------------------------------------ ${widget.bloc.conversation.cardNumber}");
    bool dialogResult = await DialogLaunchers.showDialog(
        context: context,
        dialog: DialogYesNoCancel(
            "You are leaving, do you want to come back to this later by setting a reminder",
            () {},
            noAction: () {},
            title: "Do you want to set a reminder?",
            icon: Icons.alarm));
    print("RESULT $dialogResult");
    if (dialogResult != null) {
      constructor.next();
      if (dialogResult) {
        await _showReminderDialog();
      }
      Navigator.of(context).pop();
    }
  }

  void _showDeleteAnswerDialog() {
    DialogLaunchers.showAnimatedDelete(
      context,
      title: "Delete section",
      mainText:
          "Are you sure you want to delete this part of your conversation?",
      yesAction: () {
        constructor.cancelInput();
      },
      titleIcon: Icons.delete_outline,
      noAction: () {},
      toastText: "Part of the conversation deleted",
    );
  }

  @override
  void dispose() {
    widget.bloc.destroy();
    super.dispose();
  }

  void _scrollToBottom(Duration timeStamp) {
    if (controller.hasClients) {
      controller.animateTo(controller.position.maxScrollExtent,
          duration: AppSizes.ANIMATION_DURATION,
          curve: AppSizes.ANIMATION_TYPE);
    }
  }

  void _createCoach(Duration timestemp) {
    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'endConversation',
      enableHolesAnimation: false,
      bgColor: Colors.black.withOpacity(0.75),
      // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveEndConversationCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[
        WidgetData(
          key: _endConversationButtonKey,
          isEnabled: false,
          padding: 0,
          shape: WidgetShape.TopRRect,
        ),
        WidgetData(
          key: constructor.inputFieldKey,
          isEnabled: false,
          padding: -30,
          shape: WidgetShape.StretchedVRRect,
        ),
      ],
      description: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Now you can finish the conversation or keep talking.',
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
        ),
      ),
    );
    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'afterFirstStep',
      enableHolesAnimation: false,
      bgColor: Colors.black.withOpacity(0.75),
      // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveSecondStepCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[
        WidgetData(
            key: constructor.inputFieldKey,
            isEnabled: false,
            padding: -16,
            shape: stickPosition == StickPosition.left
                ? WidgetShape.RightRRect
                : stickPosition == StickPosition.right
                    ? WidgetShape.LeftRRect
                    : WidgetShape.RRect),
      ],
      description: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 90),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Now try to take the other side of the conversation.',
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
      enableHolesAnimation: false,
      tagName: 'afterSecondStep',
      bgColor: Colors.black.withOpacity(0.75),
      // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveThirdStepCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[],
      description: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Container(
            child: Text(
              'After this third entry you\ncan end the conversation\nif you want to.',
              textAlign: TextAlign.center,
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
        ),
      ),
    );
  }

  void _showStepCoach(int index) async {
    if (index == 2 && !await PreferencesProvider().getSecondStepCoachMark()) {
      constructor.inputFieldKey.currentState.unfocus();
      showOverlayEntry(tagName: 'afterFirstStep');
    }
    if (index == 3 && !await PreferencesProvider().getThirdStepCoachMark()) {
      constructor.inputFieldKey.currentState.unfocus();
      showOverlayEntry(tagName: 'afterSecondStep');
    }
  }

  void _showEndConversationCoach() async {
    if (!await PreferencesProvider().getEndConversationCoachMark()) {
      showOverlayEntry(tagName: 'endConversation');
    }
  }
}
