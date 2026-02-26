import 'package:shared_preferences/shared_preferences.dart';

/// desc：本地储存
class SharedPreferenceUtil {
  static SharedPreferences? prefs;
  static Future<bool> setBool(String key, bool value) async {
    prefs = await SharedPreferences.getInstance();
    return await prefs!.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getBool(key);
  }

  static Future<bool> setString(String key, String value) async {
    prefs = await SharedPreferences.getInstance();
    return await prefs!.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getString(key);
  }

  static Future<bool> setDouble(String key, double value) async {
    prefs = await SharedPreferences.getInstance();
    return await prefs!.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getDouble(key);
  }

  static Future<bool> setInt(String key, int value) async {
    prefs = await SharedPreferences.getInstance();
    return await prefs!.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getInt(key);
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    prefs = await SharedPreferences.getInstance();
    return await prefs!.setStringList(key, value);
  }

  static Future<List<String>?> getStringList(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getStringList(key);
  }

  static Future<bool> containsKey(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.containsKey(key);
  }

  static Future<bool> remove(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.remove(key);
  }

  static Future<bool> clear(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.clear();
  }
}
