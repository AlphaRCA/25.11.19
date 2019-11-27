import 'package:flutter/services.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:native_mixpanel/native_mixpanel.dart';

class OnboardingBloc {
  void acceptAndStart() async {
    PreferencesProvider().saveFirstRunFinished();
    try {
      await Mixpanel().track(
          "finish onboarding", {'DateTime': DateTime.now().toIso8601String()});
    } on PlatformException {
      print('Failed to send event: "finish onboarding"');
    }
  }
}
