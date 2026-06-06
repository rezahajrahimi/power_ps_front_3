import 'package:flutter/material.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';
import 'package:powerps/models/bought_product_details_model.dart';
import 'package:powerps/models/user_model.dart';

class AgentDetailModel {
  final User user;
  final AgentPermisson? permission;
  final List<AgentAddCategoriyModel> products;

  AgentDetailModel({
    required this.user,
    required this.permission,
    required this.products,
  });

  factory AgentDetailModel.fromJson(Map<String, dynamic> json) {
    final products = <AgentAddCategoriyModel>[];
    final rawProducts = json['agent_products'];
    if (rawProducts is List) {
      for (final item in rawProducts) {
        try {
          if (item is Map<String, dynamic>) {
            products.add(AgentAddCategoriyModel.fromMap(item));
          }
        } catch (e) {
          debugPrint('Skip invalid agent product: $e');
        }
      }
    }

    AgentPermisson? permission;
    final rawPermission = json['agent_permisson'];
    if (rawPermission is Map<String, dynamic>) {
      try {
        permission = AgentPermisson.fromMap(rawPermission);
      } catch (e) {
        debugPrint('Skip invalid agent permission: $e');
      }
    }

    return AgentDetailModel(
      user: User.fromJson(json),
      permission: permission,
      products: products,
    );
  }
}

class AgentSalesPage {
  final List<BoughtProductDetailsModel> products;
  final int lastPage;

  AgentSalesPage({required this.products, required this.lastPage});
}
