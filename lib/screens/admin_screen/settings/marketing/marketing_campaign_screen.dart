import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/repositories/marketing_campaign_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class MarketingCampaignScreen extends StatefulWidget {
  const MarketingCampaignScreen({super.key});

  @override
  State<MarketingCampaignScreen> createState() => _MarketingCampaignScreenState();
}

class _MarketingCampaignScreenState extends State<MarketingCampaignScreen> {
  final _nameCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _ctaPayloadCtrl = TextEditingController();
  final _maxBalanceCtrl = TextEditingController(text: '10000');
  final _inactiveDaysCtrl = TextEditingController(text: '30');
  final _userGroupIdCtrl = TextEditingController();
  final _scheduledCtrl = TextEditingController();
  String _segment = 'never_purchased';
  String _ctaType = 'buy_menu';
  bool _sendNow = true;
  Uint8List? _imageBytes;
  String? _imageName;
  int? _previewCount;
  List<dynamic> _campaigns = [];

  final _segments = const {
    'all': 'همه کاربران',
    'never_purchased': 'هرگز خرید نکرده‌اند',
    'no_config': 'بدون کانفیگ',
    'low_balance': 'موجودی کم',
    'inactive_days': 'غیرفعال N روز',
    'user_group': 'گروه کاربری خاص',
  };

  final _ctaTypes = const {
    'buy_menu': 'منوی خرید',
    'add_balance': 'افزایش موجودی',
    'promo_code': 'کد تخفیف (نیاز به payload)',
    'recharge_product': 'تمدید بسته (نیاز به productId)',
  };

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      );

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _messageCtrl.dispose();
    _ctaPayloadCtrl.dispose();
    _maxBalanceCtrl.dispose();
    _inactiveDaysCtrl.dispose();
    _userGroupIdCtrl.dispose();
    _scheduledCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _segmentParams() {
    return switch (_segment) {
      'low_balance' => {'max_balance': double.tryParse(_maxBalanceCtrl.text) ?? 10000},
      'inactive_days' => {'days': int.tryParse(_inactiveDaysCtrl.text) ?? 30},
      'user_group' => {'user_group_id': int.tryParse(_userGroupIdCtrl.text) ?? 0},
      _ => {},
    };
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    setState(() {
      _imageBytes = result.files.single.bytes;
      _imageName = result.files.single.name;
    });
  }

  Future<void> _loadCampaigns() async {
    final items = await MarketingCampaignRepository.getAll();
    if (mounted) setState(() => _campaigns = items);
  }

  Future<void> _preview() async {
    EasyLoading.show(status: 'محاسبه گیرندگان...');
    final count = await MarketingCampaignRepository.previewCount(
      segmentType: _segment,
      segmentParams: _segmentParams(),
    );
    EasyLoading.dismiss();
    setState(() => _previewCount = count);
  }

  Future<void> _send() async {
    if (_nameCtrl.text.isEmpty || _messageCtrl.text.isEmpty) {
      showMsg(msg: 'نام و متن کمپین الزامی است', context: context, type: 'error');
      return;
    }
    if (!_sendNow && _scheduledCtrl.text.trim().isEmpty) {
      showMsg(msg: 'زمان ارسال را وارد کنید', context: context, type: 'error');
      return;
    }

    EasyLoading.show(status: 'ارسال کمپین...');
    final formMap = <String, dynamic>{
      'name': _nameCtrl.text,
      'segment_type': _segment,
      'segment_params': _segmentParams(),
      'message': _messageCtrl.text,
      'cta_type': _ctaType,
      if (_ctaPayloadCtrl.text.trim().isNotEmpty)
        'cta_payload': _ctaPayloadCtrl.text.trim(),
      if (!_sendNow) 'scheduled_at': _scheduledCtrl.text.trim(),
    };
    if (_imageBytes != null) {
      formMap['image'] = MultipartFile.fromBytes(
        _imageBytes!,
        filename: _imageName ?? 'campaign.jpg',
      );
    }
    final formData = FormData.fromMap(formMap);
    final ok = await MarketingCampaignRepository.create(formData);
    EasyLoading.dismiss();
    if (!mounted) return;
    showMsg(
      msg: ok
          ? (_sendNow ? 'کمپین در صف ارسال قرار گرفت' : 'کمپین زمان‌بندی شد')
          : 'خطا در ثبت کمپین',
      context: context,
      type: ok ? 'success' : 'error',
    );
    if (ok) {
      _nameCtrl.clear();
      _messageCtrl.clear();
      _ctaPayloadCtrl.clear();
      _scheduledCtrl.clear();
      setState(() {
        _imageBytes = null;
        _imageName = null;
        _sendNow = true;
        _previewCount = null;
      });
      _loadCampaigns();
    }
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppStyle.primaryColor),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _segmentExtraFields(bool twoColumn) {
    final fields = <Widget>[];
    if (_segment == 'low_balance') {
      fields.add(TextField(
        controller: _maxBalanceCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'حداکثر موجودی (تومان)'),
      ));
    }
    if (_segment == 'inactive_days') {
      fields.add(TextField(
        controller: _inactiveDaysCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'تعداد روز غیرفعال'),
      ));
    }
    if (_segment == 'user_group') {
      fields.add(TextField(
        controller: _userGroupIdCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'شناسه گروه کاربری'),
      ));
    }
    if (fields.isEmpty) return const SizedBox.shrink();

    if (twoColumn && fields.length == 1) {
      return fields.first;
    }
    return Column(
      children: fields
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: f,
              ))
          .toList(),
    );
  }

  Widget _formCard(BuildContext context) {
    final twoColumn = !Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(context, 'ایجاد کمپین جدید', Icons.campaign_outlined),
          const Divider(height: 28),
          if (twoColumn)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'نام کمپین'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _segment,
                    items: _segments.entries
                        .map((e) =>
                            DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _segment = v ?? 'never_purchased'),
                    decoration: const InputDecoration(labelText: 'سگمنت'),
                  ),
                ),
              ],
            )
          else ...[
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'نام کمپین'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _segment,
              items: _segments.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _segment = v ?? 'never_purchased'),
              decoration: const InputDecoration(labelText: 'سگمنت'),
            ),
          ],
          const SizedBox(height: 12),
          _segmentExtraFields(twoColumn),
          const SizedBox(height: 12),
          TextField(
            controller: _messageCtrl,
            maxLines: twoColumn ? 6 : 5,
            decoration: const InputDecoration(labelText: 'متن پیام'),
          ),
          const SizedBox(height: 12),
          if (twoColumn)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(_imageName ?? 'انتخاب تصویر (اختیاری)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _ctaType,
                    items: _ctaTypes.entries
                        .map((e) =>
                            DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _ctaType = v ?? 'buy_menu'),
                    decoration: const InputDecoration(labelText: 'دکمه اقدام (CTA)'),
                  ),
                ),
              ],
            )
          else ...[
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              label: Text(_imageName ?? 'انتخاب تصویر (اختیاری)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _ctaType,
              items: _ctaTypes.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _ctaType = v ?? 'buy_menu'),
              decoration: const InputDecoration(labelText: 'دکمه اقدام (CTA)'),
            ),
          ],
          if (_ctaType == 'promo_code' || _ctaType == 'recharge_product') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _ctaPayloadCtrl,
              decoration: InputDecoration(
                labelText: _ctaType == 'promo_code'
                    ? 'شناسه بسته برای applyPromo'
                    : 'شناسه محصول برای recharge',
              ),
            ),
          ],
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('ارسال فوری'),
            value: _sendNow,
            onChanged: (v) => setState(() => _sendNow = v),
          ),
          if (!_sendNow) ...[
            TextField(
              controller: _scheduledCtrl,
              decoration: const InputDecoration(
                labelText: 'زمان ارسال (YYYY-MM-DD HH:MM)',
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_previewCount != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppStyle.bgColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'تعداد گیرنده پیش‌بینی‌شده: $_previewCount',
                style: TextStyle(color: AppStyle.primaryColor),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Responsive(
            mobile: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _preview,
                    child: const Text('پیش‌نمایش تعداد'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyle.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(_sendNow ? 'ارسال کمپین' : 'زمان‌بندی کمپین'),
                  ),
                ),
              ],
            ),
            desktop: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _preview,
                    child: const Text('پیش‌نمایش تعداد'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyle.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(_sendNow ? 'ارسال کمپین' : 'زمان‌بندی کمپین'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _campaignsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'کمپین‌های اخیر', Icons.history),
          const Divider(height: 24),
          if (_campaigns.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppStyle.defaultPadding),
              child: Center(
                child: Text(
                  'هنوز کمپینی ثبت نشده است.',
                  style: TextStyle(color: AppStyle.deactiveStatus),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _campaigns.length.clamp(0, 15),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final c = _campaigns[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppStyle.bgColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['name']?.toString() ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${c['segment_type']} | ${c['status']}',
                        style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 13),
                      ),
                      Text(
                        '${c['total_users'] ?? 0} گیرنده'
                        '${c['scheduled_at'] != null ? ' | ${c['scheduled_at']}' : ''}',
                        style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return ListView(
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        children: [
          _formCard(context),
          SizedBox(height: AppStyle.defaultPadding),
          _campaignsCard(context),
        ],
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: _formCard(context)),
          SizedBox(width: AppStyle.defaultPadding),
          Expanded(flex: 2, child: _campaignsCard(context)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(context: context, title: 'کمپین بازاریابی'),
          body: _body(context),
        ),
      ),
    );
  }
}
