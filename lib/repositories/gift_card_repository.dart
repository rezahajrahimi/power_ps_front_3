// ignore_for_file: prefer_null_aware_operators

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/gift_card_model.dart';
import 'package:powerps/models/sub_menu_item_model.dart';

List<GiftCard> giftCardsList = [];
String gifCardChangedToken = "aa";
ChangeGiftCardController giftCardotifier = ChangeGiftCardController(0);

class ChangeGiftCardController extends ValueNotifier {
  ChangeGiftCardController(super.value);
  void changedGiftCaradData() {
    value = gifCardChangedToken;
  }
}

Future getGiftCardList() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getGiftCardList",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      giftCardsList.clear();
      var data = response.data;
      for (var i in data) {
        giftCardsList.add(GiftCard.fromJson(i));
      }

      return giftCardsList;
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

Future getAllGiftCardMenues() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getAllGiftCardMenues",
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

Future createNewGiftCard({required GiftCard giftCard}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/createNewGiftCard",
        data: {
          "code": giftCard.code,
          "discount": giftCard.discount,
          "count_of_use": giftCard.countOfUse,
          "count_of_use_per_user": giftCard.countOfUsePerUser,
          "start_date": giftCard.startDate!.toIso8601String(),
          "end_date": giftCard.endDate!.toIso8601String(),
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

Future updateGiftCardMenuAlisNameByLevel(
    {required int level, required String newText}) async {
  try {
    Response response =
        await GenaralApi.dio.post("/api/updateGiftCardMenuAlisNameByLevel",
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
    debugPrint(response.statusMessage);
    debugPrint(response.data);
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

Future updateGiftCard({required GiftCard giftCard}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/updateGiftCard",
        data: {
          "code": giftCard.code,
          "discount": giftCard.discount,
          "count_of_use": giftCard.countOfUse,
          "count_of_use_per_user": giftCard.countOfUsePerUser,
          "start_date": giftCard.startDate != null
              ? giftCard.startDate!.toIso8601String()
              : null,
          "end_date": giftCard.endDate != null
              ? giftCard.endDate!.toIso8601String()
              : null,
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

Future deleteGiftCardByCode({required String code}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/deleteGiftCardByCode/$code",
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
