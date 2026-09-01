import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/loyalty_setting_model.dart';
import 'package:powerps/repositories/loyalty_setting_repository.dart';
import 'package:powerps/screens/admin_screen/settings/loyalty/loyalty_logs_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  bool _showData = false;
  bool _isActive = false;
  bool _earnOnPurchase = true;
  bool _earnOnRenewal = true;
  bool _earnOnDeposit = true;
  bool _earnOnReferral = true;
  bool _redeemEnabled = true;

  final _descriptionController = TextEditingController();
  final _purchasePointsController = TextEditingController();
  final _renewalPointsController = TextEditingController();
  final _depositPointsController = TextEditingController();
  final _referralPointsController = TextEditingController();
  final _tomanPerPointController = TextEditingController();
  final _minRedeemController = TextEditingController();
  final _maxRedeemPercentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _purchasePointsController.dispose();
    _renewalPointsController.dispose();
    _depositPointsController.dispose();
    _referralPointsController.dispose();
    _tomanPerPointController.dispose();
    _minRedeemController.dispose();
    _maxRedeemPercentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await getLoyaltySetting();
    if (!mounted) return;
    if (data != null) {
      _descriptionController.text = data.description;
      _purchasePointsController.text =
          data.purchasePointsPer1000Toman.toString();
      _renewalPointsController.text = data.renewalPoints.toString();
      _depositPointsController.text =
          data.depositPointsPer1000Toman.toString();
      _referralPointsController.text = data.referralSignupPoints.toString();
      _tomanPerPointController.text = data.tomanPerPoint.toString();
      _minRedeemController.text = data.minRedeemPoints.toString();
      _maxRedeemPercentController.text = data.maxRedeemPercent.toString();
      _isActive = data.isActive;
      _earnOnPurchase = data.earnOnPurchase;
      _earnOnRenewal = data.earnOnRenewal;
      _earnOnDeposit = data.earnOnDeposit;
      _earnOnReferral = data.earnOnReferral;
      _redeemEnabled = data.redeemEnabled;
    }
    setState(() => _showData = true);
  }

  BoxDecoration _sectionDecoration() {
    return BoxDecoration(
      color: AppStyle.secondaryColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    );
  }

  EdgeInsets _screenPadding(BuildContext context) {
    return Responsive.adminPagePadding(context);
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
            title: 'باشگاه مشتریان (امتیاز)',
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
        mobile: _mobileLayout(context),
        tablet: _desktopLayout(context),
        desktop: _desktopLayout(context),
      ),
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _infoCard(context),
        SizedBox(height: AppStyle.defaultPadding),
        _statusCard(context),
        SizedBox(height: AppStyle.defaultPadding),
        _earnRulesCard(context),
        SizedBox(height: AppStyle.defaultPadding),
        _redeemRulesCard(context),
        SizedBox(height: AppStyle.defaultPadding),
        _descriptionCard(context),
      ],
    );
  }

  Widget _desktopLayout(BuildContext context) {
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _earnRulesCard(context)),
                      SizedBox(width: AppStyle.defaultPadding),
                      Expanded(child: _redeemRulesCard(context)),
                    ],
                  ),
                  SizedBox(height: AppStyle.defaultPadding),
                  _descriptionCard(context),
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
      padding: EdgeInsets.all(AppStyle.defaultPadding * 1.1),
      decoration: _sectionDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.stars_outlined,
              color: Colors.amber,
              size: Responsive.isMobile(context) ? 28 : 32,
            ),
          ),
          SizedBox(width: AppStyle.defaultPadding),
          Expanded(
            child: Text(
              'با فعال‌سازی باشگاه مشتریان، کاربران از خرید، تمدید، واریز و معرفی امتیاز می‌گیرند '
              'و می‌توانند بخشی از مبلغ سفارش را با امتیاز پرداخت کنند. '
              'این قابلیت در لایسنس نقره‌ای و طلایی فعال است.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(context, 'وضعیت سیستم', Icons.toggle_on_outlined),
          SizedBox(height: isMobile ? 8 : 12),
          if (isMobile) ...[
            _statusSwitch(
              title: 'فعال‌سازی باشگاه مشتریان',
              subtitle: 'غیرفعال = بدون امتیازدهی و بدون استفاده از امتیاز',
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            _statusSwitch(
              title: 'امکان خرج کردن امتیاز در خرید',
              value: _redeemEnabled,
              onChanged: (v) => setState(() => _redeemEnabled = v),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _statusSwitch(
                    title: 'فعال‌سازی باشگاه مشتریان',
                    subtitle: 'غیرفعال = بدون امتیازدهی',
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statusSwitch(
                    title: 'خرج امتیاز در خرید',
                    value: _redeemEnabled,
                    onChanged: (v) => setState(() => _redeemEnabled = v),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statusSwitch({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              )
            : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _earnRulesCard(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(context, 'قوانین کسب امتیاز', Icons.add_circle_outline),
          SizedBox(height: AppStyle.defaultPadding),
          _earnRuleItem(
            context,
            title: 'خرید اشتراک',
            enabled: _earnOnPurchase,
            onEnabledChanged: (v) => setState(() => _earnOnPurchase = v),
            controller: _purchasePointsController,
            fieldHint: isMobile ? 'امتیاز / ۱۰۰۰ تومان' : 'امتیاز',
            helper: 'به ازای هر ۱۰۰۰ تومان خرید',
          ),
          const Divider(color: Colors.white10, height: 20),
          _earnRuleItem(
            context,
            title: 'تمدید اشتراک',
            enabled: _earnOnRenewal,
            onEnabledChanged: (v) => setState(() => _earnOnRenewal = v),
            controller: _renewalPointsController,
            fieldHint: 'امتیاز ثابت',
            helper: 'پس از هر تمدید موفق',
          ),
          const Divider(color: Colors.white10, height: 20),
          _earnRuleItem(
            context,
            title: 'واریز به حساب',
            enabled: _earnOnDeposit,
            onEnabledChanged: (v) => setState(() => _earnOnDeposit = v),
            controller: _depositPointsController,
            fieldHint: isMobile ? 'امتیاز / ۱۰۰۰ تومان' : 'امتیاز',
            helper: 'به ازای هر ۱۰۰۰ تومان واریز',
          ),
          const Divider(color: Colors.white10, height: 20),
          _earnRuleItem(
            context,
            title: 'معرفی کاربر',
            enabled: _earnOnReferral,
            onEnabledChanged: (v) => setState(() => _earnOnReferral = v),
            controller: _referralPointsController,
            fieldHint: 'امتیاز معرف',
            helper: 'به معرف هنگام عضویت',
          ),
        ],
      ),
    );
  }

  Widget _earnRuleItem(
    BuildContext context, {
    required String title,
    required bool enabled,
    required ValueChanged<bool> onEnabledChanged,
    required TextEditingController controller,
    required String fieldHint,
    required String helper,
  }) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(title),
            value: enabled,
            onChanged: onEnabledChanged,
          ),
          _compactNumberField(controller, fieldHint),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(title, style: const TextStyle(fontSize: 13)),
            value: enabled,
            onChanged: onEnabledChanged,
          ),
        ),
        SizedBox(
          width: 100,
          child: _compactNumberField(controller, fieldHint),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              helper,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                    height: 1.4,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _redeemRulesCard(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(
            context,
            'قوانین استفاده از امتیاز',
            Icons.shopping_cart_checkout_outlined,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _redeemField(
            context,
            controller: _tomanPerPointController,
            label: 'ارزش هر امتیاز (تومان)',
            helper: 'مثلاً ۱۰ = هر امتیاز ده تومان ارزش دارد',
          ),
          SizedBox(height: isMobile ? 8 : 12),
          _redeemField(
            context,
            controller: _minRedeemController,
            label: 'حداقل امتیاز قابل استفاده',
            helper: 'کمتر از این مقدار در خرید اعمال نمی‌شود',
          ),
          SizedBox(height: isMobile ? 8 : 12),
          _redeemField(
            context,
            controller: _maxRedeemPercentController,
            label: 'حداکثر پوشش سفارش (٪)',
            helper: 'بین ۰ تا ۱۰۰ — سهم امتیاز از مبلغ کل',
          ),
        ],
      ),
    );
  }

  Widget _redeemField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String helper,
  }) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldLabel(label),
          const SizedBox(height: 6),
          _compactNumberField(controller, label),
          const SizedBox(height: 4),
          Text(
            helper,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: _compactNumberField(controller, label),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  helper,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _descriptionCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(context, 'توضیحات برای کاربران', Icons.notes_outlined),
          SizedBox(height: AppStyle.defaultPadding),
          CustomTextFromFieldWidget(
            controller: _descriptionController,
            keyboardType: TextInputType.multiline,
            textHint: 'متن توضیح باشگاه مشتریان',
            textDirection: TextDirection.rtl,
            validationError: 'توضیحات',
          ),
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
            onPressed: _submit,
            icon: const Icon(Icons.save_outlined),
            label: const Text('ذخیره تنظیمات'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoyaltyLogsScreen()),
            ),
            icon: const Icon(Icons.history_outlined),
            label: const Text('تاریخچه امتیازها'),
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoyaltyLogsScreen(),
                  ),
                ),
                icon: const Icon(Icons.history_outlined, size: 18),
                label: const Text('تاریخچه'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _submit,
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

  Widget _compactNumberField(TextEditingController controller, String hint) {
    return CustomTextFromFieldWidget(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(),
      textHint: hint,
      textDirection: TextDirection.ltr,
      validationError: hint,
    );
  }

  Future<void> _submit() async {
    EasyLoading.show(status: 'در حال ذخیره...');
    final model = LoyaltySettingModel(
      id: 0,
      description: _descriptionController.text.trim(),
      isActive: _isActive,
      earnOnPurchase: _earnOnPurchase,
      earnOnRenewal: _earnOnRenewal,
      earnOnDeposit: _earnOnDeposit,
      earnOnReferral: _earnOnReferral,
      redeemEnabled: _redeemEnabled,
      purchasePointsPer1000Toman:
          int.tryParse(_purchasePointsController.text) ?? 0,
      renewalPoints: int.tryParse(_renewalPointsController.text) ?? 0,
      depositPointsPer1000Toman:
          int.tryParse(_depositPointsController.text) ?? 0,
      referralSignupPoints: int.tryParse(_referralPointsController.text) ?? 0,
      tomanPerPoint: int.tryParse(_tomanPerPointController.text) ?? 1,
      minRedeemPoints: int.tryParse(_minRedeemController.text) ?? 0,
      maxRedeemPercent:
          parseLocalizedInt(_maxRedeemPercentController.text) ?? 0,
    );
    final error = await updateLoyaltySetting(model);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (error == null) {
      showMsg(msg: 'تنظیمات باشگاه مشتریان ذخیره شد', context: context);
    } else {
      showMsg(msg: error, context: context, type: 'error');
    }
  }
}
