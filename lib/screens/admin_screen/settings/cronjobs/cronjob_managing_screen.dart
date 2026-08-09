import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/license_helper.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/cron_job_model.dart';
import 'package:powerps/repositories/cron_job_repostory.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/screens/admin_screen/settings/text/text_screen_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/cron_jobs/cronjob_info_item_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/license_gate_dialog.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class CronjobManagingScreen extends StatefulWidget {
  const CronjobManagingScreen({super.key});

  @override
  State<CronjobManagingScreen> createState() => _CronjobManagingScreenState();
}

class _CronjobManagingScreenState extends State<CronjobManagingScreen> {
  List<CronJobModel> _cronJobsItemsList = [];
  bool _showData = false;
  String _licenseType = '';
  final List<Widget> _cronJobsItemWidgetList = [];

  bool get _isSilverOrAbove => LicenseHelper.isSilverOrAbove(_licenseType);

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
              context: context, title: "ویرایش پیام های خودکار"),
          body: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _showData == false
                ? const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _content(context),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _menuInfoCard(context),
                  ],
                )),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            if (!Responsive.isMobile(context))
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _menuInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "گزینه های ارسال پیام خودکار (تنها در اکانت‌های طلایی و نقره ای اجرا می شود.)",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const TextScreenScreen(initialSearch: 'cron.'),
              ),
            ),
            icon: const Icon(Icons.edit_note_outlined),
            label: const Text('ویرایش متن پیام‌های خودکار'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppStyle.primaryColor,
              side: BorderSide(
                  color: AppStyle.primaryColor.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding / 2),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const TextScreenScreen(initialSearch: 'recovery.'),
              ),
            ),
            icon: const Icon(Icons.shopping_cart_checkout_outlined),
            label: const Text('ویرایش متن بازیابی خرید'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppStyle.primaryColor,
              side: BorderSide(
                  color: AppStyle.primaryColor.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          ElevatedButton.icon(
            onPressed: _showManualExpiredDeleteFlow,
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('حذف دستی اکانت‌های منقضی‌شده'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اکانت‌هایی که بیش از ۱۰ روز از انقضا گذشته‌اند را لیست کرده و پس از تایید حذف می‌کند (نقره‌ای و طلایی).',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.5,
                  context: context,
                  importedList: _cronJobsItemWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: _cronJobsItemWidgetList),
              desktop: widgetsGridview(
                  importedList: _cronJobsItemWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showManualExpiredDeleteFlow() async {
    if (!_isSilverOrAbove) {
      await showLicenseGateDialog(
        context: context,
        title: 'حذف اکانت‌های منقضی',
        message:
            'حذف دستی اکانت‌های منقضی‌شده فقط در لایسنس نقره‌ای و طلایی فعال است.',
        requiredTier: 'نقره‌ای',
      );
      return;
    }

    EasyLoading.show(status: 'در حال دریافت لیست...');
    final items = await previewExpiredConfigsForDeletion();
    EasyLoading.dismiss();
    if (!mounted) return;

    if (items == null) {
      showMsg(
        context: context,
        msg: 'خطا در دریافت لیست اکانت‌های منقضی',
        type: 'error',
      );
      return;
    }

    if (items.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppStyle.secondaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.tealAccent),
                SizedBox(width: 10),
                Text('حذف اکانت‌های منقضی',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            content: const Text(
              'اکانت منقضی‌شده‌ای برای حذف یافت نشد.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('باشه',
                    style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final selectedKeys = <String>{
      for (final item in items) _expiredItemKey(item),
    };

    await showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppStyle.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.delete_forever_outlined,
                      color: Colors.deepOrangeAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'اکانت‌های منقضی برای حذف',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${items.length} اکانت واجد شرایط حذف هستند (بیش از ۱۰ روز از انقضا گذشته). موارد انتخاب‌شده از دیتابیس و پنل حذف می‌شوند.',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedKeys
                                ..clear()
                                ..addAll(items.map(_expiredItemKey));
                            });
                          },
                          child: const Text('انتخاب همه',
                              style: TextStyle(color: Colors.deepOrangeAccent)),
                        ),
                        TextButton(
                          onPressed: () {
                            setDialogState(() => selectedKeys.clear());
                          },
                          child: const Text('لغو انتخاب',
                              style: TextStyle(color: Colors.white54)),
                        ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: Colors.white10, height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final key = _expiredItemKey(item);
                          final remark =
                              (item['remark']?.toString().trim().isNotEmpty ==
                                      true)
                                  ? item['remark'].toString()
                                  : 'بدون نام';
                          final category =
                              item['category_name']?.toString() ?? '—';
                          final panelName =
                              item['panel_name']?.toString() ?? '—';
                          final panelType =
                              item['panel_type']?.toString() ?? '—';
                          final accountId =
                              item['account_id']?.toString() ?? '—';
                          final reason = item['reason']?.toString();
                          final reasonLabel = reason == 'usage_exceeded'
                              ? 'اتمام حجم'
                              : 'منقضی‌شده';
                          final checked = selectedKeys.contains(key);

                          return CheckboxListTile(
                            value: checked,
                            activeColor: Colors.deepOrange,
                            checkColor: Colors.white,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              remark,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                            subtitle: Text(
                              '$category · $panelName ($panelType) · کاربر $accountId · $reasonLabel',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedKeys.add(key);
                                } else {
                                  selectedKeys.remove(key);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('انصراف',
                      style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onPressed: selectedKeys.isEmpty
                      ? null
                      : () async {
                          final selectedItems = items
                              .where((e) =>
                                  selectedKeys.contains(_expiredItemKey(e)))
                              .map((e) => {
                                    'product_id': e['product_id'],
                                    'panel_id': e['panel_id'],
                                    'uuid': e['uuid'],
                                  })
                              .toList();

                          final confirmed = await showDialog<bool>(
                            context: dialogContext,
                            builder: (ctx) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: AlertDialog(
                                backgroundColor: AppStyle.secondaryColor,
                                title: const Text('تایید حذف',
                                    style: TextStyle(color: Colors.white)),
                                content: Text(
                                  'آیا از حذف ${selectedItems.length} اکانت منقضی اطمینان دارید؟ این عمل قابل بازگشت نیست.',
                                  style:
                                      const TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('خیر',
                                        style:
                                            TextStyle(color: Colors.white70)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('بله، حذف شود'),
                                  ),
                                ],
                              ),
                            ),
                          );

                          if (confirmed != true) return;
                          if (!dialogContext.mounted) return;

                          EasyLoading.show(status: 'در حال حذف...');
                          final result = await deleteSelectedExpiredConfigs(
                            items: selectedItems,
                          );
                          EasyLoading.dismiss();
                          if (!dialogContext.mounted) return;

                          Navigator.pop(dialogContext);

                          if (!mounted) return;
                          if (result != null && result['success'] == true) {
                            showMsg(
                              context: this.context,
                              msg: result['message']?.toString() ??
                                  'حذف با موفقیت انجام شد',
                            );
                          } else {
                            showMsg(
                              context: this.context,
                              msg: result?['message']?.toString() ??
                                  'خطا در حذف اکانت‌ها',
                              type: 'error',
                            );
                          }
                        },
                  child: Text('حذف (${selectedKeys.length})'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _expiredItemKey(Map<String, dynamic> item) {
    return '${item['panel_id']}:${item['uuid']}:${item['product_id']}';
  }

  void _fillData() async {
    final license = await getLicenseType();
    if (!mounted) return;
    _licenseType = license;

    await getAllCronJobs().then((res) {
      if (!mounted) return;
      if (res == null) {
        showMsg(msg: 'خطا', context: context, type: 'error');
        return;
      }
      setState(() {
        _cronJobsItemsList = res;
        _cronJobsItemWidgetList.clear();
        for (var i in _cronJobsItemsList) {
          _cronJobsItemWidgetList.add(CronjobInfoItemWidget(
            cronJobModel: i,
          ));
        }
        _showData = true;
      });
    }).onError((error, stackTrace) {
      if (!mounted) return;
      showMsg(msg: 'خطا', context: context, type: 'error');
    });
  }
}
