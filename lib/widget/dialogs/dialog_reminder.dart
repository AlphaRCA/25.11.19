import 'package:flutter/material.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/notification_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/constants/app_styles.dart';
import 'package:hold/model/reminder.dart';
import 'package:hold/widget/dialogs/dialog_the_same_reminder_exist.dart';
import 'package:hold/widget/dialogs/time_selector.dart';
import 'package:hold/widget/dialogs/toast_reminder_set.dart';
import 'package:hold/widget/dialogs/weekday_selector.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';
import 'package:oktoast/oktoast.dart';

class DialogReminder extends StatefulWidget {
  final NotificationBloc bloc;

  const DialogReminder(
    this.bloc, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DialogReminderState();
  }
}

class _DialogReminderState extends State<DialogReminder> {
  bool _switchValue;
  List<bool> _weekdaySelection;

  @override
  void initState() {
    _switchValue = widget.bloc.editedReminder.repeatWeekly;
    _weekdaySelection = widget.bloc.editedReminder.getWeekdayList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.TRANSPARENT,
      contentPadding: EdgeInsets.symmetric(vertical: 24.0),
      content: Container(
        height: 580,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(AppSizes.BORDER_RADIUS)),
              color: AppColors.DIALOG_REMINDER_BG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 24, bottom: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Make time to think",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 21.13,
                          color: AppColors.TEXT_EF),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      widget.bloc.editedReminder.getEditRequest(),
                      style: TextStyle(color: Color(0x61ffffff)),
                    ),
                  ],
                ),
              ),
              Container(
                height: AppSizes.NUMBER_PICKER_ITEM_HEIGHT * 4 + 2,
                child: TimeSelector(
                  widget.bloc.onEditedHourChange,
                  widget.bloc.onEditedMinuteChange,
                  widget.bloc.onEditedAmPmChanged,
                  initialTime: widget.bloc.editedReminder.time,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  WeekdaySelector(
                    "M",
                    () {
                      widget.bloc
                          .selectDay(Reminder.MONDAY, !_weekdaySelection[0]);
                      setState(() {
                        _weekdaySelection[0] = !_weekdaySelection[0];
                      });
                    },
                    isSelected: _weekdaySelection[0],
                  ),
                  WeekdaySelector(
                    "T",
                    () {
                      widget.bloc
                          .selectDay(Reminder.TUESDAY, !_weekdaySelection[1]);
                      setState(() {
                        _weekdaySelection[1] = !_weekdaySelection[1];
                      });
                    },
                    isSelected: _weekdaySelection[1],
                  ),
                  WeekdaySelector(
                    "W",
                    () {
                      widget.bloc
                          .selectDay(Reminder.WEDNESDAY, !_weekdaySelection[2]);
                      setState(() {
                        _weekdaySelection[2] = !_weekdaySelection[2];
                      });
                    },
                    isSelected: _weekdaySelection[2],
                  ),
                  WeekdaySelector(
                    "T",
                    () {
                      widget.bloc
                          .selectDay(Reminder.THIRSDAY, !_weekdaySelection[3]);
                      setState(() {
                        _weekdaySelection[3] = !_weekdaySelection[3];
                      });
                    },
                    isSelected: _weekdaySelection[3],
                  ),
                  WeekdaySelector(
                    "F",
                    () {
                      widget.bloc
                          .selectDay(Reminder.FRIDAY, !_weekdaySelection[4]);
                      setState(() {
                        _weekdaySelection[4] = !_weekdaySelection[4];
                      });
                    },
                    isSelected: _weekdaySelection[4],
                  ),
                  WeekdaySelector(
                    "S",
                    () {
                      widget.bloc
                          .selectDay(Reminder.SATURDAY, !_weekdaySelection[5]);
                      setState(() {
                        _weekdaySelection[5] = !_weekdaySelection[5];
                      });
                    },
                    isSelected: _weekdaySelection[5],
                  ),
                  WeekdaySelector(
                    "S",
                    () {
                      widget.bloc
                          .selectDay(Reminder.SUNDAY, !_weekdaySelection[6]);
                      setState(() {
                        _weekdaySelection[6] = !_weekdaySelection[6];
                      });
                    },
                    isSelected: _weekdaySelection[6],
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Repeat weekly",
                      style: TextStyle(color: AppColors.DIALOG_REMINDER_TEXT),
                    ),
                  ),
                  Switch(
                    activeTrackColor: Color(0xffa1b2d3),
                    activeColor: Color(0xff0ed998),
                    value: _switchValue,
                    onChanged: (value) {
                      widget.bloc.onWeekSwitch(value);
                      setState(() {
                        _switchValue = value;
                      });
                    },
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(),
                  ),
                  FlatButton(
                    textColor: Color(0xff17213c),
                    child: Text(
                      "CANCEL",
                      style: TextStyle(color: AppColors.DIALOG_REMINDER_TEXT),
                    ),
                    onPressed: () {
                      widget.bloc.dismissEdition();
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    textColor: Color(0xff17213c),
                    child: Text(
                      "SAVE",
                      style: AppStyles.GENERAL_TEXT,
                    ),
                    onPressed: () async {
                      if (widget.bloc.editedReminder.getCardNum() == 0) {
                        MixPanelProvider().trackEvent("Set General Reminder", {
                          "Time General Reminder":
                              "${widget.bloc.getTimeDay().hour}:${widget.bloc.getTimeDay().minute}${widget.bloc.getTimeDay().period == DayPeriod.am ? "am" : "pm"} ",
                          "Days General Reminder": widget.bloc.getDays(),
                          "Repeat weekly General Reminder":
                              widget.bloc.getWeekSwitch()
                        });
                      } else {
                        MixPanelProvider()
                            .trackEvent("Set Conversation Reminder", {
                          "Time Conversation Reminder":
                              "${widget.bloc.getTimeDay().hour}:${widget.bloc.getTimeDay().minute}${widget.bloc.getTimeDay().period == DayPeriod.am ? "am" : "pm"} ",
                          "Days Conversation Reminder": widget.bloc.getDays(),
                          "Repeat weekly Conversation Reminder":
                              widget.bloc.getWeekSwitch()
                        });
                      }

                      if (await widget.bloc.saveCreation()) {
                        showToastWidget(
                          ToastReminderSet(),
                          duration: Duration(seconds: 2),
                        );
                        Navigator.of(context).pop(true);
                      } else {
                        DialogLaunchers.showDialog(
                            context: context,
                            dialog: DialogTheSameReminderExists());
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
