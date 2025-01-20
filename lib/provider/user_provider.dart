import 'package:flutter/material.dart';
import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/models/user_dashboard_model.dart';

class UserProvider extends ChangeNotifier {
  bool _changed = false;
  bool get changed => _changed;
  UserDashboard _userDashboard =
      UserDashboard(ballance: null, prdoducts: null, logs: null);
  UserDashboard get userDashboard => _userDashboard;
  String _userSerchText = "";

  get userSerchText => _userSerchText;
  set userSerchText(value) {
    _userSerchText = value;
    notifyListeners();
  }

  void setUserSerchText(String userSerchText) {
    _userSerchText = userSerchText;
    notifyListeners();
  }

  List<BotUser> _resultBotUserList = [];
  List<BotUser> get resultBotUserList => _resultBotUserList;
  set resultBotUserList(value) {
    _resultBotUserList = value;
    notifyListeners();
  }

  void setBotUserList(List<BotUser> botUserList) {
    _resultBotUserList = botUserList;
    // notifyListeners();
  }

  void clearBotUserList() {
    _resultBotUserList = [];
    notifyListeners();
  }

  void clearUserSerchText() {
    _userSerchText = "";
    notifyListeners();
  }

  void clearChanged() {
    _changed = false;
    notifyListeners();
  }

  void setChanged(bool change) {
    _changed = change;
    notifyListeners();
  }

  setUserDashboard(UserDashboard userDashboard) {
    _userDashboard = userDashboard;
    _changed = true;
    notifyListeners();
  }

  getUserDashboard() {
    return _userDashboard;
  }

  clearUserDashboard() {
    _userDashboard = UserDashboard(ballance: null, prdoducts: null, logs: null);
    _changed = true;
    notifyListeners();
  }

  setBougthProductToUser(UserDashboard userDashboard) {
    _userDashboard = userDashboard;
    _changed = true;
    notifyListeners();
  }
}
