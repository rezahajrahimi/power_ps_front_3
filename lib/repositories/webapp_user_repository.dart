import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/application_model.dart';
import 'package:powerps/models/faq_model.dart';
import 'package:powerps/models/support_model.dart';

Future<List<Faq>> getWebAppFaqs() async {
  try {
    final response = await GenaralApi.dio.get('/api/webapp/faqs');
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) => Faq.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
  } on DioException catch (e) {
    debugPrint('getWebAppFaqs: ${e.message}');
  }
  return [];
}

Future<List<Support>> getWebAppSupports() async {
  try {
    final response = await GenaralApi.dio.get('/api/webapp/supports');
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) => Support.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
  } on DioException catch (e) {
    debugPrint('getWebAppSupports: ${e.message}');
  }
  return [];
}

Future<List<String>> getWebAppApplicationOses() async {
  try {
    final response = await GenaralApi.dio.get('/api/webapp/application-oses');
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) {
            if (item is Map) {
              return item['os']?.toString() ?? '';
            }
            return item.toString();
          })
          .where((os) => os.isNotEmpty)
          .toList();
    }
  } on DioException catch (e) {
    debugPrint('getWebAppApplicationOses: ${e.message}');
  }
  return [];
}

Future<List<Application>> getWebAppApplicationsByOs(String os) async {
  try {
    final response =
        await GenaralApi.dio.get('/api/webapp/applications/$os');
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) => Application.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
  } on DioException catch (e) {
    debugPrint('getWebAppApplicationsByOs: ${e.message}');
  }
  return [];
}

Future<Map<String, dynamic>?> getWebAppReferralInfo() async {
  try {
    final response = await GenaralApi.dio.get('/api/webapp/referral-info');
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
  } on DioException catch (e) {
    debugPrint('getWebAppReferralInfo: ${e.message}');
  }
  return null;
}

Future<Map<String, dynamic>> redeemWebAppGiftCard(String code) async {
  try {
    final response = await GenaralApi.dio.post(
      '/api/webapp/redeem-gift-card',
      data: {'code': code},
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'success': false, 'message': 'پاسخ نامعتبر از سرور'};
  } on DioException catch (e) {
    final data = e.response?.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {'success': false, 'message': 'خطا در برقراری ارتباط با سرور'};
  }
}

Future<Map<String, dynamic>> claimWebAppTestAccount() async {
  try {
    final response = await GenaralApi.dio.post('/api/webapp/claim-test-account');
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'success': false, 'message': 'پاسخ نامعتبر از سرور'};
  } on DioException catch (e) {
    final data = e.response?.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {'success': false, 'message': 'خطا در برقراری ارتباط با سرور'};
  }
}
