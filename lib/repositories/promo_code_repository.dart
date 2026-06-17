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

  static Future<List<dynamic>> getUsages(int id) async {
    final response = await GenaralApi.dio.get('/api/promo-codes/$id/usages');
    if (response.statusCode == 200 && response.data is List) {
      return response.data;
    }
    return [];
  }
}
