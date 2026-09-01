import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/models/bot_user_model.dart';

List<ProductDetails> productDetailsList = [];
int lastPageOfUserBought = 1;
List<ProductDetails> userBoughtProductList = [];
String productChangedToken = "aa";
ChangeProductController productNotifier = ChangeProductController(0);

class ChangeProductController extends ValueNotifier {
  ChangeProductController(super.value);
  void changedProductData() {
    value = productChangedToken;
  }
}

Future getActiveProductsByProductCatID(
    {required int productCategoryypeID}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getActiveProductsByProductCatID/$productCategoryypeID",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200) {
      productDetailsList.clear();
      var data = response.data;
      for (var i in data) {
        productDetailsList.add(ProductDetails.fromJson(i));
      }

      return true;
    } else if (response.statusCode == 201) {
      return false;
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

Future addNewProductDetails({
  required int productCatID,
  required String configs,
  required String subscriptionLink,
  required String panelLink,
}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/addNewProductDetails",
        data: {
          "product_categories_id": productCatID,
          "configs": configs,
          "subscription_link": subscriptionLink,
          "panel_link": panelLink,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    if (response.statusCode == 200 && response.data != null) {
      productDetailsList.clear();
      var data = response.data;
      for (var i in data) {
        productDetailsList.add(ProductDetails.fromJson(i));
      }

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

Future deleteProductDetails({required int id}) async {
  try {
    Response response = await GenaralApi.dio.get("/api/deleteProduct/$id",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    if (response.statusCode == 200) {
      productDetailsList.clear();
      var data = response.data;
      for (var i in data) {
        productDetailsList.add(ProductDetails.fromJson(i));
      }
      return true;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future getLastBuyersByCatIdAndCount(
    {required int catID, required int count}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getLastBuyersByCatIdAndCount/$catID/$count",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));
    if (response.statusCode == 200) {
      List<BotUser> userList = [];
      var data = response.data;
      for (var i in data) {
        ProductDetails pd = ProductDetails.fromJson(i);

        if (pd.botUser != null) {
          userList.add(BotUser(
              accountId:
                  BigInt.from(int.parse(i["user"]["account_id"].toString())),
              createdAt: i["user"]["created_at"] ?? "",
              firstName: i["user"]["first_name"] ?? "",
              id: BigInt.from(int.parse(i["user"]["id"].toString())),
              lastName: i["user"]["last_name"] ?? "",
              updatedAt: i["user"]["updated_at"] ?? "",
              username: i["user"]["username"] ?? ""));
        }
      }
      return userList;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future getUserProductsHistoryByAccountIDWithPagination(
    {required int userID, int page = 1}) async {
  try {
    Response response = await GenaralApi.dio.get(
        "/api/getUserProductsHistoryByUserIDWithPagination/$userID?page=$page",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200) {
      var data = response.data["data"];
      lastPageOfUserBought = response.data["last_page"];

      userBoughtProductList.clear();
      for (var i in data) {
        userBoughtProductList.add(ProductDetails.fromJson(i));
      }
      return userBoughtProductList;
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

Future<bool> checkAProductHasReservedConfigByProductId(
    {required int productID}) async {
  try {
    Response response = await GenaralApi.dio
        .post("/api/checkAProductHasReservedConfigByProductId",
            data: {"product_id": productID},
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}
