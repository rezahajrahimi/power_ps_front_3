import 'package:dio/dio.dart';
import 'package:powerps/helper/connector/dio.dart';

class MarketingCampaignRepository {
  static Future<List<dynamic>> getAll() async {
    final response = await GenaralApi.dio.get('/api/marketing-campaigns');
    if (response.statusCode == 200 && response.data is List) {
      return response.data;
    }
    return [];
  }

  static Future<int?> previewCount({
    required String segmentType,
    Map<String, dynamic>? segmentParams,
  }) async {
    final response = await GenaralApi.dio.post(
      '/api/marketing-campaigns/preview',
      data: {
        'segment_type': segmentType,
        'segment_params': segmentParams ?? {},
      },
    );
    if (response.statusCode == 200) {
      return response.data['count'] as int?;
    }
    return null;
  }

  static Future<bool> create(FormData formData) async {
    final response = await GenaralApi.dio.post(
      '/api/marketing-campaigns',
      data: formData,
    );
    return response.statusCode == 201;
  }
}
