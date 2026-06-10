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

String normalizeSanaeiAdminUrl(String url) {
  var panelUrl = url.trim();
  if (panelUrl.endsWith('/')) {
    panelUrl = panelUrl.substring(0, panelUrl.length - 1);
  }
  final adminIndex = panelUrl.toLowerCase().indexOf('admin');
  if (adminIndex >= 0) {
    panelUrl = panelUrl.substring(0, adminIndex);
    if (panelUrl.endsWith('/')) {
      panelUrl = panelUrl.substring(0, panelUrl.length - 1);
    }
  }
  return panelUrl;
}

/// Add Sanaei panel: saves to DB and verifies panel login on the server.
Future<bool> addSanaeiPannel({required Pannel pannel}) async {
  lastPannelAddError = '';
  try {
    final response = await GenaralApi.dio.post(
      '/api/addSanaeiPannel',
      data: {
        'type': pannel.type,
        'username': pannel.username,
        'password': pannel.password,
        'token': pannel.token,
        'location': pannel.location,
        'url_port': pannel.urlPort,
        'sub_port': pannel.subPort,
        'admin_url': normalizeSanaeiAdminUrl(pannel.adminUrl ?? ''),
        'user_link': pannel.userLink,
        'capacity': pannel.capacity,
        'api_version': pannel.apiVersion ?? 'v3',
      },
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 &&
        response.data is Map &&
        response.data['success'] == true) {
      final panelId = int.tryParse(response.data['id']?.toString() ?? '');
      if (panelId != null && panelId > 0) {
        lastPannelID = panelId;
      }
      return true;
    }

    lastPannelAddError = (response.data is Map &&
            response.data['message'] != null)
        ? response.data['message'].toString()
        : 'خطا، اطلاعات وارد شده را بررسی کنید.';
    return false;
  } on DioException catch (e) {
    final data = e.response?.data;
    lastPannelAddError = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : (e.message ?? 'خطا در ارتباط با سرور.');
    debugPrint(lastPannelAddError);
    return false;
  }
}

/// Update Sanaei panel: saves changes, clears old session, re-validates login.
Future<bool> updateSanaeiPannel({required Pannel pannel}) async {
  lastPannelAddError = '';
  try {
    final response = await GenaralApi.dio.post(
      '/api/updateSanaeiPannel',
      data: {
        'id': int.parse(pannel.id),
        'type': pannel.type,
        'username': pannel.username,
        'password': pannel.password,
        'token': pannel.token,
        'location': pannel.location,
        'url_port': pannel.urlPort,
        'sub_port': pannel.subPort,
        'admin_url': normalizeSanaeiAdminUrl(pannel.adminUrl ?? ''),
        'user_link': pannel.userLink,
        'capacity': pannel.capacity,
        'api_version': pannel.apiVersion ?? 'v3',
      },
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 &&
        response.data is Map &&
        response.data['success'] == true) {
      final panelId = int.tryParse(response.data['id']?.toString() ?? '');
      if (panelId != null && panelId > 0) {
        lastPannelID = panelId;
      }
      return true;
    }

    lastPannelAddError = (response.data is Map &&
            response.data['message'] != null)
        ? response.data['message'].toString()
        : 'خطا، اطلاعات وارد شده را بررسی کنید.';
    return false;
  } on DioException catch (e) {
    final data = e.response?.data;
    lastPannelAddError = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : (e.message ?? 'خطا در ارتباط با سرور.');
    debugPrint(lastPannelAddError);
    return false;
  }
}

/// Check Sanaei (3x-ui) admin credentials via backend (handles CSRF + SSL).
Future<bool> checkSanaeiLogin(
    {required String url,
    required String username,
    required String password,
    String? apiToken,
    String? apiVersion}) async {
  try {
    final panelUrl = normalizeSanaeiAdminUrl(url);

    final data = <String, dynamic>{
      'pannelUrl': panelUrl,
      'username': username,
      'password': password,
      'api_version': apiVersion ?? 'v3',
    };
    final token = apiToken?.trim();
    if (token != null && token.isNotEmpty) {
      data['token'] = token;
    }

    final response = await GenaralApi.dio.post(
      '/api/checkSanaeiPanelUrl',
      data: data,
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200) {
      if (response.data == true) return true;
      if (response.data is Map && response.data['success'] == true) return true;
    }

    if (response.data is Map && response.data['message'] != null) {
      lastPannelAddError = response.data['message'].toString();
    } else {
      lastPannelAddError = 'اتصال به پنل برقرار نشد.';
    }
    return false;
  } on DioException catch (e) {
    final data = e.response?.data;
    lastPannelAddError = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : (e.message ?? 'خطا در ارتباط با سرور.');
    debugPrint(lastPannelAddError);
    return false;
  } catch (e) {
    lastPannelAddError = 'خطا در بررسی اتصال پنل.';
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
