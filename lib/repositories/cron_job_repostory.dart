import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/cron_job_model.dart';

Future getAllCronJobs() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getAllCronJobs",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    List<CronJobModel> cronJobsList = [];
    if (response.statusCode == 200 && response.data != null) {
      cronJobsList.clear();
      var data = response.data;
      for (var i in data) {
        cronJobsList.add(CronJobModel.fromMap(i));
      }

      return cronJobsList;
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
    debugPrint(e.toString());
    return null;
  }
}

Future<bool> changeCronJobActiveStatusById({required int id}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/changeCronJobActiveStatusById/$id",
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
    debugPrint(e.message.toString());
    return false;
  }
}

Future<List<Map<String, dynamic>>?> previewExpiredConfigsForDeletion() async {
  try {
    Response response = await GenaralApi.dio.get(
      "/api/preview-expired-configs-for-deletion",
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json;charset=UTF-8",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*'
      }),
    );
    if (response.statusCode == 200 &&
        response.data is Map &&
        response.data['success'] == true) {
      final items = response.data['items'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    if (e.response?.statusCode == 403) {
      return null;
    }
    return null;
  }
}

Future<Map<String, dynamic>?> deleteSelectedExpiredConfigs({
  required List<Map<String, dynamic>> items,
}) async {
  try {
    Response response = await GenaralApi.dio.post(
      "/api/delete-selected-expired-configs",
      data: {'items': items},
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json;charset=UTF-8",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*'
      }),
    );
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    if (e.response?.data is Map) {
      return Map<String, dynamic>.from(e.response!.data);
    }
    return null;
  }
}

