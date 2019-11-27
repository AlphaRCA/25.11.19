import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/bloc/ui_text_updater.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/initial_screen.dart';
import 'package:hold/onboarding_screen.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:native_mixpanel/native_mixpanel.dart';
import 'package:oktoast/oktoast.dart';

import 'constants/app_styles.dart';

void main() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    PreferencesProvider preferencesProvider = PreferencesProvider();
    bool hasToShowOnboarding = await preferencesProvider.getFirstRunFinished();
    runApp(MyApp(hasToShowOnboarding ? InitialScreen() : OnboardingScreen()));
  });
}

class MyApp extends StatelessWidget {
  final Mixpanel mixpanel;
  final Widget initialScreen;
  static double screenWidth;

  MyApp(
    this.initialScreen, {
    Key key,
    this.mixpanel,
  }) : super(key: key) {
    MixPanelProvider(mixpanel: mixpanel);
    StorageProvider().clearOldReminders();
    UITextUpdater();
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'HOLD',
        theme: ThemeData(
          fontFamily: 'Cabin',
          primaryColor: AppColors.APP_BAR,
          canvasColor: AppColors.BACKGROUND,
          cardColor: AppColors.BOTTOM_SHEET_BG,
          buttonTheme: ButtonThemeData(
            buttonColor: AppColors.BUTTON_ACTIVE,
            textTheme: ButtonTextTheme.primary,
          ),
          appBarTheme: AppBarTheme(
            textTheme: TextTheme(
              title: AppStyles.APPBAR_TITLE_TEXT,
            ),
          ),
          primaryTextTheme: TextTheme(
              body1: AppStyles.GENERAL_TEXT,
              button: TextStyle(
                color: AppColors.TEXT,
              )),
        ),
        home: initialScreen,
      ),
    );
  }
}
