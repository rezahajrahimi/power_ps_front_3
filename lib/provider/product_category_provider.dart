import 'package:flutter/material.dart';

class ProductCategoryProvider extends ChangeNotifier {
  bool _showCategoryProduct = false;
  bool get showCategoryProduct => _showCategoryProduct;
  bool _changed = false;
  bool get changed => _changed;
  void setShowCategoryProduct(bool show) {
    _showCategoryProduct = show;
    notifyListeners();
  }

  void clearShowCategoryProduct() {
    _showCategoryProduct = false;
    notifyListeners();
  }

  void setChanged(bool change) {
    _changed = change;
    notifyListeners();
  }
}
