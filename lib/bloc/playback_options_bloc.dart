import 'dart:async';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'mixpanel_provider.dart';

class PlaybackOptionsBloc {
  BehaviorSubject<String> _selectedLanguageController = new BehaviorSubject();
  Stream<String> get selectedLanguage => _selectedLanguageController.stream;

  BehaviorSubject<String> _selectedVoiceController = new BehaviorSubject();
  Stream<String> get selectedVoice => _selectedVoiceController.stream;

  Future<Map<String, String>> availableLanguages;
  StreamController<Map<String, String>> _voicesController =
      new StreamController();
  Stream<Map<String, String>> get voices => _voicesController.stream;
  Map<String, Map<String, String>> _allVoices = new Map();

  Map<String, String> _realLanguages = new Map();
  int _voiceCounter = 0;

  PlaybackOptionsBloc() {
    _initData();
  }

  Future<Map<String, String>> _getAvailableLanguages() async {
    FlutterTts _tts = new FlutterTts();
    var languages = await _tts.getLanguages;
    Map<String, String> result = new Map();
    for (String lang in languages) {
      _realLanguages[lang.toLowerCase()] = lang;
      if (_LANGUAGES.containsKey(lang.toLowerCase())) {
        result[lang.toLowerCase()] = _LANGUAGES[lang.toLowerCase()];
      } else {
        result[lang.toLowerCase()] = lang;
      }
    }
    return result;
  }

  Future<Map<String, Map<String, String>>> _getAvailableVoices() async {
    _voiceCounter = 0;
    FlutterTts tts = new FlutterTts();
    var voices = await tts.getVoices;
    Map<String, Map<String, String>> result = new Map();
    for (String voice in voices) {
      List<String> voiceSignature = voice.split("-");
      if (voiceSignature.length < 2) continue;
      String langKey = voiceSignature[0].toLowerCase() +
          "-" +
          voiceSignature[1].toLowerCase();
      if (!result.containsKey(langKey)) {
        result[langKey] = new Map();
      }
      String readableVoice = _formVoiceString(voice);
      if (Platform.isAndroid) {
        result[langKey][voice] = readableVoice;
      } else {
        result[langKey][readableVoice] = readableVoice;
      }
    }
    return result;
  }

  Future selectLanguage(String selectedLanguage, {String voice}) async {
    MixPanelProvider().trackEvent("PROFILE", {
      "Click Language Dropdown": DateTime.now().toIso8601String(),
      "selected_language": selectedLanguage
    });
    if (voice == null)
      await PreferencesProvider()
          .selectLanguage(_realLanguages[selectedLanguage]);
    _selectedLanguageController.add(selectedLanguage);
    _voicesController.add(_allVoices[selectedLanguage]);
    selectVoice(voice ?? _allVoices[selectedLanguage].entries.first.key);
  }

  void selectVoice(String selectedVoice) {
    MixPanelProvider().trackEvent("PROFILE", {
      "Click Playback Voice Dropdown": DateTime.now().toIso8601String(),
      "selected_voice": selectedVoice
    });
    PreferencesProvider().selectVoice(selectedVoice);
    _selectedVoiceController.add(selectedVoice);
  }

  void _initData() async {
    availableLanguages = _getAvailableLanguages();
    await availableLanguages;
    _allVoices = await _getAvailableVoices();

    selectLanguage(
        (await PreferencesProvider().getSavedLanguage()).toLowerCase(),
        voice: await PreferencesProvider().getSavedVoice());
  }

  static const _LANGUAGES = {
    "ar-xa": "Arabic",
    "cs-cz": "Czech (Czech Republic)",
    "da-dk": "Danish (Denmark)",
    "nl-nl": "Dutch (Netherlands)",
    "en-au": "English (Australia)",
    "en-in": "English (India)",
    "en-gb": "English (UK)",
    "en-us": "English (US)",
    "fil-ph": "Filipino (Philippines)",
    "fi-fi": "Finnish (Finland)",
    "fr-ca": "French (Canada)",
    "fr-fr": "French (France)",
    "de-de": "German (Germany)",
    "el-gr": "Greek (Greece)",
    "hi-in": "Hindi (India)",
    "hu-hu": "Hungarian (Hungary)",
    "id-id": "Indonesian (Indonesia)",
    "it-it": "Italian (Italy)",
    "ja-jp": "Japanese (Japan)",
    "ko-kr": "Korean (South Korea)",
    "cmn-cn": "Mandarin Chinese",
    "nb-no": "Norwegian (Norway)",
    "pl-pl": "Polish (Poland)",
    "pt-br": "Portuguese (Brazil)",
    "pt-pt": "Portuguese (Portugal)",
    "ru-ru": "Russian (Russia)",
    "sk-sk": "Slovak (Slovakia)",
    "es-es": "Spanish (Spain)",
    "sv-se": "Swedish (Sweden)",
    "tr-tr": "Turkish (Turkey)",
    "uk-ua": "Ukrainian (Ukraine)",
    "vi-vn": "Vietnamese (Vietnam)"
  };

  String _formVoiceString(String voice) {
    if (Platform.isAndroid) {
      String networkPart;
      if (voice.contains("network")) {
        networkPart = "(Network)";
      } else {
        networkPart = "(local)";
      }
      String gender = "Voice";
      if (voice.contains("male"))
        gender = "Male";
      else if (voice.contains("female")) {
        gender = "Female";
      }
      _voiceCounter++;
      return "$gender $_voiceCounter $networkPart";
    } else {
      List<String> voiceParts = voice.split("-");
      return voiceParts.last;
    }
  }
}
