import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/setting_model.dart';

String botToken = "";
Future getBotSetting() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getBotSetting",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      Setting botSetting = Setting.fromJson(response.data);

      return botSetting;
    } else if (response.statusCode == 201) {
      return null;
    } else if (response.statusCode == 401) {
      return null;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  } catch (e) {
    return null;
  }
}

Future getBotToken() async {
  try {
    if (botToken == "") {
      Response response = await GenaralApi.dio.get("/api/getBotToken",
          options: Options(headers: {
            'Accept': 'application/json',
            'Connection': 'keep-alive',
            "Content-Type": "application/json;charset=UTF-8",
            "Charset": "utf-8",
            'Access-Control-Allow-Origin': '*'
          }));

      if (response.statusCode == 200 && response.data != null) {
        botToken = response.data;
        return botToken;
      } else if (response.statusCode == 201) {
        return null;
      } else if (response.statusCode == 401) {
        return null;
      } else if (response.statusCode == 500) {
        return null;
      } else {
        return null;
      }
    } else {
      return botToken;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<bool> updateBotSetting({required Setting setting}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/updateBotSetting",
        data: {
          "bot_name": setting.botName,
          "admin_id": int.parse(setting.adminId),
          "bot_token": setting.botToken,
          "welcome_message": setting.welcomeMessage,
          "panel_address": setting.panelAddress,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    debugPrint(response.data);
    if (response.statusCode == 200 ||
        response.data == 1 ||
        response.data == "1") {
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
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}
