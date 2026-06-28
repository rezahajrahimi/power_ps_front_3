import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/styles/app_theme.dart';

class MarzbanInboundItem {
  final String protocol;
  final String tag;

  MarzbanInboundItem({required this.protocol, required this.tag});

  String get key => '${protocol.toLowerCase()}|$tag';

  String get label => '${protocol.toUpperCase()} · $tag';

  factory MarzbanInboundItem.fromKey(String key) {
    final parts = key.split('|');
    return MarzbanInboundItem(
      protocol: parts.first,
      tag: parts.sublist(1).join('|'),
    );
  }
}

Map<String, List<String>> parseMarzbanInboundsFromText(String text) {
  if (text.trim().isEmpty) return {};
  try {
    final decoded = jsonDecode(text);
    if (decoded is! Map) return {};
    final result = <String, List<String>>{};
    decoded.forEach((protocol, tags) {
      if (tags is! List) return;
      final normalizedTags = tags
          .map((t) => t.toString().trim())
          .where((t) => t.isNotEmpty)
          .toList();
      if (normalizedTags.isNotEmpty) {
        result[protocol.toString().toLowerCase()] = normalizedTags;
      }
    });
    return result;
  } catch (_) {
    return {};
  }
}

String formatMarzbanInboundsText(Map<String, List<String>> inbounds) {
  if (inbounds.isEmpty) return '';
  final sorted = Map.fromEntries(
    inbounds.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
  return jsonEncode(sorted);
}

Set<String> marzbanInboundKeysFromText(String text) {
  final map = parseMarzbanInboundsFromText(text);
  final keys = <String>{};
  map.forEach((protocol, tags) {
    for (final tag in tags) {
      keys.add('${protocol.toLowerCase()}|$tag');
    }
  });
  return keys;
}

Map<String, List<String>> marzbanInboundsFromKeys(Set<String> keys) {
  final result = <String, List<String>>{};
  for (final key in keys) {
    final item = MarzbanInboundItem.fromKey(key);
    result.putIfAbsent(item.protocol.toLowerCase(), () => []);
    if (!result[item.protocol.toLowerCase()]!.contains(item.tag)) {
      result[item.protocol.toLowerCase()]!.add(item.tag);
    }
  }
  return result;
}

Future<List<MarzbanInboundItem>?> fetchMarzbanInbounds(int pannelId) async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/syncMarzbanInbounds/$pannelId',
      options: Options(headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json;charset=UTF-8',
      }),
    );
    if (response.statusCode == 200 && response.data is Map) {
      final data = response.data as Map;
      if (data['success'] == true && data['inbounds'] is Map) {
        final inbounds = data['inbounds'] as Map;
        final items = <MarzbanInboundItem>[];
        inbounds.forEach((protocol, tags) {
          if (tags is! List) return;
          for (final tag in tags) {
            final tagStr = tag.toString().trim();
            if (tagStr.isEmpty) continue;
            items.add(MarzbanInboundItem(
              protocol: protocol.toString().toLowerCase(),
              tag: tagStr,
            ));
          }
        });
        items.sort((a, b) => a.label.compareTo(b.label));
        return items;
      }
    }
    return null;
  } on DioException catch (e) {
    debugPrint('fetchMarzbanInbounds: ${e.message}');
    return null;
  }
}

Future<void> showMarzbanInboundPicker(
  BuildContext context, {
  required int pannelId,
  required TextEditingController inboundsController,
  String panelLabel = 'Marzban',
}) async {
  EasyLoading.show(status: 'در حال دریافت Inboundها...');
  final inbounds = await fetchMarzbanInbounds(pannelId);
  EasyLoading.dismiss();
  if (!context.mounted) return;

  if (inbounds == null) {
    showMsg(
      msg: 'خطا در دریافت Inboundها. اتصال پنل را بررسی کنید.',
      context: context,
      type: 'error',
    );
    return;
  }

  if (inbounds.isEmpty) {
    showMsg(msg: 'Inbound فعالی در پنل یافت نشد.', context: context, type: 'error');
    return;
  }

  final initialSelected = marzbanInboundKeysFromText(inboundsController.text);

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      final selectedKeys = Set<String>.from(initialSelected);

      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            backgroundColor: AppStyle.secondaryColor,
            title: Text(
              'انتخاب Inboundهای $panelLabel',
              style: const TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: inbounds.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final item = inbounds[index];
                  final isSelected = selectedKeys.contains(item.key);

                  return CheckboxListTile(
                    value: isSelected,
                    activeColor: AppStyle.primaryColor,
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      item.label,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    onChanged: (checked) {
                      setDialogState(() {
                        if (checked == true) {
                          selectedKeys.add(item.key);
                        } else {
                          selectedKeys.remove(item.key);
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
                onPressed: selectedKeys.isEmpty
                    ? null
                    : () {
                        final map = marzbanInboundsFromKeys(selectedKeys);
                        inboundsController.text = formatMarzbanInboundsText(map);
                        Navigator.pop(ctx);
                        showMsg(
                          msg: '${selectedKeys.length} Inbound انتخاب شد.',
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

Future<void> runMarzbanInboundSync(
  BuildContext context, {
  required int pannelId,
  required TextEditingController inboundsController,
  String panelType = 'marzban',
}) {
  return showMarzbanInboundPicker(
    context,
    pannelId: pannelId,
    inboundsController: inboundsController,
    panelLabel: getMarzbanCompatiblePanelLabel(panelType),
  );
}
