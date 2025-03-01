import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/models/hiffify_config_model.dart';

List<BotUser> botUserList = [];

String botUserChangedToken = "aa";
int lastPage = 1;
ChangeBotUserController botUserNotifier = ChangeBotUserController(0);

class ChangeBotUserController extends ValueNotifier {
  ChangeBotUserController(super.value);
  void changedBotUserData() {
    value = botUserChangedToken;
  }
}

Future getBotUserListByPagination({int page = 1}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/getBotUserListByPagination?page=$page",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200) {
      var data = response.data["data"];
      lastPage = response.data["last_page"];

      botUserList.clear();
      for (var i in data) {
        botUserList.add(BotUser.fromJson(i));
      }
      // transactionChangedToken = "transactionChanged";

      // transactionNotifier.changedTransactionLockData();
      return botUserList;
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

Future getBotUserList() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getBotUserList",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      botUserList.clear();
      var data = response.data;
      for (var i in data) {
        botUserList.add(BotUser.fromJson(i));
      }
      // transactionChangedToken = "transactionChanged";

      // transactionNotifier.changedTransactionLockData();
      return botUserList;
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

Future searchBotUsers({required String searchUserText}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/searchBotUsers",
        data: {"search": searchUserText},
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    if (response.statusCode == 200 && response.data != null) {
      botUserList.clear();
      var data = response.data;
      for (var i in data) {
        botUserList.add(BotUser.fromJson(i));
      }
      return botUserList;
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

Future getBotUserByID({required int id}) async {
  try {
    Response response = await GenaralApi.dio.get("/api/getBotUserByID/$id",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      BotUser botUser = BotUser.fromJson(response.data);
      return botUser;
    } else if (response.statusCode == 201) {
      return null;
    } else if (response.statusCode == 401) {
      return null;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

Future getProductBoughtedByProductId({required int productID}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getProductBoughtedByProductId/$productID",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200) {
      HiddifyConfig hiddifyConfig = HiddifyConfig.fromJson(response.data);
      return hiddifyConfig;
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
    debugPrint(e.error.toString());
    return false;
  }
}

Future changeProductByAdminWithPrID({
  required int id,
  required int newPrCatID,
  required bool recharge,
  required bool changeBallance,
}) async {
  try {
    Response response =
        await GenaralApi.dio.put("/api/changeProductByAdminWithPrID",
            data: {
              "id": id,
              "newPrCatID": newPrCatID,
              "changeBallance": changeBallance,
              "recharge": recharge
            },
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
    debugPrint(e.error.toString());
    return false;
  }
}

Future changeProductByAgentWithPrID({
  required int id,
  required int newPrCatID,
  required bool recharge,
}) async {
  try {
    Response response =
        await GenaralApi.dio.put("/api/changeProductByAgentWithPrID",
            data: {"id": id, "newPrCatID": newPrCatID, "recharge": recharge},
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
    debugPrint(e.error.toString());
    return false;
  }
}

Future reChargeProductByAdminWithPrID({required int productID}) async {
  try {
    Response response =
        await GenaralApi.dio.patch("/api/reChargeProductByAdminWithPrID",
            data: {"id": productID},
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
    debugPrint(e.error.toString());
    return false;
  }
}

Future getBoughtProductsPannelLinkFromServerByIdAdminMode(
    {required int productID}) async {
  try {
    Response response = await GenaralApi.dio.get(
        "/api/getBoughtProductsPannelLinkFromServerByIdAdminMode/$productID",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200) {
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
    debugPrint(e.error.toString());
    return false;
  }
}

Future softDeleteProductByAgentWithPrIDAdminMOde(
    {required int productID}) async {
  try {
    Response response = await GenaralApi.dio
        .delete("/api/softDeleteProductByAgentWithPrIDAdminMOde/$productID",
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
    debugPrint(e.error.toString());
    return false;
  }
}

Future changeActivationOfHiddifyUserByAdmin(
    {required int productID, required bool enable}) async {
  try {
    Response response =
        await GenaralApi.dio.post("/api/changeActivationOfHiddifyUserByAdmin",
            data: {"id": productID, "enable": enable},
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
    debugPrint(e.error.toString());
    return false;
  }
}

Future changeActivationOfHiddifyUserByAgent(
    {required int productID, required bool enable}) async {
  try {
    Response response =
        await GenaralApi.dio.post("/api/changeActivationOfHiddifyUserByAgent",
            data: {"id": productID, "enable": enable},
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
      return response.data;
    } else if (response.statusCode == 500) {
      return false;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.error.toString());
    return false;
  }
}
