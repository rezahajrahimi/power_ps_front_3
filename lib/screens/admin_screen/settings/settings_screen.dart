import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/advanced_setting_model.dart';
import 'package:powerps/models/details_info.dart';
import 'package:powerps/models/setting_model.dart';
import 'package:powerps/screens/admin_screen/settings/admins/manage_admins_screen.dart';
import 'package:powerps/screens/admin_screen/settings/agent/agents_manage_screen.dart';
import 'package:powerps/screens/admin_screen/settings/applications/applications_screen.dart';
import 'package:powerps/screens/admin_screen/settings/bot_details/edit_bot_details_screen.dart';
import 'package:powerps/screens/admin_screen/settings/channel_lock/channel_lock_screen.dart';
import 'package:powerps/screens/admin_screen/settings/cronjobs/cronjob_managing_screen.dart';
import 'package:powerps/screens/admin_screen/settings/gif_card/gif_card_details_screen.dart';
import 'package:powerps/screens/admin_screen/settings/main_menu_item/main_menu_item_screen.dart';
import 'package:powerps/screens/admin_screen/settings/pannel/pannel_screen.dart';
import 'package:powerps/screens/admin_screen/settings/payment_type/payment_type_details_screen.dart';
import 'package:powerps/screens/admin_screen/settings/user_groups/user_groups_manage_screen.dart';
import 'package:powerps/screens/admin_screen/settings/referral/referral_screen.dart';
import 'package:powerps/screens/admin_screen/settings/promo/promo_codes_screen.dart';
import 'package:powerps/screens/admin_screen/settings/marketing/marketing_campaign_screen.dart';
import 'package:powerps/screens/admin_screen/settings/reports/group_operations_screen.dart';
import 'package:powerps/screens/admin_screen/settings/support%20and%20faq/support_and_faq_screen.dart';
import 'package:powerps/screens/admin_screen/settings/test_accounts/test_account_management_screen.dart';
import 'package:powerps/repositories/setting_repository.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/helper/license_helper.dart';
import 'package:powerps/widgets/public/license_gate_dialog.dart';
import 'package:powerps/screens/admin_screen/settings/text/text_screen_screen.dart';
import 'package:powerps/screens/admin_screen/settings/appinfo/app_info_manage_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/details_info_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:powerps/widgets/setting/advanced_setting_info_widget.dart';
import 'package:powerps/widgets/setting/advanced_setting_choice_widget.dart';

import 'backup/backup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showData = false;
  bool _showAdvancedSetting = false;
  String _licenseType = '';
  late Setting _setting;
  final List<Widget> _advancedSettingWidgetList = [];
  final List<Widget> _advancedSettingChoiceWidgetList = [];
  @override
  void initState() {
    _fillData();
    _loadLicenseType();
    super.initState();
  }

  bool get _isGoldLicense => LicenseHelper.isGold(_licenseType);
  bool get _isSilverOrAbove => LicenseHelper.isSilverOrAbove(_licenseType);

  void _navigateGated({
    required bool allowed,
    required String title,
    required String message,
    required String requiredTier,
    required Widget screen,
  }) {
    if (allowed) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      return;
    }
    showLicenseGateDialog(
      context: context,
      title: title,
      message: message,
      requiredTier: requiredTier,
    );
  }

  Future<void> _loadLicenseType() async {
    final type = await getLicenseType();
    if (mounted) {
      setState(() => _licenseType = type);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SingleChildScrollView(
            primary: false,
            child: Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: Column(
                children: [
                  // const Header(title: "تنظیمات"),
                  // SizedBox(height: AppStyle.defaultPadding),
                  _content(context),
                ],
              ),
            ),
          ),
          // bottomNavigationBar: Responsive.isMobile(context)
          //     ? _buildBottomNavigationBar(context)
          //     : const Opacity(opacity: 1),
        ),
      ),
    );
  }

  void _fillData() async {
    await getBotSetting().then((value) {
      if (!mounted) return;
      if (null != value) {
        setState(() {
          _setting = value;
          _showData = true;
        });
      } else {
        setState(() {
          _setting = Setting(
              adminId: "تعریف نشده",
              botName: "تعریف نشده",
              botToken: "تعریف نشده",
              id: "تعریف نشده",
              panelAddress: "لینک هسته ربات را وارد کنید");
          _showData = true;
        });
      }
    });
    await getBotAdvancedSetting().then((value) {
      if (!mounted) return;
      if (value.isNotEmpty && value != null) {
        _advancedSettingWidgetList.clear();
        _advancedSettingChoiceWidgetList.clear();
        for (var item in value) {
          if (item.name == 'bot_show_one_row_config') {
            continue;
          }

          if (AdvancedSettingModel.isChoiceSetting(item.name)) {
            _advancedSettingChoiceWidgetList.add(AdvancedSettingChoiceWidget(
              name: item.name,
              value: item.value,
              options: AdvancedSettingModel.packageButtonLayoutOptions,
              description: AdvancedSettingModel.displayDescription(
                item.name,
                item.description,
              ),
            ));
            continue;
          }

          _advancedSettingWidgetList.add(AdvancedSettingInfoWidget(
            state: item.value == "true" ? true : false,
            description: AdvancedSettingModel.displayDescription(
              item.name,
              item.description,
            ),
            name: item.name,
          ));
        }
        setState(() {
          _showAdvancedSetting = true;
        });
      }
    });
  }

  _content(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _showData
                      ? _robotInfoTabCard(context)
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                  SizedBox(height: AppStyle.defaultPadding),
                  if (Responsive.isMobile(context)) _operationInfoCard(context),
                  if (Responsive.isMobile(context))
                    SizedBox(height: AppStyle.defaultPadding),
                  _showAdvancedSetting
                      ? _advancedSettingTabCard(context)
                      : Container(),
// side bar mobile
                ],
              ),
            ),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            // On Mobile means if the screen is less than 850 we dont want to show it
            if (!Responsive.isMobile(context)) // side windows
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _operationInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        )
      ],
    );
  }

  _robotInfoTabCard(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    List<Widget> factoryWidgetList = [
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نام ربات",
        itemValue: _setting.botName.length > 30
            ? "${_setting.botName.substring(0, 30)}..."
            : _setting.botName,
        icon: const Icon(Icons.smart_toy_outlined, color: Colors.blue),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "token ربات",
        itemValue: _setting.botToken.length > 30
            ? "${_setting.botToken.substring(0, 30)}..."
            : _setting.botToken,
        icon: const Icon(Icons.vpn_key_outlined, color: Colors.orange),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "ID ادمین ربات",
        itemValue: _setting.adminId,
        icon: const Icon(Icons.admin_panel_settings_outlined,
            color: Colors.green),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "لینک اتصال به دامنه (هسته ربات)",
        itemValue: _setting.panelAddress.length > 30
            ? "${_setting.panelAddress.substring(0, 30)}..."
            : _setting.panelAddress,
        icon: const Icon(Icons.link_outlined, color: Colors.purple),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "پیشوند نام کانفیگ",
        itemValue: _setting.configNamePrefix,
        icon: const Icon(Icons.badge_outlined, color: Colors.teal),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "قالب نام کانفیگ",
        itemValue: _setting.configNameFormat,
        icon: const Icon(Icons.text_fields_outlined, color: Colors.cyan),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نام مستعار در کانفیگ",
        itemValue: _setting.useAdminAliasInConfigName ? "فعال" : "غیرفعال",
        icon: const Icon(Icons.person_outline, color: Colors.indigo),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نمونه نام کانفیگ",
        itemValue: _setting.configNamePreview(),
        icon: const Icon(Icons.preview_outlined, color: Colors.amber),
      )),
    ];

    List<Widget> actionsWidgetList = [
      _buildSettingButton(
        context: context,
        label: "ویرایش اطلاعات",
        icon: Icons.edit_outlined,
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditBotDetailsScreen(),
              )).then((value) => {
                _fillData(),
              });
        },
      ),
    ];

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
              Icon(Icons.info_outline, color: AppStyle.primaryColor),
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
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: factoryWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: factoryWidgetList),
              desktop: widgetsGridview(
                  importedList: factoryWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 4 : 4.5,
                  crossAxisCount: 2),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 4,
                  context: context,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2,
                  importedList: actionsWidgetList),
              desktop: widgetsGridview(
                  importedList: actionsWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 4 : 5.5,
                  crossAxisCount: 4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    String? tierBadge,
    bool locked = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        locked ? Icons.lock_outline : icon,
        size: 18,
        color: color ?? Colors.white,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: color ?? Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (tierBadge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tierBadge,
                style: TextStyle(
                  color: Colors.amber.shade300,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: (color ?? AppStyle.primaryColor)
            .withValues(alpha: locked ? 0.05 : 0.1),
        foregroundColor: color ?? Colors.white,
        side: BorderSide(
            color: (color ?? AppStyle.primaryColor).withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  _operationInfoCard(BuildContext context) {
    List<Widget> actionsWidgetList = [
      _buildSettingButton(
        context: context,
        label: "تغییر متن منوها",
        icon: Icons.menu_open_outlined,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MainMenuItemsScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "درگاه ها و پرداخت",
        icon: Icons.credit_card_outlined,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PaymentTypeScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "دسته‌بندی کاربران",
        icon: Icons.groups_outlined,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UserGroupsManageScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "گیف کارت",
        icon: Icons.card_giftcard_outlined,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const GifCardScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "تنظیمات پنل‌ها",
        icon: Icons.dns_outlined,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PannelScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "پشتیبانی و سوالات",
        icon: Icons.support_agent_outlined,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SupportFaqScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "قفل ربات",
        icon: Icons.lock_outline,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChannelLockScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "برنامه‌های مورد نیاز",
        icon: Icons.app_settings_alt_outlined,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ApplicationScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "پیام‌های خودکار",
        icon: Icons.notifications_active_outlined,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CronjobManagingScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "بازاریابی و دعوت",
        icon: Icons.share_outlined,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ReferralScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "اکانت آزمایشی",
        icon: Icons.timer_outlined,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TestAccountManagementScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "مدیران",
        icon: Icons.admin_panel_settings_outlined,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ManageAdminsScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "دستیاران فروش",
        icon: Icons.people_outline,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AgentsManageScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "پشتیبان‌گیری",
        icon: Icons.backup_outlined,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const BackupScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "متن ها",
        icon: Icons.text_fields_outlined,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const TextScreenScreen())),
      ),
      _buildSettingButton(
        context: context,
        label: "برندینگ پنل",
        icon: Icons.palette_outlined,
        tierBadge: 'طلایی',
        locked: !_isGoldLicense,
        onPressed: () => _navigateGated(
          allowed: _isGoldLicense,
          title: 'برندینگ پنل (White-label)',
          message:
              'با لایسنس طلایی نام، رنگ، لوگو و فوتر پنل را شخصی‌سازی کنید و برند PowerPS را مخفی کنید.',
          requiredTier: 'طلایی',
          screen: const AppInfoManageScreen(),
        ),
      ),
      _buildSettingButton(
        context: context,
        label: "کدهای تخفیف",
        icon: Icons.discount_outlined,
        tierBadge: 'نقره',
        locked: !_isSilverOrAbove,
        onPressed: () => _navigateGated(
          allowed: _isSilverOrAbove,
          title: 'کدهای تخفیف',
          message:
              'در لایسنس نقره‌ای تا ۵ کد تخفیف ساده بسازید. نسخه طلایی محدودیت پیشرفته و تاریخچه استفاده دارد.',
          requiredTier: 'نقره‌ای',
          screen: const PromoCodesScreen(),
        ),
      ),
      _buildSettingButton(
        context: context,
        label: "کمپین بازاریابی",
        icon: Icons.campaign_outlined,
        tierBadge: 'طلایی',
        locked: !_isGoldLicense,
        onPressed: () => _navigateGated(
          allowed: _isGoldLicense,
          title: 'کمپین بازاریابی',
          message:
              'پیام هدفمند به سگمنت‌های مختلف کاربران بفرستید؛ با تصویر، زمان‌بندی و دکمه اقدام.',
          requiredTier: 'طلایی',
          screen: const MarketingCampaignScreen(),
        ),
      ),
      _buildSettingButton(
        context: context,
        label: "عملیات گروهی",
        icon: Icons.layers_outlined,
        tierBadge: 'نقره‌ای',
        locked: !_isSilverOrAbove,
        onPressed: () => _navigateGated(
          allowed: _isSilverOrAbove,
          title: 'عملیات گروهی',
          message:
              'مقدار زمان و حجم کانفیگ های موجود را بصورت گروهی تغییر بدهید.',
          requiredTier: 'نقره‌ای',
          screen: const GroupOperationsScreen(),
        ),
      ),
    ];

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
              Icon(Icons.settings_outlined, color: AppStyle.primaryColor),
              const SizedBox(width: 10),
              Text(
                "عملیات ها",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 5,
                  context: context,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              desktop: widgetsGridview(
                  importedList: actionsWidgetList,
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _advancedSettingTabCard(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.stars_outlined, color: Colors.amber),
                  const SizedBox(width: 10),
                  Text(
                    "تنظیمات پیشرفته",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              IconButton(
                tooltip: "بازنشانی تنظیمات پیش فرض",
                onPressed: () async {
                  _advancedSettingWidgetList.clear();
                  _advancedSettingChoiceWidgetList.clear();
                  _restoreAdvancedSettings();
                },
                icon: const Icon(Icons.refresh, color: Colors.white70),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          if (_advancedSettingChoiceWidgetList.isNotEmpty) ...[
            ..._advancedSettingChoiceWidgetList,
            SizedBox(height: AppStyle.defaultPadding),
          ],
          if (_advancedSettingWidgetList.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.9,
                    context: context,
                    importedList: _advancedSettingWidgetList),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: _advancedSettingWidgetList),
                desktop: widgetsGridview(
                    importedList: _advancedSettingWidgetList,
                    context: context,
                    childAspectRatio: size.width < 1400 ? 4 : 4.5,
                    crossAxisCount: 2),
              ),
            ),
        ],
      ),
    );
  }

  void _restoreAdvancedSettings() async {
    showDialog(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppStyle.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.refresh, color: Colors.orangeAccent),
                  SizedBox(width: 10),
                  Text("بازنشانی تنظیمات",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
              content: const Text(
                  "آیا از بازنشانی تنظیمات پیش فرض مطمئن هستید؟",
                  style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("انصراف",
                        style: TextStyle(color: Colors.white60))),
                ElevatedButton(
                    onPressed: () async {
                      EasyLoading.showInfo("در حال بازنشانی");
                      await restoreToDefaultAdvancedSettings().then((val) {
                        if (val) {
                          EasyLoading.dismiss();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          setState(() {
                            _showAdvancedSetting = false;
                          });

                          _fillData();
                          EasyLoading.showInfo("بازنشانی با موفقیت انجام شد.");
                        } else {
                          EasyLoading.showError("خطا");
                        }
                      }).catchError((e) {
                        EasyLoading.dismiss();
                        EasyLoading.showError("خطا");
                      });
                    },
                    child: const Text("بازنشانی")),
              ],
            ),
          );
        });
  }
}

class OprWidget extends StatelessWidget {
  const OprWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50.0,
        decoration: BoxDecoration(
          color: AppStyle.primaryColor,
        ),
        child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.list,
                color: Colors.white,
              ),
              SizedBox(
                width: 4.0,
              ),
              Text(
                "عملیات",
                style: TextStyle(color: Colors.white),
              ),
            ]));
  }
}
