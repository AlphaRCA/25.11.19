import 'package:flutter/material.dart';
import 'package:hold/bloc/notification_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/widget/bottom_info_sheet.dart';
import 'package:hold/widget/dialogs/animated_yes_no_dialog.dart';
import 'package:hold/widget/dialogs/dialog_reminder.dart';

class DialogLaunchers {
  static Future<bool> showReminderDialog(
      BuildContext context, NotificationBloc bloc) {
    return showGeneralDialog(
        context: context,
        barrierColor: AppColors.DIALOG_FADER,
        barrierDismissible:
            true, // should dialog be dismissed when tapped outside
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionDuration: Duration(
            milliseconds:
                400), // how long it takes to popup dialog after button click
        pageBuilder: (_, __, ___) {
          return DialogReminder(bloc);
        });
  }

  static Future showDialog(
      {@required BuildContext context, @required Widget dialog}) {
    return showGeneralDialog(
        context: context,
        barrierColor: AppColors.DIALOG_FADER,
        barrierDismissible:
            true, // should dialog be dismissed when tapped outside
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionDuration: Duration(
            milliseconds:
                400), // how long it takes to popup dialog after button click
        pageBuilder: (_, __, ___) {
          return dialog;
        });
  }

  static void showInfo(BuildContext context, String title, String text) {
    Navigator.of(context).push(_TransparentRoute(
        builder: (BuildContext context) => BottomInfoSheet(title, text)));
  }

  static Future<bool> showAnimatedDelete(
    BuildContext context, {
    Key key,
    @required String title,
    @required String mainText,
    @required IconData titleIcon,
    @required VoidCallback yesAction,
    @required String toastText,
    VoidCallback noAction,
  }) {
    return showGeneralDialog(
        context: context,
        barrierColor: AppColors.BOTTOM_SHEET_FADER, // background color
        barrierDismissible:
            false, // should dialog be dismissed when tapped outside
        barrierLabel: "Dialog", // label for barrier
        transitionDuration: Duration(
            milliseconds:
                400), // how long it takes to popup dialog after button click
        pageBuilder: (_, __, ___) {
          // your widget implementation
          return AnimatedYesNoDialog(
            key: key,
            titleIcon: titleIcon,
            title: title,
            mainText: mainText,
            yesAction: yesAction,
            noAction: noAction,
            toastText: toastText,
          );
        });
  }
}

class _TransparentRoute extends PageRoute<void> {
  _TransparentRoute({
    @required this.builder,
    RouteSettings settings,
  })  : assert(builder != null),
        super(settings: settings, fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final result = builder(context);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: result,
      ),
    );
  }
}
