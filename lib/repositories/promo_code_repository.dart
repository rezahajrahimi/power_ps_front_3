import 'package:powerps/helper/connector/dio.dart';

class PromoCodeRepository {
  static Future<List<dynamic>> getAll() async {
    final response = await GenaralApi.dio.get('/api/promo-codes');
    if (response.statusCode == 200 && response.data is List) {
      return response.data;
    }
    return [];
  }

  static Future<bool> create(Map<String, dynamic> data) async {
    final response = await GenaralApi.dio.post('/api/promo-codes', data: data);
    return response.statusCode == 201;
  }

  static Future<bool> update(int id, Map<String, dynamic> data) async {
    final response =
        await GenaralApi.dio.put('/api/promo-codes/$id', data: data);
    return response.statusCode == 200;
  }

  static Future<bool> delete(int id) async {
    final response = await GenaralApi.dio.delete('/api/promo-codes/$id');
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> getUsages(
    int id, {
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await GenaralApi.dio.get(
      '/api/promo-codes/$id/usages',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
    if (response.statusCode == 200 && response.data is Map) {
      final data = Map<String, dynamic>.from(response.data as Map);
      return {
        'data': List<dynamic>.from(data['data'] ?? const []),
        'current_page':
            int.tryParse('${data['current_page'] ?? 1}') ?? 1,
        'last_page': int.tryParse('${data['last_page'] ?? 1}') ?? 1,
        'total': int.tryParse('${data['total'] ?? 0}') ?? 0,
      };
    }
    if (response.statusCode == 200 && response.data is List) {
      final list = List<dynamic>.from(response.data as List);
      return {
        'data': list,
        'current_page': 1,
        'last_page': 1,
        'total': list.length,
      };
    }
    return {
      'data': <dynamic>[],
      'current_page': 1,
      'last_page': 1,
      'total': 0,
    };
  }
}
