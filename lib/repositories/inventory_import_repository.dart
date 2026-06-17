import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/models/product_details_model.dart';

class InventoryStockResponse {
  final Map<String, int> summary;
  final List<ProductDetails> items;
  final int currentPage;
  final int lastPage;
  final int total;

  InventoryStockResponse({
    required this.summary,
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

Future<List<Pannel>> getInventoryPanels() async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/getInventoryPanels',
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) => Pannel.fromJson(item))
          .toList();
    }
  } on DioException catch (e) {
    debugPrint(e.message);
  }

  return [];
}

Future<Map<String, dynamic>?> importInventoryExcel({
  required int panelId,
  required String filePath,
}) async {
  try {
    final formData = FormData.fromMap({
      'pannel_id': panelId,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    final response = await GenaralApi.dio.post(
      '/api/importInventoryExcel',
      data: formData,
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
  } on DioException catch (e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return {
        'success': false,
        'message': data['message'].toString(),
      };
    }
    debugPrint(e.message);
  }

  return null;
}

Future<String?> downloadInventoryImportTemplate({
  required String savePath,
}) async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/downloadInventoryImportTemplate',
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': 'text/csv',
          'Connection': 'keep-alive',
          'Access-Control-Allow-Origin': '*',
        },
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final file = File(savePath);
      await file.writeAsBytes(response.data as List<int>);
      return savePath;
    }
  } on DioException catch (e) {
    debugPrint(e.message);
  }

  return null;
}

Future<InventoryStockResponse?> getInventoryStock({
  required int panelId,
  String status = 'all',
  String sort = 'created_at_desc',
  String? search,
  int page = 1,
  int perPage = 20,
}) async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/getInventoryStock',
      queryParameters: {
        'pannel_id': panelId,
        'status': status,
        'sort': sort,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'per_page': perPage,
      },
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 && response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      final summaryRaw = data['summary'] as Map? ?? {};
      final items = (data['data'] as List? ?? [])
          .map((item) => ProductDetails.fromJson(item as Map))
          .toList();

      return InventoryStockResponse(
        summary: {
          'active': int.tryParse(summaryRaw['active']?.toString() ?? '0') ?? 0,
          'sold': int.tryParse(summaryRaw['sold']?.toString() ?? '0') ?? 0,
          'total': int.tryParse(summaryRaw['total']?.toString() ?? '0') ?? 0,
        },
        items: items,
        currentPage:
            int.tryParse(data['current_page']?.toString() ?? '1') ?? 1,
        lastPage: int.tryParse(data['last_page']?.toString() ?? '1') ?? 1,
        total: int.tryParse(data['total']?.toString() ?? '0') ?? 0,
      );
    }
  } on DioException catch (e) {
    debugPrint(e.message);
  }

  return null;
}

Future<Map<String, dynamic>?> updateInventoryStockItem({
  required int productId,
  required int panelId,
  required String configs,
  String? subscriptionLink,
  String? panelLink,
}) async {
  try {
    final response = await GenaralApi.dio.post(
      '/api/updateInventoryStockItem',
      data: {
        'product_id': productId,
        'pannel_id': panelId,
        'configs': configs,
        'subscription_link': subscriptionLink ?? '',
        'panel_link': panelLink ?? '',
      },
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
  } on DioException catch (e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return {
        'success': false,
        'message': data['message'].toString(),
      };
    }
    debugPrint(e.message);
  }

  return null;
}

Future<Map<String, dynamic>?> deleteInventoryStockItem({
  required int productId,
  required int panelId,
}) async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/deleteInventoryStockItem/$productId',
      queryParameters: {'pannel_id': panelId},
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
  } on DioException catch (e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return {
        'success': false,
        'message': data['message'].toString(),
      };
    }
    debugPrint(e.message);
  }

  return null;
}
