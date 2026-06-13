import 'dart:convert';

import 'package:powerps/models/product_category_model.dart';

class AgentAddCategoriyModel {
  int id;
  int? productCategoriesId;
  int? userId;
  bool? isActive;
  int price;
  int? newPrice;
  double priceInDollar;
  double? newPriceInDollar;
  ProductCategory? productCategories;

  AgentAddCategoriyModel({
    required this.id,
    this.productCategoriesId,
    this.userId,
    this.isActive,
    required this.price,
    required this.newPrice,
    required this.priceInDollar,
    required this.newPriceInDollar,
    this.productCategories,
  });

  setNewPricesValus({
    required int newPrice,
    required double newPriceInDollar,
  }) {
    this.newPrice = newPrice;
    this.newPriceInDollar = newPriceInDollar;
    return this;
  }

  removeNewPricesValus() {
    newPrice = null;
    newPriceInDollar = null;
    return this;
  }

  AgentAddCategoriyModel copyWith({
    int? id,
    int? productCategoriesId,
    int? userId,
    bool? isActive,
    int? price,
    int? newPrice,
    double? priceInDollar,
    double? newPriceInDollar,
    ProductCategory? productCategories,
  }) {
    return AgentAddCategoriyModel(
      id: id ?? this.id,
      productCategoriesId: productCategoriesId ?? this.productCategoriesId,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      price: price ?? this.price,
      newPrice: newPrice ?? this.newPrice,
      priceInDollar: priceInDollar ?? this.priceInDollar,
      newPriceInDollar: newPriceInDollar ?? this.newPriceInDollar,
      productCategories: productCategories ?? this.productCategories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productCategoriesId': productCategoriesId ?? id,
      'userId': userId,
      'isActive': isActive,
      'price': price,
      'newPrice': newPrice,
      'priceInDollar': priceInDollar,
      'newPriceInDollar': newPriceInDollar,
      'productCategories': productCategories?.toMap(),
    };
  }

  static int _parsePrice(dynamic value) {
    return double.tryParse(value?.toString() ?? '0')?.toInt() ?? 0;
  }

  static double _parsePriceDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  factory AgentAddCategoriyModel.fromMap(Map<String, dynamic> map) {
    final categoryId = map['product_categories_id']?.toInt() ?? map['id']?.toInt() ?? 0;

    return AgentAddCategoriyModel(
      id: map['id']?.toInt() ?? 0,
      productCategoriesId: categoryId,
      userId: map['user_id']?.toInt(),
      isActive: map['is_active'] == 1 ? true : false,
      price: _parsePrice(map['price']),
      newPrice: _parsePrice(map['price']),
      priceInDollar: _parsePriceDouble(map['price_in_dollar']),
      newPriceInDollar: _parsePriceDouble(map['price_in_dollar']),
      productCategories: map['product_categories'] != null
          ? ProductCategory.fromMap(
              Map<String, dynamic>.from(map['product_categories'] as Map),
            )
          : null,
    );
  }

  Object toJson() => toMap();

  factory AgentAddCategoriyModel.fromJson(String source) =>
      AgentAddCategoriyModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AgentAddCategoriyModel(id: $id, productCategoriesId: $productCategoriesId, userId: $userId, isActive: $isActive, price: $price, newPrice: $newPrice, priceInDollar: $priceInDollar, newPriceInDollar: $newPriceInDollar, productCategories: $productCategories)';
  }

  int get categoryId => productCategoriesId ?? id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AgentAddCategoriyModel && other.categoryId == categoryId;
  }

  @override
  int get hashCode => categoryId.hashCode;
}
