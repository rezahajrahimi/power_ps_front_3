import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/bot_button_config_model.dart';

class BotButtonConfigResult {
  final BotButtonConfig? config;
  final String? errorMessage;
  final int? statusCode;

  const BotButtonConfigResult({
    this.config,
    this.errorMessage,
    this.statusCode,
  });

  bool get isSuccess => config != null;
}

Future<BotButtonConfigResult> getBotButtonConfig() async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/get-bot-button-config',
      options: Options(headers: _headers()),
    );

    if (response.statusCode == 200 && response.data is Map) {
      final map = Map<String, dynamic>.from(response.data as Map);
      if (map.containsKey('reply_buttons_per_row')) {
        return BotButtonConfigResult(
          config: BotButtonConfig.fromJson(map),
          statusCode: response.statusCode,
        );
      }
    }

    final message = response.data is Map
        ? response.data['message']?.toString()
        : null;

    return BotButtonConfigResult(
      errorMessage: message ?? 'خطا در دریافت تنظیمات دکمه‌ها',
      statusCode: response.statusCode,
    );
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return BotButtonConfigResult(
      errorMessage: e.message ?? 'خطا در ارتباط با سرور',
      statusCode: e.response?.statusCode,
    );
  } catch (e) {
    debugPrint(e.toString());
    return BotButtonConfigResult(errorMessage: 'خطای غیرمنتظره در بارگذاری');
  }
}

Future<BotButtonConfig?> updateBotButtonLayout(
    Map<String, dynamic> payload) async {
  try {
    final response = await GenaralApi.dio.post(
      '/api/update-bot-button-layout',
      data: payload,
      options: Options(headers: _headers()),
    );

    if (response.statusCode == 200 && response.data is Map) {
      return BotButtonConfig.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<BotButtonConfig?> updateBotButtonStyleRules(
    List<BotButtonStyleRule> rules) async {
  try {
    final response = await GenaralApi.dio.post(
      '/api/update-bot-button-style-rules',
      data: {
        'style_rules': rules.map((e) => e.toJson()).toList(),
      },
      options: Options(headers: _headers()),
    );

    if (response.statusCode == 200 && response.data is Map) {
      return BotButtonConfig.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<bool> updateMainMenuButtonStyle({
  required String name,
  String? buttonStyle,
  String? iconCustomEmojiId,
  bool? soloRow,
}) async {
  try {
    final response = await GenaralApi.dio.post(
      '/api/update-main-menu-button-style',
      data: {
        'name': name,
        'button_style': buttonStyle,
        'icon_custom_emoji_id': iconCustomEmojiId,
        'solo_row': soloRow,
      },
      options: Options(headers: _headers()),
    );

    return response.statusCode == 200;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Map<String, String> _headers() => {
      'Accept': 'application/json',
      'Connection': 'keep-alive',
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8',
      'Access-Control-Allow-Origin': '*',
    };
