import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/agent_dashboard_model.dart';
import 'package:powerps/models/ballance_model.dart';
import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/models/bought_product_details_model.dart';
import 'package:powerps/models/dashboard_model.dart';
import 'package:powerps/models/details_info.dart';
import 'package:powerps/models/log_model.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/models/transaction_model.dart';
import 'package:powerps/models/user_dashboard_model.dart';

List<BoughtProductDetailsModel> boughtProducts = [];
int lastPageBougthProduct = 1;
Future<Dashboard?> getDashboardAnalytics() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getDashboardAnalytics",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      var data = response.data;
      List<BotUser> users = [];
      List<Log> logs = [];
      List<Transaction> conTransactions = [];
      List<Transaction> unConTransactions = [];
      List<DetailsInfoItem> mostSelledProductCategory = [];
      List<ProductDetails> last10ProductSelled = [];

      for (var i in data["Last10User"]) {
        users.add(BotUser.fromJson(i));
      }

      for (var i in data["Last20Logs"]) {
        logs.add(Log.fromJson(i));
      }
      for (var i in data["Last10ConfirmedTransaction"]) {
        conTransactions.add(Transaction.fromJson(i));
      }
      for (var i in data["UnConfirmedTransaction"]) {
        unConTransactions.add(Transaction.fromJson(i));
      }
      for (var i in data["MostSelledProductCategory"]) {
        mostSelledProductCategory.add(DetailsInfoItem(
            icon: const Icon(Icons.info),
            itemName: i["category_name"],
            itemValue: i["count"].toString()));
      }
      for (var i in data["last10ProductSelled"]) {
        last10ProductSelled.add(ProductDetails.fromJson(i));
      }
      Dashboard dashboard = Dashboard(
          users: users,
          logs: logs,
          conTransactions: conTransactions,
          unConTransactions: unConTransactions,
          mostSelledProductCategory: mostSelledProductCategory,
          last10ProductSelled: last10ProductSelled);
      return dashboard;
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
    debugPrint(e.message);
    return null;
  }
}

Future<AgentDashboard?> getAgentDashboardData() async {
  // try {
  Response response =
      await GenaralApi.dio.get("/api/getAgentDashboardAnalytics",
          options: Options(headers: {
            'Accept': 'application/json',
            'Connection': 'keep-alive',
            "Content-Type": "application/json;charset=UTF-8",
            "Charset": "utf-8",
            'Access-Control-Allow-Origin': '*',
          }));
  if (response.statusCode == 200 && response.data != null) {
    final agentBallance = Ballance.fromJson(response.data["accBallance"]);
    List<AgentAddCategoriyModel> agentAddCategories = [];
    // List<BoughtProductDetailsModel> boughtProducts = [];
    List<Log> logs = [];

    for (var i in response.data["products"]) {
      agentAddCategories.add(AgentAddCategoriyModel.fromMap(i));
    }
    // for (var i in response.data["boughtProducts"]) {
    //   boughtProducts.add(BoughtProductDetailsModel.fromJson(i));
    // }
    for (var i in response.data["Last20Logs"]) {
      logs.add(Log.fromJson(i));
    }

    final agentDashboard = AgentDashboard(
        ballance: agentBallance,
        agentProducts: agentAddCategories,
        boughtProducts: null,
        logs: logs);
    return agentDashboard;
  }
  debugPrint(response.data);
  debugPrint(response.statusMessage.toString());
  return null;
  // } catch (e) {
  //   debugPrint(e.toString());
  //   return null;
  // }
}

Future<UserDashboard?> getUserDashboardAnalytics() async {
  // try {
  Response response = await GenaralApi.dio.get("/api/getUserDashboardAnalytics",
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json;charset=UTF-8",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*',
      }));
  if (response.statusCode == 200 && response.data != null) {
    final agentBallance = Ballance.fromJson(response.data["accBallance"]);
    List<ProductCategory> products = [];
    // List<BoughtProductDetailsModel> boughtProducts = [];
    List<Log> logs = [];

    for (var i in response.data["products"]) {
      products.add(ProductCategory.fromMap(i));
    }
    // for (var i in response.data["boughtProducts"]) {
    //   boughtProducts.add(BoughtProductDetailsModel.fromJson(i));
    // }
    for (var i in response.data["Last20Logs"]) {
      logs.add(Log.fromJson(i));
    }

    final userDashboard =
        UserDashboard(ballance: agentBallance, prdoducts: products, logs: logs);
    return userDashboard;
  }
  return null;
  // } catch (e) {
  //   debugPrint(e.toString());
  //   return null;
  // }
}

Future<List<BoughtProductDetailsModel>> getAgentSelledProductsByPagination(
    {int page = 1}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getAgentSelledProductsByPagination?page=$page",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*',
            }));
    if (response.statusCode == 200 && response.data != null) {
      var data = response.data["data"];
      lastPageBougthProduct = response.data["last_page"];
      boughtProducts.clear();
      for (var i in data) {
        boughtProducts.add(BoughtProductDetailsModel.fromJson(i));
      }
      return boughtProducts;
    }
    return boughtProducts;
  } catch (e) {
    debugPrint(e.toString());
    return boughtProducts;
  }
}

Future<List<BoughtProductDetailsModel>> getUserSelledProductsByPagination(
    {int page = 1}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getUserSelledProductsByPagination?page=$page",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*',
            }));
    if (response.statusCode == 200 && response.data != null) {
      var data = response.data["data"];
      lastPageBougthProduct = response.data["last_page"];
      boughtProducts.clear();
      for (var i in data) {
        boughtProducts.add(BoughtProductDetailsModel.fromJson(i));
      }
      return boughtProducts;
    }
    return boughtProducts;
  } catch (e) {
    debugPrint(e.toString());
    return boughtProducts;
  }
}

Future getAgentPaymentWays() async {
  // try {
  Response response = await GenaralApi.dio.get("/api/getAgentPaymentWays",
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json;charset=UTF-8",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*',
      }));
  if (response.statusCode == 200 && response.data != null) {
    List res = [];
    for (var i in response.data["active_payment"]) {
      res.add({"name": i["name"], "merchant_id": i["merchant_id"]});
    }
    res.add({
      "name": "crypto_payment_status",
      "status": response.data["crypto_payment_status"]
    });

    return res;
  }
  debugPrint(response.data);
  debugPrint(response.statusMessage.toString());
  return null;
  // } catch (e) {
  //   debugPrint(e.toString());
  //   return null;
  // }
}

Future createNewAgentTomanBillUrl({required int amount}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/createNewAgentTomanBillUrl/$amount",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*',
            }));
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    }
    return null;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

Future createNewAgentDollarBillUrl({required int amount}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/createNewAgentDollarBillUrl/$amount",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*',
            }));
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    }
    return null;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}
Future<String> getLicenseType() async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/get-license-type",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*',
            }));
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    }
    return "Trial";
  } catch (e) {
    debugPrint(e.toString());
    return "Trial";
  }
}
