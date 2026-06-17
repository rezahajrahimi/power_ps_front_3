import 'package:dio/dio.dart';
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
    } on DioException {
      return [];
    }
  }
}
