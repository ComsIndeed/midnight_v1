import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static late final SharedPreferences _prefs;

  // Private constructor
  AppPrefs._();

  // Static instance getter
  static final AppPrefs instance = AppPrefs._();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _embeddingEnabledKey = 'embeddingEnabled';
  bool get embeddingEnabled =>
      _prefs.getBool(_embeddingEnabledKey) ?? false;
  set embeddingEnabled(bool value) =>
      _prefs.setBool(_embeddingEnabledKey, value);

  static const _useIdentificationQuestionsKey = 'useIdentifcationQuestions';
  bool get useIdentificationQuestions =>
      _prefs.getBool(_useIdentificationQuestionsKey) ?? false;
  set useIdentificationQuestions(bool value) =>
      _prefs.setBool(_useIdentificationQuestionsKey, value);

  String getApiKey() => _prefs.getString('apiKey') ?? '';
  String get apiKey => _prefs.getString('apiKey') ?? '';
  set apiKey(String string) => _prefs.setString('apiKey', string);
  Future<void> saveApiKey(String val) async {
    await _prefs.setString('apiKey', val);
  }
}
