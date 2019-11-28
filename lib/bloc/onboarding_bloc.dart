import 'package:hold/bloc/preferences_provider.dart';

class OnboardingBloc {
  void acceptAndStart() async {
    PreferencesProvider().saveFirstRunFinished();
  }
}
