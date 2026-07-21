import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';
import 'package:powerps/models/bought_product_details_model.dart';
import 'package:powerps/models/hiffify_config_model.dart';
import 'package:powerps/models/marzban_config_model.dart';
import 'package:powerps/models/sanaei_config_model.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/product_category_model.dart';

Future createAndEditBatchOfUserAgentProduct(
    {required int userID,
    required List<AgentAddCategoriyModel> gentAddCategoriyList,
    required AgentPermisson agentPermisson}) async {
  var formData = FormData.fromMap({
    'UserID': userID,
    'minusBallance': agentPermisson.minusBallance,
    'minusBallanceLimit': agentPermisson.minusBallanceLimit,
    'deleteProducts': agentPermisson.deleteProducts,
    'createProducts': agentPermisson.createProducts,
    'trafficLimitationTB': agentPermisson.trafficLimitationTB,
    'productLimitation': agentPermisson.productLimitation,
    'selectedProductList': json.encode(
      gentAddCategoriyList.map((item) => item.toMap()).toList(),
    ),
  });

  try {
    Response response =
        await GenaralApi.dio.post("/api/createBatchOfUserAgentProduct",
            data: formData,
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));
    debugPrint(response.statusCode.toString());
    debugPrint(response.statusMessage);
    if (response.statusCode == 200 && response.data != null) {
      return true;
    } else if (response.statusCode == 201) {
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
    return null;
  }
}

Future removeAgent({required int userID}) async {
  var formData = FormData.fromMap({
    'UserID': userID,
  });

  try {
    Response response = await GenaralApi.dio.post("/api/removeAgent",
        data: formData,
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    debugPrint(response.statusCode.toString());
    debugPrint(response.statusMessage);
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

Future obtainBatchOfExistProductsToUser({
  required int pannelID,
  required int accountID,
  required List<HiddifyConfig> hiddifyConfig,
}) async {
  var formData = FormData.fromMap({
    'accountID': accountID,
    'pannelID': pannelID,
    'configs': json.encode(hiddifyConfig.map((config) => config.toMap()).toList()),
  });

  try {
    Response response =
        await GenaralApi.dio.post("/api/obtainBatchOfExistProductsToUser",
            data: formData,
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));
    debugPrint(response.statusCode.toString());
    debugPrint(response.statusMessage);
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

Future deleteBatchOfUserAgentProduct({
  required int userID,
  required List<AgentAddCategoriyModel> gentAddCategoriyList,
}) async {
  var formData = FormData.fromMap({
    'UserID': userID,
    'selectedProductList': json.encode(
      gentAddCategoriyList.map((item) => item.toMap()).toList(),
    ),
  });

  // try {
  Response response =
      await GenaralApi.dio.post("/api/deleteBatchOfUserAgentProduct",
          data: formData,
          options: Options(headers: {
            'Accept': 'application/json',
            'Connection': 'keep-alive',
            "Content-Type": "application/json;charset=UTF-8",
            "Charset": "utf-8",
            'Access-Control-Allow-Origin': '*'
          }));
  debugPrint(response.statusCode.toString());
  debugPrint(response.statusMessage);
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
  // } on DioException catch (e) {
  //   debugPrint(e.message.toString());
  //   return null;
  // }
}

Future batchExistSubscriptionJobDayOpr(
    {required String action,
    required int panelId,
    required int day,
    required String vol,
    required List<HiddifyConfig> hiddifyConfig}) async {
  var formData = FormData.fromMap({
    'action': action,
    'panel_id': panelId,
    'days': day,
    'vol': vol,
    'configs': json.encode(hiddifyConfig.map((config) => config.toMap()).toList()),
  });

  try {
    final response = await GenaralApi.dio.post("/api/batchExistSubscriptionJob",
        data: formData,
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    if (response.statusCode == 200 && response.data != null) {
      final status = response.data is Map
          ? response.data['status']?.toString()
          : null;
      return status == null || status == 'success';
    }
    return false;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future getAgentProductsWithNotSelectedByUserID({required int userID}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getAgentProductsNotSelectedByUserID/$userID",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200) {
      List<ProductCategory> notSelected = [];
      var dataNotSelected = response.data;
      for (var i in dataNotSelected) {
        notSelected.add(ProductCategory.fromMap(i));
      }

      return notSelected;
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
    return e.error;
  }
}

Future getAgentProductsByUserID({required int userID}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/getAgentProductsByUserID/$userID",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200) {
      List<AgentAddCategoriyModel> selected = [];
      var dataSelected = response.data;
      for (var i in dataSelected) {
        selected.add(AgentAddCategoriyModel.fromMap(
          Map<String, dynamic>.from(i as Map),
        ));
      }

      return selected;
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
    return e.error;
  }
}

Future getAgentSelledProducts() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getAgentSelledProducts",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200) {
      List<BoughtProductDetailsModel> list = [];
      for (var i in response.data) {
        list.add(BoughtProductDetailsModel.fromJson(i));
      }
      return list;
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
    return e.error;
  }
}

Future buyProductByAgentWithPrID({
  required int productID,
  required String remark,
  String? promoCode,
  bool useLoyaltyPoints = true,
}) async {
  try {
    Response response =
        await GenaralApi.dio.put("/api/buyProductByAgentWithPrID",
            data: {
              "id": productID,
              "remark": remark,
              if (promoCode != null && promoCode.isNotEmpty)
                "promo_code": promoCode,
              "use_loyalty_points": useLoyaltyPoints,
            },
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
      return response.data;
    } else if (response.statusCode == 500) {
      return false;
    } else {
      return false;
    }
  } on DioException catch (e) {
    return e.error;
  }
}

Future buyProductByUserWithPrID({
  required int productID,
  required String remark,
  String? promoCode,
  bool useLoyaltyPoints = true,
}) async {
  try {
    Response response =
        await GenaralApi.dio.put("/api/buyProductByUserWithPrID",
            data: {
              "id": productID,
              "remark": remark,
              if (promoCode != null && promoCode.isNotEmpty)
                "promo_code": promoCode,
              "use_loyalty_points": useLoyaltyPoints,
            },
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 403 && response.data is Map) {
      return Map<String, dynamic>.from(response.data);
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
    final data = e.response?.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return e.error;
  }
}

Future buyProductByAdmin(
    {required int productID,
    required String remark,
    username,
    required int userID,
    required int accountId,
    bool deductFromWallet = true}) async {
  try {
    Response response = await GenaralApi.dio.put("/api/buyProductByAdmin",
        data: {
          "id": productID,
          "remark": remark,
          "account_id": accountId,
          "username": username,
          "user_id": userID,
          "deduct_from_wallet": deductFromWallet,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 401) {
      return response.data ?? 'موجودی کیف پول کاربر کافی نیست';
    } else if (response.statusCode == 500) {
      return response.data ?? false;
    } else {
      return false;
    }
  } on DioException catch (e) {
    final data = e.response?.data;
    if (data is String && data.isNotEmpty) return data;
    return e.error;
  }
}

Future getBoughtProductsStatusFromServerById({required int productID}) async {
  return _fetchBoughtProductStatus(
    endpoint: "/api/getBoughtProductsStatusFromServerById/$productID",
  );
}

Future getProductBoughtedByProductIdUserMode({required int productID}) async {
  return _fetchBoughtProductStatus(
    endpoint: "/api/getProductBoughtedByProductIdUserMode/$productID",
  );
}

Future<dynamic> fetchBoughtProductStatus({
  required int productID,
  String userRole = "user",
}) {
  if (userRole == "agent") {
    return getBoughtProductsStatusFromServerById(productID: productID);
  }
  return getProductBoughtedByProductIdUserMode(productID: productID);
}

dynamic parseBoughtProductStatusJson(Map<String, dynamic> json) {
  final panelType = json['panel_type']?.toString() ?? '';
  if (isMarzbanCompatiblePanel(panelType) ||
      (json.containsKey('used_traffic') &&
          json.containsKey('username') &&
          !json.containsKey('uuid'))) {
    return MarzbanConfig.fromJson(json);
  }
  if (panelType == 'hiddify' ||
      (json.containsKey('uuid') && json.containsKey('current_usage_GB'))) {
    return HiddifyConfig.fromJson(json);
  }
  if (panelType == 'sanaei' ||
      json.containsKey('client') ||
      json.containsKey('inbound')) {
    return SanaeiConfig.fromJson(json);
  }
  return HiddifyConfig.fromJson(json);
}

Future _fetchBoughtProductStatus({required String endpoint}) async {
  try {
    Response response = await GenaralApi.dio.get(endpoint,
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data is Map) {
      return parseBoughtProductStatusJson(
          Map<String, dynamic>.from(response.data));
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

Future getBoughtProductsPannelLinkFromServerById(
    {required int productID}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getBoughtProductsPannelLinkFromServerById/$productID",
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

Future renameHiddifyRemark(
    {required int productID, required String remark}) async {
  try {
    Response response = await GenaralApi.dio.patch("/api/renameHiddifyRemark",
        data: {"id": productID, "name": remark},
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

Future reChargeProductByAgentWithPrID({required int productID}) async {
  try {
    Response response =
        await GenaralApi.dio.patch("/api/reChargeProductByAgentWithPrID",
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

Future reChargeProductByUserWithPrID({required int productID}) async {
  try {
    Response response =
        await GenaralApi.dio.patch("/api/reChargeProductByUserWithPrID",
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

Future softDeleteProductByAgentWithPrID({required int productID}) async {
  try {
    Response response = await GenaralApi.dio
        .delete("/api/softDeleteProductByAgentWithPrID/$productID",
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

Future softDeleteProductByUserWithPrID({required int productID}) async {
  try {
    Response response = await GenaralApi.dio
        .delete("/api/softDeleteProductByUserWithPrID/$productID",
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
