import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/crypto_payment_gateway_model.dart';
import 'package:powerps/models/payment_type_model.dart';
import 'package:powerps/models/sub_menu_item_model.dart';

List<PaymentType> paymentTypesList = [];
String paymentTypeChangedToken = "aa";
ChangePaymentTyoeController paymentTypeotifier = ChangePaymentTyoeController(0);

class ChangePaymentTyoeController extends ValueNotifier {
  ChangePaymentTyoeController(super.value);
  void changedPaymentTypeData() {
    value = paymentTypeChangedToken;
  }
}

Future getAllOfflinePayments() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getAllOfflinePayments",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      paymentTypesList.clear();
      var data = response.data;
      for (var i in data) {
        paymentTypesList.add(PaymentType.fromJson(i));
      }

      return paymentTypesList;
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

Future<bool> getDollorTransactionSetting() async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/getDollorTransactionSetting",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      if (response.data.toString() == "1" || response.data == true) {
        return true;
      }
      return false;
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

Future<bool> setDollorTransactionSetting(
    {required bool dollarTransaction}) async {
  try {
    Response response =
        await GenaralApi.dio.patch("/api/setDollorTransactionSetting",
            data: {"dollar_transaction": dollarTransaction},
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      if (response.data == 1 || response.data == true) {
        return true;
      }
      return false;
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

Future getAllActiveOfflinePaymentTypes() async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/getAllActiveOfflinePaymentTypes",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      paymentTypesList.clear();
      var data = response.data;
      for (var i in data) {
        paymentTypesList.add(PaymentType.fromJson(i));
      }

      return paymentTypesList;
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

Future getAllPaymentTypeMenues() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getAllPaymentTypeMenues",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      List<SubMenuItem> subList = [];
      var data = response.data;
      for (var i in data) {
        subList.add(SubMenuItem.fromJson(i));
      }

      return subList;
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

Future updatePaymentMenuAlisNameByLevel(
    {required int level, required String newText}) async {
  try {
    Response response =
        await GenaralApi.dio.post("/api/updatePaymentMenuAlisNameByLevel",
            data: {
              "level": level,
              "alias_name": newText,
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
      return true;
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

Future getZarinpalPaymentDetails() async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/getZarinpalPaymentDetails",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      PaymentType payment = PaymentType.fromJson(response.data);

      return payment;
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

Future updateNowPaymentDetails(
    {required CryptoPaymentGateway cryptoPaymentGateway}) async {
  try {
    Response response =
        await GenaralApi.dio.patch("/api/updateNowPayment", data: {
      "api_key": cryptoPaymentGateway.apiKey,
      "email": cryptoPaymentGateway.email,
      "password": cryptoPaymentGateway.password,
      "is_fee_paid_by_user": cryptoPaymentGateway.isFeePaidByUser,
      "is_active": cryptoPaymentGateway.isActive,
    });

    if (response.statusCode == 200 && response.data != null) {
      return CryptoPaymentGateway.fromMap(response.data);
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

Future getNovPaymentDetails() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getNovPaymentData");

    if (response.statusCode == 200 && response.data != null) {
      return CryptoPaymentGateway.fromMap(response.data);
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

Future<bool> chanegeMerChantIdByPaymentTypeName(
    {required String name, required String merchantId}) async {
  try {
    Response response =
        await GenaralApi.dio.post("/api/chanegeMerChantIdByPaymentTypeName",
            data: {"name": name, "merchant_id": merchantId},
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
  }
}

Future<bool> updateOfflinePaymentType(
    {required int id, required String name, required String merchantId}) async {
  try {
    Response response =
        await GenaralApi.dio.post("/api/updateOfflinePaymentType",
            data: {"name": name, "merchant_id": merchantId, "id": id},
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
  }
}

Future<bool> addNewOfflinePaymentType(
    {required String name, required String merchantId}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/createNewPaymentType",
        data: {"name": name, "merchant_id": merchantId, "type": "offline"},
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

Future<bool> deActivePaymentType({required String name}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/deActivePaymentType/$name",
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
  }
}

Future removePaymentType({required String name}) async {
  try {
    Response response = await GenaralApi.dio.get("/api/removePaymentType/$name",
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
    } else if (response.statusCode == 202) {
      return response.data;
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

Future<bool> reActivePaymentType({required String name}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/reActivePaymentType/$name",
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
  }
}
