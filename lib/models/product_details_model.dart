import 'dart:convert';

import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/models/product_category_model.dart';

class ProductDetails {
  BigInt id;
  BigInt productCategoriesId;
  BigInt? accountId;
  String? remark;
  String configs;
  String subscriptionLink;
  String panelLink;
  bool? isActive;
  String createdAt;
  String updatedAt;
  BotUser? botUser;

  ProductCategory? productCategory;
  ProductDetails(
      {
      // required this.id,
      required this.id,
      required this.productCategoriesId,
      this.remark,
      this.accountId,
      required this.configs,
      required this.subscriptionLink,
      required this.panelLink,
      this.isActive,
      required this.createdAt,
      required this.updatedAt,
      this.botUser,
      this.productCategory});

  factory ProductDetails.fromJson(Map<dynamic, dynamic> json) {
    return ProductDetails(
      id: BigInt.from(json['id']),
      productCategoriesId: BigInt.from(json['product_categories_id']),
      remark: json['remark'].toString(),
      accountId: BigInt.from(json['account_id'] ?? 0),
      configs: json['configs'].toString(),
      subscriptionLink: json['subscription_link'].toString(),
      panelLink: json['panel_link'].toString(),
      isActive: int.parse(json['isActive'].toString()) == 1 ||
              json['isActive'].toString() == "true"
          ? true
          : false,
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      botUser: json['user'] != null ? BotUser.fromJson(json['user']) : null,
      productCategory: json['product_category'] != null
          ? ProductCategory.fromMap(json['product_category'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productCategoriesId': productCategoriesId,
      'accountId': accountId?.toString(),
      'remark': remark,
      'configs': configs,
      'subscriptionLink': subscriptionLink,
      'panelLink': panelLink,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'botUser': botUser?.toMap(),
      'productCategory': productCategory?.toMap(),
    };
  }

  factory ProductDetails.fromMap(Map<String, dynamic> map) {
    return ProductDetails.fromMap(map);
  }

  String toJson() => json.encode(toMap());
}
