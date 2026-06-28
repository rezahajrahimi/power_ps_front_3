import 'package:flutter/material.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/helper/shared_prefrencess.dart';

class AuthChangeController extends ChangeNotifier {
  User _user = User(accountId: 0, id: 0, name: "unathicated", role: "unknown");
  Future<void>? _authCheckFuture;

  User get user => _user;

  Future<void> checkAuthStatus() async {
    _authCheckFuture ??= _loadAuthStatus();
    return _authCheckFuture!;
  }

  Future<void> _loadAuthStatus() async {
    User? savedUser = await LoggingPreference().getUserData();
    if (savedUser != null) {
      _user = savedUser;
      notifyListeners();
    }
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
