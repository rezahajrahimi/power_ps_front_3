import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/product_category_model.dart';

List<ProductCategory> productCategoryList = [];
Future getAllProdctCategory() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getAllProdctCategory",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200) {
      productCategoryList.clear();
      var data = response.data;
      debugPrint("API Response: $data");
      for (var i in data) {
        debugPrint("Product item: $i");
        productCategoryList.add(ProductCategory.fromMap(i));
      }

      return productCategoryList;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message);
    return false;
  }
}

Future addNewProductCategory({
  required String name,
  required int price,
  required double priceInDollar,
  required int pannelID,
  // required int categoryTypeId,
  required int expDay,
  required int volume,
  required bool rechargable,
  required bool showPannelLink,
  required bool showSubscriptionLink,
  required bool sendConfigToUser,
  List<int>? allowedUserGroupIds,
  int? inboundId,
  int? ipLimit,
  String? sampleInbound,
  int? upsellCategoryId,
}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/addNewProductCategory",
        data: {
          "category_name": name,
          "price": price,
          "price_in_dollar": priceInDollar,
          "pannel_id": pannelID,
          // "category_type_id": categoryTypeId,
          "expire_day": expDay,
          "volume": volume,
          "rechargable": rechargable,
          "show_pannel_link": showPannelLink,
          "show_subscription_link": showSubscriptionLink,
          "send_config_to_user": sendConfigToUser,
          "allowed_user_group_ids": allowedUserGroupIds ?? [],
          "inbound_id": inboundId,
          "ip_limit": ipLimit,
          "sample_inbound": sampleInbound,
          "upsell_category_id": upsellCategoryId,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      productCategoryList.clear();
      var data = response.data;
      for (var i in data) {
        productCategoryList.add(ProductCategory.fromMap(i));
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

Future<bool> editProductCategory({
  required String name,
  required int id,
  required int price,
  required double priceInDollar,
  required int pannelID,
  required int expDay,
  required int volume,
  required bool rechargable,
  required bool showPannelLink,
  required bool showSubscriptionLink,
  required bool sendConfigToUser,
  required bool isActive,
  List<int>? allowedUserGroupIds,
  int? inboundId,
  int? ipLimit,
  String? sampleInbound,
  int? upsellCategoryId,
}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/editProductCategory",
        data: {
          "category_name": name,
          "price": price,
          "price_in_dollar": priceInDollar,
          "pannel_id": pannelID,
          "expire_day": expDay,
          "volume": volume,
          "rechargable": rechargable,
          "show_pannel_link": showPannelLink,
          "show_subscription_link": showSubscriptionLink,
          "send_config_to_user": sendConfigToUser,
          'is_active': isActive,
          "id": id,
          "allowed_user_group_ids": allowedUserGroupIds ?? [],
          "inbound_id": inboundId,
          "ip_limit": ipLimit,
          "sample_inbound": sampleInbound,
          "upsell_category_id": upsellCategoryId,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      debugPrint("Edit response: ${response.data}");
      productCategoryList.clear();
      var data = response.data;
      for (var i in data) {
        debugPrint("Updated product: $i");
        productCategoryList.add(ProductCategory.fromMap(i));
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

Future reActiveProductCategory({required int id}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/reActiveProductCategory/$id",
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

Future deActiveProductCategory({required int id}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/deActiveProductCategory/$id",
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

Future getCountOfProductSelledSummeryByCatID({required int id}) async {
  try {
    Response response = await GenaralApi.dio
        .get("/api/getCountOfProductSelledSummeryByCatID/$id",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));
    if (response.statusCode == 200) {
      return response.data;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future deleteProductCategoryByID({required int id}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/deleteProductCategoryByID/$id",
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

Future updatePricesByyTether() async {
  try {
    Response response = await GenaralApi.dio.post("/api/updatePricesByyTether",
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

Future updatePricesByTether() async {
  try {
    Response response = await GenaralApi.dio.post("/api/updatePricesByTether",
        options: Options(headers: {
          "Accept": "application/json",
          "Connection": "keep-alive",
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          "Access-Control-Allow-Origin": "*"
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
