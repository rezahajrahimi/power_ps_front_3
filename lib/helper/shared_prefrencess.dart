import 'package:shared_preferences/shared_preferences.dart';

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
  setToken({required String token}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? "void";
  }
}
