import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/referral_setting_model.dart';
import 'package:powerps/repositories/referral_setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'referral_logs_screen.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  bool _showData = false;
  final _descriptionTxtEdit = TextEditingController();
  final _visitCardTxtEdit = TextEditingController();
  final _referralPercentTxtEdit = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _fillData();
  }

  @override
  void dispose() {
    _descriptionTxtEdit.dispose();
    _visitCardTxtEdit.dispose();
    _referralPercentTxtEdit.dispose();
    super.dispose();
  }

  EdgeInsets _screenPadding(BuildContext context) {
    return EdgeInsets.all(AppStyle.defaultPadding);
  }

  BoxDecoration _sectionDecoration() {
    return BoxDecoration(
      color: AppStyle.secondaryColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
            context: context,
            title: 'بازاریابی و لینک دعوت',
          ),
          body: !_showData
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(context),
          bottomNavigationBar:
              isMobile && _showData ? _mobileBottomBar(context) : null,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: _screenPadding(context),
      child: Responsive(
        mobile: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _infoCard(context),
            SizedBox(height: AppStyle.defaultPadding),
            _statusCard(context),
            SizedBox(height: AppStyle.defaultPadding),
            _textSettingsCard(context),
            SizedBox(height: AppStyle.defaultPadding),
            _percentCard(context),
          ],
        ),
        tablet: _desktopContent(context),
        desktop: _desktopContent(context),
      ),
    );
  }

  Widget _desktopContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _infoCard(context),
        SizedBox(height: AppStyle.defaultPadding),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _statusCard(context),
                  SizedBox(height: AppStyle.defaultPadding),
                  _textSettingsCard(context),
                  SizedBox(height: AppStyle.defaultPadding),
                  _percentCard(context),
                ],
              ),
            ),
            SizedBox(width: AppStyle.defaultPadding),
            Expanded(
              flex: 1,
              child: _desktopActionsCard(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding * 1.25),
      decoration: _sectionDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppStyle.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.campaign_outlined,
              color: AppStyle.primaryColor,
              size: Responsive.isMobile(context) ? 28 : 32,
            ),
          ),
          SizedBox(width: AppStyle.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سیستم بازاریابی و دعوت',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'کاربران با لینک اختصاصی دوستان را دعوت می‌کنند و از هر واریز تأییدشده، درصد کمیسیون دریافت می‌کنند.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        height: 1.6,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(context, 'وضعیت سیستم', Icons.toggle_on_outlined),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppStyle.bgColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (_isActive ? Colors.greenAccent : Colors.orangeAccent)
                    .withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
                  color: _isActive ? Colors.greenAccent : Colors.orangeAccent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isActive ? 'بازاریابی فعال است' : 'بازاریابی غیرفعال است',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _isActive
                            ? 'لینک دعوت و کمیسیون برای کاربران فعال است'
                            : 'ثبت دعوت و پرداخت کمیسیون متوقف شده',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white54,
                            ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isActive,
                  activeThumbColor: Colors.greenAccent,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textSettingsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(context, 'متن‌های نمایشی', Icons.text_fields_outlined),
          const SizedBox(height: 6),
          Text(
            'از \\r\\n برای خط جدید در متن استفاده کنید.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _fieldLabel('متن توضیحات بازاریابی'),
          const SizedBox(height: 8),
          CustomTextFromFieldWidget(
            controller: _descriptionTxtEdit,
            keyboardType: TextInputType.multiline,
            textHint: 'متن توضیحات بازاریابی',
            textDirection: TextDirection.rtl,
            validationError: 'متن توضیحات بازاریابی',
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _fieldLabel('متن ویزیت‌کارت (کپی متن دعوت)'),
          const SizedBox(height: 8),
          CustomTextFromFieldWidget(
            controller: _visitCardTxtEdit,
            keyboardType: TextInputType.multiline,
            textHint: 'متن ویزیت کارت',
            textDirection: TextDirection.rtl,
            validationError: 'متن ویزیت کارت',
          ),
        ],
      ),
    );
  }

  Widget _percentCard(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(context, 'تنظیمات کمیسیون', Icons.percent_outlined),
          SizedBox(height: AppStyle.defaultPadding),
          if (isMobile) ...[
            CustomTextFromFieldWidget(
              controller: _referralPercentTxtEdit,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textHint: 'درصد بازاریابی (۰ تا ۱۰۰)',
              textDirection: TextDirection.ltr,
              validationError: 'میزان درصد بازاریابی',
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: CustomTextFromFieldWidget(
                    controller: _referralPercentTxtEdit,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textHint: 'درصد',
                    textDirection: TextDirection.ltr,
                    validationError: 'میزان درصد بازاریابی',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'درصدی از مبلغ هر واریز تأییدشده کاربر دعوت‌شده به کیف همکاری معرف واریز می‌شود.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                            height: 1.5,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          if (isMobile) ...[
            const SizedBox(height: 8),
            Text(
              'درصدی از مبلغ واریز تأییدشده به کیف همکاری معرف واریز می‌شود.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _desktopActionsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(context, 'عملیات', Icons.settings_outlined),
          SizedBox(height: AppStyle.defaultPadding),
          ElevatedButton.icon(
            onPressed: () => _submitData(context),
            icon: const Icon(Icons.save_outlined),
            label: const Text('ذخیره تنظیمات'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _openLogs(context),
            icon: const Icon(Icons.history_outlined),
            label: const Text('مشاهده لاگ‌ها'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _mobileBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openLogs(context),
                icon: const Icon(Icons.history_outlined, size: 18),
                label: const Text('لاگ‌ها'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _submitData(context),
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('ذخیره'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppStyle.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppStyle.deactiveStatus,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _openLogs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReferralLogsScreen()),
    );
  }

  Future<void> _fillData() async {
    final value = await getReferralSetting();
    if (!mounted) return;
    if (value is ReferralSettingModel) {
      setState(() {
        _descriptionTxtEdit.text = value.description;
        _visitCardTxtEdit.text = value.visitCardText;
        _referralPercentTxtEdit.text = value.referralPercent.toString();
        _isActive = value.isActive;
        _showData = true;
      });
    } else {
      setState(() => _showData = true);
      showMsg(
        msg: 'خطا در دریافت تنظیمات بازاریابی',
        context: context,
        type: 'error',
      );
    }
  }

  Future<void> _submitData(BuildContext context) async {
    if (_descriptionTxtEdit.text.trim().isEmpty ||
        _visitCardTxtEdit.text.trim().isEmpty ||
        _referralPercentTxtEdit.text.trim().isEmpty) {
      showMsg(
        msg: 'اطلاعات درخواستی را وارد کنید',
        context: context,
        type: 'error',
      );
      return;
    }

    final percent = double.tryParse(_referralPercentTxtEdit.text.trim());
    if (percent == null || percent < 0 || percent > 100) {
      showMsg(
        msg: 'درصد بازاریابی باید عددی بین ۰ تا ۱۰۰ باشد',
        context: context,
        type: 'error',
      );
      return;
    }

    final ref = ReferralSettingModel(
      id: 1,
      description: _descriptionTxtEdit.text.trim(),
      visitCardText: _visitCardTxtEdit.text.trim(),
      referralPercent: percent,
      isActive: _isActive,
    );

    EasyLoading.show();
    final value = await updateReferralSetting(referralSettingModel: ref);
    EasyLoading.dismiss();

    if (!context.mounted) return;
    if (value) {
      showMsg(msg: 'ذخیره شد.', context: context);
    } else {
      showMsg(msg: 'خطا در ذخیره تنظیمات', context: context, type: 'error');
    }
  }
}
