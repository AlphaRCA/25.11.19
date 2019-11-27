import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hold/widget/dialogs/time_item_selector.dart';

import 'am_pm_selector.dart';

class TimeSelector extends StatelessWidget {
  final TimeOfDay initialTime;
  final ValueChanged<int> onHourChanged, onMinuteChanged;
  final ValueChanged<DayPeriod> onDayPeriodChanged;

  const TimeSelector(
    this.onHourChanged,
    this.onMinuteChanged,
    this.onDayPeriodChanged, {
    Key key,
    this.initialTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        TimeItemSelector(
          12,
          onHourChanged,
          initialValue:
              initialTime == null ? DateTime.now().hour : initialTime.hour % 12,
        ),
        TimeItemSelector(
          60,
          onMinuteChanged,
          initialValue:
              initialTime == null ? DateTime.now().minute : initialTime.minute,
        ),
        AmPmSelector(onDayPeriodChanged,
            initialValue: initialTime == null
                ? DateTime.now().hour >= 12 ? DayPeriod.pm : DayPeriod.am
                : initialTime.period),
      ],
    );
  }
}
