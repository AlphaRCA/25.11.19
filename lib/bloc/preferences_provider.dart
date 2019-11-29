import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PreferencesProvider {
  static const KEY_FIRST_RUN = "first_run";
  static const KEY_UID = "uid";
  static const KEY_NOTIFICATIONS = "notifications";
  static const KEY_MY_NOTIFICATIONS = "my_notifications";
  static const VOICE_KEY = "voice";
  static const LANGUAGE_KEY = "language";
  static const KEY_CONVERSATION_LEVEL = "conv_level";
  static const KEY_COLLECTION_LEVEL = "col_level";
  static const KEY_QUESTION_ROTATION_INTERVAL = "question_rotation";
  static const KEY_CONTINUOUS_PLAY = "continuous_play";

  static const KEYCM_MAIN_SCREEN = "KEYCM_MAIN_SCREEN";
  static const KEYCM_PROFILE_SCREEN = "KEYCM_PROFILE_SCREEN";
  static const KEYCM_FIRST_EMOTION = "KEYCM_FIRST_EMOTION";
  static const KEYCM_FIRST_CONVERSATION = "KEYCM_FIRST_CONVERSATION";
  static const KEYCM_TWO_CONVERSATIONS = "KEYCM_TWO_CONVERSATIONS";
  static const KEYCM_FIRST_REFLECT = "KEYCM_FIRST_REFLECT";
  static const KEYCM_FIRST_REVIEW = "KEYCM_FIRST_REVIEW";
  static const KEYCM_FIRST_IN_REVIEW = "KEYCM_FIRST_IN_REVIEW";
  static const KEYCM_FIRST_IN_COLLECTION = "KEYCM_FIRST_IN_COLLECTION";
  static const KEYCM_FIRST_QUESTION = "KEYCM_FIRST_QUESTION";
  static const KEYCM_SECOND_STEP = "KEYCM_SECOND_STEP";
  static const KEYCM_THIRD_STEP = "KEYCM_THIRD_STEP";
  static const KEYCM_END_CONVERSATION = "KEYCM_END_CONVERSATION";

  static PreferencesProvider _instance;
  Future _initialized;
  SharedPreferences _preferences;

  factory PreferencesProvider() {
    if (_instance == null) {
      _instance = PreferencesProvider._();
    }
    return _instance;
  }

  PreferencesProvider._() {
    _initialized = _initPreferences();
  }

  void saveFirstRunFinished() {
    _preferences.setBool(KEY_FIRST_RUN, true);
  }

  Future<bool> getFirstRunFinished() async {
    await _initialized;
    bool result = _preferences.getBool(KEY_FIRST_RUN);
    return result ?? false;
  }

  Future _initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<String> getUid() async {
    await _initialized;
    String result = _preferences.getString(KEY_UID);
    if (result == null) {
      result = Uuid().v4();
      _preferences.setString(KEY_UID, result);
    }
    return result;
  }

  Future<bool> getAllNotificationsEnabled() async {
    await _initialized;
    return _preferences.getBool(KEY_NOTIFICATIONS) ?? true;
  }

  Future saveMixpanelNotificationsEnabled(bool value) {
    return _preferences.setBool(KEY_NOTIFICATIONS, value);
  }

  Future<bool> getMyNotificationsEnabled() async {
    await _initialized;
    return _preferences.getBool(KEY_MY_NOTIFICATIONS) ?? true;
  }

  Future saveMyNotificationsEnabled(bool value) {
    return _preferences.setBool(KEY_MY_NOTIFICATIONS, value);
  }

  Future selectLanguage(String selectedLanguage) {
    return _preferences.setString(LANGUAGE_KEY, selectedLanguage);
  }

  Future selectVoice(String selectedVoice) {
    return _preferences.setString(VOICE_KEY, selectedVoice);
  }

  Future<String> getSavedVoice() async {
    await _initialized;
    return _preferences.getString(VOICE_KEY);
  }

  Future<String> getSavedLanguage() async {
    await _initialized;
    return _preferences.getString(LANGUAGE_KEY) ?? "en-US";
  }

  Future<int> getHighestConversationReflectionLevel() async {
    await _initialized;
    return _preferences.getInt(KEY_CONVERSATION_LEVEL) ?? 1;
  }

  Future<int> getHighestCollectionReflectionLevel() async {
    await _initialized;
    return _preferences.getInt(KEY_COLLECTION_LEVEL) ?? 1;
  }

  Future saveHighestConversationLevel(int level) {
    return _preferences.setInt(KEY_CONVERSATION_LEVEL, level);
  }

  Future saveHighestCollectionLevel(int level) {
    return _preferences.setInt(KEY_COLLECTION_LEVEL, level);
  }

  Future<bool> getMainScreenCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_MAIN_SCREEN) ?? false;
  }

  Future saveMainScreenCoachMark() {
    return _preferences.setBool(KEYCM_MAIN_SCREEN, true);
  }

  Future<bool> getProfileScreenCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_PROFILE_SCREEN) ?? false;
  }

  Future saveProfileScreenCoachMark() {
    return _preferences.setBool(KEYCM_PROFILE_SCREEN, true);
  }

  Future<bool> getFirstEmotionCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_FIRST_EMOTION) ?? false;
  }

  Future saveFirstEmotionCoachMark() {
    return _preferences.setBool(KEYCM_FIRST_EMOTION, true);
  }

  Future<bool> getFirstConversationCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_FIRST_CONVERSATION) ?? false;
  }

  Future saveFirstConversationCoachMark() {
    return _preferences.setBool(KEYCM_FIRST_CONVERSATION, true);
  }

  Future<bool> getTwoConversationsCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_TWO_CONVERSATIONS) ?? false;
  }

  Future saveTwoConversationsCoachMark() {
    return _preferences.setBool(KEYCM_TWO_CONVERSATIONS, true);
  }

  Future<bool> getFirstReflectCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_FIRST_REFLECT) ?? false;
  }

  Future saveFirstReflectCoachMark() {
    return _preferences.setBool(KEYCM_FIRST_REFLECT, true);
  }

  Future<bool> getFirstReviewCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_FIRST_REVIEW) ?? false;
  }

  Future saveFirstReviewCoachMark() {
    return _preferences.setBool(KEYCM_FIRST_REVIEW, true);
  }

  Future<bool> getFirstInCollectionCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_FIRST_IN_COLLECTION) ?? false;
  }

  Future saveFirstInCollectionCoachMark() {
    return _preferences.setBool(KEYCM_FIRST_IN_COLLECTION, true);
  }

  Future<bool> getFirstInReviewCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_FIRST_IN_REVIEW) ?? false;
  }

  Future saveFirstInReviewCoachMark() {
    return _preferences.setBool(KEYCM_FIRST_IN_REVIEW, true);
  }

  Future<bool> getFirstQuestionCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_FIRST_QUESTION) ?? false;
  }

  Future saveFirstQuestionCoachMark() {
    return _preferences.setBool(KEYCM_FIRST_QUESTION, true);
  }

  Future<bool> getSecondStepCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_SECOND_STEP) ?? false;
  }

  Future saveSecondStepCoachMark() {
    return _preferences.setBool(KEYCM_SECOND_STEP, true);
  }

  Future<bool> getThirdStepCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_THIRD_STEP) ?? false;
  }

  Future saveThirdStepCoachMark() {
    return _preferences.setBool(KEYCM_THIRD_STEP, true);
  }

  Future<bool> getEndConversationCoachMark() async {
    await _initialized;
    return _preferences.getBool(KEYCM_END_CONVERSATION) ?? false;
  }

  Future saveEndConversationCoachMark() {
    return _preferences.setBool(KEYCM_END_CONVERSATION, true);
  }

  Future<int> getQuestionRotationInterval() async {
    await _initialized;
    return _preferences.getInt(KEY_QUESTION_ROTATION_INTERVAL) ?? 6000;
  }

  Future saveQuestionRotationInterval(int value) async {
    await _initialized;
    await _preferences.setInt(KEY_QUESTION_ROTATION_INTERVAL, value);
  }

  Future saveContinuousSetting(bool value) {
    return _preferences.setBool(KEY_CONTINUOUS_PLAY, value);
  }

  Future<bool> getContinuousSetting() async {
    await _initialized;
    return _preferences.getBool(KEY_CONTINUOUS_PLAY) ?? true;
  }
}
