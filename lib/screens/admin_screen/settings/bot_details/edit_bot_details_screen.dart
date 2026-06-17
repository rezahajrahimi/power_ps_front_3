import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/setting_model.dart';
import 'package:powerps/repositories/setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';

class EditBotDetailsScreen extends StatefulWidget {
  const EditBotDetailsScreen({super.key});

  @override
  State<EditBotDetailsScreen> createState() => _EditBotDetailsScreenState();
}

class _EditBotDetailsScreenState extends State<EditBotDetailsScreen> {
  late Setting _setting;
  bool _showData = false;
  final _botNameTxtEdit = TextEditingController();
  final _botTokenTxtEdit = TextEditingController();
  final _adminIdTxtEdit = TextEditingController();
  final _panelAddressTxtEdit = TextEditingController();
  final _configNamePrefixTxtEdit = TextEditingController();
  final _configNameFormatTxtEdit = TextEditingController();

  @override
  void initState() {
    _configNamePrefixTxtEdit.addListener(_refreshPreview);
    _configNameFormatTxtEdit.addListener(_refreshPreview);
    _fillData();
    super.initState();
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
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
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _showData == true
            ? Scaffold(
                appBar: appBarWithBackButton(
                    context: context, title: "ویرایش اطلاعات ربات"),
                bottomNavigationBar: Responsive.isMobile(context)
                    ? _buildBottomNavigationBar(context)
                    : const Opacity(opacity: 1),
                body: SingleChildScrollView(
                  primary: false,
                  padding: EdgeInsets.all(AppStyle.defaultPadding),
                  child: _showData == false
                      ? const SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: CircularProgressIndicator()))
                      : _content(context),
                ),
              )
            : const SizedBox(
                width: 50,
                height: 50,
                child: Center(child: CircularProgressIndicator())),
      ),
    );
  }

  void _fillData() async {
    await getBotSetting().then((value) {
      if (!mounted) return;
      if (null != value) {
        setState(() {
          _setting = value;
          _botNameTxtEdit.text = _setting.botName;
          _adminIdTxtEdit.text = _setting.adminId;
          _botTokenTxtEdit.text = _setting.botToken;
          _panelAddressTxtEdit.text = _setting.panelAddress;
          _configNamePrefixTxtEdit.text = _setting.configNamePrefix;
          _configNameFormatTxtEdit.text = _setting.configNameFormat;
          _showData = true;
        });
      } else {
        setState(() {
          _setting = Setting(
              adminId: "تعریف نشده",
              botName: "تعریف نشده",
              botToken: "تعریف نشده",
              id: "تعریف نشده",
              panelAddress: "تعریف نشده",
              configNamePrefix: "bot",
              configNameFormat: "{prefix}{account_label}");
          _showData = true;
        });
      }
    });
  }

  _content(BuildContext context) {
    return Column(
      children: [
        _botInfoCard(context),
        SizedBox(height: AppStyle.defaultPadding),
        if (!Responsive.isMobile(context))
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 200,
                child: _buildSubmitButton(context),
              ),
            ],
          ),
      ],
    );
  }

  _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: _buildSubmitButton(context),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        if (_botNameTxtEdit.text.isNotEmpty &&
            _botTokenTxtEdit.text.isNotEmpty &&
            _adminIdTxtEdit.text.isNotEmpty &&
            _panelAddressTxtEdit.text.isNotEmpty &&
            _configNamePrefixTxtEdit.text.isNotEmpty &&
            _configNameFormatTxtEdit.text.isNotEmpty) {
          _submitData(context);
        }
      },
      icon: const Icon(Icons.check_circle_outline),
      label: const Text("ثبت تغییرات"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppStyle.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  _botInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_outlined, color: AppStyle.primaryColor),
              const SizedBox(width: 10),
              Text(
                "اطلاعات ربات",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          _buildInputField(
            controller: _botNameTxtEdit,
            label: "نام ربات",
            hint: "@botSeller",
            helper: "نام ربات را همراه با @ وارد کنید",
            icon: Icons.alternate_email,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _buildInputField(
            controller: _botTokenTxtEdit,
            label: "توکن ربات",
            hint: "123456789:ABCDEF...",
            helper: "توکن ربات خود را از @BotFather دریافت کنید",
            icon: Icons.vpn_key_outlined,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _buildInputField(
            controller: _adminIdTxtEdit,
            label: "ID ادمین",
            hint: "123456789",
            helper: "آیدی عددی ادمین اصلی ربات",
            icon: Icons.admin_panel_settings_outlined,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _buildInputField(
            controller: _panelAddressTxtEdit,
            label: "آدرس هسته ربات",
            hint: "https://your-domain.com",
            helper: "آدرس دامنه متصل به هاست (تغییر ندهید مگر با اطمینان)",
            icon: Icons.link_outlined,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _buildInputField(
            controller: _configNamePrefixTxtEdit,
            label: "پیشوند نام کانفیگ",
            hint: "bot",
            helper: "مقدار {prefix} در قالب نام. فقط حروف و عدد انگلیسی",
            icon: Icons.badge_outlined,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _buildInputField(
            controller: _configNameFormatTxtEdit,
            label: "قالب نام کانفیگ",
            hint: "{prefix}{account_label}",
            helper:
                "متغیرها: {prefix} {account_id} {account_label} {chat_id} {product_id} {random}",
            icon: Icons.text_fields_outlined,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _configNamePreviewCard(),
        ],
      ),
    );
  }

  Widget _configNamePreviewCard() {
    final preview = Setting(
      id: '',
      botName: '',
      adminId: '',
      botToken: '',
      panelAddress: '',
      configNamePrefix: _configNamePrefixTxtEdit.text,
      configNameFormat: _configNameFormatTxtEdit.text,
    ).configNamePreview();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'پیش‌نمایش نام کانفیگ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            preview,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'سانائی: اگر {random} در قالب نباشد، -abcd به انتها اضافه می‌شود',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String helper,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        CustomTextFromFieldWidget(
          controller: controller,
          textDirection: TextDirection.ltr,
          textHint: hint,
          validationError: "$label را وارد کنید",
        ),
        const SizedBox(height: 4),
        Text(
          helper,
          style: TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }

  void _submitData(BuildContext context) async {
    bool res = false;
    try {
      EasyLoading.show(status: '...در حال ثبت اطلاعات');

      Setting set = Setting(
          id: _setting.id,
          botName: _botNameTxtEdit.text,
          adminId: _adminIdTxtEdit.text,
          botToken: _botTokenTxtEdit.text,
          panelAddress: _panelAddressTxtEdit.text,
          configNamePrefix: _configNamePrefixTxtEdit.text.trim(),
          configNameFormat: _configNameFormatTxtEdit.text.trim());

      res = await updateBotSetting(setting: set);

      if (res == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "دخیره شد",
              textDirection: TextDirection.rtl,
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ));
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "خطا",
              textDirection: TextDirection.rtl,
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ));
        }
      }
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();

      debugPrint(e.toString());
    }
  }
}
