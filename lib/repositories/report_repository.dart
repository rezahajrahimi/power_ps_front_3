import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';

class ReportRepository {
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      Response response = await GenaralApi.dio.get("/api/getDashboardStats");
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      debugPrint("Error in getDashboardStats: $e");
      return {};
    }
  }

  static Future<Map<String, dynamic>> getFinancialReport(
      {String? startDate,
      String? endDate,
      int count = 50,
      int page = 1}) async {
    try {
      Map<String, dynamic> queryParams = {'count': count, 'page': page};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      Response response = await GenaralApi.dio
          .get("/api/getFinancialReport", queryParameters: queryParams);
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      debugPrint("Error in getFinancialReport: $e");
      return {};
    }
  }

  static Future<Map<String, dynamic>> getUserReport(
      {String? startDate,
      String? endDate,
      String? search,
      int count = 50,
      int page = 1}) async {
    try {
      Map<String, dynamic> queryParams = {'count': count, 'page': page};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (search != null) queryParams['search'] = search;

      Response response = await GenaralApi.dio
          .get("/api/getUserReport", queryParameters: queryParams);
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      debugPrint("Error in getUserReport: $e");
      return {};
    }
  }

  static Future<Map<String, dynamic>> getProductReport(
      {String? startDate,
      String? endDate,
      int? categoryId,
      int count = 50,
      int page = 1}) async {
    try {
      Map<String, dynamic> queryParams = {'count': count, 'page': page};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (categoryId != null) queryParams['category_id'] = categoryId;

      Response response = await GenaralApi.dio
          .get("/api/getProductReport", queryParameters: queryParams);
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      debugPrint("Error in getProductReport: $e");
      return {};
    }
  }

  static Future<List<dynamic>> getRecentSales({int count = 20}) async {
    try {
      Response response =
          await GenaralApi.dio.get("/api/getLastProductSelled/$count");
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      debugPrint("Error in getRecentSales: $e");
      return [];
    }
  }

  static Future<List<dynamic>> getBotUsers({int days = 30}) async {
    try {
      Response response =
          await GenaralApi.dio.get("/api/get_users_by_past_days/$days");
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      debugPrint("Error in getBotUsers: $e");
      return [];
    }
  }
}
