import 'package:flutter/material.dart';
import 'package:powerps/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  bool _showUnConfirmedTransaction = false;
  bool get showUnConfirmedTransaction => _showUnConfirmedTransaction;

  bool _showConfirmedTransaction = false;
  bool get showConfirmedTransaction => _showConfirmedTransaction;
  bool _changed = false;
  bool get changed => _changed;

  List<Transaction> _unConfirmedTransactions = [];
  List<Transaction> get unConfirmedTransactions => _unConfirmedTransactions;

  List<Transaction> _confirmedTransactions = [];
  List<Transaction> get confirmedTransactions => _confirmedTransactions;

  bool setChanged(bool change) {
    _changed = change;
    debugPrint("changed $change");
    try {
      notifyListeners(); // Notify listeners of the state change
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    return _changed;
  }

  void setUnconfirmedTransaction(List<Transaction> transaction) {
    _unConfirmedTransactions = transaction;

    _showUnConfirmedTransaction = true;
    try {
      notifyListeners(); // Notify listeners of the state change
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void setShowUnconfirmedTransaction(bool show) {
    _showUnConfirmedTransaction = show;
    try {
      notifyListeners(); // Notify listeners of the state change
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void setShowConfirmedTransaction(bool show) {
    _showConfirmedTransaction = show;
    try {
      notifyListeners(); // Notify listeners of the state change
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void setConfirmedTransaction(List<Transaction> transaction) {
    _confirmedTransactions = transaction;

    _showConfirmedTransaction = true;
    try {
      notifyListeners(); // Notify listeners of the state change
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  // bool getShowUnconfirmedTransaction() {
  //   return _showUnConfirmedTransaction;
  // }

  List<Transaction> getUnconfirmedTransaction() {
    return _unConfirmedTransactions;
  }
}
