import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/referral_log_model.dart';
import 'package:powerps/models/referral_setting_model.dart';

Future getReferralSetting() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getReferralSetting",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200) {
      ReferralSettingModel referralSettingModel =
          ReferralSettingModel.fromMap(response.data);
      return referralSettingModel;
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
    return e.error;
  }
}

Future updateReferralSetting(
    {required ReferralSettingModel referralSettingModel}) async {
  try {
    Response response = await GenaralApi.dio.put("/api/updateReferralSetting",
        data: {
          "description": referralSettingModel.description,
          "visit_card_text": referralSettingModel.visitCardText,
          "referral_percent": referralSettingModel.referralPercent,
          "is_active": referralSettingModel.isActive
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
      return true;
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

Future setNewReferralBallance(
    {required int ballance, required int userID}) async {
  try {
    Response response =
        await GenaralApi.dio.put("/api/editAmountOfRefWalletByAccountId",
            data: {
              "amount": ballance,
              "account_id": userID,
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

Future<List<ReferralLogModel>?> getReferralLogsByAccountId(
    {required int userID}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/getReferralLogsByAccountId/$userID",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      List<ReferralLogModel> list = [];
      for (var i in response.data) {
        list.add(ReferralLogModel.fromMap(i));
      }
      return list;
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
