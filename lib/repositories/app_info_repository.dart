import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/app_info_model.dart';

Future<AppInfoModel> fetchAppInfo() async {
  Response response = await GenaralApi.dio.get("/api/get-application-info",
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json;charset=UTF-8",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*'
      }));

  if (response.statusCode == 200) {
    return AppInfoModel.fromJson(json.decode(response.data));
  } else {
    throw Exception('Failed to load app info');
  }
}

Future<bool> updateAppInfo(AppInfoModel appInfo) async {
  Response response = await GenaralApi.dio.post("/api/update-application-info",
      data: appInfo.toJson(),
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json;charset=UTF-8",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*'
      }));

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
