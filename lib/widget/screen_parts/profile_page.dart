import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hold/bloc/data_overall_bloc.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/notification_bloc.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_styles.dart';
import 'package:hold/get_support_screen.dart';
import 'package:hold/improve_hold_screen.dart';
import 'package:hold/loaded_text_screen.dart';
import 'package:hold/widget/buttons/green_action.dart';
import 'package:hold/widget/dialogs/dialog_yes_no_cancel.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';
import 'package:hold/widget/screen_parts/divider_line.dart';
import 'package:hold/widget/screen_parts/flat_text_button.dart';
import 'package:hold/widget/screen_parts/playback_options.dart';
import 'package:hold/widget/screen_parts/reminders_list.dart';
import 'package:hold/widget/white_text.dart';
import 'package:coach_marks/TutorialOverlayUtil.dart';
import 'package:coach_marks/WidgetData.dart';

class ProfilePage extends StatefulWidget {
  static const TERMS_ADDRESS = "https://hold.new-staging.springsapps.com/terms";
  static const PRIVACY_ADDRESS =
      "https://hold.new-staging.springsapps.com/privacy";

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final NotificationBloc notificationBloc = new NotificationBloc();
  final DataOverallBloc dataBloc = new DataOverallBloc();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(_createCoach);
    super.initState();
    _showCoachMark();
  }

  @override
  Widget build(BuildContext context) {
    MixPanelProvider().trackEvent(
        "PROFILE", {"Pageview Profile": DateTime.now().toIso8601String()});
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 48,
          ),
          WhiteText(
            "REMINDERS",
            paddingLeft: 24,
            paddingTop: 8,
          ),
          RemindersList(notificationBloc),
          DividerLine(),
          WhiteText(
            "SUPPORT",
            paddingLeft: 24,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              "For further support click on the button below.",
              style: AppStyles.PROFILE_TEXT,
            ),
          ),
          GreenAction("GET SUPPORT", () {
            MixPanelProvider().trackEvent("PROFILE",
                {"Click Get Support Button": DateTime.now().toIso8601String()});
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => GetSupportScreen()));
          }),
          DividerLine(),
          PlaybackOptions(),
          DividerLine(),
          WhiteText(
            "FEEDBACK",
            paddingLeft: 24,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              "If you want to take part in the improvement of 'HOLD' "
              "or you have feedback for the team, click below to "
              "enter your details:",
              style: AppStyles.PROFILE_TEXT,
            ),
          ),
          GreenAction("IMPROVE HOLD", () => _openImprovementPage(context)),
          DividerLine(),
          WhiteText(
            "DATA",
            paddingLeft: 24,
          ),
          FlatTextButton("Terms of service", () {
            MixPanelProvider().trackEvent("PROFILE",
                {"Click Terms of Service": DateTime.now().toIso8601String()});
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LoadedTextScreen(
                    "Terms of service", ProfilePage.TERMS_ADDRESS)));
          }),
          FlatTextButton("Privacy policy", () {
            MixPanelProvider().trackEvent("PROFILE",
                {"Click Privacy Policy": DateTime.now().toIso8601String()});
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LoadedTextScreen(
                    "Privacy policy", ProfilePage.PRIVACY_ADDRESS)));
          }),
          StreamBuilder<bool>(
            initialData: false,
            stream: dataBloc.hasData,
            builder: (BuildContext ctxt, AsyncSnapshot<bool> data) {
              bool hasData = data.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatTextButton("Export data", hasData ? _doExport : null),
                  FlatTextButton("Import data", hasData ? null : _doImport),
                  FlatTextButton(
                      "Delete my data",
                      hasData
                          ? () {
                        MixPanelProvider().trackEvent("PROFILE",
                            {"Click Delete my Data": DateTime.now().toIso8601String()});
                              DialogLaunchers.showDialog(
                                context: context,
                                dialog: DialogYesNoCancel(
                                  "By tapping 'YES' you will delete everything in the HOLD "
                                  "App and you will not be able to recover this data",
                                  _doDelete,
                                  title:
                                      "Are you sure you want to delete all your data?",
                                  icon: Icons.delete_outline,
                                ),
                              );
                            }
                          : null),
                ],
              );
            },
          ),
          DividerLine(),
          FutureBuilder<String>(
            initialData: "",
            future: PreferencesProvider().getUid(),
            builder: (BuildContext context, AsyncSnapshot<String> data) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  data.data,
                  style: TextStyle(color: AppColors.QUESTION_INACTIVE_TEXT),
                ),
              );
            },
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  void _openImprovementPage(context) {
    MixPanelProvider().trackEvent("PROFILE",
        {"Click Improve HOLD Button": DateTime.now().toIso8601String()});
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ImproveHoldScreen()));
  }

  Future _doExport() async {
    MixPanelProvider().trackEvent("PROFILE",
        {"Click Export Data": DateTime.now().toIso8601String()});
    //TODO show progress
    dataBloc.exportData();
  }

  Future _doImport() async {
    MixPanelProvider().trackEvent("PROFILE",
        {"Click Import Data": DateTime.now().toIso8601String()});
    await dataBloc.importData();
    //TODO recreate notifications
  }

  void _createCoach(Duration timestamp) {
    createTutorialOverlay(
      context: context,
      defaultPadding: 0,
      tagName: 'profile',
      bgColor: Colors.black.withOpacity(
          0.75), // Optional. uses black color with 0.4 opacity by default
      onTap: () {
        PreferencesProvider().saveProfileScreenCoachMark();
        hideOverlayEntryIfExists();
      },
      widgetsData: <WidgetData>[],
      description: Center(
        child: Text(
          'Here you can change your\n'
          'reminders, get further\n'
          'support, offer feedback to\n'
          'the HOLD team or manage\nyour data.',
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
    );
  }

  void _showCoachMark() async {
    if (!await PreferencesProvider().getProfileScreenCoachMark())
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            showOverlayEntry(tagName: 'profile');
          });
        }
      });
  }

  void _doDelete() async {
    await notificationBloc.switchAllNotifications(false);
    await dataBloc.clearData();
  }
}
