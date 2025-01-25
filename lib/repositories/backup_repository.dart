import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';

Future<bool?> createBackup() async {
  try {
    Response response = await GenaralApi.dio.get("/api/createBackup",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    debugPrint("response=>${response.data}");
    if (response.statusCode == 200 && response.data != null) {
      return response.data['url'];
    } else {
      debugPrint(response.data.toString());
      return null;
    }
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

Future<bool> restoreBackup({required FormData formData}) async {
  Response response =
      await GenaralApi.dio.post("/api/restoreBackup", data: formData);
  if (response.statusCode == 200 && response.data != null) {
    return true;
  } else {
    return false;
  }
}
