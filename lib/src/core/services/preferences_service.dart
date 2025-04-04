import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._();
  static final instance = PreferencesService._();

  Future<String> getString(String key) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.getString(key) ?? "";
  }

  Future<void> setString(String key, String value) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    instance.setString(key, value);
  }

  Future<String> getPassword() async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.getString("password") ?? "1234";
  }

  Future<void> setPassword(String value) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    instance.setString("password", value);
  }

  Future<bool> getBool(String key) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.getBool(key) ?? false;
  }

  Future<void> setBool(String key, bool value) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    instance.setBool(key, value);
  }
}
