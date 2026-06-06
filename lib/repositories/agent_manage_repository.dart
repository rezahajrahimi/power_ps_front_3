import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/agent_detail_model.dart';
import 'package:powerps/models/bought_product_details_model.dart';

Future<AgentDetailModel?> getAgentDetailById({required int id}) async {
  try {
    final response = await GenaralApi.dio.get(
      "/api/getAgentByIdWithProductsAndPremissons/$id",
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json;charset=UTF-8",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        final item = data.first;
        if (item is Map<String, dynamic>) {
          return AgentDetailModel.fromJson(item);
        }
      }
      if (data is Map<String, dynamic>) {
        return AgentDetailModel.fromJson(data);
      }
    }
    return null;
  } on DioException catch (e) {
    debugPrint('getAgentDetailById dio: ${e.message}');
    return null;
  } catch (e) {
    debugPrint('getAgentDetailById parse: $e');
    return null;
  }
}

Future<AgentSalesPage?> getAgentSelledProductsByAdmin({
  required int userId,
  int page = 1,
}) async {
  try {
    final response = await GenaralApi.dio.get(
      "/api/getAgentSelledProductsByAdmin/$userId?page=$page",
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json;charset=UTF-8",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as List? ?? [];
      final products = <BoughtProductDetailsModel>[];
      for (final item in data) {
        try {
          products.add(BoughtProductDetailsModel.fromJson(item));
        } catch (e) {
          debugPrint('Skip invalid sale item: $e');
        }
      }
      return AgentSalesPage(
        products: products,
        lastPage: response.data['last_page'] ?? 1,
      );
    }
    return null;
  } on DioException catch (e) {
    debugPrint('getAgentSelledProductsByAdmin dio: ${e.message}');
    return null;
  } catch (e) {
    debugPrint('getAgentSelledProductsByAdmin parse: $e');
    return null;
  }
}
