import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/styles/app_theme.dart';

class PasarguardGroupItem {
  final int id;
  final String name;
  final List<String> inboundTags;

  PasarguardGroupItem({
    required this.id,
    required this.name,
    required this.inboundTags,
  });

  String get label {
    if (inboundTags.isEmpty) {
      return '$name (#$id)';
    }
    return '$name · ${inboundTags.length} inbound';
  }

  String get subtitle => inboundTags.isEmpty
      ? 'بدون inbound'
      : inboundTags.take(3).join('، ');
}

List<int> parsePasarguardGroupIdsFromText(String text) {
  if (text.trim().isEmpty) return [];
  try {
    final decoded = jsonDecode(text);
    if (decoded is List) {
      return decoded
          .map((v) => int.tryParse(v.toString()))
          .whereType<int>()
          .toList();
    }
  } catch (_) {}

  return text
      .split(RegExp(r'[,; ]+'))
      .map((part) => int.tryParse(part.trim()))
      .whereType<int>()
      .toList();
}

String formatPasarguardGroupIdsText(List<int> ids) {
  if (ids.isEmpty) return '';
  final sorted = List<int>.from(ids)..sort();
  return jsonEncode(sorted);
}

Set<int> pasarguardGroupIdsFromText(String text) {
  return parsePasarguardGroupIdsFromText(text).toSet();
}

class PasarguardGroupsFetchResult {
  final List<PasarguardGroupItem>? groups;
  final String? error;

  const PasarguardGroupsFetchResult({this.groups, this.error});

  bool get isSuccess => groups != null;
}

Future<PasarguardGroupsFetchResult> fetchPasarguardGroups(int pannelId) async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/syncPasarguardGroups/$pannelId',
      options: Options(headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json;charset=UTF-8',
      }),
    );

    if (response.data is Map) {
      final data = Map<String, dynamic>.from(response.data as Map);

      if (data['success'] == true && data['groups'] is List) {
        final groups = data['groups'] as List;
        final items = <PasarguardGroupItem>[];
        for (final raw in groups) {
          if (raw is! Map) continue;
          final id = int.tryParse(raw['id']?.toString() ?? '');
          if (id == null) continue;
          final tags = (raw['inbound_tags'] as List? ?? [])
              .map((t) => t.toString().trim())
              .where((t) => t.isNotEmpty)
              .toList();
          items.add(PasarguardGroupItem(
            id: id,
            name: raw['name']?.toString() ?? 'Group $id',
            inboundTags: tags,
          ));
        }
        items.sort((a, b) => a.name.compareTo(b.name));
        return PasarguardGroupsFetchResult(groups: items);
      }

      final msg = data['msg']?.toString();
      if (msg != null && msg.isNotEmpty) {
        return PasarguardGroupsFetchResult(error: msg);
      }
    }

    if (response.statusCode == 404) {
      return const PasarguardGroupsFetchResult(
        error:
            'مسیر API یافت نشد. روی سرور دستور php artisan route:clear را اجرا کنید.',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      return const PasarguardGroupsFetchResult(
        error: 'دسترسی غیرمجاز. لطفاً دوباره وارد پنل ادمین شوید.',
      );
    }

    return PasarguardGroupsFetchResult(
      error: 'خطا در دریافت گروه‌ها (کد ${response.statusCode})',
    );
  } on DioException catch (e) {
    debugPrint('fetchPasarguardGroups: ${e.message}');
    final data = e.response?.data;
    if (data is Map && data['msg'] != null) {
      return PasarguardGroupsFetchResult(error: data['msg'].toString());
    }
    return PasarguardGroupsFetchResult(
      error: e.message ?? 'خطا در اتصال به سرور',
    );
  }
}

Future<void> showPasarguardGroupPicker(
  BuildContext context, {
  required int pannelId,
  required TextEditingController groupIdsController,
}) async {
  EasyLoading.show(status: 'در حال دریافت گروه‌ها...');
  final result = await fetchPasarguardGroups(pannelId);
  EasyLoading.dismiss();
  if (!context.mounted) return;

  if (!result.isSuccess) {
    showMsg(
      msg: result.error ?? 'خطا در دریافت گروه‌ها. اتصال پنل را بررسی کنید.',
      context: context,
      type: 'error',
    );
    return;
  }

  final groups = result.groups ?? [];
  if (groups.isEmpty) {
    showMsg(msg: 'گروه فعالی در پنل یافت نشد.', context: context, type: 'error');
    return;
  }

  final initialSelected = pasarguardGroupIdsFromText(groupIdsController.text);

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      final selectedIds = Set<int>.from(initialSelected);

      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            backgroundColor: AppStyle.secondaryColor,
            title: const Text(
              'انتخاب گروه‌های PasarGuard',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: groups.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final item = groups[index];
                  final isSelected = selectedIds.contains(item.id);

                  return CheckboxListTile(
                    value: isSelected,
                    activeColor: AppStyle.primaryColor,
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      item.label,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                    onChanged: (checked) {
                      setDialogState(() {
                        if (checked == true) {
                          selectedIds.add(item.id);
                        } else {
                          selectedIds.remove(item.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: selectedIds.isEmpty
                    ? null
                    : () {
                        final sorted = selectedIds.toList()..sort();
                        groupIdsController.text =
                            formatPasarguardGroupIdsText(sorted);
                        Navigator.pop(ctx);
                        showMsg(
                          msg: '${selectedIds.length} گروه انتخاب شد.',
                          context: context,
                        );
                      },
                child: const Text('تأیید انتخاب'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> runPasarguardGroupSync(
  BuildContext context, {
  required int pannelId,
  required TextEditingController groupIdsController,
}) {
  return showPasarguardGroupPicker(
    context,
    pannelId: pannelId,
    groupIdsController: groupIdsController,
  );
}
