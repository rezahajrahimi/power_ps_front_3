import 'package:flutter/material.dart';

class UserAdminProvider extends ChangeNotifier {
  bool _changed = false;
  bool get changed => _changed;

  void setChanged(bool change) {
    _changed = change;
    notifyListeners();
  }
}
