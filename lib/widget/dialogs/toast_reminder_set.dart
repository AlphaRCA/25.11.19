import 'package:flutter/material.dart';
import 'package:hold/widget/dialogs/general_toast.dart';

class ToastReminderSet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GeneralToast(
      "Your new reminder is set",
      iconData: Icons.alarm,
    );
  }
}
