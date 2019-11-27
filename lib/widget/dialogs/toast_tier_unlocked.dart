import 'package:flutter/material.dart';
import 'package:hold/widget/dialogs/general_toast.dart';

class ToastTierUnlocked extends StatelessWidget {
  final int tierLevel;

  const ToastTierUnlocked(
    this.tierLevel, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GeneralToast(
      "Stage $tierLevel\n unlocked!",
      iconData: Icons.lock_open,
    );
  }
}
