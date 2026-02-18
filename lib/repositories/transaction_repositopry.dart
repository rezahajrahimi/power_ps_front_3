import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/transaction_model.dart';

List<Transaction> transactionList = [];
List<Transaction> confirmedTransactionList = [];
List<Transaction> unConfirmedTransactionList = [];
String transactionChangedToken = "aa";
ChangeTransactionController transactionNotifier =
    ChangeTransactionController(0);

class ChangeTransactionController extends ValueNotifier {
  ChangeTransactionController(super.value);
  void changedTransactionLockData() {
    value = transactionChangedToken;
  }
}

Future getConfirmedTransactions({int count = 10, int page = 1}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getConfirmedTransactions/$count?page=$page",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      var data = response.data['data'];
      List<Transaction> list = [];
      for (var i in data) {
        list.add(Transaction.fromJson(i));
      }
      return {
        'data': list,
        'last_page': response.data['last_page'],
        'current_page': response.data['current_page'],
      };
    } else {
      return null;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future getUnConfirmedTransactions({int count = 10, int page = 1}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getUnConfirmedTransactions/$count?page=$page",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      var data = response.data['data'];
      List<Transaction> list = [];
      for (var i in data) {
        list.add(Transaction.fromJson(i));
      }
      return {
        'data': list,
        'last_page': response.data['last_page'],
        'current_page': response.data['current_page'],
      };
    } else {
      return null;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<bool> removeUnconfirmedTransaction({required int transactionId}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/removeUnconfirmedTransaction/$transactionId",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));
    if (response.statusCode == 200) {
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

Future editUserTranaction({
  required int id,
  required int amount,
  required int paymentTypeId,
  required String recipeNUmber,
  required bool confirmed,
}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/editUserTranaction",
        data: {
          "id": id,
          "amount": amount,
          "paymentTypeId": paymentTypeId,
          "recipeNUmber": recipeNUmber,
          "confirmed": confirmed,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      // unConfirmedTransactionList.clear();
      // var data = response.data;
      // for (var i in data) {
      //   unConfirmedTransactionList.add(Transaction.fromJson(i));
      // }
      // transactionChangedToken = "transactionChanged";
      // transactionNotifier.changedTransactionLockData();
      // return unConfirmedTransactionList;
      return true;
    } else if (response.statusCode == 201) {
      return true;
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
