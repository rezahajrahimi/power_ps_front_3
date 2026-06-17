import 'package:flutter/foundation.dart';
import 'package:powerps/models/product_category_model.dart';

class PurchaseCartItem {
  PurchaseCartItem({
    required this.product,
    required this.remark,
  });

  final ProductCategory product;
  String remark;
}

class PurchaseCartProvider extends ChangeNotifier {
  final List<PurchaseCartItem> _items = [];

  List<PurchaseCartItem> get items => List.unmodifiable(_items);
  int get count => _items.length;

  int totalToman() =>
      _items.fold(0, (sum, item) => sum + item.product.price);

  double totalDollar() =>
      _items.fold(0.0, (sum, item) => sum + item.product.priceInDollar);

  void add(ProductCategory product, {String remark = ''}) {
    _items.add(PurchaseCartItem(product: product, remark: remark));
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void updateRemark(int index, String remark) {
    if (index < 0 || index >= _items.length) return;
    _items[index].remark = remark;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
