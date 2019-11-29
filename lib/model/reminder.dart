import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Reminder {
  static const TABLE_NAME = "reminder";

  static const COLUMN_ID = "id";
  static const COLUMN_CARD_NUMBER = "card_num";
  static const COLUMN_CREATED = "created";
  static const COLUMN_WEEKDAYS = "weekdays";
  static const COLUMN_REPEAT = "repeat_week";
  static const COLUMN_TIME = "time_of_day";
  static const COLUMNS = [
    COLUMN_CARD_NUMBER,
    COLUMN_CREATED,
    COLUMN_WEEKDAYS,
    COLUMN_REPEAT,
    COLUMN_TIME,
    COLUMN_ID,
  ];

  static const CREATE_EXPRESSION = '''
            create table $TABLE_NAME ( 
              $COLUMN_ID integer primary key autoincrement, 
              $COLUMN_CREATED integer not null,
              $COLUMN_CARD_NUMBER integer,
              $COLUMN_WEEKDAYS text, 
              $COLUMN_REPEAT integer,
              $COLUMN_TIME integer)
            ''';

  bool repeatWeekly = false;
  static const MONDAY = "Monday";
  static const TUESDAY = "Tuesday";
  static const WEDNESDAY = "Wednesday";
  static const THIRSDAY = "Thursday";
  static const FRIDAY = "Friday";
  static const SATURDAY = "Saturday";
  static const SUNDAY = "Sunday";
  Map<String, bool> weekdays = {
    MONDAY: false,
    TUESDAY: false,
    WEDNESDAY: false,
    THIRSDAY: false,
    FRIDAY: false,
    SATURDAY: false,
    SUNDAY: false,
  };
  TimeOfDay time;
  final int cardNum;
  final DateTime created;
  final String title;
  int id;

  Reminder(this.cardNum, this.title) : created = DateTime.now();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_CREATED: created.millisecondsSinceEpoch,
      COLUMN_CARD_NUMBER: cardNum,
      COLUMN_WEEKDAYS: _formWeekdaysString(),
      COLUMN_REPEAT: repeatWeekly ? 1 : 0,
      COLUMN_TIME: _getTimeString(time),
    };
    if (id != null) {
      map[COLUMN_ID] = id;
    }
    return map;
  }

  Reminder.fromMap(Map<String, dynamic> map, this.title)
      : cardNum = map[COLUMN_CARD_NUMBER],
        created = DateTime.fromMillisecondsSinceEpoch(map[COLUMN_CREATED]),
        repeatWeekly = map[COLUMN_REPEAT] > 0,
        weekdays = _formWeekdaysMap(map[COLUMN_WEEKDAYS]),
        time = _formTimeOfDay(map[COLUMN_TIME]),
        id = map[COLUMN_ID];

  _formWeekdaysString() {
    return weekdays.values.map((value) {
      return value ? "1" : "0";
    }).join();
  }

  static Map<String, bool> _formWeekdaysMap(String dbValue) {
    return {
      MONDAY: dbValue[0] == "1",
      TUESDAY: dbValue[1] == "1",
      WEDNESDAY: dbValue[2] == "1",
      THIRSDAY: dbValue[3] == "1",
      FRIDAY: dbValue[4] == "1",
      SATURDAY: dbValue[5] == "1",
      SUNDAY: dbValue[6] == "1",
    };
  }

  static TimeOfDay _formTimeOfDay(String dbValue) {
    List<String> s = dbValue.split(":");
    return TimeOfDay(hour: int.parse(s[0]), minute: int.parse(s[1]));
  }

  String getTitle() {
    if (cardNum == 0) {
      return "What’s on your mind?";
    } else {
      if (title == null || title.isEmpty || title == "Untitled") {
        return "Your conversation reminder";
      } else {
        return title;
      }
    }
  }

  String getDescrption() {
    if (cardNum == 0) {
      return "What do you want to talk about?\nYou can start a new conversation, reflect on previous entries or build on your collections.";
    } else {
      return "You wanted to come back to your conversation. Would you like to continue now?";
    }
  }

  _getTimeString(TimeOfDay time) {
    return "${time.hour}:${time.minute}";
  }

  String getPropertiesString() {
    String dayDescription = "";
    if (repeatWeekly) {
      dayDescription += "Every ";
    }
    int selectedDaysCount = _getSelectedDaysCount();
    if (selectedDaysCount == 1) {
      if (weekdays[MONDAY]) dayDescription += "Monday";
      if (weekdays[TUESDAY]) dayDescription += "Tuesday";
      if (weekdays[WEDNESDAY]) dayDescription += "Wednesday";
      if (weekdays[THIRSDAY]) dayDescription += "Thursday";
      if (weekdays[FRIDAY]) dayDescription += "Friday";
      if (weekdays[SATURDAY]) dayDescription += "Saturday";
      if (weekdays[SUNDAY]) dayDescription += "Sunday";
    } else if (selectedDaysCount == 0) {
      dayDescription += DateFormat('EEEE').format(created);
    } else {
      dayDescription += "$selectedDaysCount days";
    }

    String hourString = time.hourOfPeriod < 10
        ? "0" + time.hourOfPeriod.toString()
        : time.hourOfPeriod.toString();
    String minuteString = time.minute < 10
        ? "0" + time.minute.toString()
        : time.minute.toString();
    String period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hourString:$minuteString $period $dayDescription";
  }

  int _getSelectedDaysCount() {
    int count = 0;
    for (bool value in weekdays.values) {
      if (value) count++;
    }
    return count;
  }

  DateTime getDateTimeNextWeek() {
    DateTime now = DateTime.now();
    now = now.add(new Duration(days: 7));
    return new DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  DateTime getDateTime(int weekday) {
    DateTime now = DateTime.now();
    while (now.weekday != weekday) {
      now = now.add(new Duration(days: 1));
    }
    return new DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  bool isTomorrowTime() {
    return created.hour > time.hour ||
        (created.hour == time.hour && created.minute > time.minute);
  }

  List<bool> getWeekdayList() {
    return [
      weekdays[SUNDAY],
      weekdays[MONDAY],
      weekdays[TUESDAY],
      weekdays[WEDNESDAY],
      weekdays[THIRSDAY],
      weekdays[FRIDAY],
      weekdays[SATURDAY],
    ];
  }

  String getEditRequest() {
    if (cardNum == 0) {
      return "Pick a time and a day when you want to come back to HOLD.";
    } else {
      String titleInRequest = title.isEmpty ? "Untitled" : title;
      return "Pick a time and a day when you want to remind yourself to come back to '$titleInRequest'.";
    }
  }

  int getCardNum(){
    return cardNum;
  }

  int getDatabaseRepeat() {
    return repeatWeekly ? 1 : 0;
  }

  String getDatabaseWeekdsays() {
    return _formWeekdaysString();
  }

  String getDatabaseTime() {
    return _getTimeString(time);
  }

  @override
  String toString() {
    return 'Reminder{repeatWeekly: $repeatWeekly, weekdays: $weekdays, time: $time, cardNum: $cardNum, created: $created, title: $title, id: $id}';
  }
}
