import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/web_app_menu_item_model.dart';

List<WebAPPMenuItemModel> defaultWebAppMenuItems() {
  const defaults = [
    {
      'key': 'buy_subscription',
      'title': 'خرید اشتراک',
      'subtitle': 'خرید کانفیگ جدید',
      'is_active': true,
      'position': 1,
    },
    {
      'key': 'subscription_history',
      'title': 'سابقه خرید',
      'subtitle': 'مشاهده کانفیگ های خریداری شده',
      'is_active': true,
      'position': 2,
    },
    {
      'key': 'wallet',
      'title': 'کیف پول',
      'subtitle': 'مشاهده موجودی حساب و افزایش آن',
      'is_active': true,
      'position': 3,
    },
    {
      'key': 'how_to_use',
      'title': 'آموزش استفاده',
      'subtitle': 'نحوه استفاده و سوالات متداول',
      'is_active': true,
      'position': 4,
    },
    {
      'key': 'support',
      'title': 'پشتیبانی',
      'subtitle': 'ارتباط با پشتیبان',
      'is_active': true,
      'position': 5,
    },
    {
      'key': 'trial_account',
      'title': 'اکانت آزمایشی',
      'subtitle': 'دریافت اکانت آزمایشی',
      'is_active': true,
      'position': 6,
    },
    {
      'key': 'gift_card',
      'title': 'گیفت کارت',
      'subtitle': 'ثبت کد گیفت کارت',
      'is_active': true,
      'position': 7,
    },
    {
      'key': 'app_download',
      'title': 'دانلود برنامه',
      'subtitle': 'دانلود اپلیکیشن‌های مورد نیاز',
      'is_active': true,
      'position': 8,
    },
    {
      'key': 'referral',
      'title': 'کسب درآمد',
      'subtitle': 'دریافت لینک دعوت',
      'is_active': true,
      'position': 9,
    },
  ];

  return defaults
      .map((item) => WebAPPMenuItemModel.fromMap({
            'id': 0,
            ...item,
          }))
      .toList();
}

Future<List<WebAPPMenuItemModel>> getAllActiveWebAppMenuItems({
  void Function(bool usedFallback)? onMeta,
}) async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/getAllActiveWebAppMenuItems',
      options: Options(
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          'Content-Type': 'application/json;charset=UTF-8',
          'Charset': 'utf-8',
        },
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        onMeta?.call(false);
        return data
            .map((item) =>
                WebAPPMenuItemModel.fromMap(Map<String, dynamic>.from(item)))
            .where((item) => item.isActive)
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));
      }
    }
  } on DioException catch (e) {
    debugPrint('getAllActiveWebAppMenuItems: ${e.message}');
  } catch (e) {
    debugPrint('getAllActiveWebAppMenuItems: $e');
  }

  onMeta?.call(true);
  return defaultWebAppMenuItems();
}
