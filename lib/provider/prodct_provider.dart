import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  bool _showProduct = false;
  bool get showProduct => _showProduct;
  bool _changed = false;
  bool get changed => _changed;

  void setShowProduct(bool show) {
    _showProduct = show;
    notifyListeners();
  }

  void clearShowProduct() {
    _showProduct = false;
    notifyListeners();
  }

  void setChanged(bool change) {
    _changed = change;
    notifyListeners();
  }
}
