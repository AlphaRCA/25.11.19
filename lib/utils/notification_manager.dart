import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hold/bloc/conversation_creation_bloc.dart';
import 'package:hold/main_screen.dart';

import '../conversation_creation_screen.dart';

class NotificationManager {
  BuildContext context;

  static final NotificationManager _instance = NotificationManager._internal();

  factory NotificationManager() => _instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationManager._internal() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    // Android
    final initializationSettingsAndroid =
        AndroidInitializationSettings('ic_announcement');

    // iOS
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    // Init
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: _onSelect,
    );
  }

  Future _onSelect(String payload) async {
    print("_onSelect: $payload");

    if (context == null) return;

    if (int.parse(payload) == 0) {
      print("aaaaa");
      print(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_context) => MainScreen()),
      );
    } else {
      ConversationCreationBloc blocInside =
          ConversationCreationBloc(unfinishedCardNumber: int.parse(payload));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ConversationCreationScreen(
            blocInside,
            initialWidth: 0,
            initialHeight: 0,
            offset: null,
          ),
        ),
      );
    }
  }
}
