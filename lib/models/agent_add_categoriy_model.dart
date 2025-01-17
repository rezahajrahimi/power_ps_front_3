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
      'productCategoriesId': productCategoriesId,
      'userId': userId,
      'isActive': isActive,
      'price': price,
      'newPrice': newPrice,
      'priceInDollar': priceInDollar,
      'newPriceInDollar': newPriceInDollar,
      'productCategories': productCategories?.toMap(),
    };
  }

  factory AgentAddCategoriyModel.fromMap(Map<String, dynamic> map) {
    return AgentAddCategoriyModel(
      id: map['id']?.toInt() ?? 0,
      productCategoriesId: map['product_categories_id']?.toInt(),
      userId: map['user_id']?.toInt(),
      isActive: map['is_active'] == 1 ? true : false,
      price: double.parse(map['price'].toString()).toInt(),
      newPrice: double.parse(map['price'].toString()).toInt(),
      priceInDollar: double.parse(map['price_in_dollar'].toString()),
      newPriceInDollar: double.parse(map['price_in_dollar'].toString()),
      productCategories: map['product_categories'] != null
          ? ProductCategory.fromMap(map['product_categories'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AgentAddCategoriyModel.fromJson(String source) =>
      AgentAddCategoriyModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AgentAddCategoriyModel(id: $id, productCategoriesId: $productCategoriesId, userId: $userId, isActive: $isActive, price: $price, newPrice: $newPrice, priceInDollar: $priceInDollar, newPriceInDollar: $newPriceInDollar, productCategories: $productCategories)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AgentAddCategoriyModel &&
        other.id == id &&
        other.productCategoriesId == productCategoriesId &&
        other.userId == userId &&
        other.isActive == isActive &&
        other.price == price &&
        other.newPrice == newPrice &&
        other.priceInDollar == priceInDollar &&
        other.newPriceInDollar == newPriceInDollar &&
        other.productCategories == productCategories;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        productCategoriesId.hashCode ^
        userId.hashCode ^
        isActive.hashCode ^
        price.hashCode ^
        newPrice.hashCode ^
        priceInDollar.hashCode ^
        newPriceInDollar.hashCode ^
        productCategories.hashCode;
  }
}
