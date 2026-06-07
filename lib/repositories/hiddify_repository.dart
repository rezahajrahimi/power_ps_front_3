import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:persian_datetimepickers/persian_datetimepickers.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/connector/hiddify_connector.dart';
import 'package:powerps/models/hiffify_config_model.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/repositories/pannel_repository.dart';

Future<bool> checkIsHiddifyUrl(
    {required String url, required String secretCode}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/checkHiddifyPanelUrl",
        data: {"secretValue": secretCode, "pannelUrl": url},
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*',
        }));
    if (response.statusCode == 200 && response.data == true) {
      return true;
    } else if (response.statusCode == 201) {
      return false;
    } else if (response.statusCode == 401) {
      return false;
    } else if (response.statusCode == 500) {
      return false;
    } else {
      return false;
    }
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

/// Check Sanaei (x-ui) admin login using provided admin URL, username and password.
/// When [apiToken] is provided, validates via /panel/api/server/status first (3x-ui v3).
/// Returns true if login successful, false otherwise.
Future<bool> checkSanaeiLogin(
    {required String url,
    required String username,
    required String password,
    String? apiToken}) async {
  try {
    String baseUrl = url;
    if (!baseUrl.endsWith('/')) baseUrl = '$baseUrl/';

    if (apiToken != null && apiToken.trim().isNotEmpty) {
      String token = apiToken.trim();
      if (!token.toLowerCase().startsWith('bearer ')) {
        token = 'Bearer $token';
      }
      final statusUrl = '${baseUrl}panel/api/server/status';
      Dio tokenDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        validateStatus: (status) => status! < 500,
      ));
      Response tokenResponse = await tokenDio.get(statusUrl,
          options: Options(headers: {
            'Accept': 'application/json',
            'Authorization': token,
          }));
      if (tokenResponse.statusCode == 200 &&
          tokenResponse.data is Map &&
          tokenResponse.data['success'] == true) {
        return true;
      }
    }

    String loginUrl = '${baseUrl}login';

    // Use a fresh Dio instance for panel calls
    Dio dio = Dio(BaseOptions(
      baseUrl: loginUrl,
      followRedirects: false,
      validateStatus: (status) => status! < 500,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ));

    Response response = await dio.post(loginUrl,
        data: {'username': username, 'password': password},
        options: Options(headers: {
          'Accept': 'application/json, text/html, */*',
          'Content-Type': 'application/x-www-form-urlencoded',
        }));

    // Successful login typically returns 200 and sets a cookie
    if (response.statusCode == 200 && response.data["success"] != false) {
      try {
        // Check for Set-Cookie header (some servers use lowercase)
        if (response.headers.map.containsKey('set-cookie') ||
            response.headers.map.containsKey('Set-Cookie')) {
          return true;
        }
        // Even if cookie not present in headers, consider 200 as success
        return true;
      } catch (e) {
        return true;
      }
    }
    return false;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future addHiddifyPannel({required Pannel pannel}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/addHiddifyPannel",
        data: {
          "location": pannel.location,
          "admin_url": pannel.adminUrl,
          "capacity": pannel.capacity,
          "secretValue": pannel.secretCode,
          "user_link": pannel.userLink
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200) {
      lastPannelID = response.data;
      return true;
    } else if (response.statusCode == 201) {
      return response.data;
    } else if (response.statusCode == 401) {
      return false;
    } else if (response.statusCode == 500) {
      return false;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future<bool> updateHiddifyPannel({required Pannel pannel}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/updateHiddifyPannel",
        data: {
          "id": int.parse(pannel.id),
          "location": pannel.location,
          "admin_url": pannel.adminUrl,
          "capacity": pannel.capacity,
          "secretValue": pannel.secretCode,
          "user_link": pannel.userLink
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 401) {
      return false;
    } else if (response.statusCode == 500) {
      return false;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future<dynamic> getHiddifyUserInfo(
    {required String url, required String userUuid}) async {
  try {
    hiddifyURL = url;
    Response response = await HiddifyApi.dio.get("/api/v1/user/?uuid=$userUuid",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      try {
        HiddifyConfig hiddifyConfig = HiddifyConfig.fromJson(response.data);
        return hiddifyConfig;
      } catch (e) {
        debugPrint(e.toString());
        return false;
      }
    } else if (response.statusCode == 201) {
      return false;
    } else if (response.statusCode == 401) {
      return false;
    } else if (response.statusCode == 500) {
      return false;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<dynamic> getHiddifyPanelUsersByPannelID({required int pannelID}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getHiddifyPanelUsersByPannelID/$pannelID",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      try {
        List<HiddifyConfig> list = [];
        for (var element in response.data) {
          list.add(HiddifyConfig.fromJson(element));
        }
        return list;
      } catch (e) {
        debugPrint(e.toString());
        return false;
      }
    } else if (response.statusCode == 201) {
      return false;
    } else if (response.statusCode == 401) {
      return false;
    } else if (response.statusCode == 500) {
      return false;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<dynamic> resetHiddifyUserConfig(
    {required String url, required HiddifyConfig hiddify}) async {
  try {
    hiddifyURL = url;
    Response response = await HiddifyApi.dio.post("/api/v1/user/",
        data: {
          'uuid': hiddify.uuid,
          'name': hiddify.name,
          'current_usage_GB': 0,
          'usage_limit_GB': hiddify.usageLimitGB,
          'package_days': hiddify.packageDays,
          'start_date': null,
          'comment':
              "ریست شده توسط پنل ربات در تاریخ ${DateTime.now().toPersianDate()}",
          'mode': 'no_reset',
          'telegram_id': null,
          'telegram_token': null,
          'added_by_uuid': hiddify.addedByUuid,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    debugPrint(response.statusMessage);
    debugPrint(response.statusCode.toString());
    debugPrint(response.data.toString());
    if (response.statusCode == 200 && response.data != null) {
      try {
        return true;
      } catch (e) {
        debugPrint(e.toString());
        return false;
      }
    } else if (response.statusCode == 201) {
      return false;
    } else if (response.statusCode == 401) {
      return false;
    } else if (response.statusCode == 500) {
      return false;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<dynamic> deleteHiddifyUserConfig(
    {required String url,
    required HiddifyConfig hiddify,
    required int productID}) async {
  // try {
  hiddifyURL = url;
  Response response =
      await HiddifyApi.dio.post("/api/v1/user/?uuid=${hiddify.uuid}",
          data: {
            'uuid': hiddify.uuid,
            'name': hiddify.name,
            'current_usage_GB': 0,
            'usage_limit_GB': hiddify.usageLimitGB,
            'package_days': hiddify.packageDays,
            'mode': 'no_reset',
            'telegram_id': null,
            'telegram_token': null,
            // 'added_by_uuid': hiddify.addedByUuid,
          },
          options: Options(headers: {
            'Accept': 'application/json',
            'Connection': 'keep-alive',
            "Content-Type": "application/json;charset=UTF-8",
            "Charset": "utf-8",
            'Access-Control-Allow-Origin': '*'
          }));
  if (response.statusCode == 200 && response.data != null) {
    try {
      Response responseBack =
          await GenaralApi.dio.get("/api/deleteProductByProductID/$productID",
              options: Options(headers: {
                'Accept': 'application/json',
                'Connection': 'keep-alive',
                "Content-Type": "application/json;charset=UTF-8",
                "Charset": "utf-8",
                'Access-Control-Allow-Origin': '*'
              }));
      if (responseBack.statusCode == 200 && responseBack.data != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  } else if (response.statusCode == 201) {
    return false;
  } else if (response.statusCode == 401) {
    return false;
  } else if (response.statusCode == 500) {
    return false;
  } else {
    return false;
  }
}
