import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:native_mixpanel/native_mixpanel.dart';

class MixPanelProvider {
  static MixPanelProvider _instance;
  Future initialized;
  final Mixpanel mixpanel;
  int flushIndex = 0;

  factory MixPanelProvider({Mixpanel mixpanel}) {
    if (_instance == null) {
      _instance = MixPanelProvider._(mixpanel ?? Mixpanel());
    }
    return _instance;
  }

  MixPanelProvider._(this.mixpanel) {
    initialized = _initialize();
  }

  Future _initialize() async {
    PreferencesProvider preferencesProvider = new PreferencesProvider();
    bool firstRun = await preferencesProvider.getFirstRunFinished();
    String uid = await preferencesProvider.getUid();
    String eventName;
    if (firstRun == null || firstRun)
      eventName = 'First App Open';
    else
      eventName = "App Open";
    try {
      await mixpanel.initialize('6fa6516c702c2e2c63fee644cbf313fd');
      await mixpanel.identify(uid);
      await mixpanel
          .track(eventName, {'DateTime': DateTime.now().toIso8601String()});
      Map<String, dynamic> map = new Map();
      if (firstRun == null || firstRun) {
        map["created"] = DateTime.now().toIso8601String();
      }
      map["last app open"] = DateTime.now().toIso8601String();
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        map["device_manufactirer"] = "Apple";
        map["device"] = iosInfo.utsname.machine;
        map["device_version"] = iosInfo.systemVersion;
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        map["device_manufactirer"] = androidInfo.manufacturer;
        map["device"] = androidInfo.model;
        map["device_version"] = androidInfo.version.codename;
        map["device_display_name"] = androidInfo.display;
      } else {
        map["device"] = "Unknown";
      }
      await mixpanel.setPeopleProperties(map);
      print("Mixpanel init finished");
    } catch (e) {
      print('Failed to send event: $eventName');
    }
  }

  Future trackEvent(String eventName, Map<String, dynamic> map) async {
    try {
      await initialized;
      await mixpanel.track(eventName, map);
      flushIndex++;
      if (flushIndex % 10 == 0) {
        sendMany();
      }
    } on PlatformException {
      print('Failed to send event: $eventName');
    }
  }

  Future trackPeopleProperties(Map<String, dynamic> map) async {
    try {
      await initialized;
      await mixpanel.setPeopleProperties(map);
    } on PlatformException {
      print('Failed to send peope Properties: $map');
    }
  }

  Future trackSuperPropertyProperties(Map<String, dynamic> map) async {
    try {
      await initialized;
      await mixpanel.registerSuperProperties(map);
    } on PlatformException {
      print('Failed to send peope Properties: $map');
    }
  }

  Future trackIncrement(String eventName) async {
    try {
      print("let's track increment");
      await initialized;
      await mixpanel.increment(eventName);
    } on PlatformException {
      print('Failed to send peope Properties: $eventName');
    }
  }

  Future sendMany() async {
    await mixpanel.flush();
  }
}
