import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/connector/marzban_connector.dart';
import 'package:powerps/models/marzban_config_model.dart';

Future<String?> resolveMarzbanAuthToken({
  required String url,
  String? storedToken,
  String? admin,
  String? password,
}) async {
  final normalizedToken = storedToken?.trim();
  if (normalizedToken != null &&
      normalizedToken.isNotEmpty &&
      normalizedToken.toLowerCase() != 'null' &&
      normalizedToken != 'Bearer') {
    if (normalizedToken.toLowerCase().startsWith('bearer ')) {
      return normalizedToken;
    }
    return 'Bearer $normalizedToken';
  }

  if (admin == null || password == null) {
    return null;
  }

  return checkIsMarzbanUrl(
    url: url,
    username: admin,
    password: password,
  );
}

String encodeMarzbanUsername(String username) {
  return Uri.encodeComponent(username);
}

Future<String?> checkIsMarzbanUrl({
  required String url,
  required String username,
  required String password,
}) async {
  try {
    setMarzbanBaseUrl(url);
    Response response = await MarzbanApi.dio.post(
      "/api/admin/token",
      data: {
        'username': username,
        'password': password,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'Accept': 'application/json',
        },
      ),
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
    setMarzbanBaseUrl(url);
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
        final tags = <String>[];
        for (final item in value) {
          if (item is String && item.isNotEmpty) {
            tags.add(item);
          } else if (item is Map) {
            final tag = item['tag'] ?? item['name'] ?? item['remark'];
            if (tag != null && tag.toString().isNotEmpty) {
              tags.add(tag.toString());
            }
          }
        }
        if (tags.isNotEmpty) {
          result[key.toString()] = tags;
        }
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
  String? storedToken,
}) async {
  try {
    setMarzbanBaseUrl(url);
    final token = await resolveMarzbanAuthToken(
      url: url,
      storedToken: storedToken,
      admin: admin,
      password: password,
    );
    if (token == null) {
      return null;
    }

    Response response = await MarzbanApi.dio.get(
      "/api/user/${encodeMarzbanUsername(username)}",
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
  String? storedToken,
}) async {
  try {
    setMarzbanBaseUrl(url);
    final token = await resolveMarzbanAuthToken(
      url: url,
      storedToken: storedToken,
      admin: admin,
      password: password,
    );
    if (token == null) {
      return false;
    }

    Response response = await MarzbanApi.dio.post(
      "/api/user/${encodeMarzbanUsername(username)}/reset",
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

Future<bool> changeActivationOfMarzbanUser({
  required String url,
  required String username,
  required String admin,
  required String password,
  required bool enable,
  String? storedToken,
}) async {
  try {
    setMarzbanBaseUrl(url);
    final token = await resolveMarzbanAuthToken(
      url: url,
      storedToken: storedToken,
      admin: admin,
      password: password,
    );
    if (token == null) {
      return false;
    }

    Response response = await MarzbanApi.dio.put(
      "/api/user/${encodeMarzbanUsername(username)}",
      data: {
        'status': enable ? 'active' : 'disabled',
      },
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
  String? storedToken,
}) async {
  try {
    setMarzbanBaseUrl(url);
    final token = await resolveMarzbanAuthToken(
      url: url,
      storedToken: storedToken,
      admin: admin,
      password: password,
    );
    if (token == null) {
      return false;
    }

    Response response = await MarzbanApi.dio.delete(
      "/api/user/${encodeMarzbanUsername(username)}",
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
