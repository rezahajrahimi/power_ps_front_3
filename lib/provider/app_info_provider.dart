import 'package:flutter/material.dart';
import 'package:powerps/helper/shared_prefrencess.dart';
import 'package:powerps/models/app_info_model.dart';

class AppInfoProvider extends ChangeNotifier {
  AppInfoModel? _appInfo;
  bool _isLoading = true;

  AppInfoModel? get appInfo => _appInfo;
  bool get isLoading => _isLoading;

  AppInfoProvider() {
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    _isLoading = true;
    notifyListeners();
    final appInfoPref = AppInfoPreference();
    AppInfoModel? info = await appInfoPref.getAppInfo();
    if (info == null) {
      // اگر SharedPreferences خالی بود، از دیتابیس یا مقادیر پیش‌فرض بخوان
      // اینجا فرض می‌کنیم دیتابیس نداریم و از مقادیر ثابت استفاده می‌کنیم
      info = AppInfoModel(
        name: 'Power Proxy Seller',
        version: '6.7.0',
        image: '',
      );
      await appInfoPref.saveAppInfo(info);
    }
    _appInfo = info;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadAppInfo();
  }
}
