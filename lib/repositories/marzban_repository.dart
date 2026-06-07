import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/connector/marzban_connector.dart';
import 'package:powerps/models/marzban_config_model.dart';

Future<String?> checkIsMarzbanUrl({
  required String url,
  required String username,
  required String password,
}) async {
  try {
    marzbanURL = url;
    var formData = FormData.fromMap({
      'username': username,
      'password': password,
    });
    Response response = await MarzbanApi.dio.post(
      "/api/admin/token",
      data: formData,
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*'
      }),
    );
    if (response.statusCode == 200 && response.data != null) {
      final tokenType = response.data["token_type"];
      final accessToken = response.data["access_token"];
      if (tokenType != null && accessToken != null) {
        return "$tokenType $accessToken";
      }
    }
    return null;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

Future<Map<String, List<String>>?> fetchMarzbanPanelInbounds({
  required String url,
  required String token,
}) async {
  try {
    marzbanURL = url;
    final response = await MarzbanApi.dio.get(
      '/api/inbounds',
      options: Options(headers: {
        'Accept': 'application/json',
        'Authorization': token,
      }),
    );
    if (response.statusCode != 200 || response.data == null) {
      return null;
    }

    final data = response.data;
    if (data is! Map) {
      return null;
    }

    final result = <String, List<String>>{};
    data.forEach((key, value) {
      if (value is List) {
        result[key.toString()] =
            value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      }
    });
    return result.isEmpty ? null : result;
  } catch (e) {
    debugPrint('fetchMarzbanPanelInbounds: $e');
    return null;
  }
}

Future<MarzbanConfig?> getMarzbanUserInfo({
  required String url,
  required String username,
  required String admin,
  required String password,
}) async {
  try {
    marzbanURL = url;
    final token = await checkIsMarzbanUrl(
      url: url,
      password: password,
      username: admin,
    );
    if (token == null) {
      return null;
    }

    Response response = await MarzbanApi.dio.get(
      "/api/user/$username",
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*',
        'Authorization': token
      }),
    );
    if (response.statusCode == 200 && response.data != null) {
      return MarzbanConfig.fromJson(response.data);
    }
    return null;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

Future<bool> resetMarzbanUser({
  required String url,
  required String username,
  required String admin,
  required String password,
}) async {
  try {
    marzbanURL = url;
    final token = await checkIsMarzbanUrl(
      url: url,
      password: password,
      username: admin,
    );
    if (token == null) {
      return false;
    }

    Response response = await MarzbanApi.dio.post(
      "/api/user/$username/reset",
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*',
        'Authorization': token
      }),
    );
    return response.statusCode == 200;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<bool> deleteMarzbanUser({
  required String url,
  required String username,
  required String admin,
  required String password,
  required int productID,
}) async {
  try {
    marzbanURL = url;
    final token = await checkIsMarzbanUrl(
      url: url,
      password: password,
      username: admin,
    );
    if (token == null) {
      return false;
    }

    Response response = await MarzbanApi.dio.delete(
      "/api/user/$username",
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*',
        'Authorization': token
      }),
    );
    if (response.statusCode == 200) {
      Response responseBack = await GenaralApi.dio.get(
        "/api/deleteProductByProductID/$productID",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }),
      );
      return responseBack.statusCode == 200 && responseBack.data != null;
    }
    return false;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
