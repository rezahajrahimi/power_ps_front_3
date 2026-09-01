import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/loyalty_setting_model.dart';
import 'package:powerps/models/loyalty_transaction_model.dart';

Future<LoyaltySettingModel?> getLoyaltySetting() async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/getLoyaltySetting',
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 && response.data != null) {
      if (response.data is Map && response.data['data'] is Map) {
        return LoyaltySettingModel.fromMap(
            Map<String, dynamic>.from(response.data['data']));
      }
      if (response.data is Map) {
        return LoyaltySettingModel.fromMap(
            Map<String, dynamic>.from(response.data));
      }
    }
    return null;
  } on DioException catch (e) {
    debugPrint('getLoyaltySetting: ${e.message}');
    debugPrint('getLoyaltySetting response: ${e.response?.data}');
    return null;
  }
}

String? _loyaltyApiErrorMessage(dynamic data) {
  if (data is! Map) return null;
  final message = data['message']?.toString();
  if (message != null && message.isNotEmpty) return message;

  final errors = data['errors'];
  if (errors is Map && errors.isNotEmpty) {
    final first = errors.values.first;
    if (first is List && first.isNotEmpty) {
      return first.first.toString();
    }
    return first?.toString();
  }
  return null;
}

Future<String?> updateLoyaltySetting(LoyaltySettingModel model) async {
  try {
    final response = await GenaralApi.dio.post(
      '/api/updateLoyaltySetting',
      data: model.toApiMap(),
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map && response.data['success'] == false) {
        return _loyaltyApiErrorMessage(response.data) ??
            'خطا در ذخیره تنظیمات';
      }
      return null;
    }

    return _loyaltyApiErrorMessage(response.data) ?? 'خطا در ذخیره تنظیمات';
  } on DioException catch (e) {
    debugPrint('updateLoyaltySetting: ${e.message}');
    debugPrint('updateLoyaltySetting response: ${e.response?.data}');
    return _loyaltyApiErrorMessage(e.response?.data) ??
        'خطا در ذخیره تنظیمات';
  }
}

Future<bool> setLoyaltyPointsBalance({
  required int balance,
  required int userID,
}) async {
  try {
    final response = await GenaralApi.dio.put(
      '/api/editLoyaltyPointsByAccountId',
      data: {
        'balance': balance,
        'account_id': userID,
      },
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    return response.statusCode == 200 &&
        response.data is Map &&
        (response.data['success'] == true || response.data['success'] == 1);
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future<List<LoyaltyTransactionModel>?> getAllLoyaltyLogs() async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/getAllLoyaltyLogs',
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
          .map((e) => LoyaltyTransactionModel.fromMap(
              Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<List<Map<String, dynamic>>?> getTopLoyaltyUsers() async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/getTopLoyaltyUsers',
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(
        (response.data as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }
    return [];
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<Map<String, dynamic>?> getLoyaltyLogsByAccountId({
  required int userID,
  int page = 1,
  int perPage = 15,
}) async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/getLoyaltyLogsByAccountId/$userID',
      queryParameters: {
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
      final data = Map<String, dynamic>.from(response.data as Map);
      final logs = (data['data'] as List? ?? [])
          .map((e) => LoyaltyTransactionModel.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList();
      final summaryRaw = data['summary'] as Map? ?? {};

      return {
        'logs': logs,
        'current_page':
            int.tryParse(data['current_page']?.toString() ?? '1') ?? 1,
        'last_page': int.tryParse(data['last_page']?.toString() ?? '1') ?? 1,
        'total': int.tryParse(data['total']?.toString() ?? '0') ?? 0,
        'summary': {
          'earn_count':
              int.tryParse(summaryRaw['earn_count']?.toString() ?? '0') ?? 0,
          'redeem_count':
              int.tryParse(summaryRaw['redeem_count']?.toString() ?? '0') ??
                  0,
          'total_earned':
              int.tryParse(summaryRaw['total_earned']?.toString() ?? '0') ?? 0,
          'current_balance': int.tryParse(
                  summaryRaw['current_balance']?.toString() ?? '0') ??
              0,
        },
      };
    }
    return {
      'logs': <LoyaltyTransactionModel>[],
      'current_page': 1,
      'last_page': 1,
      'total': 0,
      'summary': {
        'earn_count': 0,
        'redeem_count': 0,
        'total_earned': 0,
        'current_balance': 0,
      },
    };
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<Map<String, dynamic>?> validateLoyaltyRedemption({
  required double orderAmountToman,
  bool useLoyaltyPoints = true,
}) async {
  try {
    final response = await GenaralApi.dio.post(
      '/api/webapp/validate-loyalty-redemption',
      data: {
        'order_amount_toman': orderAmountToman,
        'use_loyalty_points': useLoyaltyPoints,
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
      return Map<String, dynamic>.from(response.data);
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<Map<String, dynamic>?> getWebAppLoyaltyInfo() async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/webapp/loyalty-info',
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}
