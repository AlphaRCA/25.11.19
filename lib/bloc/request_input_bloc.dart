import 'dart:async';
import 'dart:math';

import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/storage/editable_ui_request.dart';
import 'package:hold/storage/storage_provider.dart';
import 'package:rxdart/rxdart.dart';

class RequestInputBloc {
  BehaviorSubject<EditableUIRequest> _questionController =
      new BehaviorSubject();
  Stream<EditableUIRequest> get question => _questionController.stream;
  Timer _questionLoader;

  final String _questionKey;
  List<EditableUIRequest> _requests;
  final Random _rnd = new Random();
  int previousIndex = 0;

  RequestInputBloc(this._questionKey) {
    _initQuestionRotation();
  }

  void _initQuestionRotation() async {
    _requests = await StorageProvider().getUIRequests(_questionKey);
    _questionController.add(_requests[_rnd.nextInt(_requests.length - 1)]);
    if (_requests.length > 1) {
      int rotationTime =
          await PreferencesProvider().getQuestionRotationInterval();
      _questionLoader = Timer.periodic(
          Duration(milliseconds: rotationTime), (Timer t) => _reloadQuestion());
    }
  }

  void dispose() {
    _questionLoader?.cancel();
    _questionLoader = null;
  }

  void stopQuestionRotation() {
    _questionLoader?.cancel();
  }

  void _reloadQuestion() {
    int index = _rnd.nextInt(_requests.length);
    while (index == previousIndex) {
      index = _rnd.nextInt(_requests.length);
    }
    _questionController.add(_requests[index]);
    previousIndex = index;
  }
}
