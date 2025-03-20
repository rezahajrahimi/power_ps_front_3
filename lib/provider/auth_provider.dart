import 'package:flutter/material.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/helper/shared_prefrencess.dart';

class AuthChangeController extends ChangeNotifier {
  User _user = User(accountId: 0, id: 0, name: "unathicated", role: "unknown");
  bool _initialized = false;

  User get user => _user;

  // متد جدید برای بررسی وضعیت احراز هویت در زمان راه‌اندازی
  Future<void> checkAuthStatus() async {
    if (_initialized) return;
    
    User? savedUser = await LoggingPreference().getUserData();
    if (savedUser != null) {
      _user = savedUser;
      notifyListeners();
    }
    _initialized = true;
  }

  void setUser(User user) {
    _user = user;
    // ذخیره اطلاعات کاربر در SharedPreferences
    LoggingPreference().saveUserData(user);
    notifyListeners();
  }

  getUser() {
    return _user;
  }

  void clearUser() {
    _user = User(accountId: 0, id: 0, name: "unathicated", role: "unknown");
    // حذف اطلاعات کاربر از SharedPreferences
    LoggingPreference().removeToken();
    notifyListeners();
  }

  void logout() {
    clearUser();
    notifyListeners();
  }
}
