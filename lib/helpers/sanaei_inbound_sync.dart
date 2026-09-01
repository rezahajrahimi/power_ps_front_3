import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/repositories/hiddify_repository.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class SanaeiInboundItem {
  final int? id;
  final String remark;
  final String protocol;
  final int? port;

  SanaeiInboundItem({
    required this.id,
    required this.remark,
    required this.protocol,
    required this.port,
  });

  factory SanaeiInboundItem.fromJson(Map<String, dynamic> json) {
    return SanaeiInboundItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      remark: '${json['remark'] ?? json['tag'] ?? ''}',
      protocol: '${json['protocol'] ?? ''}',
      port: json['port'] is int ? json['port'] : int.tryParse('${json['port']}'),
    );
  }

  String get label {
    final parts = <String>[];
    if (id != null) parts.add('ID: $id');
    if (remark.isNotEmpty) parts.add(remark);
    if (protocol.isNotEmpty) parts.add(protocol);
    if (port != null) parts.add(':$port');
    return parts.join(' · ');
  }
}

/// Parses comma/semicolon/space-separated inbound IDs from text input.
List<int> parseInboundIdsFromText(String text) {
  if (text.trim().isEmpty) return [];
  return text
      .split(RegExp(r'[,; ]+'))
      .map((part) => int.tryParse(part.trim()))
      .whereType<int>()
      .toSet()
      .toList()
    ..sort();
}

String formatInboundIdsText(List<int> ids) {
  if (ids.isEmpty) return '';
  final sorted = List<int>.from(ids)..sort();
  return sorted.join(', ');
}

Future<List<SanaeiInboundItem>?> fetchSanaeiInbounds(int pannelId) async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/syncSanaeiInbounds/$pannelId',
      options: Options(headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json;charset=UTF-8',
      }),
    );
    if (response.statusCode == 200 && response.data is Map) {
      final data = response.data as Map;
      if (data['success'] == true && data['inbounds'] is List) {
        return (data['inbounds'] as List)
            .map((e) => SanaeiInboundItem.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }
    return null;
  } on DioException catch (e) {
    debugPrint('fetchSanaeiInbounds: ${e.message}');
    return null;
  }
}

Future<Map<String, dynamic>?> checkSanaeiPanelLoginStatus(int pannelId) async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/checkSanaeiLoginStatus/$pannelId',
      options: Options(headers: {'Accept': 'application/json'}),
    );
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    return null;
  } on DioException catch (e) {
    debugPrint('checkSanaeiPanelLoginStatus: ${e.message}');
    return null;
  }
}

Future<bool> refreshSanaeiPanelLogin(int pannelId) async {
  try {
    final response = await GenaralApi.dio.post(
      '/api/refreshSanaeiLogin/$pannelId',
      options: Options(headers: {'Accept': 'application/json'}),
    );
    if (response.statusCode == 200 && response.data is Map) {
      return response.data['success'] == true;
    }
    return false;
  } on DioException catch (e) {
    debugPrint('refreshSanaeiPanelLogin: ${e.message}');
    return false;
  }
}

/// Fetches inbounds from panel and shows multi-select picker dialog.
/// If [inboundIdController] is set, selected inbound ids are written as comma-separated text.
Future<void> showSanaeiInboundPicker(
  BuildContext context, {
  required int pannelId,
  TextEditingController? inboundIdController,
}) async {
  EasyLoading.show(status: 'در حال دریافت Inboundها...');
  final inbounds = await fetchSanaeiInbounds(pannelId);
  EasyLoading.dismiss();
  if (!context.mounted) return;

  if (inbounds == null) {
    showMsg(
      msg: 'خطا در دریافت Inboundها. اتصال پنل و API Token را بررسی کنید.',
      context: context,
      type: 'error',
    );
    return;
  }

  if (inbounds.isEmpty) {
    showMsg(msg: 'Inbound فعالی در پنل یافت نشد.', context: context, type: 'error');
    return;
  }

  final initialSelected = inboundIdController != null
      ? parseInboundIdsFromText(inboundIdController.text).toSet()
      : <int>{};

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
              'انتخاب Inboundها',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: inbounds.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final item = inbounds[index];
                  final itemId = item.id;
                  final isSelectable =
                      inboundIdController != null && itemId != null;
                  final isSelected =
                      itemId != null && selectedIds.contains(itemId);

                  return CheckboxListTile(
                    value: isSelected,
                    activeColor: AppStyle.primaryColor,
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      item.label,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    onChanged: isSelectable
                        ? (checked) {
                            setDialogState(() {
                              if (checked == true) {
                                selectedIds.add(itemId);
                              } else {
                                selectedIds.remove(itemId);
                              }
                            });
                          }
                        : null,
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('انصراف'),
              ),
              if (inboundIdController != null)
                ElevatedButton(
                  onPressed: selectedIds.isEmpty
                      ? null
                      : () {
                          inboundIdController.text =
                              formatInboundIdsText(selectedIds.toList());
                          Navigator.pop(ctx);
                          showMsg(
                            msg:
                                '${selectedIds.length} Inbound انتخاب شد: ${formatInboundIdsText(selectedIds.toList())}',
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

Future<void> runSanaeiInboundSync(
  BuildContext context, {
  required int pannelId,
  TextEditingController? inboundIdController,
}) {
  return showSanaeiInboundPicker(
    context,
    pannelId: pannelId,
    inboundIdController: inboundIdController,
  );
}

Future<void> runSanaeiRefreshLogin(BuildContext context, int pannelId) async {
  EasyLoading.show(status: 'در حال بروزرسانی session...');
  final ok = await refreshSanaeiPanelLogin(pannelId);
  EasyLoading.dismiss();
  if (!context.mounted) return;
  showMsg(
    msg: ok ? 'Session پنل با موفقیت بروزرسانی شد.' : 'بروزرسانی session ناموفق بود.',
    context: context,
    type: ok ? 'info' : 'error',
  );
}

Future<void> runSanaeiLoginStatusCheck(BuildContext context, int pannelId) async {
  EasyLoading.show(status: 'در حال بررسی وضعیت...');
  final status = await checkSanaeiPanelLoginStatus(pannelId);
  EasyLoading.dismiss();
  if (!context.mounted) return;

  if (status == null) {
    showMsg(msg: 'بررسی وضعیت ناموفق بود.', context: context, type: 'error');
    return;
  }

  final connected = status['success'] == true;
  final version = status['api_version'] ?? 'نامشخص';
  final hasToken = status['has_token'] == true;
  showMsg(
    msg: connected
        ? 'اتصال OK · API: $version · Token: ${hasToken ? "دارد" : "ندارد"}'
        : 'اتصال به پنل برقرار نیست.',
    context: context,
    type: connected ? 'info' : 'error',
  );
}

/// Shared action buttons for Sanaei panel add/edit forms.
class SanaeiPanelActionButtons extends StatelessWidget {
  final int? pannelId;
  final TextEditingController adminUrlController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController? apiTokenController;
  final TextEditingController? inboundIdController;
  final String Function(String url) normalizeUrl;
  final String? apiVersion;

  const SanaeiPanelActionButtons({
    super.key,
    this.pannelId,
    required this.adminUrlController,
    required this.usernameController,
    required this.passwordController,
    this.apiTokenController,
    this.inboundIdController,
    required this.normalizeUrl,
    this.apiVersion,
  });

  Future<void> _checkLogin(BuildContext context) async {
    final adminUrl = adminUrlController.text;
    final username = usernameController.text;
    final password = passwordController.text;
    final apiToken = apiTokenController?.text;
    if (adminUrl.isEmpty || username.isEmpty || password.isEmpty) {
      showMsg(
        msg: 'لطفاً آدرس، نام کاربری و رمز را وارد کنید.',
        context: context,
        type: 'error',
      );
      return;
    }
    EasyLoading.show();
    final ok = await checkSanaeiLogin(
      url: normalizeUrl(adminUrl),
      username: username,
      password: password,
      apiToken: apiToken?.trim().isEmpty ?? true ? null : apiToken!.trim(),
      apiVersion: apiVersion,
    );
    EasyLoading.dismiss();
    if (!context.mounted) return;
    showMsg(
      msg: ok
          ? 'موفق، اطلاعات وارد شده صحیح است.'
          : (lastPannelAddError.isNotEmpty
              ? lastPannelAddError
              : 'ناموفق، اطلاعات را بررسی کنید.'),
      context: context,
      type: ok ? 'info' : 'error',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: () => _checkLogin(context),
          icon: const Icon(Icons.checklist_rtl),
          label: const Text('بررسی لینک'),
        ),
        if (pannelId != null) ...[
          ElevatedButton.icon(
            onPressed: () => runSanaeiInboundSync(
              context,
              pannelId: pannelId!,
              inboundIdController: inboundIdController,
            ),
            icon: const Icon(Icons.sync),
            label: const Text('همگام‌سازی Inbound'),
          ),
          ElevatedButton.icon(
            onPressed: () => runSanaeiRefreshLogin(context, pannelId!),
            icon: const Icon(Icons.refresh),
            label: const Text('بروزرسانی Session'),
          ),
          OutlinedButton.icon(
            onPressed: () => runSanaeiLoginStatusCheck(context, pannelId!),
            icon: const Icon(Icons.info_outline),
            label: const Text('وضعیت API'),
          ),
        ],
      ],
    );
  }
}
