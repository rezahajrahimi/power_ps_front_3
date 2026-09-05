import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/agent_dashboard_model.dart';
import 'package:powerps/models/agent_limit_usage_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';
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
Future<Dashboard?> getDashboardAnalytics({int unconfirmedPage = 1}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getDashboardAnalytics?page=$unconfirmedPage",
            options: Options(
              receiveTimeout: const Duration(seconds: 25),
              sendTimeout: const Duration(seconds: 25),
              headers: {
                'Accept': 'application/json',
                'Connection': 'keep-alive',
                "Content-Type": "application/json;charset=UTF-8",
                "Charset": "utf-8",
                'Access-Control-Allow-Origin': '*'
              },
            ));

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final List<BotUser> users = [];
      final List<Log> logs = [];
      final List<Transaction> conTransactions = [];
      final List<Transaction> unConTransactions = [];
      int unConTransactionsLastPage = 1;
      int unConTransactionsCurrentPage = 1;
      final List<DetailsInfoItem> mostSelledProductCategory = [];
      final List<ProductDetails> last10ProductSelled = [];

      for (final i in (data["Last10User"] as List? ?? [])) {
        try {
          users.add(BotUser.fromJson(i));
        } catch (e) {
          debugPrint('getDashboardAnalytics: skip user $e');
        }
      }

      for (final i in (data["Last20Logs"] as List? ?? [])) {
        try {
          logs.add(Log.fromJson(i));
        } catch (e) {
          debugPrint('getDashboardAnalytics: skip log $e');
        }
      }
      for (final i in (data["Last10ConfirmedTransaction"] as List? ?? [])) {
        try {
          conTransactions.add(Transaction.fromJson(i));
        } catch (e) {
          debugPrint('getDashboardAnalytics: skip confirmed tx $e');
        }
      }

      if (data["UnConfirmedTransaction"] != null) {
        final unconfirmed = data["UnConfirmedTransaction"];
        unConTransactionsLastPage = unconfirmed["last_page"] ?? 1;
        unConTransactionsCurrentPage = unconfirmed["current_page"] ?? 1;
        for (final i in (unconfirmed["data"] as List? ?? [])) {
          try {
            unConTransactions.add(Transaction.fromJson(i));
          } catch (e) {
            debugPrint('getDashboardAnalytics: skip unconfirmed tx $e');
          }
        }
      }

      for (final i in (data["MostSelledProductCategory"] as List? ?? [])) {
        try {
          mostSelledProductCategory.add(DetailsInfoItem(
              icon: const Icon(Icons.info),
              itemName: i["category_name"],
              itemValue: i["count"].toString()));
        } catch (e) {
          debugPrint('getDashboardAnalytics: skip category $e');
        }
      }
      for (final i in (data["last10ProductSelled"] as List? ?? [])) {
        try {
          last10ProductSelled.add(ProductDetails.fromJson(i));
        } catch (e) {
          debugPrint('getDashboardAnalytics: skip product $e');
        }
      }

      final List<Map<String, dynamic>> pannelsStatus = [];
      if (data["PannelsStatus"] != null) {
        for (final i in (data["PannelsStatus"] as List? ?? [])) {
          pannelsStatus.add(Map<String, dynamic>.from(i));
        }
      }

      Map<String, dynamic> financialSummary = {};
      if (data["FinancialSummary"] != null) {
        financialSummary = Map<String, dynamic>.from(data["FinancialSummary"]);
      }

      return Dashboard(
          users: users,
          logs: logs,
          conTransactions: conTransactions,
          unConTransactions: unConTransactions,
          unConTransactionsLastPage: unConTransactionsLastPage,
          unConTransactionsCurrentPage: unConTransactionsCurrentPage,
          mostSelledProductCategory: mostSelledProductCategory,
          last10ProductSelled: last10ProductSelled,
          pannelsStatus: pannelsStatus,
          financialSummary: financialSummary);
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
    debugPrint('getDashboardAnalytics: ${e.message}');
    return null;
  } catch (e) {
    debugPrint('getDashboardAnalytics parse error: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> getPanelDashboardStatus(int panelId) async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/getPanelDashboardStatus/$panelId',
      options: Options(
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 12),
        headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          'Content-Type': 'application/json;charset=UTF-8',
          'Charset': 'utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      ),
    );
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return null;
  } on DioException catch (e) {
    debugPrint('getPanelDashboardStatus($panelId): ${e.message}');
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

    AgentPermisson? permission;
    if (response.data["agentPermisson"] != null) {
      permission = AgentPermisson.fromMap(response.data["agentPermisson"]);
    }

    AgentLimitUsage? limitUsage;
    if (response.data["agentLimitUsage"] != null) {
      limitUsage = AgentLimitUsage.fromMap(
          Map<String, dynamic>.from(response.data["agentLimitUsage"]));
    }

    final agentDashboard = AgentDashboard(
        ballance: agentBallance,
        agentProducts: agentAddCategories,
        boughtProducts: null,
        logs: logs,
        permission: permission,
        limitUsage: limitUsage);
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
    res.add({
      "name": "swappay_payment_status",
      "status": response.data["swappay_payment_status"] ?? false
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

Future createNewAgentSwapPayBillUrl({required int amount}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/createNewAgentSwapPayBillUrl/$amount",
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
  // Open source: all features unlocked (gold).
  try {
    Response response = await GenaralApi.dio.get("/api/get-license-type",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*',
        }));
    if (response.statusCode == 200 && response.data != null) {
      final value = response.data.toString().trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return 'gold';
  } catch (e) {
    debugPrint(e.toString());
    return 'gold';
  }
}
