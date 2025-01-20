import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/test_account_model.dart';

Future<TestAccount?> getTestAccountDetails() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getTestAccountDetails",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null && response.data != "") {
      TestAccount testAccount = TestAccount.fromJson(response.data);
      return testAccount;
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
  }
}

Future<TestAccount?> updateTestAccountDetails({
  required int pannelID,
  required int expireDays,
  required double volume,
}) async {
  try {
    Response response =
        await GenaralApi.dio.post("/api/updateTestAccountDetails",
            data: {
              "pannel_id": pannelID,
              "expire_day": expireDays,
              "volume": volume,
            },
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      TestAccount testAccount = TestAccount.fromJson(response.data);
      return testAccount;
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
  }
}
