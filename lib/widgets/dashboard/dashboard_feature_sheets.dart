import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/application_model.dart';
import 'package:powerps/models/faq_model.dart';
import 'package:powerps/models/support_model.dart';
import 'package:powerps/repositories/webapp_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardFeatureSheets {
  static Future<void> showFaqSheet(BuildContext context) async {
    EasyLoading.show();
    final faqs = await getWebAppFaqs();
    EasyLoading.dismiss();
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyle.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SheetScaffold(
        title: 'آموزش و سوالات متداول',
        child: faqs.isEmpty
            ? const _EmptyState(message: 'سوالی ثبت نشده است.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: faqs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) => _FaqTile(faq: faqs[index]),
              ),
      ),
    );
  }

  static Future<void> showSupportSheet(BuildContext context) async {
    EasyLoading.show();
    final supports = await getWebAppSupports();
    EasyLoading.dismiss();
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyle.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SheetScaffold(
        title: 'پشتیبانی',
        child: supports.isEmpty
            ? const _EmptyState(message: 'راه ارتباطی ثبت نشده است.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: supports.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) =>
                    _SupportTile(support: supports[index]),
              ),
      ),
    );
  }

  static Future<void> showAppDownloadSheet(BuildContext context) async {
    EasyLoading.show();
    final oses = await getWebAppApplicationOses();
    EasyLoading.dismiss();
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyle.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AppDownloadSheet(oses: oses),
    );
  }

  static Future<void> showGiftCardSheet(
    BuildContext context, {
    VoidCallback? onSuccess,
  }) async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyle.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppStyle.defaultPadding,
          right: AppStyle.defaultPadding,
          top: AppStyle.defaultPadding,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppStyle.defaultPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ثبت گیفت کارت',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'کد گیفت کارت خود را وارد کنید تا موجودی حساب شما افزایش یابد.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'کد گیفت کارت',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final code = controller.text.trim();
                if (code.isEmpty) {
                  showMsg(
                    msg: 'کد را وارد کنید.',
                    context: ctx,
                    type: 'error',
                  );
                  return;
                }
                EasyLoading.show();
                final result = await redeemWebAppGiftCard(code);
                EasyLoading.dismiss();
                if (!ctx.mounted) return;
                final success = result['success'] == true;
                showMsg(
                  msg: result['message']?.toString() ?? 'خطا',
                  context: ctx,
                  type: success ? 'info' : 'error',
                );
                if (success) {
                  Navigator.pop(ctx);
                  onSuccess?.call();
                }
              },
              icon: const Icon(Icons.redeem),
              label: const Text('ثبت کد'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  static Future<void> showReferralSheet(BuildContext context) async {
    EasyLoading.show();
    final info = await getWebAppReferralInfo();
    EasyLoading.dismiss();
    if (!context.mounted) return;

    final isActive = info?['is_active'] == true;
    final inviteUrl = info?['invite_url']?.toString() ?? '';
    final description = info?['formatted_text']?.toString() ??
        info?['description']?.toString() ??
        '';
    final visitCard = info?['visit_card_text']?.toString() ?? '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyle.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SheetScaffold(
        title: 'کسب درآمد',
        child: !isActive
            ? const _EmptyState(message: 'سیستم دعوت فعال نیست.')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (description.isNotEmpty)
                    SelectableText(
                      description,
                      style: const TextStyle(height: 1.5),
                    ),
                  if (inviteUrl.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(inviteUrl),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: inviteUrl),
                              );
                              showMsg(
                                msg: 'لینک کپی شد',
                                context: ctx,
                                type: 'info',
                              );
                            },
                            icon: const Icon(Icons.link),
                            label: const Text('کپی لینک'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final text = visitCard.isNotEmpty
                                  ? '$visitCard\n$inviteUrl'
                                  : inviteUrl;
                              Clipboard.setData(ClipboardData(text: text));
                              showMsg(
                                msg: 'متن دعوت کپی شد',
                                context: ctx,
                                type: 'info',
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('کپی متن'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  static Future<void> showTestAccountSheet(
    BuildContext context, {
    VoidCallback? onSuccess,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اکانت آزمایشی'),
        content: const Text(
          'با دریافت اکانت آزمایشی می‌توانید سرویس را قبل از خرید تست کنید. ادامه می‌دهید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('دریافت'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    EasyLoading.show();
    final result = await claimWebAppTestAccount();
    EasyLoading.dismiss();
    if (!context.mounted) return;

    final success = result['success'] == true;
    if (!success) {
      showMsg(
        msg: result['message']?.toString() ?? 'خطا',
        context: context,
        type: 'error',
      );
      return;
    }

    onSuccess?.call();
    final link = result['subscription_link']?.toString() ??
        result['config']?.toString() ??
        result['panel_link']?.toString();
    if (link != null && link.isNotEmpty) {
      await _showConfigResultDialog(context, link);
    } else {
      showMsg(
        msg: result['message']?.toString() ?? 'اکانت آزمایشی ایجاد شد',
        context: context,
        type: 'info',
      );
    }
  }

  static Future<void> _showConfigResultDialog(
    BuildContext context,
    String config,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اکانت آزمایشی'),
        content: SizedBox(
          width: Responsive.isMobile(context) ? double.infinity : 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: config,
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 16),
                SelectableText(config, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: config));
              showMsg(msg: 'کپی شد', context: ctx, type: 'info');
            },
            child: const Text('کپی'),
          ),
          if (config.startsWith('http'))
            TextButton(
              onPressed: () {
                launchUrl(Uri.parse(config),
                    mode: LaunchMode.externalApplication);
              },
              child: const Text('باز کردن'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }
}

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return Padding(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white54),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final Faq faq;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(faq.question),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: SelectableText(faq.answer),
          ),
        ),
      ],
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({required this.support});

  final Support support;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.support_agent_outlined),
      title: Text(support.question),
      subtitle: SelectableText(support.answer),
      isThreeLine: true,
    );
  }
}

class _AppDownloadSheet extends StatefulWidget {
  const _AppDownloadSheet({required this.oses});

  final List<String> oses;

  @override
  State<_AppDownloadSheet> createState() => _AppDownloadSheetState();
}

class _AppDownloadSheetState extends State<_AppDownloadSheet> {
  String? _selectedOs;
  List<Application> _apps = [];
  bool _loading = false;

  Future<void> _loadApps(String os) async {
    setState(() {
      _selectedOs = os;
      _loading = true;
    });
    final apps = await getWebAppApplicationsByOs(os);
    if (!mounted) return;
    setState(() {
      _apps = apps;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'دانلود برنامه',
      child: widget.oses.isEmpty
          ? const _EmptyState(message: 'برنامه‌ای ثبت نشده است.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.oses
                      .map(
                        (os) => ChoiceChip(
                          label: Text(os),
                          selected: _selectedOs == os,
                          onSelected: (_) => _loadApps(os),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _selectedOs == null
                          ? const _EmptyState(
                              message: 'سیستم‌عامل را انتخاب کنید.',
                            )
                          : _apps.isEmpty
                              ? const _EmptyState(
                                  message: 'برنامه‌ای برای این سیستم نیست.',
                                )
                              : ListView.separated(
                                  itemCount: _apps.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (_, index) =>
                                      _AppTile(app: _apps[index]),
                                ),
                ),
              ],
            ),
    );
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.apps),
      title: Text(app.name ?? 'برنامه'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (app.description != null && app.description!.isNotEmpty)
            Text(app.description!),
          if (app.howToUse != null && app.howToUse!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                app.howToUse!,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
        ],
      ),
      isThreeLine: true,
      trailing: app.downloadLink != null && app.downloadLink!.isNotEmpty
          ? IconButton(
              onPressed: () {
                launchUrl(
                  Uri.parse(app.downloadLink!),
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const Icon(Icons.download),
            )
          : null,
    );
  }
}
