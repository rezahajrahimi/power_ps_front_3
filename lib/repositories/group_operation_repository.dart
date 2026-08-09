import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:powerps/helper/connector/dio.dart';

class GroupOperationRepository {
  static Future<Map<String, dynamic>?> submitBatchJob({
    required String action,
    required int panelId,
    required int day,
    required String vol,
    required String configsJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        'action': action,
        'panel_id': panelId,
        'days': day,
        'vol': vol,
        'configs': configsJson,
      });
      final response = await GenaralApi.dio.post(
        '/api/batchExistSubscriptionJob',
        data: formData,
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
      return null;
    } on DioException {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getJob(int id) async {
    try {
      final response = await GenaralApi.dio.get(
        '/api/groupOperationJobs/$id',
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
      return null;
    } on DioException {
      return null;
    }
  }

  static Future<List<dynamic>> getRecentJobs({int page = 1}) async {
    try {
      final response = await GenaralApi.dio.get(
        '/api/groupOperationJobs?page=$page',
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          'Content-Type': 'application/json;charset=UTF-8',
          'Charset': 'utf-8',
          'Access-Control-Allow-Origin': '*',
        }),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        if (data['data'] is List) {
          return List<dynamic>.from(data['data'] as List);
        }
      }
      return [];
    }     on DioException {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> previewExpiredConfigsForDeletion({
    int? panelId,
  }) async {
    try {
      final response = await GenaralApi.dio.get(
        '/api/preview-expired-configs-for-deletion',
        queryParameters: {
          if (panelId != null && panelId > 0) 'panel_id': panelId,
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 10),
          headers: {
            'Accept': 'application/json',
            'Connection': 'keep-alive',
          },
        ),
      );

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }

      return {
        'success': false,
        'message':
            'پاسخ نامعتبر از سرور (کد ${response.statusCode ?? 'نامشخص'}).',
      };
    } on DioException catch (e) {
      debugPrint('previewExpiredConfigsForDeletion: $e');
      if (e.response?.data is Map) {
        return Map<String, dynamic>.from(e.response!.data as Map);
      }
      final typeLabel = switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'زمان درخواست به پایان رسید. پنل را انتخاب کنید و دوباره تلاش کنید.',
        DioExceptionType.connectionError =>
          'ارتباط با سرور برقرار نشد.',
        _ => 'خطا در دریافت لیست اکانت‌های منقضی (کد ${e.response?.statusCode ?? '-'}).',
      };
      return {
        'success': false,
        'message': typeLabel,
      };
    }
  }

  static Future<Map<String, dynamic>?> deleteSelectedExpiredConfigs({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await GenaralApi.dio.post(
        '/api/delete-selected-expired-configs',
        data: {'items': items},
        options: Options(
          receiveTimeout: const Duration(minutes: 2),
          headers: {
            'Accept': 'application/json',
            'Connection': 'keep-alive',
            'Content-Type': 'application/json;charset=UTF-8',
          },
        ),
      );
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return {
        'success': false,
        'status': 'error',
        'message': 'پاسخ نامعتبر از سرور هنگام ثبت حذف.',
      };
    } on DioException catch (e) {
      debugPrint('deleteSelectedExpiredConfigs: $e');
      if (e.response?.data is Map) {
        return Map<String, dynamic>.from(e.response!.data as Map);
      }
      return {
        'success': false,
        'status': 'error',
        'message': 'خطا در ثبت درخواست حذف (کد ${e.response?.statusCode ?? '-'}).',
      };
    }
  }
}
