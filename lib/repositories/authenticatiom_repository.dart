import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/shared_prefrencess.dart';
import 'package:powerps/models/user_model.dart';

Future logIn({
  required String accountID,
  required String password,
}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/login",
        data: {"account_id": accountID, "password": password},
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    debugPrint(response.data.toString());
    if (response.statusCode == 200 && response.data != null) {
      User user = User.fromJson(response.data["user"]);

      final token = response.data["token"];
      GenaralApi.dio.options.headers['Authorization'] = 'Bearer $token';
      GenaralApi.dio.options.headers['x-access-token'] = token;
      LoggingPreference().setToken(token: token);
      return user;
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
    debugPrint(e.message);
    return null;
  }
}

Future getlogedUserData() async {
  try {
    Response response = await GenaralApi.dio.get("/api/user",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      User user = User.fromJson(response.data);

      return user;
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
    debugPrint(e.message);
    return false;
  }
}

Future<bool> forgetPassword({
  required int accountID,
}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/forgetPassword",
        data: {"account_id": accountID},
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
    debugPrint(e.message);
    return false;
  }
}

Future<bool> logOut() async {
  try {
    Response response = await GenaralApi.dio.post("/api/logout");

    if (response.statusCode == 200 && response.data != null) {
      // stateKey.currentContext?.read<AuthChangeController>().logout();

      const token = "void";

      LoggingPreference().setToken(token: token);

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
    debugPrint(e.message);
    return false;
  }
}
