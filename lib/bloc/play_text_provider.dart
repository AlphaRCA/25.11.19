import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:rxdart/rxdart.dart';

class PlayTextProvider {
  final BehaviorSubject<bool> _playController = new BehaviorSubject();
  Stream<bool> get playState => _playController.stream;

  final BehaviorSubject<int> _percentageController = new BehaviorSubject();
  Stream<int> get percentage => _percentageController.stream;

  final FlutterTts _flutterTts;

  List<String> _phrases = new List();
  int _phraseIndex;

  Future initialized;

  PlayTextProvider({FlutterTts tts}) : _flutterTts = tts ?? new FlutterTts() {
    initialized = _setupTts();
  }

  Future speak(String text) async {
    _divideTextToPhrases(text);
    _phraseIndex = 0;
    print("phrase: ${_phrases[_phraseIndex]}");
    _percentageController.add(0);
    var result = await _flutterTts.speak(_phrases[_phraseIndex]);
    if (result == 1) _playController.add(true);
  }

  Future pause() async {
    var result = await _flutterTts.stop();
    print("false because of pause");
    if (result == 1) _playController.add(false);
  }

  Future resume() async {
    if (_phraseIndex == null) _phraseIndex = 0;
    if (_phrases.length < _phraseIndex) return;
    if (_phrases.length == _phraseIndex) _phraseIndex = 0;
    var result = await _flutterTts.speak(_phrases[_phraseIndex]);
    print("true");
    if (result == 1) _playController.add(true);
  }

  Future _setupTts() async {
    String selectedLanguage = await PreferencesProvider().getSavedLanguage();
    await _flutterTts.setLanguage(selectedLanguage);
    String selectedVoice = await PreferencesProvider().getSavedVoice();
    if (selectedVoice != null) {
      await _flutterTts.setVoice(selectedVoice);
    }
    _flutterTts.setCompletionHandler(() {
      _checkForNextPhrase();
    });
    _playController.add(false);
  }

  void _checkForNextPhrase() {
    _phraseIndex += 1;
    if (_phraseIndex < _phrases.length) {
      _percentageController.add(_countPercent(_phraseIndex, _phrases.length));
      _flutterTts.speak(_phrases[_phraseIndex]);
    } else {
      print("false in checkForNextPhrase");
      _playController.add(false);
      _percentageController.add(100);
    }
  }

  void _divideTextToPhrases(String text) {
    _phrases.clear();
    String phrase = "";
    for (int i = 0; i < text.length; i++) {
      if (_isPunctuation(text[i])) {
        if (phrase.isNotEmpty) {
          _phrases.add(phrase + text[i]);
        }
        phrase = "";
      } else {
        phrase += text[i];
      }
    }
    _phrases.add(phrase);
  }

  int _countPercent(int phraseIndex, int phrasesCount) {
    int percent = (phraseIndex * 100 / phrasesCount).round();
    print("percent: $percent");
    return percent;
  }

  bool _isPunctuation(String text) {
    return [".", ",", ":", "-", "?", "!"].contains(text);
  }
}
