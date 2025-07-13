import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';
import 'package:powerps/models/bought_product_details_model.dart';
import 'package:powerps/models/hiffify_config_model.dart';
import 'package:powerps/models/product_category_model.dart';

Future createAndEditBatchOfUserAgentProduct(
    {required int userID,
    required List<AgentAddCategoriyModel> gentAddCategoriyList,
    required AgentPermisson agentPermisson}) async {
  var formData = FormData.fromMap({
    'UserID': userID,
    'minusBallance': agentPermisson.minusBallance,
    'deleteProducts': agentPermisson.deleteProducts,
    'createProducts': agentPermisson.createProducts,
    'trafficLimitationTB': agentPermisson.trafficLimitationTB,
    'productLimitation': agentPermisson.productLimitation,
    'selectedProductList': json.encode(gentAddCategoriyList),
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
    'configs': json.encode(hiddifyConfig),
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
    'selectedProductList': json.encode(gentAddCategoriyList),
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
    required double vol,
    required List<HiddifyConfig> hiddifyConfig}) async {
  var formData = FormData.fromMap({
    'action': action,
    'panel_id': panelId,
    'days': day,
    'vol': vol,
    'configs': json.encode(hiddifyConfig),
  });

  try {
    Response response =
        await GenaralApi.dio.post("/api/batchExistSubscriptionJob",
            data: formData,
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));
    debugPrint("response ${response.statusCode}");
    debugPrint("status code:=>${response.statusMessage}");
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
        selected.add(AgentAddCategoriyModel.fromMap(i));
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

Future buyProductByAgentWithPrID(
    {required int productID, required String remark}) async {
  try {
    Response response =
        await GenaralApi.dio.put("/api/buyProductByAgentWithPrID",
            data: {"id": productID, "remark": remark},
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

Future buyProductByUserWithPrID(
    {required int productID, required String remark}) async {
  try {
    Response response =
        await GenaralApi.dio.put("/api/buyProductByUserWithPrID",
            data: {"id": productID, "remark": remark},
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

Future buyProductByAdmin(
    {required int productID,
    required String remark,
    username,
    required int userID,
    required int accountId}) async {
  try {
    Response response = await GenaralApi.dio.put("/api/buyProductByAdmin",
        data: {
          "id": productID,
          "remark": remark,
          "account_id": accountId,
          "username": username,
          "user_id": userID
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

Future getBoughtProductsStatusFromServerById({required int productID}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getBoughtProductsStatusFromServerById/$productID",
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

Future getProductBoughtedByProductIdUserMode({required int productID}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getProductBoughtedByProductIdUserMode/$productID",
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
