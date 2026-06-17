import 'dart:convert';

import 'package:powerps/helper/constes.dart';
import 'package:powerps/models/app_info_model.dart';
import 'package:powerps/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoggingPreference {
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? "void";
  }

  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user", jsonEncode(user.toJson()));
  }

  Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString("user");
    if (userData != null) {
      return User.fromJson(jsonDecode(userData) as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("user");
  }
}

class AppInfoPreference {
  static const _key = 'APP_INFO_JSON';

  Future<void> saveAppInfo(AppInfoModel appInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(appInfo.toMap()));
    await prefs.setString("APP_Name", appInfo.name);
    await prefs.setString("APP_Version", appInfo.version);
    await prefs.setString("APP_Image", appInfo.image);
  }

  Future<AppInfoModel?> getAppInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        return AppInfoModel.fromMap(
            jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }

    final appName = prefs.getString("APP_Name");
    final appVersion = prefs.getString("APP_Version");
    final appImage = prefs.getString("APP_Image");
    if (appName != null && appVersion != null && appImage != null) {
      return AppInfoModel(
        name: appName,
        version: appVersion,
        image: appImage,
      );
    }
    return null;
  }

  Future<void> removeAppInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove("APP_Name");
    await prefs.remove("APP_Version");
    await prefs.remove("APP_Image");
  }

  Future<String> getAppName() async {
    final info = await getAppInfo();
    return info?.name ?? "";
  }

  Future<String> getAppVersion() async {
    final info = await getAppInfo();
    return resolveAppVersion(info?.version);
  }
}

Future<void> clearSharedPrfrence() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
