import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/crypto_payment_gateway_model.dart';
import 'package:powerps/models/payment_setting_model.dart';
import 'package:powerps/models/payment_type_model.dart';
import 'package:powerps/models/sub_menu_item_model.dart';
import 'package:powerps/provider/paymeny_provider.dart';
import 'package:powerps/repositories/payment_type_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/payment_type_info_widget.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentTypeScreen extends StatefulWidget {
  const PaymentTypeScreen({super.key});

  @override
  State<PaymentTypeScreen> createState() => _PaymentTypeScreenState();
}

class _PaymentTypeScreenState extends State<PaymentTypeScreen> {
  bool _showData = false;
  bool _hasDollarePayment = false;
  List<PaymentType> _paymentTypeList = [];
  List<SubMenuItem> subList = [];
  PaymentType? _zarinPal;
  CryptoPaymentGateway? _nowPayment;
  CryptoPaymentGateway? _cryptomus;
  final _zarinpalMerchantIdTxtEdit = TextEditingController();
  final _zarinpalCallbackDomainTxtEdit = TextEditingController();
  String? _zarinpalResolvedCallbackUrl;
  String? _zarinpalDefaultCallbackUrl;
  bool _isZarinPalSandbox = false;
  final _newPaymentMerchantIdTxtEdit = TextEditingController();
  final _newPaymentNameTxtEdit = TextEditingController();
  final _shetabVerifyApiKeyTxtEdit = TextEditingController();
  bool _isZarinPalActive = true;
  final List<Widget> _paymentItemWidgetList = [];
  PaymentSettingModel? _shetabVerifySetting;

  final _nowPaymentApiKeyTxtEdit = TextEditingController();
  final _nowPaymentEmaikTxtEdit = TextEditingController();
  final _nowPaymentPasswordTxtEdit = TextEditingController();
  bool _nowPaymentIsActive = true;
  bool _nowPaymentIsFeePaidByUser = true;

  final _cryptomusApiKeyTxtEdit = TextEditingController();
  final _cryptomusMerchantIdTxtEdit = TextEditingController();
  bool _cryptomusIsActive = true;

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppStyle.primaryColor),
      filled: true,
      fillColor: AppStyle.bgColor.withValues(alpha: 0.45),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppStyle.primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _zarinpalMerchantIdTxtEdit.dispose();
    _zarinpalCallbackDomainTxtEdit.dispose();
    _newPaymentMerchantIdTxtEdit.dispose();
    _newPaymentNameTxtEdit.dispose();
    _shetabVerifyApiKeyTxtEdit.dispose();
    _nowPaymentApiKeyTxtEdit.dispose();
    _nowPaymentEmaikTxtEdit.dispose();
    _nowPaymentPasswordTxtEdit.dispose();
    _cryptomusApiKeyTxtEdit.dispose();
    _cryptomusMerchantIdTxtEdit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: AppStyle.bgColor,
      appBar: appBarWithBackButton(context: context, title: 'درگاه‌ها و پرداخت'),
      bottomNavigationBar:
          _showData && Responsive.isMobile(context) ? _mobileAddBar() : null,
      body: !_showData
          ? const Center(child: CircularProgressIndicator())
          : Responsive(
              mobile: _mobileBody(),
              tablet: _desktopBody(),
              desktop: _desktopBody(),
            ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Responsive.isMobile(context) ? SafeArea(child: scaffold) : scaffold,
    );
  }

  Widget _mobileBody() {
    return ListView(
      padding: Responsive.adminPagePadding(context),
      children: [
        _pageHeader(compact: true),
        const SizedBox(height: 16),
        ..._allSections(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _desktopBody() {
    return SingleChildScrollView(
      padding: Responsive.adminPagePadding(context),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _pageHeader(compact: false),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      _offlinePaymentSection(),
                      const SizedBox(height: 12),
                      _zarinpalSection(),
                      const SizedBox(height: 12),
                      _shetabVerifySection(),
                      const SizedBox(height: 12),
                      _dollarPaymentSection(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      _operationsSidebar(),
                      const SizedBox(height: 12),
                      _nowPaymentSection(),
                      const SizedBox(height: 12),
                      _cryptomusSection(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _allSections() => [
        _offlinePaymentSection(),
        const SizedBox(height: 16),
        _zarinpalSection(),
        const SizedBox(height: 16),
        _shetabVerifySection(),
        const SizedBox(height: 16),
        _dollarPaymentSection(),
        const SizedBox(height: 16),
        _nowPaymentSection(),
        const SizedBox(height: 16),
        _cryptomusSection(),
      ];

  Widget _pageHeader({required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppStyle.primaryColor.withValues(alpha: 0.18),
            AppStyle.secondaryColor,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppStyle.primaryColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppStyle.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.payments_outlined,
                color: AppStyle.primaryColor, size: compact ? 28 : 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مدیریت درگاه‌های پرداخت',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'پرداخت آفلاین، زرین‌پال، ارز دیجیتال و تایید خودکار کارت‌به‌کارت',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: compact ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    String? subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppStyle.primaryColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Colors.white10),
          ),
          child,
        ],
      ),
    );
  }

  Widget _helperText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
      ),
    );
  }

  Widget _toggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
        ),
        value: value,
        activeThumbColor: AppStyle.primaryColor,
        onChanged: onChanged,
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool outlined = false,
  }) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppStyle.primaryColor,
          side: BorderSide(color: AppStyle.primaryColor.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyle.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _mobileAddBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppStyle.defaultPadding,
        12,
        AppStyle.defaultPadding,
        AppStyle.defaultPadding,
      ),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: _actionButton(
          label: 'افزودن پرداخت آفلاین',
          icon: Icons.add_circle_outline,
          onPressed: () => _newPaymentDialog(context),
        ),
      ),
    );
  }

  Widget _operationsSidebar() {
    return _sectionCard(
      title: 'عملیات سریع',
      icon: Icons.bolt_outlined,
      subtitle: 'افزودن روش پرداخت جدید',
      child: _actionButton(
        label: 'افزودن پرداخت آفلاین',
        icon: Icons.add_circle_outline,
        onPressed: () => _newPaymentDialog(context),
        outlined: true,
      ),
    );
  }

  Widget _offlinePaymentSection() {
    return Consumer<PaymentProvider>(builder: (context, paymentProvider, _) {
      if (paymentProvider.changed) {
        Future.microtask(_rebuildOfflinePayment);
      }

      return _sectionCard(
        title: 'پرداخت‌های آفلاین',
        icon: Icons.account_balance_wallet_outlined,
        subtitle: 'کارت‌به‌کارت و روش‌های دستی',
        trailing: Responsive.isMobile(context)
            ? null
            : IconButton(
                tooltip: 'افزودن',
                onPressed: () => _newPaymentDialog(context),
                icon: Icon(Icons.add_circle_outline, color: AppStyle.primaryColor),
              ),
        child: _paymentItemWidgetList.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppStyle.bgColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 40, color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(height: 8),
                    Text(
                      'هنوز روش پرداخت آفلاینی ثبت نشده',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = Responsive.isMobile(context)
                      ? 1
                      : (constraints.maxWidth > 500 ? 2 : 1);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: Responsive.isMobile(context) ? 2.8 : 3.2,
                    ),
                    itemCount: _paymentItemWidgetList.length,
                    itemBuilder: (_, i) => _paymentItemWidgetList[i],
                  );
                },
              ),
      );
    });
  }

  Widget _dollarPaymentSection() {
    return _sectionCard(
      title: 'پرداخت دلاری',
      icon: Icons.attach_money,
      subtitle: 'نمایش قیمت و درگاه‌های ارزی',
      child: _toggleTile(
        title: 'فعال‌سازی پرداخت دلاری',
        subtitle:
            'قیمت‌ها به دلار نمایش داده می‌شود و درگاه‌های ارزی فعال می‌شوند.',
        value: _hasDollarePayment,
        onChanged: (newValue) async {
          EasyLoading.show();
          final val = await setDollorTransactionSetting(dollarTransaction: newValue);
          if (mounted) {
            showMsg(
              msg: val ? 'فعال شد.' : 'غیرفعال شد.',
              context: context,
            );
            setState(() => _hasDollarePayment = newValue);
          }
          EasyLoading.dismiss();
        },
      ),
    );
  }

  Widget _zarinpalSection() {
    return _sectionCard(
      title: 'زرین‌پال',
      icon: Icons.credit_card,
      subtitle: 'درگاه پرداخت آنلاین ریالی',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _zarinpalMerchantIdTxtEdit,
            textDirection: TextDirection.ltr,
            decoration: _fieldDecoration(
              label: 'کد درگاه (Merchant ID)',
              hint: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
              icon: Icons.key_outlined,
            ),
          ),
          _helperText(
              'کد درگاه را از پنل زرین‌پال → تنظیمات درگاه کپی کنید.'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _zarinpalCallbackDomainTxtEdit,
            textDirection: TextDirection.ltr,
            decoration: _fieldDecoration(
              label: 'دامنه Callback',
              hint: 'https://pay.example.com',
              icon: Icons.language_outlined,
            ),
          ),
          _helperText(
            _zarinpalResolvedCallbackUrl != null
                ? 'فقط دامنه را وارد کنید؛ مسیر همیشه /order است.\nآدرس نهایی: $_zarinpalResolvedCallbackUrl\nخالی = دامنه پیش‌فرض پنل (${_zarinpalDefaultCallbackUrl ?? '—'}).'
                : 'فقط دامنه اصلی را وارد کنید (مثل https://pay.example.com). مسیر /order ثابت می‌ماند. خالی = دامنه پیش‌فرض پنل.',
          ),
          const SizedBox(height: 12),
          _toggleTile(
            title: 'حالت Sandbox (آزمایشی)',
            subtitle:
                'فقط برای آزمایش درگاه استفاده می‌شود. پرداخت واقعی انجام نمی‌شود و باید Merchant ID سندباکس زرین‌پال را وارد کنید. برای فروش واقعی خاموش بگذارید.',
            value: _isZarinPalSandbox,
            onChanged: (newValue) {
              setState(() => _isZarinPalSandbox = newValue);
            },
          ),
          if (_isZarinPalSandbox)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
                ),
                child: const Text(
                  'Sandbox فعال است: تراکنش‌ها روی محیط آزمایشی زرین‌پال انجام می‌شوند و برای تست اتصال درگاه است، نه دریافت وجه واقعی.',
                  style: TextStyle(color: Colors.amber, fontSize: 12, height: 1.5),
                ),
              ),
            ),
          _toggleTile(
            title: 'فعال بودن درگاه',
            subtitle: 'برای فعال‌سازی باید درگاه تأییدشده در زرین‌پال داشته باشید.',
            value: _isZarinPalActive,
            onChanged: (newValue) async {
              EasyLoading.show();
              if (newValue) {
                final res = await reActivePaymentType(name: 'زرین پال');
                if (res && mounted) showMsg(msg: 'فعال شد.', context: context);
              } else {
                final res = await deActivePaymentType(name: 'زرین پال');
                if (res && mounted) {
                  showMsg(msg: 'غیرفعال شد.', context: context);
                }
              }
              if (mounted) setState(() => _isZarinPalActive = newValue);
              EasyLoading.dismiss();
            },
          ),
          _actionButton(
            label: 'ذخیره تنظیمات زرین‌پال',
            icon: Icons.save_outlined,
            onPressed: () async {
              if (_zarinpalMerchantIdTxtEdit.text.isEmpty) return;
              EasyLoading.show();
              final res = await chanegeMerChantIdByPaymentTypeName(
                merchantId: _zarinpalMerchantIdTxtEdit.text.trim(),
                name: 'زرین پال',
                callbackDomain: _zarinpalCallbackDomainTxtEdit.text.trim(),
                isSandbox: _isZarinPalSandbox,
              );
              EasyLoading.dismiss();
              if (!mounted) return;
              showMsg(
                msg: res ? 'ویرایش شد.' : 'خطا.',
                context: context,
                type: res ? 'success' : 'error',
              );
              if (res) {
                await _fillData();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _shetabVerifySection() {
    if (_shetabVerifySetting == null) {
      return _sectionCard(
        title: 'تایید خودکار کارت‌به‌کارت',
        icon: Icons.verified_user_outlined,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final endpoint = '$baseURL/api/shetab-verify';

    return _sectionCard(
      title: 'تایید خودکار کارت‌به‌کارت',
      icon: Icons.verified_user_outlined,
      subtitle: 'Shetab Verify — تأیید خودکار واریز',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _toggleTile(
            title: 'فعال‌سازی تایید خودکار',
            subtitle: 'با نصب اپ Shetab Verify، واریزها خودکار تأیید می‌شوند.',
            value: _shetabVerifySetting!.status,
            onChanged: (newValue) async {
              EasyLoading.show();
              await setShetabVerifySetting(status: newValue).then((val) {
                if (mounted) {
                  showMsg(msg: val ? 'ذخیره شد.' : 'خطا', context: context);
                  setState(() => _shetabVerifySetting!.status = newValue);
                }
              }).whenComplete(EasyLoading.dismiss);
            },
          ),
          _secretRow(
            label: 'API ENDPOINT',
            value: endpoint,
            showQr: true,
          ),
          const SizedBox(height: 8),
          _secretRow(
            label: 'API KEY',
            value: _shetabVerifySetting!.value,
            showQr: true,
            onRefresh: () {
              reGenerateShetabVerifyApiKey().then((val) {
                if (val != null && mounted) {
                  setState(() => _shetabVerifySetting!.value = val);
                  showMsg(msg: 'API KEY بازنشانی شد.', context: context);
                }
              });
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppStyle.bgColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اپ Shetab Verify را نصب کنید و در تنظیمات API مقادیر بالا را وارد کنید.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse('https://cafebazaar.ir/app/ir.webdide.verify'),
                  ),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('دانلود از کافه‌بازار'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _shetabVerifyApiKeyTxtEdit,
            keyboardType: TextInputType.number,
            decoration: _fieldDecoration(
              label: 'شماره کارت مقصد',
              hint: '6037xxxxxxxxxxxx',
              icon: Icons.credit_card_outlined,
            ),
          ),
          const SizedBox(height: 12),
          _actionButton(
            label: 'ذخیره شماره کارت',
            icon: Icons.save_outlined,
            onPressed: () {
              if (_shetabVerifyApiKeyTxtEdit.text.isEmpty) return;
              setShetabVeriyNewCardNumber(
                cardNumber: _shetabVerifyApiKeyTxtEdit.text,
              ).then((val) {
                if (!mounted) return;
                showMsg(
                  msg: val ? 'ذخیره شد.' : 'خطا',
                  context: context,
                  type: val ? 'success' : 'error',
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _secretRow({
    required String label,
    required String value,
    bool showQr = false,
    VoidCallback? onRefresh,
  }) {
    final display = value.length > 28 ? '${value.substring(0, 28)}...' : value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
                const SizedBox(height: 2),
                SelectableText(
                  display,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'کپی',
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              showMsg(msg: '$label کپی شد.', context: context);
            },
          ),
          if (showQr)
            IconButton(
              tooltip: 'QR Code',
              icon: const Icon(Icons.qr_code, size: 18),
              onPressed: () => _showQrDialog(label, value),
            ),
          if (onRefresh != null)
            IconButton(
              tooltip: 'بازنشانی',
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: onRefresh,
            ),
        ],
      ),
    );
  }

  void _showQrDialog(String title, String data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppStyle.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('بستن'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nowPaymentSection() {
    return _sectionCard(
      title: 'NOWPayments',
      icon: Icons.currency_bitcoin,
      subtitle: 'درگاه پرداخت ارز دیجیتال',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nowPaymentApiKeyTxtEdit,
            textDirection: TextDirection.ltr,
            decoration: _fieldDecoration(
              label: 'API Key',
              hint: 'API KEY',
              icon: Icons.vpn_key_outlined,
            ),
          ),
          _helperText('از Settings → Payments در پنل NOWPayments کپی کنید.'),
          const SizedBox(height: 12),
          _toggleTile(
            title: 'فعال بودن درگاه',
            subtitle: 'امکان پرداخت از NOWPayments',
            value: _nowPaymentIsActive,
            onChanged: (v) => setState(() => _nowPaymentIsActive = v),
          ),
          _toggleTile(
            title: 'کارمزد توسط کاربر',
            subtitle: 'در صورت غیرفعال بودن، کارمزد از مبلغ پرداختی کسر می‌شود.',
            value: _nowPaymentIsFeePaidByUser,
            onChanged: (v) => setState(() => _nowPaymentIsFeePaidByUser = v),
          ),
          _actionButton(
            label: 'ذخیره NOWPayments',
            icon: Icons.save_outlined,
            onPressed: () async {
              if (_nowPaymentApiKeyTxtEdit.text.isEmpty) {
                showMsg(
                  msg: 'API KEY نمی‌تواند خالی باشد.',
                  context: context,
                  type: 'ERROR',
                );
                return;
              }
              EasyLoading.show();
              await updateNowPaymentDetails(
                cryptoPaymentGateway: CryptoPaymentGateway(
                  id: 0,
                  name: 'nowpayments',
                  apiKey: _nowPaymentApiKeyTxtEdit.text,
                  email: 'john@gmail.com',
                  password: '123456789',
                  isActive: _nowPaymentIsActive,
                  isFeePaidByUser: _nowPaymentIsFeePaidByUser,
                ),
              ).then((value) {
                if (value != null && mounted) {
                  setState(() => _nowPayment = value);
                }
              }).whenComplete(() {
                EasyLoading.dismiss();
                if (mounted) showMsg(msg: 'ذخیره شد.', context: context);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _cryptomusSection() {
    return _sectionCard(
      title: 'Cryptomus',
      icon: Icons.currency_exchange,
      subtitle: 'درگاه پرداخت ارز دیجیتال',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _cryptomusApiKeyTxtEdit,
            textDirection: TextDirection.ltr,
            decoration: _fieldDecoration(
              label: 'API Key',
              icon: Icons.vpn_key_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cryptomusMerchantIdTxtEdit,
            textDirection: TextDirection.ltr,
            decoration: _fieldDecoration(
              label: 'Merchant ID',
              icon: Icons.storefront_outlined,
            ),
          ),
          _helperText('مقادیر را از Settings → Payments در پنل Cryptomus وارد کنید.'),
          const SizedBox(height: 12),
          _toggleTile(
            title: 'فعال بودن درگاه',
            subtitle: 'امکان پرداخت از Cryptomus',
            value: _cryptomusIsActive,
            onChanged: (v) => setState(() => _cryptomusIsActive = v),
          ),
          _actionButton(
            label: 'ذخیره Cryptomus',
            icon: Icons.save_outlined,
            onPressed: () async {
              if (_cryptomusApiKeyTxtEdit.text.isEmpty ||
                  _cryptomusMerchantIdTxtEdit.text.isEmpty) {
                showMsg(
                  msg: 'API KEY نمی‌تواند خالی باشد.',
                  context: context,
                  type: 'ERROR',
                );
                return;
              }
              EasyLoading.show();
              await updateCryptomusPaymentDetails(
                cryptoPaymentGateway: CryptoPaymentGateway(
                  id: 0,
                  name: 'Cryptomus',
                  apiKey: _cryptomusApiKeyTxtEdit.text,
                  email: 'john@gmail.com',
                  password: _cryptomusMerchantIdTxtEdit.text,
                  isActive: _cryptomusIsActive,
                  isFeePaidByUser: false,
                ),
              ).then((value) {
                if (value != null && mounted) {
                  setState(() => _cryptomus = value);
                }
              }).whenComplete(() {
                EasyLoading.dismiss();
                if (mounted) showMsg(msg: 'ذخیره شد.', context: context);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _rebuildOfflinePayment() async {
    await getAllOfflinePayments().then((res) {
      if (res != null && res != false) {
        setState(() {
          _paymentTypeList = res;
          _paymentItemWidgetList.clear();
          for (var i in _paymentTypeList) {
            _paymentItemWidgetList.add(PaymentTypeItemInfoWidget(
              paymentType: PaymentType(
                id: i.id,
                name: i.name,
                merchantId: i.merchantId,
                isActive: i.isActive,
                type: i.type,
              ),
            ));
          }
        });
      }
    }).onError((e, s) {
      debugPrint(e.toString());
    });
  }

  Future<void> _fillData() async {
    if (!context.mounted) return;

    var res = await getAllOfflinePayments();
    var resZarinpal = await getZarinpalPaymentDetails();
    var resNowPayment = await getNovPaymentDetails();
    var resCryptomus = await getCryptomusPaymentDetails();
    await getShetabVerifySetting().then((val) {
      if (mounted) {
        setState(() {
          _shetabVerifySetting = val;
          _shetabVerifyApiKeyTxtEdit.text = val.description.isEmpty
              ? 'یک شماره کارت وارد کنید'
              : val.description;
        });
      }
    });

    await getDollorTransactionSetting().then((val) {
      if (mounted) {
        setState(() => _hasDollarePayment = val);
      }
    });

    if (res != null &&
        res != false &&
        resZarinpal != null &&
        resZarinpal != false &&
        resNowPayment != null &&
        resNowPayment != false) {
      setState(() {
        _paymentTypeList = res;
        _paymentItemWidgetList.clear();
        for (var i in _paymentTypeList) {
          _paymentItemWidgetList.add(PaymentTypeItemInfoWidget(
            paymentType: PaymentType(
              id: i.id,
              name: i.name,
              merchantId: i.merchantId,
              isActive: i.isActive,
              type: i.type,
            ),
          ));
        }

        _zarinPal = resZarinpal;
        _zarinpalMerchantIdTxtEdit.text = _zarinPal!.merchantId;
        _zarinpalCallbackDomainTxtEdit.text =
            _zarinPal!.callbackDomain ?? _zarinPal!.callbackUrl ?? '';
        _zarinpalResolvedCallbackUrl = _zarinPal!.resolvedCallbackUrl;
        _zarinpalDefaultCallbackUrl = _zarinPal!.defaultCallbackUrl;
        _isZarinPalSandbox = _zarinPal!.isSandbox;
        _isZarinPalActive = _zarinPal!.isActive;

        _nowPayment = resNowPayment;
        _nowPaymentApiKeyTxtEdit.text = _nowPayment!.apiKey;
        _nowPaymentEmaikTxtEdit.text = _nowPayment!.email;
        _nowPaymentPasswordTxtEdit.text = _nowPayment!.password;
        _nowPaymentIsActive = _nowPayment!.isActive;
        _nowPaymentIsFeePaidByUser = _nowPayment!.isFeePaidByUser;

        if (resCryptomus != null) {
          _cryptomus = resCryptomus;
          _cryptomusApiKeyTxtEdit.text = _cryptomus!.apiKey;
          _cryptomusMerchantIdTxtEdit.text = _cryptomus!.password;
          _cryptomusIsActive = _cryptomus!.isActive;
        } else {
          _cryptomus = null;
          _cryptomusApiKeyTxtEdit.clear();
          _cryptomusMerchantIdTxtEdit.clear();
          _cryptomusIsActive = false;
        }
      });
    }

    if (mounted) setState(() => _showData = true);
  }

  void _newPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppStyle.secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.add_card, color: Colors.white70),
              SizedBox(width: 8),
              Text('افزودن پرداخت آفلاین'),
            ],
          ),
          content: SizedBox(
            width: Responsive.isMobile(context) ? double.maxFinite : 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _newPaymentNameTxtEdit,
                  decoration: _fieldDecoration(
                    label: 'نام روش پرداخت',
                    icon: Icons.label_outline,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPaymentMerchantIdTxtEdit,
                  textDirection: TextDirection.ltr,
                  decoration: _fieldDecoration(
                    label: 'شماره حساب / آدرس واریز',
                    icon: Icons.numbers,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyle.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                EasyLoading.show();
                if (_newPaymentNameTxtEdit.text.isNotEmpty &&
                    _newPaymentMerchantIdTxtEdit.text.isNotEmpty) {
                  final res = await addNewOfflinePaymentType(
                    merchantId: _newPaymentMerchantIdTxtEdit.text,
                    name: _newPaymentNameTxtEdit.text,
                  );
                  if (res) {
                    _newPaymentMerchantIdTxtEdit.clear();
                    _newPaymentNameTxtEdit.clear();
                    paymentTypeChangedToken = 'paymentTypeChanged';
                    if (context.mounted) {
                      showMsg(msg: 'اضافه گردید', context: context);
                      Navigator.pop(context);
                    }
                    paymentTypeotifier.changedPaymentTypeData();
                  }
                } else {
                  if (context.mounted) {
                    Navigator.pop(context);
                    showMsg(msg: 'خطا.', context: context, type: 'error');
                  }
                  paymentTypeotifier.changedPaymentTypeData();
                }
                EasyLoading.dismiss();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('افزودن'),
            ),
          ],
        ),
      ),
    );
  }
}
