import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static late SharedPreferences _prefs;

  Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  static const _embeddingEnabledKey = 'embeddingEnabled';

  static bool get embeddingEnabled =>
      _prefs.getBool(_embeddingEnabledKey) ?? false;
  static set embeddingEnabled(bool value) =>
      _prefs.setBool(_embeddingEnabledKey, value);

  String getApiKey() => _prefs.getString('apiKey') ?? '';
  static String get apiKey => _prefs.getString('apiKey') ?? '';
  static set apiKey(String string) => _prefs.setString('apiKey', string);
  Future<void> saveApiKey(String val) async {
    await _prefs.setString('apiKey', val);
  }
}
