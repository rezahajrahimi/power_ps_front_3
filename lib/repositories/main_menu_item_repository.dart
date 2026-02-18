import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/main_menu_item_model.dart';

List<MainMenuItem> mainMenuItemsList = [];
String menuChangedToken = "aa";
ChangeMenuItemController menuItemNotifier = ChangeMenuItemController(0);

class ChangeMenuItemController extends ValueNotifier {
  ChangeMenuItemController(super.value);
  void changedMenuData() {
    value = menuChangedToken;
  }
}

Future getAllMainMenuItems() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getAllMainMenuItems",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      mainMenuItemsList.clear();
      var data = response.data;
      for (var i in data) {
        mainMenuItemsList.add(MainMenuItem.fromJson(i));
      }

      return mainMenuItemsList;
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

Future<bool> deActiveMainMenuItem({required String name}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/deActiveMainMenuItem/$name",
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
    return false;
  }
}

Future<bool> reActiveMainMenuItem({required String name}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/reActiveMainMenuItem/$name",
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
    return false;
  }
}

Future<bool> changeMainMenuAliasName(
    {required String oldName, required String newName}) async {
  try {
    Response response =
        await GenaralApi.dio.post("/api/changeMainMenuAliasName",
            data: {"oldName": oldName, "newName": newName},
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
    return false;
  }
}

Future<bool> updateMainMenuItems(List<MainMenuItem> items) async {
  try {
    Response response = await GenaralApi.dio.post("/api/reorder-main-menu-items",
        data: {"items": items.map((e) => e.toMap()).toList()},
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
  }  catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
