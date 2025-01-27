import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

import 'package:powerps/helper/responsive.dart';
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
import 'package:powerps/screens/admin_screen/settings/referral/referral_screen.dart';
import 'package:powerps/screens/admin_screen/settings/support%20and%20faq/support_and_faq_screen.dart';
import 'package:powerps/screens/admin_screen/settings/test_accounts/edit_test_account_details_screen.dart';
import 'package:powerps/repositories/setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/details_info_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:powerps/widgets/setting/advanced_setting_info_widget.dart';

import 'backup/backup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showData = false;
  bool _showAdvancedSetting = false;
  late Setting _setting;
  final List<Widget> _advancedSettingWidgetList = [];
  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
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
        ),
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : const Opacity(opacity: 1),
      ),
    );
  }

  void _fillData() async {
    await getBotSetting().then((value) {
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
              panelAddress: "لینک هسته ربات را وارد کنید",
              welcomeMessage: "تعریف نشده");
          _showData = true;
        });
      }
    });
    await getBotAdvancedSetting().then((value) {
      if (value.isNotEmpty) {
        for (var item in value) {
          _advancedSettingWidgetList.add(AdvancedSettingInfoWidget(
            state: item.value == "true" ? true : false,
            description: item.description,
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
                  _showAdvancedSetting
                      ? _advancedSettingTabCard(context)
                      : Container(),
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

    List<Widget> factoryWidgetList = [];
    List<Widget> actionsWidgetList = [];

    setState(() {
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditBotDetailsScreen(),
              )).then((value) => {
                _fillData(),
              });
        },
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش اطلاعات"),
      ));
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نام ربات",
        itemValue: _setting.botName.length > 30
            ? "${_setting.botName.substring(0, 30)}..."
            : _setting.botName,
        icon: const Icon(Icons.info),
      )));
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "token ربات",
        itemValue: _setting.botToken.length > 30
            ? "${_setting.botToken.substring(0, 30)}..."
            : _setting.botToken,
        icon: const Icon(Icons.info),
      )));
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "ID ادمین ربات",
        itemValue: _setting.adminId,
        icon: const Icon(Icons.admin_panel_settings),
      )));

      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "لینک اتصال به دامنه (هسته ربات)",
        itemValue: _setting.panelAddress.length > 30
            ? "${_setting.panelAddress.substring(0, 30)}..."
            : _setting.panelAddress,
        icon: const Icon(Icons.link),
      )));
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "متن خوش آمد گویی به کاربر",
        itemValue: _setting.welcomeMessage.length > 30
            ? "${_setting.welcomeMessage.substring(0, 30)}..."
            : _setting.welcomeMessage,
        icon: const Icon(Icons.info),
      )));
    });
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "اطلاعات ربات",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
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

  _operationInfoCard(BuildContext context) {
    List<Widget> actionsWidgetList = [];

    setState(() {
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MainMenuItemsScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.menu),
        label: const Text("تغییر متن منوها"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentTypeScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.credit_card),
        label: const Text("درگاه ها و پرداخت"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GifCardScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.discount),
        label: const Text("گیف کارت"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PannelScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.input),
        label: const Text("تنظیمات پنل‌ها"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SupportFaqScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.support),
        label: const Text("پشتتیبانی و سوالات"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChannelLockScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.lock),
        label: const Text("قفل ربات"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ApplicationScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.app_settings_alt),
        label: const Text("برنامه‌های مورد نیاز"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CronjobManagingScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.notifications),
        label: const Text("پیام‌های خودکار"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReferralScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.featured_play_list_sharp),
        label: const Text("بازاریابی و لینک دعوت"),
      ));

      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditTestAccountDetailsScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.first_page),
        label: const Text("اکانت آزمایشی"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageAdminsScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.admin_panel_settings),
        label: const Text("مدیران"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AgentsManageScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.supervised_user_circle),
        label: const Text("دستیاران فروش"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BackupScreen(),
              )).then((value) => {});
        },
        icon: const Icon(Icons.backup),
        label: const Text("پشتیبان‌گیری و بازیابی"),
      ));
    });
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
            "عملیات ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
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

  _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: FocusedMenuHolder(
              menuWidth: MediaQuery.of(context).size.width * 0.50,
              menuItems: [
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("تغییر متن منوها"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainMenuItemsScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.menu)),
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("درگاه ها و پرداخت"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentTypeScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.credit_card)),
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("گیف کارت"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GifCardScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.discount)),
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("تنظیمات پنل‌ها"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PannelScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.input)),
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("پشتتیبانی و سوالات"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupportFaqScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.support)),
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("قفل ربات"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChannelLockScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.lock)),
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("برنامه‌های مورد نیاز"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ApplicationScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.app_settings_alt)),
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("پیام‌های خودکار"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CronjobManagingScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.notifications)),
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("بازاریابی و لینک دعوت"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReferralScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.featured_play_list_sharp)),
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("اکانت آزمایشی"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const EditTestAccountDetailsScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.first_page)),
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("دستیاران فروش"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AgentsManageScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.supervised_user_circle)),
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("مدیران"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageAdminsScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.admin_panel_settings)),
                FocusedMenuItem(
                    backgroundColor: AppStyle.primaryColor,
                    title: const Text("پشتیبان‌گیری و بازیابی"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BackupScreen(),
                          )).then((value) => {});
                    },
                    trailingIcon: const Icon(Icons.backup)),
              ],
              menuOffset: 50,
              duration: const Duration(milliseconds: 2),
              blurBackgroundColor: Colors.white70,
              animateMenuItems: true,
              openWithTap: true,
              onPressed: () {},
              child: const OprWidget(),
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
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "تنظیمات پیشرفته (اکانتهای نقره ای و طلایی)",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
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
