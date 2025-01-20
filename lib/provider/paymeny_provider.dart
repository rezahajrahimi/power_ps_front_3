// create payment type provider
import 'package:flutter/material.dart';

class PaymentProvider extends ChangeNotifier {
  bool _changed = false;
  bool get changed => _changed;

  void setChanged(bool change) {
    _changed = change;
    notifyListeners();
  }
}
