import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/models/product_category_model.dart';

class BoughtProductDetailsModel {
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
  BoughtProductDetailsModel(
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

  factory BoughtProductDetailsModel.fromJson(Map<dynamic, dynamic> json) {
    return BoughtProductDetailsModel(
      id: BigInt.from(json['id']),
      productCategoriesId: BigInt.from(json['product_categories_id']),
      remark: json['remark'].toString(),
      accountId: BigInt.from(json['account_id'] ?? 0),
      configs: json['configs'].toString(),
      subscriptionLink: json['subscription_link'].toString(),
      panelLink: json['panel_link'].toString(),
      isActive: int.parse(json['isActive'].toString()) == 1 ? true : false,
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      botUser: json['user'] != null ? BotUser.fromJson(json['user']) : null,
      productCategory: json['product_category_and_panel'] != null
          ? ProductCategory.fromMap(json['product_category_and_panel'])
          : null,
    );
  }
}
