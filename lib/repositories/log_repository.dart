import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/log_model.dart';

List<Log> lastLogList = [];
Future getAllLogs({required int count}) async {
  try {
    Response response = await GenaralApi.dio.get("/api/getAllLogs/$count",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      lastLogList.clear();
      var data = response.data;
      for (var i in data) {
        lastLogList.add(Log.fromJson(i));
      }
      // transactionChangedToken = "transactionChanged";

      // transactionNotifier.changedTransactionLockData();
      return lastLogList;
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
