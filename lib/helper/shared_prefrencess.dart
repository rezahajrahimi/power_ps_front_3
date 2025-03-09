// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:powerps/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

clearSharedPrfrence() async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.clear();
    return true;
  } catch (e) {
    return false;
  }
}

class DarkThemePreference {
  static const themeSTATUS = "THEMESTATUS";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(themeSTATUS, value);
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(themeSTATUS) ?? false;
  }
}

class LoggingPreference {
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_DATA_KEY = 'user_data';
  
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    debugPrint("Token saved: $token");
  }
  
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TOKEN_KEY) ?? 'void';
    debugPrint("Token retrieved: $token");
    return token;
  }
  
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(USER_DATA_KEY);
    debugPrint("Token and user data removed");
  }
  
  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_DATA_KEY, jsonEncode(user.toJson()));
    debugPrint("User data saved: ${user.name}");
  }
  
  Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(USER_DATA_KEY);
    if (userData != null && userData.isNotEmpty) {
      debugPrint("User data retrieved");
      return User.fromJson(jsonDecode(userData));
    }
    debugPrint("No user data found");
    return null;
  }
}
