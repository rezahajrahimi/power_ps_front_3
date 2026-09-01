import 'package:flutter/material.dart';
import 'package:powerps/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  bool _showUnConfirmedTransaction = false;
  bool get showUnConfirmedTransaction => _showUnConfirmedTransaction;

  bool _showConfirmedTransaction = false;
  bool get showConfirmedTransaction => _showConfirmedTransaction;
  bool _changed = false;
  bool get changed => _changed;

  void setChanged(bool change) {
    _changed = change;
    notifyListeners();
  }

  List<Transaction> _unConfirmedTransactions = [];
  List<Transaction> get unConfirmedTransactions => _unConfirmedTransactions;

  List<Transaction> _confirmedTransactions = [];
  List<Transaction> get confirmedTransactions => _confirmedTransactions;

  int _unConfirmedCurrentPage = 1;
  int _unConfirmedLastPage = 1;
  bool _unConfirmedLoadingMore = false;

  int _confirmedCurrentPage = 1;
  int _confirmedLastPage = 1;
  bool _confirmedLoadingMore = false;

  int get unConfirmedCurrentPage => _unConfirmedCurrentPage;
  int get unConfirmedLastPage => _unConfirmedLastPage;
  bool get unConfirmedLoadingMore => _unConfirmedLoadingMore;

  int get confirmedCurrentPage => _confirmedCurrentPage;
  int get confirmedLastPage => _confirmedLastPage;
  bool get confirmedLoadingMore => _confirmedLoadingMore;

  void setUnconfirmedTransaction(List<Transaction> transactions,
      {int currentPage = 1, int lastPage = 1}) {
    if (currentPage == 1) {
      _unConfirmedTransactions = transactions;
    } else {
      _unConfirmedTransactions.addAll(transactions);
    }
    _unConfirmedCurrentPage = currentPage;
    _unConfirmedLastPage = lastPage;
    _showUnConfirmedTransaction = true;
    _unConfirmedLoadingMore = false;
    notifyListeners();
  }

  void setConfirmedTransaction(List<Transaction> transactions,
      {int currentPage = 1, int lastPage = 1}) {
    if (currentPage == 1) {
      _confirmedTransactions = transactions;
    } else {
      _confirmedTransactions.addAll(transactions);
    }
    _confirmedCurrentPage = currentPage;
    _confirmedLastPage = lastPage;
    _showConfirmedTransaction = true;
    _confirmedLoadingMore = false;
    notifyListeners();
  }

  void setUnConfirmedLoadingMore(bool loading) {
    _unConfirmedLoadingMore = loading;
    notifyListeners();
  }

  void setConfirmedLoadingMore(bool loading) {
    _confirmedLoadingMore = loading;
    notifyListeners();
  }

  void resetUnconfirmed() {
    _unConfirmedTransactions = [];
    _unConfirmedCurrentPage = 1;
    _unConfirmedLastPage = 1;
    _showUnConfirmedTransaction = false;
    notifyListeners();
  }

  void resetConfirmed() {
    _confirmedTransactions = [];
    _confirmedCurrentPage = 1;
    _confirmedLastPage = 1;
    _showConfirmedTransaction = false;
    notifyListeners();
  }

  // bool getShowUnconfirmedTransaction() {
  //   return _showUnConfirmedTransaction;
  // }

  List<Transaction> getUnconfirmedTransaction() {
    return _unConfirmedTransactions;
  }
}
