// import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/connector/marzban_connector.dart';
import 'package:powerps/models/marzban_config_model.dart';

Future checkIsMarzbanUrl(
    {required String url, required username, required password}) async {
  try {
    marzbanURL = url;
    var formData = FormData.fromMap({
      'username': username,
      'password': password,
    });
    Response response = await MarzbanApi.dio.post("/api/admin/token",
        data: formData,
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    if (response.statusCode == 200 && response.data != null) {
      try {
        var s =
            "${response.data["token_type"]}  ${response.data["access_token"]}";
        return s;
      } catch (e) {
        return null;
      }
    } else if (response.statusCode == 201) {
      return null;
    } else if (response.statusCode == 401) {
      return null;
    } else if (response.statusCode == 500) {
      debugPrint(response.statusMessage);
      return null;
    } else {
      return null;
    }
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

Future<MarzbanConfig> getMarzbanUserInfo(
    {required String url, username, admin, password}) async {
  try {
    MarzbanConfig? marzbanConfig;
    marzbanURL = url;
    String token =
        await checkIsMarzbanUrl(url: url, password: password, username: admin);
    Response response = await MarzbanApi.dio.get("/api/user/$username",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*',
          'Authorization': token
        }));
    if (response.statusCode == 200 && response.data != null) {
      try {
        MarzbanConfig marzbanConfig = MarzbanConfig.fromJson(response.data);
        return marzbanConfig;
      } catch (e) {
        debugPrint(e.toString());
        return marzbanConfig!;
      }
    } else if (response.statusCode == 201) {
      return marzbanConfig!;
    } else if (response.statusCode == 401) {
      return marzbanConfig!;
    } else if (response.statusCode == 500) {
      debugPrint(response.statusMessage);
      return marzbanConfig!;
    } else {
      return marzbanConfig!;
    }
  } catch (e) {
    MarzbanConfig? marzbanConfig;

    debugPrint(e.toString());
    return marzbanConfig!;
  }
}

Future<bool> resetMarzbanUser(
    {required String url, username, admin, password}) async {
  try {
    marzbanURL = url;
    String token =
        await checkIsMarzbanUrl(url: url, password: password, username: admin);
    Response response = await MarzbanApi.dio.post("/api/user/$username/reset",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*',
          'Authorization': token
        }));
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
      debugPrint(response.statusMessage);
      return false;
    } else {
      return false;
    }
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<bool> deleteMarzbanUser(
    {required String url,
    username,
    admin,
    password,
    required int productID}) async {
  try {
    marzbanURL = url;
    String token =
        await checkIsMarzbanUrl(url: url, password: password, username: admin);
    Response response = await MarzbanApi.dio.delete("/api/user/$username",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*',
          'Authorization': token
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
      debugPrint(response.statusMessage);
      return false;
    } else {
      return false;
    }
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
