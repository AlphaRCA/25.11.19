import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/utils/notification_manager.dart';
import 'package:hold/model/reminder.dart';
import 'package:hold/storage/reminder_id.dart';
import 'package:hold/storage/storage_provider.dart';

import 'mixpanel_provider.dart';

class NotificationBloc {
  static const channnelID = "156";
  static const channelName = "Reflection reminders";
  static const channelDescription = "Reminders to continue reflecting";

  static const String reflectionNotificationDescription =
      "What do you want to talk about?\nYou can start a new conversation, reflect on previous entries or build on your collections.";

  NotificationManager notificationManager = NotificationManager();

  StreamController<List<Reminder>> _remindersController =
      new StreamController();

  Stream<List<Reminder>> get reminders => _remindersController.stream;
  List<Reminder> _reminders;

  StreamController<bool> _mixpanelNotificationsEnabledController =
      new StreamController();

  Stream<bool> get allNotificationsEnabled =>
      _mixpanelNotificationsEnabledController.stream;

  StreamController<bool> _myNotificationsEnabledController =
      new StreamController();

  Stream<bool> get myNotificationsEnabled =>
      _myNotificationsEnabledController.stream;

  int editedCardNumber;
  Reminder editedReminder;
  bool isUpdated;

  NotificationBloc() {
    _loadReminders();
    _loadPreferences();
  }

  Future switchAllNotifications(bool value) async {
    MixPanelProvider().trackEvent("PROFILE", {
      "Click Notifications switch": DateTime.now().toIso8601String(),
      "value": value ? "enabled" : "disabled"
    });
    await PreferencesProvider().saveMixpanelNotificationsEnabled(value);
    _mixpanelNotificationsEnabledController.add(value);
  }

  void switchMyNotifications(bool value) {
    MixPanelProvider().trackEvent("PROFILE", {
      "Click Reminders": DateTime.now().toIso8601String(),
      "value": value ? "enabled" : "disabled"
    });
    PreferencesProvider().saveMyNotificationsEnabled(value);
    _myNotificationsEnabledController.add(value);
    if (value) {
      _reinitReflectionNotifications();
    } else {
      _cancelReflectionNotifications();
    }
  }

  void selectDay(String selectedIndex, bool value) {
    editedReminder.weekdays[selectedIndex] = value;
  }

  void onWeekSwitch(bool value) {
    editedReminder.repeatWeekly = value;
  }

  void dismissEdition() {
    editedReminder = null;
    editedCardNumber = null;
  }

  Future<bool> saveCreation() async {
    MixPanelProvider().trackEvent("PROFILE", {
      "Set reminder result": DateTime.now().toIso8601String(),
      "update action": isUpdated,
      "selected weekdays": editedReminder.weekdays,
      "time": "${editedReminder.time.hour}:${editedReminder.time.minute}"
    });

    if (await StorageProvider().hasTheSameReminder(editedReminder)) {
      return false;
    } else {
      if (isUpdated) {
        _removeNotifications(editedReminder.id);
        StorageProvider().updateReminder(editedReminder);
        _createScheduledNotification(editedReminder);
      } else {
        int reminderId = await StorageProvider().addReminder(editedReminder);
        editedReminder.id = reminderId;
        _createScheduledNotification(editedReminder);
        editedReminder = null;
        editedCardNumber = null;
      }
      _loadReminders();
      return true;
    }
  }

  Future initReminderItem(int cardNumber, String title) async {
    editedCardNumber = cardNumber;
    editedReminder =
        await StorageProvider().getReminderForCard(cardNumber, title);
    if (editedReminder == null) {
      isUpdated = false;
      editedReminder = new Reminder(cardNumber, title);
      DateTime now = DateTime.now();
      editedReminder.time = TimeOfDay(hour: now.hour, minute: now.minute);
    } else {
      isUpdated = true;
    }
  }

  Future editReminderById(Reminder reminder) async {
    editedReminder = reminder;
    isUpdated = true;
  }

  void createGeneralReminder() {
    editedCardNumber = 0;
    isUpdated = false;
    editedReminder = new Reminder(0, "General reminder");
    DateTime now = DateTime.now();
    editedReminder.time = TimeOfDay(hour: now.hour, minute: now.minute);
  }

  void onEditedMinuteChange(int value) {
    editedReminder.time =
        TimeOfDay(hour: editedReminder.time.hour, minute: value);
  }

  void onEditedHourChange(int value) {
    bool isAmSelected = editedReminder.time.hour < 12;
    editedReminder.time = TimeOfDay(
        hour: isAmSelected ? value : value + 12,
        minute: editedReminder.time.minute);
  }

  void onEditedAmPmChanged(DayPeriod value) {
    bool wasAmSelected = editedReminder.time.period == DayPeriod.am;
    if (value == DayPeriod.am && !wasAmSelected) {
      editedReminder.time = TimeOfDay(
          hour: editedReminder.time.hour - 12,
          minute: editedReminder.time.minute);
    } else if (value == DayPeriod.pm && wasAmSelected) {
      editedReminder.time = TimeOfDay(
          hour: editedReminder.time.hour + 12,
          minute: editedReminder.time.minute);
    }
  }

  Future deleteReminder(int id) async {
    await _removeNotifications(id);
    await StorageProvider().deleteReminder(id);
    _loadReminders();
  }

  Future _loadReminders() async {
    await StorageProvider().clearOldReminders();
    _reminders = await StorageProvider().getActualReminders();
    _remindersController.add(_reminders);
  }

  void _loadPreferences() async {
    bool areAllNotificationsEnabled =
        await PreferencesProvider().getAllNotificationsEnabled();
    _mixpanelNotificationsEnabledController.add(areAllNotificationsEnabled);

    bool areMyNotificationsEnabled =
        await PreferencesProvider().getMyNotificationsEnabled();
    _myNotificationsEnabledController.add(areMyNotificationsEnabled);
  }

  Future _createScheduledNotification(Reminder reminder) async {
    bool atLeastOneDaySelected = false;
    if (reminder.repeatWeekly) {
      if (reminder.weekdays[Reminder.MONDAY]) {
        atLeastOneDaySelected = true;
        await _createReminderNotification(reminder, 1);
      }
      if (reminder.weekdays[Reminder.TUESDAY]) {
        atLeastOneDaySelected = true;
        await _createReminderNotification(reminder, 2);
      }
      if (reminder.weekdays[Reminder.WEDNESDAY]) {
        atLeastOneDaySelected = true;
        await _createReminderNotification(reminder, 3);
      }
      if (reminder.weekdays[Reminder.THIRSDAY]) {
        atLeastOneDaySelected = true;
        await _createReminderNotification(reminder, 4);
      }
      if (reminder.weekdays[Reminder.FRIDAY]) {
        atLeastOneDaySelected = true;
        await _createReminderNotification(reminder, 5);
      }
      if (reminder.weekdays[Reminder.SATURDAY]) {
        atLeastOneDaySelected = true;
        await _createReminderNotification(reminder, 6);
      }
      if (reminder.weekdays[Reminder.SUNDAY]) {
        atLeastOneDaySelected = true;
        await _createReminderNotification(reminder, 7);
      }
      if (!atLeastOneDaySelected) {
        if (reminder.isTomorrowTime()) {
          int tomorrow = reminder.created.weekday + 1;
          if (tomorrow > 7) tomorrow = 1;
          await _createReminderNotification(reminder, tomorrow);
        } else {
          await _createReminderNotification(reminder, reminder.created.weekday);
        }
      }
    } else {
      if (reminder.weekdays[Reminder.MONDAY]) {
        atLeastOneDaySelected = true;
        DateTime flushTime = 1 == DateTime.now().weekday
            ? reminder.getDateTimeNextWeek()
            : reminder.getDateTime(1);
        int notificationId = await StorageProvider().insertReminderId(
            new ReminderId(reminder.id, reminder.getTitle(), false, flushTime,
                reminder.cardNum));
        _scheduleNotification(notificationId, reminder.getTitle(),
            reminder.getDescrption(), flushTime, reminder.cardNum.toString());
      }
      if (reminder.weekdays[Reminder.TUESDAY]) {
        atLeastOneDaySelected = true;
        DateTime flushTime = 2 == DateTime.now().weekday
            ? reminder.getDateTimeNextWeek()
            : reminder.getDateTime(2);
        int notificationId = await StorageProvider().insertReminderId(
            new ReminderId(reminder.id, reminder.getTitle(), false, flushTime,
                reminder.cardNum));
        _scheduleNotification(
          notificationId,
          reminder.getTitle(),
          reminder.getDescrption(),
          flushTime,
          reminder.cardNum.toString(),
        );
      }
      if (reminder.weekdays[Reminder.WEDNESDAY]) {
        atLeastOneDaySelected = true;
        DateTime flushTime = 3 == DateTime.now().weekday
            ? reminder.getDateTimeNextWeek()
            : reminder.getDateTime(3);
        int notificationId = await StorageProvider().insertReminderId(
            new ReminderId(reminder.id, reminder.getTitle(), false, flushTime,
                reminder.cardNum));
        _scheduleNotification(
          notificationId,
          reminder.getTitle(),
          reminder.getDescrption(),
          flushTime,
          reminder.cardNum.toString(),
        );
      }
      if (reminder.weekdays[Reminder.THIRSDAY]) {
        atLeastOneDaySelected = true;
        DateTime flushTime = 4 == DateTime.now().weekday
            ? reminder.getDateTimeNextWeek()
            : reminder.getDateTime(4);
        int notificationId = await StorageProvider().insertReminderId(
            new ReminderId(reminder.id, reminder.getTitle(), false, flushTime,
                reminder.cardNum));
        _scheduleNotification(
          notificationId,
          reminder.getTitle(),
          reminder.getDescrption(),
          flushTime,
          reminder.cardNum.toString(),
        );
      }
      if (reminder.weekdays[Reminder.FRIDAY]) {
        atLeastOneDaySelected = true;
        DateTime flushTime = 5 == DateTime.now().weekday
            ? reminder.getDateTimeNextWeek()
            : reminder.getDateTime(5);
        int notificationId = await StorageProvider().insertReminderId(
            new ReminderId(reminder.id, reminder.getTitle(), false, flushTime,
                reminder.cardNum));
        _scheduleNotification(
          notificationId,
          reminder.getTitle(),
          reminder.getDescrption(),
          flushTime,
          reminder.cardNum.toString(),
        );
      }
      if (reminder.weekdays[Reminder.SATURDAY]) {
        atLeastOneDaySelected = true;
        DateTime flushTime = 6 == DateTime.now().weekday
            ? reminder.getDateTimeNextWeek()
            : reminder.getDateTime(6);
        int notificationId = await StorageProvider().insertReminderId(
            new ReminderId(reminder.id, reminder.getTitle(), false, flushTime,
                reminder.cardNum));
        _scheduleNotification(
          notificationId,
          reminder.getTitle(),
          reminder.getDescrption(),
          flushTime,
          reminder.cardNum.toString(),
        );
      }
      if (reminder.weekdays[Reminder.SUNDAY]) {
        atLeastOneDaySelected = true;
        DateTime flushTime = 7 == DateTime.now().weekday
            ? reminder.getDateTimeNextWeek()
            : reminder.getDateTime(7);
        int notificationId = await StorageProvider().insertReminderId(
            new ReminderId(reminder.id, reminder.getTitle(), false, flushTime,
                reminder.cardNum));
        _scheduleNotification(
          notificationId,
          reminder.getTitle(),
          reminder.getDescrption(),
          flushTime,
          reminder.cardNum.toString(),
        );
      }

      print(" atLeastOneDaySelected : ${atLeastOneDaySelected} ");
      if (!atLeastOneDaySelected) {
        DateTime flushTime;
        if (reminder.isTomorrowTime()) {
          int tomorrow = reminder.created.weekday + 1;
          if (tomorrow > 7) tomorrow = 1;
          flushTime = reminder.getDateTime(tomorrow);
        } else {
          flushTime = reminder.getDateTime(reminder.created.weekday);
        }
        int notificationId = await StorageProvider().insertReminderId(
            new ReminderId(reminder.id, reminder.getTitle(), false, flushTime,
                reminder.cardNum));

        _scheduleNotification(
          notificationId,
          reminder.getTitle(),
          reminder.getDescrption(),
          flushTime,
          reminder.cardNum.toString(),
        );
      }
    }
  }

  Future _onSelectNotification(dynamic payload) async {
    print("payload $payload");
  }

  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDateTime,
    String payload,
  ) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channnelID, channelName, channelDescription,
        enableLights: true,
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await notificationManager.flutterLocalNotificationsPlugin.schedule(
      id,
      title,
      body,
      scheduledDateTime,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> _cancelAllNotifications() async {
    await notificationManager.flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _cancelReflectionNotifications() async {
    List<ReminderId> notificationsData =
        await StorageProvider().getAllReminders();
    for (ReminderId notification in notificationsData) {
      notificationManager.flutterLocalNotificationsPlugin
          .cancel(notification.id);
    }
  }

  Future<void> _showWeeklyAtDayAndTime(ReminderId reminderId) async {
    var androidPlatformChannelSpecifics =
        AndroidNotificationDetails(channnelID, channelName, channelDescription);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await notificationManager.flutterLocalNotificationsPlugin
        .showWeeklyAtDayAndTime(
      reminderId.id,
      reminderId.title,
      reflectionNotificationDescription,
      Day(reminderId.flushTime.weekday),
      Time(reminderId.flushTime.hour, reminderId.flushTime.minute),
      platformChannelSpecifics,
      payload: reminderId.payload.toString(),
    );
  }

  Future _removeNotifications(int id) async {
    List<ReminderId> notificationsData =
        await StorageProvider().getReminderIds(id);
    for (ReminderId notification in notificationsData) {
      notificationManager.flutterLocalNotificationsPlugin
          .cancel(notification.id);
    }
    await StorageProvider().deleteNotificationsForReminder(id);
  }

  Future _reinitReflectionNotifications() async {
    List<ReminderId> notificationsData =
        await StorageProvider().getAllReminders();
    for (ReminderId notification in notificationsData) {
      _recreateScheduledNotification(notification);
    }
  }

  void _recreateScheduledNotification(ReminderId reminderId) {
    notificationManager.flutterLocalNotificationsPlugin.cancel(reminderId.id);
    if (reminderId.isRepeating) {
      _showWeeklyAtDayAndTime(reminderId);
    } else {
      _scheduleNotification(
        reminderId.id,
        reminderId.title,
        reflectionNotificationDescription,
        reminderId.flushTime,
        reminderId.payload.toString(),
      );
    }
  }

  Future _createReminderNotification(Reminder reminder, int weekday) async {
    ReminderId reminderId = new ReminderId(reminder.id, reminder.getTitle(),
        true, reminder.getDateTime(weekday), reminder.cardNum);
    int notificationId = await StorageProvider().insertReminderId(reminderId);
    reminderId.id = notificationId;
    _showWeeklyAtDayAndTime(reminderId);
  }
}
