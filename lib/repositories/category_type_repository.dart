import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/category_type_model.dart';

Future<List<CategoryTypeModel>> getAllCategoryType() async {
  try {
    Response response = await GenaralApi.dio.get("/api/get-all-category-types",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    List<CategoryTypeModel> categoryTypeList = [];

    if (response.statusCode == 200 && response.data != null) {
      var data = response.data;
      for (var i in data) {
        categoryTypeList.add(CategoryTypeModel.fromMap(i));
      }
      // transactionChangedToken = "transactionChanged";

      // transactionNotifier.changedTransactionLockData();
      return categoryTypeList;
    } else {
      return categoryTypeList;
    }
  } on DioException catch (e) {
    List<CategoryTypeModel> categoryTypeList = [];

    debugPrint(e.message.toString());
    return categoryTypeList;
  }

}
  Future<bool> deleteCategoryType(int categoryTypeId) async {
    try {
      Response response = await GenaralApi.dio.delete("/api/delete-category-type/$categoryTypeId",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    if (response.statusCode == 200 && response.data != null) {
      return true;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
  Future<bool> updateCategoryType({required int categoryTypeId, required String name,
  required bool isActive,
  }) async {
    try {
      Response response = await GenaralApi.dio.put("/api/update-category-type",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }),
        data: {
          "id": categoryTypeId,
          "name": name,
          "is_active": isActive,
        });
    if (response.statusCode == 200 && response.data != null) {
      debugPrint(response.data.toString());
      return true;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
  Future<bool> addCategoryType({required String name,
  required bool isActive,
  }) async {
    try {
      Response response = await GenaralApi.dio.post("/api/create-category-type",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }),
        data: {
          "name": name,
          "is_active": isActive,
        });
    if (response.statusCode == 200 && response.data != null) {
      debugPrint(response.data.toString());
      return true;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

    
  
