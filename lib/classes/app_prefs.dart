import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static late SharedPreferences _prefs;

  Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  String getApiKey() => _prefs.getString('apiKey') ?? '';
  static String get apiKey => _prefs.getString('apiKey') ?? '';
  static set apiKey(String string) => _prefs.setString('apiKey', string);
  Future<void> saveApiKey(String val) async {
    await _prefs.setString('apiKey', val);
  }
}
