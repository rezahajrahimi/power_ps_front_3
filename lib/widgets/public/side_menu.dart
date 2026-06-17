import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/shared_prefrencess.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/provider/app_info_provider.dart';
import 'package:powerps/repositories/authenticatiom_repository.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'drawer_list_tile_v4_widget.dart';

class SideMenu extends StatefulWidget {
  final Function(String)? callback;
  final String? currentPage;
  final User logedUser;
  const SideMenu(
      {super.key, this.callback, this.currentPage, required this.logedUser});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  // String projectName = "";
  String _licennseType = "Trial";
  bool _showLicenseData = false;
  @override
  void initState() {
    super.initState();
    _fillProjectInfo();
  }

  @override
  Widget build(BuildContext context) {
    return _selectDrawer(context);
  }

  _selectDrawer(BuildContext context) {
    if (widget.logedUser.role == "admin") {
      return _sliderItemsTypeAdmin(context);
    } else {
      return _sliderItemsTypeAgent(context);
    }
  }

  _sliderItemsTypeAdmin(BuildContext context) {
    // Future.microtask(() {
    //   _fillProjectInfo();
    // });
    return Drawer(
      child: Column(
        children: [
          Consumer<AppInfoProvider>(
            builder: (context, appInfoProvider, _) {
              final title = appInfoProvider.displayTitle;
              final version = appInfoProvider.displayVersion;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppStyle.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        version,
                        style: TextStyle(color: AppStyle.deactiveStatus),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          DrawerListTileV4(
            title: "داشبورد",
            icon: Icons.dashboard,
            isSelected: widget.currentPage == "داشبورد" ? true : false,
            press: () {
              _callBack("dashboard");
            },
          ),
          DrawerListTileV4(
            title: "کانفیگ‌ها",
            icon: Icons.code,
            isSelected: widget.currentPage == "کانفیگ‌ها" ? true : false,
            press: () {
              _callBack("configs");
            },
          ),
          DrawerListTileV4(
            title: "کاربران",
            icon: Icons.account_box,
            isSelected: widget.currentPage == "کاربران" ? true : false,
            press: () {
              _callBack("botUsers");
            },
          ),
          DrawerListTileV4(
            title: "تراکنش‌ها",
            icon: Icons.account_balance,
            isSelected: widget.currentPage == "تراکنش‌ها" ? true : false,
            press: () {
              _callBack("transactions");
            },
          ),
          DrawerListTileV4(
            title: "گزارشات",
            icon: Icons.analytics,
            isSelected: widget.currentPage == "گزارشات" ? true : false,
            press: () {
              _callBack("reports");
            },
          ),
          DrawerListTileV4(
            title: "رخدادها",
            icon: Icons.event,
            isSelected: widget.currentPage == "رخدادها" ? true : false,
            press: () {
              _callBack("logs");
            },
          ),
          DrawerListTileV4(
            title: "تنظیمات ربات",
            icon: Icons.settings,
            isSelected: widget.currentPage == "تنظیمات" ? true : false,
            press: () {
              _callBack("settings");
            },
          ),
          DrawerListTileV4(
              icon: Icons.logout,
              press: () async {
                if (widget.currentPage != "Sign Up") {
                  logOut().then((value) {
                    if (!context.mounted) return;
                    if (value == true) {
                      clearSharedPrfrence();
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      showMsg(msg: "خطا", context: context, type: "error");
                    }
                  });
                }
              },
              title: "خروج",
              isSelected: widget.currentPage == "Sign Up" ? true : false),
          const Spacer(),
          const Divider(),
          Consumer<AppInfoProvider>(
            builder: (context, appInfoProvider, _) {
              final info = appInfoProvider.appInfo;
              final showCredit = info?.showPowerpsCredit ?? true;
              final footer = info?.footerText?.trim();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showCredit)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton.filled(
                              color: AppStyle.webBackgroundColor,
                              onPressed: () {
                                launchUrl(Uri.parse(
                                    "https://t.me/powerproxysellerchat"));
                              },
                              icon: const Icon(FontAwesomeIcons.telegram)),
                          IconButton.filled(
                              color: AppStyle.webBackgroundColor,
                              onPressed: () {
                                launchUrl(Uri.parse(
                                    "https://t.me/powerproxysellersupport"));
                              },
                              icon: const Icon(Icons.support_agent)),
                          IconButton.filled(
                              color: AppStyle.webBackgroundColor,
                              onPressed: () {
                                launchUrl(Uri.parse(
                                    "https://www.youtube.com/@powerproxyseller"));
                              },
                              icon: const Icon(FontAwesomeIcons.youtube)),
                        ],
                      ),
                    ),
                  if (footer != null && footer.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        footer,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppStyle.deactiveStatus,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          _showLicenseData
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "نوع لایسنس: $_licennseType",
                      style: TextStyle(color: AppStyle.deactiveStatus),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Drawer _sliderItemsTypeAgent(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Consumer<AppInfoProvider>(
            builder: (context, appInfoProvider, _) {
              final title = appInfoProvider.displayTitle;
              final version = appInfoProvider.displayVersion;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppStyle.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        version,
                        style: TextStyle(color: AppStyle.deactiveStatus),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),

          DrawerListTileV4(
            title: "داشبورد",
            icon: Icons.dashboard,
            isSelected: widget.currentPage == "داشبورد" ? true : false,
            press: () {
              _callBack("dashboard");
            },
          ),
          // DrawerListTileV4(
          //   title: "کانفیگ‌ها",
          //   icon: Icons.code,
          //   isSelected: widget.currentPage == "کانفیگ‌ها" ? true : false,
          //   press: () {
          //     _callBack("configs");
          //   },
          // ),
          // DrawerListTileV4(
          //   title: "رخدادها",
          //   icon: Icons.event,
          //   isSelected: widget.currentPage == "رخدادها" ? true : false,
          //   press: () {
          //     _callBack("logs");
          //   },
          // ),
          DrawerListTileV4(
              icon: Icons.logout,
              press: () async {
                if (widget.currentPage != "Sign Up") {
                  logOut().then((value) {
                    if (!context.mounted) return;
                    if (value == true) {
                      clearSharedPrfrence();
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      showMsg(msg: "خطا", context: context, type: "error");
                    }
                  });
                }
              },
              title: "خروج",
              isSelected: widget.currentPage == "Sign Up" ? true : false),
          const Spacer(),
          const Divider(),
          Consumer<AppInfoProvider>(
            builder: (context, appInfoProvider, _) {
              final info = appInfoProvider.appInfo;
              final showCredit = info?.showPowerpsCredit ?? true;
              final footer = info?.footerText?.trim();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showCredit)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton.filled(
                              color: AppStyle.webBackgroundColor,
                              onPressed: () {
                                launchUrl(Uri.parse(
                                    "https://t.me/powerproxysellerchat"));
                              },
                              icon: const Icon(FontAwesomeIcons.telegram)),
                          IconButton.filled(
                              color: AppStyle.webBackgroundColor,
                              onPressed: () {
                                launchUrl(Uri.parse(
                                    "https://t.me/powerproxysellersupport"));
                              },
                              icon: const Icon(Icons.support_agent)),
                          IconButton.filled(
                              color: AppStyle.webBackgroundColor,
                              onPressed: () {
                                launchUrl(Uri.parse(
                                    "https://www.youtube.com/@powerproxyseller"));
                              },
                              icon: const Icon(FontAwesomeIcons.youtube)),
                        ],
                      ),
                    ),
                  if (footer != null && footer.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        footer,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppStyle.deactiveStatus,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _callBack(String selectedItem) {
    widget.callback!(selectedItem);
  }

  void _fillProjectInfo() async {
    await getLicenseType().then((value) {
      if (value.isNotEmpty) {
        switch (value.toUpperCase()) {
          case "TRIAL":
            _licennseType = "آزمایشی";
            break;
          case "FREE":
            _licennseType = "برنز";
            break;
          case "BORONZE":
            _licennseType = "برنز";
            break;
          case "SILVER":
            _licennseType = "نقره‌ای";
            break;
          case "GOLD":
            _licennseType = "طلایی";
            break;
          default:
            _licennseType = "آزمایشی";
        }
      }
      if (!mounted) return;
      setState(() {
        _showLicenseData = true;
      });
    });
    // String name = await AppInfoPreference().getAppName();
    // setState(() {
    //   projectName = name;
    // });
  }
}
