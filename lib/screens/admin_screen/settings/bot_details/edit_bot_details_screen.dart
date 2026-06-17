import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/setting_model.dart';
import 'package:powerps/repositories/setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class EditBotDetailsScreen extends StatefulWidget {
  const EditBotDetailsScreen({super.key});

  @override
  State<EditBotDetailsScreen> createState() => _EditBotDetailsScreenState();
}

class _EditBotDetailsScreenState extends State<EditBotDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late Setting _setting;
  bool _showData = false;
  bool _obscureToken = true;

  final _botNameTxtEdit = TextEditingController();
  final _botTokenTxtEdit = TextEditingController();
  final _adminIdTxtEdit = TextEditingController();
  final _panelAddressTxtEdit = TextEditingController();
  final _configNamePrefixTxtEdit = TextEditingController();
  final _configNameFormatTxtEdit = TextEditingController();
  bool _useAdminAliasInConfigName = true;

  static const _formatPlaceholders = [
    '{prefix}',
    '{account_id}',
    '{account_label}',
    '{chat_id}',
    '{product_id}',
    '{random}',
  ];

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
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppStyle.primaryColor),
      suffixIcon: suffix,
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
    _configNamePrefixTxtEdit.addListener(_refreshPreview);
    _configNameFormatTxtEdit.addListener(_refreshPreview);
    _fillData();
    super.initState();
  }

  void _refreshPreview() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _configNamePrefixTxtEdit.removeListener(_refreshPreview);
    _configNameFormatTxtEdit.removeListener(_refreshPreview);
    _botNameTxtEdit.dispose();
    _botTokenTxtEdit.dispose();
    _adminIdTxtEdit.dispose();
    _panelAddressTxtEdit.dispose();
    _configNamePrefixTxtEdit.dispose();
    _configNameFormatTxtEdit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
          backgroundColor: AppStyle.bgColor,
          appBar: appBarWithBackButton(
            context: context,
            title: 'ویرایش اطلاعات ربات',
          ),
          bottomNavigationBar:
              _showData && Responsive.isMobile(context) ? _mobileSaveBar() : null,
          body: _showData
              ? Responsive(
                  mobile: _mobileBody(),
                  tablet: _desktopBody(),
                  desktop: _desktopBody(),
                )
              : const Center(child: CircularProgressIndicator()),
        );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Responsive.isMobile(context) ? SafeArea(child: scaffold) : scaffold,
    );
  }

  Widget _mobileBody() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: Responsive.adminPagePadding(context),
        children: [
        _pageHeader(compact: true),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'اتصال و هویت ربات',
          icon: Icons.smart_toy_outlined,
          child: _connectionFields(twoColumn: false),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'نام‌گذاری کانفیگ',
          icon: Icons.badge_outlined,
          child: _configNamingFields(twoColumn: false),
        ),
        const SizedBox(height: 16),
        _previewPanel(compact: true),
        const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _desktopBody() {
    return SingleChildScrollView(
      padding: Responsive.adminPagePadding(context),
      child: SizedBox(
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _pageHeader(compact: false),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _sectionCard(
                          title: 'اتصال و هویت ربات',
                          icon: Icons.smart_toy_outlined,
                          child: _connectionFields(twoColumn: true),
                        ),
                        const SizedBox(height: 12),
                        _sectionCard(
                          title: 'نام‌گذاری کانفیگ',
                          icon: Icons.badge_outlined,
                          child: _configNamingFields(twoColumn: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _previewPanel(compact: false),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: _saveButton(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            child: Icon(Icons.settings_suggest_outlined,
                color: AppStyle.primaryColor, size: compact ? 28 : 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنظیمات ربات تلگرام',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'اطلاعات اتصال BotFather و قالب نام کاربران در پنل VPN',
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
  }) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppStyle.primaryColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
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

  Widget _connectionFields({required bool twoColumn}) {
    final nameAdmin = twoColumn
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _botNameField()),
              const SizedBox(width: 12),
              Expanded(child: _adminIdField()),
            ],
          )
        : Column(
            children: [
              _botNameField(),
              const SizedBox(height: 14),
              _adminIdField(),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        nameAdmin,
        const SizedBox(height: 14),
        _botTokenField(),
        const SizedBox(height: 14),
        _panelAddressField(),
      ],
    );
  }

  Widget _configNamingFields({required bool twoColumn}) {
    final prefixFormat = twoColumn
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _configPrefixField()),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _configFormatField()),
            ],
          )
        : Column(
            children: [
              _configPrefixField(),
              const SizedBox(height: 14),
              _configFormatField(),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        prefixFormat,
        const SizedBox(height: 12),
        _placeholderChips(),
        const SizedBox(height: 14),
        _aliasSwitchTile(),
      ],
    );
  }

  Widget _botNameField() {
    return TextFormField(
      controller: _botNameTxtEdit,
      textDirection: TextDirection.ltr,
      decoration: _fieldDecoration(
        label: 'نام ربات',
        hint: '@botSeller',
        icon: Icons.alternate_email,
      ),
      validator: (v) => v == null || v.trim().isEmpty ? 'نام ربات را وارد کنید' : null,
    );
  }

  Widget _botTokenField() {
    return TextFormField(
      controller: _botTokenTxtEdit,
      textDirection: TextDirection.ltr,
      obscureText: _obscureToken,
      decoration: _fieldDecoration(
        label: 'توکن ربات',
        hint: '123456789:ABCDEF...',
        icon: Icons.vpn_key_outlined,
        suffix: IconButton(
          icon: Icon(
            _obscureToken ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.white54,
            size: 20,
          ),
          onPressed: () => setState(() => _obscureToken = !_obscureToken),
        ),
      ),
      validator: (v) => v == null || v.trim().isEmpty ? 'توکن را وارد کنید' : null,
    );
  }

  Widget _adminIdField() {
    return TextFormField(
      controller: _adminIdTxtEdit,
      textDirection: TextDirection.ltr,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _fieldDecoration(
        label: 'ID ادمین',
        hint: '123456789',
        icon: Icons.admin_panel_settings_outlined,
      ),
      validator: (v) => v == null || v.trim().isEmpty ? 'آیدی ادمین را وارد کنید' : null,
    );
  }

  Widget _panelAddressField() {
    return TextFormField(
      controller: _panelAddressTxtEdit,
      textDirection: TextDirection.ltr,
      keyboardType: TextInputType.url,
      decoration: _fieldDecoration(
        label: 'آدرس هسته ربات',
        hint: 'https://your-domain.com',
        icon: Icons.link_outlined,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'آدرس را وارد کنید';
        final uri = Uri.tryParse(v.trim());
        if (uri == null || !uri.isAbsolute) return 'آدرس معتبر نیست';
        return null;
      },
    );
  }

  Widget _configPrefixField() {
    return TextFormField(
      controller: _configNamePrefixTxtEdit,
      textDirection: TextDirection.ltr,
      decoration: _fieldDecoration(
        label: 'پیشوند نام کانفیگ',
        hint: 'bot',
        icon: Icons.label_outline,
      ),
      validator: (v) => v == null || v.trim().isEmpty ? 'پیشوند را وارد کنید' : null,
    );
  }

  Widget _configFormatField() {
    return TextFormField(
      controller: _configNameFormatTxtEdit,
      textDirection: TextDirection.ltr,
      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      decoration: _fieldDecoration(
        label: 'قالب نام کانفیگ',
        hint: '{prefix}{account_label}',
        icon: Icons.text_fields_outlined,
      ),
      validator: (v) => v == null || v.trim().isEmpty ? 'قالب را وارد کنید' : null,
    );
  }

  Widget _placeholderChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'متغیرهای قالب — برای افزودن به قالب لمس کنید',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _formatPlaceholders.map((placeholder) {
            return ActionChip(
              label: Text(
                placeholder,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
              backgroundColor: AppStyle.bgColor.withValues(alpha: 0.6),
              side: BorderSide(color: AppStyle.primaryColor.withValues(alpha: 0.35)),
              labelStyle: TextStyle(color: AppStyle.primaryColor.withValues(alpha: 0.9)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: () => _insertPlaceholder(placeholder),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _insertPlaceholder(String placeholder) {
    final controller = _configNameFormatTxtEdit;
    final text = controller.text;
    final selection = controller.selection;

    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, placeholder);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + placeholder.length),
    );
  }

  Widget _aliasSwitchTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'استفاده از نام مستعار',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          'در صورت وجود نام مستعار، به‌جای آیدی تلگرام در ساخت اکانت استفاده شود',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
        ),
        value: _useAdminAliasInConfigName,
        activeThumbColor: AppStyle.primaryColor,
        onChanged: (value) => setState(() => _useAdminAliasInConfigName = value),
      ),
    );
  }

  Widget _previewPanel({required bool compact}) {
    final preview = Setting(
      id: '',
      botName: '',
      adminId: '',
      botToken: '',
      panelAddress: '',
      configNamePrefix: _configNamePrefixTxtEdit.text,
      configNameFormat: _configNameFormatTxtEdit.text,
      useAdminAliasInConfigName: _useAdminAliasInConfigName,
    ).configNamePreview(useAdminAlias: _useAdminAliasInConfigName);

    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppStyle.primaryColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.preview_outlined, color: AppStyle.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'پیش‌نمایش زنده',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: AppStyle.bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: SelectableText(
              preview,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppStyle.primaryColor,
                fontFamily: 'monospace',
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _previewLegend(
            label: 'با نام مستعار',
            sample: _useAdminAliasInConfigName ? 'فعال' : 'غیرفعال',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 6),
          _previewLegend(
            label: 'پیشوند',
            sample: _configNamePrefixTxtEdit.text.isEmpty
                ? 'bot'
                : _configNamePrefixTxtEdit.text,
            icon: Icons.label_outline,
          ),
          const SizedBox(height: 10),
          Text(
            'سانائی: اگر {random} در قالب نباشد، پسوند تصادفی اضافه می‌شود.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _previewLegend({
    required String label,
    required String sample,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const Spacer(),
        Text(
          sample,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _mobileSaveBar() {
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
      child: SafeArea(top: false, child: _saveButton()),
    );
  }

  Widget _saveButton() {
    return ElevatedButton.icon(
      onPressed: _submitData,
      icon: const Icon(Icons.check_circle_outline, size: 20),
      label: const Text('ثبت تغییرات', style: TextStyle(fontSize: 15)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppStyle.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _fillData() async {
    await getBotSetting().then((value) {
      if (!mounted) return;
      if (value != null) {
        setState(() {
          _setting = value;
          _botNameTxtEdit.text = _setting.botName;
          _adminIdTxtEdit.text = _setting.adminId;
          _botTokenTxtEdit.text = _setting.botToken;
          _panelAddressTxtEdit.text = _setting.panelAddress;
          _configNamePrefixTxtEdit.text = _setting.configNamePrefix;
          _configNameFormatTxtEdit.text = _setting.configNameFormat;
          _useAdminAliasInConfigName = _setting.useAdminAliasInConfigName;
          _showData = true;
        });
      } else {
        setState(() {
          _setting = Setting(
            adminId: 'تعریف نشده',
            botName: 'تعریف نشده',
            botToken: 'تعریف نشده',
            id: 'تعریف نشده',
            panelAddress: 'تعریف نشده',
            configNamePrefix: 'bot',
            configNameFormat: '{prefix}{account_label}',
            useAdminAliasInConfigName: true,
          );
          _showData = true;
        });
      }
    });
  }

  Future<void> _submitData() async {
    if (Responsive.isMobile(context)) {
      if (!_formKey.currentState!.validate()) return;
    } else if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    if (_botNameTxtEdit.text.isEmpty ||
        _botTokenTxtEdit.text.isEmpty ||
        _adminIdTxtEdit.text.isEmpty ||
        _panelAddressTxtEdit.text.isEmpty ||
        _configNamePrefixTxtEdit.text.isEmpty ||
        _configNameFormatTxtEdit.text.isEmpty) {
      return;
    }

    try {
      EasyLoading.show(status: '...در حال ثبت اطلاعات');

      final set = Setting(
        id: _setting.id,
        botName: _botNameTxtEdit.text,
        adminId: _adminIdTxtEdit.text,
        botToken: _botTokenTxtEdit.text,
        panelAddress: _panelAddressTxtEdit.text,
        configNamePrefix: _configNamePrefixTxtEdit.text.trim(),
        configNameFormat: _configNameFormatTxtEdit.text.trim(),
        useAdminAliasInConfigName: _useAdminAliasInConfigName,
      );

      final res = await updateBotSetting(setting: set);
      EasyLoading.dismiss();

      if (!mounted) return;

      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('دخیره شد', textDirection: TextDirection.rtl),
            backgroundColor: Colors.blue,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطا در ذخیره', textDirection: TextDirection.rtl),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint(e.toString());
    }
  }
}
