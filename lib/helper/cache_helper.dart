import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  //keys
  static const String userLoggedInKey = 'LOGGEDINKEY';
  static const String userNameKey = 'USERNAMEKEY';
  static const String userEmailKey = 'USEREMAILKEY';
  //save data
  static Future<bool> saveUserLoggedIn(bool key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(userLoggedInKey, true);
  }

  static Future<bool> saveUserName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userNameKey, name);
  }

  static Future<bool> saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userEmailKey, email);
  }

  //get data
  static Future<bool?> getUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(userLoggedInKey);
  }

  static Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  //clear
  static Future<bool> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
