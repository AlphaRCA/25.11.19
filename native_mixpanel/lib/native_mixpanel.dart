import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

abstract class _Mixpanel {
  Future track(String eventName, [dynamic props]);
}

class _MixpanelOptedIn extends _Mixpanel {
  final MethodChannel _channel = const MethodChannel('native_mixpanel');

  Future track(String eventName, [dynamic props]) async {
    return await _channel.invokeMethod(eventName, props);
  }
}

class Mixpanel extends _Mixpanel {
  static Mixpanel _instance;
  _Mixpanel _mp;

  factory Mixpanel({bool shouldLogEvents, bool isOptedOut}) {
    if (_instance == null) {
      _instance = new Mixpanel._();
    }
    return _instance;
  }

  Mixpanel._() {
    _mp = _MixpanelOptedIn();
  }

  Future initialize(String token) {
    return this._mp.track('initialize', token);
  }

  Future identify(String distinctId) {
    return this._mp.track('identify', distinctId);
  }

  Future alias(String alias) {
    return this._mp.track('alias', alias);
  }

  Future setPeopleProperties(Map<String, dynamic> props) {
    return this._mp.track('setPeopleProperties', jsonEncode(props));
  }

  Future registerSuperProperties(Map<String, dynamic> props) {
    return this._mp.track('registerSuperProperties', jsonEncode(props));
  }

  Future reset() {
    return this._mp.track('reset');
  }

  Future flush() {
    return this._mp.track('flush');
  }

  Future track(String eventName, [dynamic props]) {
    return this._mp.track(eventName, jsonEncode(props));
  }
}
