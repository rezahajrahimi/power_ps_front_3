import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/agent_limit_usage_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';

Future resetAgentLimitUsage({required int userId}) async {
  try {
    final response = await GenaralApi.dio.post(
      "/api/resetAgentLimitUsage/$userId",
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json;charset=UTF-8",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*',
      }),
    );

    if (response.statusCode == 200 && response.data != null) {
      return AgentLimitUsage.fromMap(
          Map<String, dynamic>.from(response.data));
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.error.toString());
    return null;
  }
}

Future getUserPremissionByAgentID({required int userID}) async {
  try {
    Response response =
        await GenaralApi.dio.get("/api/getUserPremissionByAgentID/$userID",
            options: Options(headers: {
              'Accept': 'application/json',
              'Connection': 'keep-alive',
              "Content-Type": "application/json;charset=UTF-8",
              "Charset": "utf-8",
              'Access-Control-Allow-Origin': '*'
            }));

    if (response.statusCode == 200) {
      AgentPermisson agentPermisson = AgentPermisson.fromMap(response.data);
      return agentPermisson;
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
    debugPrint(e.error.toString());
    return false;
  }
}
