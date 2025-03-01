import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/advanced_setting_model.dart';
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
    // be sure settings.pannelAddress is not empty and is valid url
    if (setting.panelAddress == "" ||
        !Uri.parse(setting.panelAddress).isAbsolute) {
      return false;
    }
    // be sure settings.panelAddress has not ended with /
    if (setting.panelAddress.endsWith("/")) {
      setting.panelAddress =
          setting.panelAddress.substring(0, setting.panelAddress.length - 1);
    }

    Response response = await GenaralApi.dio.post("/api/updateBotSetting",
        data: {
          "bot_name": setting.botName,
          "admin_id": int.parse(setting.adminId),
          "bot_token": setting.botToken,
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

Future getBotAdvancedSetting() async {
  try {
    Response response = await GenaralApi.dio.get("/api/advanceSettingLookup",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200) {
      List advancedSettingModel = response.data
          .map((item) => AdvancedSettingModel.fromMap(item))
          .toList();

      debugPrint(advancedSettingModel.length.toString());
      return advancedSettingModel;
    } else if (response.statusCode == 201) {
      return [];
    } else if (response.statusCode == 401) {
      return [];
    } else if (response.statusCode == 500) {
      return [];
    } else {
      return [];
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return [];
  } catch (e) {
    debugPrint(e.toString());
    return [];
  }
}
Future restoreToDefaultAdvancedSettings()async{
  try{
      Response response = await GenaralApi.dio.get("/api/restore-default-advanced-settings",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
        if(response.statusCode == 200) {
          return true;
        }
        return false;
  } catch(e){
    return null;
  }
}

/*************  ✨ Codeium Command ⭐  *************/
/// Change advanced setting of the bot.
///
/// `name` is the name of the advanced setting to be changed.
/// `value` is the new value of the advanced setting.
///
/// Returns true if the operation is successful, false otherwise.
///
/// Throws [DioException] if the request fails.
/// ****  a7d96d50-6115-4c3e-b14a-5c4c13311c5d  ******
Future<bool> changeAdvancedSetting({
  required String name,
  required bool value,
}) async {
  try {
    Response response =
        await GenaralApi.dio.post("/api/advanceSettingLookupUpdateByName",
            data: {"name": name, "value": value.toString()},
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
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
  } catch (e) {
    return false;
  }
}
