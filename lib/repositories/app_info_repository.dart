import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/shared_prefrencess.dart';
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
  // save appinfo in localstorage

  if (response.statusCode == 200) {
    // Save the app info in local storage
    // Return the app info
    final appInfo = AppInfoModel.fromMap(response.data);
    AppInfoPreference().saveAppInfo(appInfo);
    return appInfo;
  } else {
    throw Exception('Failed to load app info');
  }
}

Future<bool> updateAppInfo({required AppInfoModel appInfo}) async {
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

Future<bool> uploadImage({required Uint8List imageBytes}) async {
  FormData formData = FormData.fromMap({
    'image': MultipartFile.fromBytes(imageBytes, filename: 'app_image.png'),
  });

  Response response = await GenaralApi.dio.post("/api/save-application-image",
      data: formData,
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "multipart/form-data",
        'Access-Control-Allow-Origin': '*'
      }));

  debugPrint(response.data.toString());

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
