import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/notification_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_styles.dart';
import 'package:hold/model/reminder.dart';
import 'package:hold/widget/buttons/green_action.dart';
import 'package:hold/widget/dialogs/dialog_yes_no_cancel.dart';
import 'package:hold/widget/dialogs/general_toast.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';
import 'package:oktoast/oktoast.dart';

class RemindersList extends StatefulWidget {
  final NotificationBloc bloc;

  const RemindersList(
    this.bloc, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RemindersListState();
  }
}

class _RemindersListState extends State<RemindersList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StreamBuilder<bool>(
          stream: widget.bloc.allNotificationsEnabled,
          initialData: false,
          builder: (BuildContext ctxt, AsyncSnapshot<bool> value) {
            return Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: SwitchListTile(
                activeTrackColor: Color(0xffa1b2d3),
                activeColor: Color(0xff0ed998),
                inactiveTrackColor: Color(0xffa1b2d3),
                value: value.data,
                title: Text(
                  "Notifications",
                  style: AppStyles.PROFILE_TEXT,
                ),
                onChanged: (value) {
                  MixPanelProvider()
                      .trackPeopleProperties({"Notifications Enabled": value});
                  widget.bloc.switchAllNotifications(value);
                },
              ),
            );
          },
        ),
        StreamBuilder<bool>(
          stream: widget.bloc.myNotificationsEnabled,
          initialData: false,
          builder: (BuildContext ctxt,
              AsyncSnapshot<bool> myNotificationsEnabledSnapshot) {
            final myNotificationsEnabled = myNotificationsEnabledSnapshot.data;

            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: SwitchListTile(
                    activeTrackColor: Color(0xffa1b2d3),
                    activeColor: Color(0xff0ed998),
                    inactiveTrackColor: Color(0xffa1b2d3),
                    value: myNotificationsEnabled,
                    title: Text(
                      "My reminders",
                      style: AppStyles.PROFILE_TEXT,
                    ),
                    onChanged: widget.bloc.switchMyNotifications,
                  ),
                ),
                StreamBuilder<List<Reminder>>(
                  initialData: new List(),
                  stream: widget.bloc.reminders,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Reminder>> data) {
                    List<Reminder> list = data.data;
                    MixPanelProvider().trackPeopleProperties(
                        {"# Reminders": list.length});
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: new BorderRadius.circular(18.0),
                                color: AppColors.REMINDER_EDITION_BG,
                              ),
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          list[index].cardNum == 0
                                              ? "General reminder"
                                              : (list[index].title == null ||
                                                      list[index].title.isEmpty)
                                                  ? "Incomplete conversation"
                                                  : list[index].title,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: myNotificationsEnabled
                                                ? AppColors.TEXT_EF
                                                : AppColors
                                                    .REMINDER_EDITION_TEXT,
                                            fontSize: 17.25,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        Text(
                                          list[index].getPropertiesString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: myNotificationsEnabled
                                                ? AppColors.TEXT_EF
                                                : AppColors
                                                    .REMINDER_EDITION_TEXT,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                      padding: EdgeInsets.zero,
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      icon: SvgPicture.asset(
                                        'assets/material_icons/rounded/action/delete_outline.svg',
                                        color: AppColors.REMINDER_EDITION_TEXT,
                                      ),
                                      onPressed: () {
                                        DialogLaunchers.showDialog(
                                          context: context,
                                          dialog: DialogYesNoCancel(
                                            "Are you sure you want to delete this reminder?",
                                            () {
                                              widget.bloc.deleteReminder(
                                                  list[index].id);
                                            },
                                            noAction: () {},
                                            title: "Delete reminder",
                                            icon: Icons.alarm,
                                          ),
                                        );
                                      }),
                                  IconButton(
                                      padding: EdgeInsets.zero,
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      icon: Icon(Icons.edit,
                                          color:
                                              AppColors.REMINDER_EDITION_TEXT),
                                      onPressed: () {
                                        widget.bloc
                                            .editReminderById(list[index]);
                                        DialogLaunchers.showReminderDialog(
                                            context, widget.bloc);
                                      })
                                ],
                              ),
                            ));
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
        GreenAction("ADD REMINDER", () async {
          widget.bloc.createGeneralReminder();
          bool result =
              await DialogLaunchers.showReminderDialog(context, widget.bloc);
          if (result ?? false) {
            _showReminderSetToast();
          }
        }),
      ],
    );
  }

  void _showReminderSetToast() {
    showToastWidget(
      GeneralToast(
        "Your new \nreminder is \nset",
        iconData: Icons.alarm,
      ),
      duration: Duration(seconds: 2),
    );
  }
}
