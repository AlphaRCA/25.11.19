import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/speech_recognition/speech_functionality.dart';
import 'package:rxdart/rxdart.dart';

class SpeechRecognitionBloc {
  final BehaviorSubject<bool> _listeningStateController = new BehaviorSubject();

  Stream<bool> get isListening => _listeningStateController.stream;

  final BehaviorSubject<String> _spokenTextController = new BehaviorSubject();

  Stream<String> get spokenText => _spokenTextController.stream;
  final BehaviorSubject<String> _finalTextController = new BehaviorSubject();

  Stream<String> get finalText => _finalTextController.stream;

  SpeechRecognition _speech;
  String _preferredLanguage;

  SpeechRecognitionBloc() {
    _activateSpeechRecognizer();
  }

  void _onSpeechAvailability(bool result) {
    if (result) {
      print("speech is available");
      _listeningStateController.add(false);
    } else {
      print("speech is not available");
      _listeningStateController.add(null);
    }
  }

  void _onRecognitionStarted() {
    print("recognition is started");
    _listeningStateController.add(true);
  }

  void _onRecognitionResult(String text) {
    print("recognition result '$text'");
    _spokenTextController.add(text);
  }

  void _onRecognitionComplete(String text) {
    print("recognition complete with '$text'");
    _finalTextController.add(" " + text);
    _listeningStateController.add(false);
  }

  void _errorHandler() async {
    await AudioCache().play("audio_error.wav");
    _listeningStateController.add(null);
    print("error while doing speech recognition");
    _activateSpeechRecognizer();
  }

  void _activateSpeechRecognizer() async {
    _preferredLanguage = await PreferencesProvider().getSavedLanguage();
    print("MYLANGUAGE: $_preferredLanguage");
    _speech = new SpeechRecognition()
      ..setAvailabilityHandler(_onSpeechAvailability)
      ..setRecognitionStartedHandler(_onRecognitionStarted)
      ..setRecognitionResultHandler(_onRecognitionResult)
      ..setRecognitionCompleteHandler(_onRecognitionComplete)
      ..setErrorHandler(_errorHandler)
      ..activate().then((res) {
        _listeningStateController.add(false);
      });
  }

  void start() =>
      _speech
          .listen(_preferredLanguage ?? "en-US")
          .then((result) => print('_MyAppState.start => result $result'));

  void stop() =>
      _speech.stop().then((result) {
        _listeningStateController.add(false);
      });

  void reinit() {
    _activateSpeechRecognizer();
  }
}
