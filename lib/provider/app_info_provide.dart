import 'package:flutter/material.dart';
import 'package:powerps/models/app_info_model.dart';
import 'package:powerps/helper/shared_prefrencess.dart';

class AppInfoProvide extends ChangeNotifier {
  AppInfoModel _appInfo = AppInfoModel(
    name: "PowerPS",
    version: "1.0.0",
    image: "",
  );
  bool _initialized = false;

  AppInfoModel get appInfo => _appInfo;

  // متد جدید برای بررسی وضعیت احراز هویت در زمان راه‌اندازی
  Future<void> checkAuthStatus() async {
    if (_initialized) return;

    AppInfoModel? savedAppInfo = await AppInfoPreference().getAppInfo();
    if (savedAppInfo != null) {
      _appInfo = savedAppInfo;
      notifyListeners();
    }
    _initialized = true;
  }

  void setAppInfo(AppInfoModel appInfo) {
    _appInfo = appInfo;
    // ذخیره اطلاعات اپلیکیشن در SharedPreferences
    AppInfoPreference().saveAppInfo(appInfo);
    notifyListeners();
  }

  AppInfoModel getAppInfo() {
    return _appInfo;
  }

  void clearUser() {
    _appInfo = AppInfoModel(
      name: "unathenticated",
      version: "unknown",
      image: "",
    );
    AppInfoPreference().removeAppInfo();
    notifyListeners();
  }
}
