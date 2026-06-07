import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/models/proxy_model.dart';

List<Pannel> pannelList = [];
String pannelChangedToken = "aa";
int lastPannelID = 0;
ChangePannelController pannelNotifier = ChangePannelController(0);

class ChangePannelController extends ValueNotifier {
  ChangePannelController(super.value);
  void changedPannelData() {
    value = pannelChangedToken;
  }
}

Future getPannels() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getPannels",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      pannelList.clear();
      var data = response.data;
      for (var i in data) {
        pannelList.add(Pannel.fromJson(i));
      }

      return pannelList;
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

Future<bool> addNewPannel({required Pannel pannel}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/addNewPannel",
        data: {
          "type": pannel.type,
          "username": pannel.username,
          "password": pannel.password,
          "token": pannel.token,
          "location": pannel.location,
          "url_port": pannel.urlPort,
          "sub_port": pannel.subPort,
          "admin_url": pannel.adminUrl,
          "user_link": pannel.userLink,
          "secret_code": pannel.secretCode,
          "capacity": pannel.capacity,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 201) {
      lastPannelID = response.data;
      return true;
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

Future<bool> addNewPannelMarzban({
  required Pannel pannel,
  required List<Map<String, dynamic>> dynamicInbounds,
}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/addNewPannelMarzban",
        data: {
          "type": pannel.type,
          "username": pannel.username,
          "password": pannel.password,
          "token": pannel.token,
          "location": pannel.location,
          "url_port": pannel.urlPort,
          "capacity": pannel.capacity,
          "dynamic_inbounds": dynamicInbounds,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 201) {
      lastPannelID = response.data;
      return true;
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

Future<bool> editMarzbanPannel({
  required Pannel pannel,
  required List<Map<String, dynamic>> dynamicInbounds,
}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/editMarzbanPannel",
        data: {
          "id": int.parse(pannel.id),
          "username": pannel.username,
          "password": pannel.password,
          "token": pannel.token,
          "location": pannel.location,
          "url_port": pannel.urlPort,
          "capacity": pannel.capacity,
          "dynamic_inbounds": dynamicInbounds,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 201) {
      lastPannelID = response.data;
      return true;
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

Future updatePannel({required Pannel pannel}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/updatePannel",
        data: {
          "id": int.parse(pannel.id),
          "type": pannel.type,
          "username": pannel.username,
          "password": pannel.password,
          "token": pannel.token,
          "location": pannel.location,
          "url_port": pannel.urlPort,
          "sub_port": pannel.subPort,
          "admin_url": pannel.adminUrl,
          "user_link": pannel.userLink,
          "secret_code": pannel.secretCode,
          "capacity": pannel.capacity,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    debugPrint(response.statusMessage);

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

Future<bool> deletePannel({required int pannelId}) async {
  try {
    Response response = await GenaralApi.dio.get("/api/deletePannel/$pannelId",
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
      return false;
    } else if (response.statusCode == 500) {
      debugPrint(response.statusMessage);

      return false;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future getPannelById({required int pannelId}) async {
  try {
    Response response = await GenaralApi.dio.get("/api/getPannelById/$pannelId",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      Pannel pannel = Pannel.fromJson(response.data);
      return pannel;
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

Future<List<Proxy>> getProxiesByPannelID({required int pannelId}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/getProxiesByPannelID/$pannelId",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      final List<Proxy> proxies = [];
      final raw = response.data;
      if (raw is List) {
        for (final item in raw) {
          if (item is! Map) continue;
          try {
            proxies.add(
              Proxy.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (e) {
            debugPrint("getProxiesByPannelID parse error: $e");
          }
        }
      }
      return proxies;
    }

    return [];
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return [];
  } catch (e, st) {
    debugPrint("getProxiesByPannelID error: $e\n$st");
    return [];
  }
}
