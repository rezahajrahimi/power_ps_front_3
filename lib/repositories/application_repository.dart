import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/application_model.dart';

String applicationChangedToken = "aa";
ChangeApplicationController applicationNotifier =
    ChangeApplicationController(0);

class ChangeApplicationController extends ValueNotifier {
  ChangeApplicationController(super.value);
  void changedApplicationtData() {
    value = applicationChangedToken;
  }
}

Future<List<Application>?> getAllAplicationList() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getAllAplicationList",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    List<Application> applications = [];

    if (response.statusCode == 200 && response.data != null) {
      for (var i in response.data) {
        applications.add(Application.fromJson(i));
      }

      return applications;
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

Future<List<Application>?> getAllActiveAplicationList() async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/getAllActiveAplicationList",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));
    List<Application> applications = [];

    if (response.statusCode == 200 && response.data != null) {
      for (var i in response.data) {
        applications.add(Application.fromJson(i));
      }

      return applications;
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

Future<List<Application>?> getAllActiveAplicationListByOS(
    {required String os}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/getAllActiveAplicationListByOS/$os",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));
    List<Application> applications = [];

    if (response.statusCode == 200 && response.data != null) {
      for (var i in response.data) {
        applications.add(Application.fromJson(i));
      }

      return applications;
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

Future<Application?> getActiveAplicationByName({required String name}) async {
  Application? application;

  try {
    Response response =
        await GenaralApi.dio.get("/api/getActiveAplicationByName/$name",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      application = Application.fromJson(response.data);

      return application;
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

Future<Application?> getActiveAplicationByID({required int id}) async {
  Application? application;

  try {
    Response response =
        await GenaralApi.dio.get("/api/getActiveAplicationByID/$id",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200 && response.data != null) {
      application = Application.fromJson(response.data);

      return application;
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

Future<bool> deleteApplication({required int id}) async {
  try {
    Response response =
        await GenaralApi.dio.delete("/api/deleteApplication/$id",
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
    debugPrint(e.message);
    return false;
  }
}

Future<bool> createNewApplication({required Application application}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/createNewApplication",
        data: {
          "name": application.name,
          "download_link": application.downloadLink,
          "os": application.os,
          "how_to_use": application.howToUse,
          "youtube_link": application.youtubeLink,
          "is_active": application.isActive,
          "description": application.description,
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
    debugPrint(e.message);
    return false;
  }
}

Future<bool> updateApplication({required Application application}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/updateApplication",
        data: {
          "id": application.id,
          "name": application.name,
          "download_link": application.downloadLink,
          "os": application.os,
          "how_to_use": application.howToUse,
          "youtube_link": application.youtubeLink,
          "is_active": application.isActive,
          "description": application.description,
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
    debugPrint(e.message);
    return false;
  }
}
