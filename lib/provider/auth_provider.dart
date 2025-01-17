import 'package:flutter/material.dart';
import 'package:powerps/models/user_model.dart';

class AuthChangeController extends ChangeNotifier {
  User _user = User(accountId: 0, id: 0, name: "unathicated", role: "unknown");

  User get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners(); // Notify listeners of the state change
  }

  getUser() {
    return _user;
  }

  void clearUser() {
    _user = User(accountId: 0, id: 0, name: "unathicated", role: "unknown");
    notifyListeners(); // Notify listeners of the state change
  }

  void logout() {
    clearUser();
    notifyListeners(); // Notify listeners of the state change
  }
}
