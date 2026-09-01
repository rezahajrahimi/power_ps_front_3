import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/service_type_model.dart';

List<ServiceType> serviceTypeList = [];
Future getServiceTypies() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getServiceTypes",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));
    if (response.statusCode == 200) {
      serviceTypeList.clear();
      var data = response.data;
      for (var i in data) {
        serviceTypeList.add(ServiceType.fromJson(i));
        debugPrint(i.toString());
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
