import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';

Future setNewAccountBallance(
    {required int ballance, required int userID}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/setNewAccountBallance",
        data: {
          "ballance": ballance,
          "userID": userID,
        },
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
    return null;
  }
}

Future increaseUserAccuntBalanceByUserID(
    {required double ballance,
    required int userID,
    required String type}) async {
  try {
    Response response =
        await GenaralApi.dio.put("/api/increaseUserAccuntBalanceByUserID",
            data: {
              "ballance": type == "toman" ? ballance.toInt() : ballance,
              "userID": userID,
              "type": type,
            },
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      return response.data;
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
    return null;
  }
}

Future decreaseUserAccuntBalanceByUserID(
    {required double ballance,
    required int userID,
    required String type,
    required bool isRequestByAdmin}) async {
  try {
    Response response =
        await GenaralApi.dio.put("/api/decreaseUserAccuntBalanceByUserID",
            data: {
              "ballance": type == "toman" ? ballance.toInt() : ballance,
              "userID": userID,
              "type": type,
              "is_request_by_admin": isRequestByAdmin
            },
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      return response.data;
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
    return null;
  }
}

Future setNewDollarAccountBallance(
    {required double ballance, required int userID}) async {
  try {
    Response response =
        await GenaralApi.dio.post("/api/setNewDollarAccountBallance",
            data: {
              "ballance": ballance,
              "userID": userID,
            },
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
    return null;
  }
}
