import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtil {
  late SharedPreferences prefs;
  Future<bool> setBool(String key, bool value) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getBool(key);
  }

  Future<bool> setString(String key, String value) async {
    prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getString(key);
  }

  Future<bool> setDouble(String key, double value) async {
    prefs = await SharedPreferences.getInstance();
    return await prefs.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  Future<bool> setInt(String key, int value) async {
    prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  Future<bool> containsKey(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  Future<bool> remove(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  Future<bool> clear(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
