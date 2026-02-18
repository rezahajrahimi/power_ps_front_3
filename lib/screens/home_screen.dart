import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/helper/shared_prefrencess.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/provider/auth_provider.dart';
import 'package:powerps/provider/menu_provider.dart';
import 'package:powerps/screens/admin_screen/admin_dashboard_screen.dart';
import 'package:powerps/screens/admin_screen/logs/log_list_screen.dart';
import 'package:powerps/screens/admin_screen/product/product_category_screen.dart';
import 'package:powerps/screens/admin_screen/settings/settings_screen.dart';
import 'package:powerps/screens/admin_screen/transaction/transaction_list_screen.dart';
import 'package:powerps/screens/admin_screen/user/bot_users_screen.dart';
import 'package:powerps/screens/admin_screen/reports/resports_screen.dart';
import 'package:powerps/repositories/authenticatiom_repository.dart';
import 'package:powerps/screens/agent_screen/agent_dashboard_screen.dart';
import 'package:powerps/screens/user_screens/user_dashboard_screen.dart';
import 'package:powerps/widgets/public/header_widget.dart';
import 'package:powerps/widgets/public/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final int selectedPage;

  const HomeScreen({super.key, required this.selectedPage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  String _currentPageName = "داشبورد";
  late User loggedUSer;
  static final List<Widget> _adminPages = <Widget>[
    const AdminDashboardScreen(),
    const SettingsScreen(),
    const ProductCategoryScreen(),
    const TransactionListScreen(),
    const BotUsersScreen(),
    const LogsListScreen(),
    const ReportScreen(),
  ];

  static final List<Widget> _agentPages = <Widget>[
    const AgentDashboardScreen(),
  ];
  static final List<Widget> _userPages = <Widget>[
    const USerDasboardScreen(),
  ];
  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: _selectDrawer(context),
    );
  }

  _selectDrawer(BuildContext context) {
    if (loggedUSer.role == "admin") {
      return _adminItems(context);
    } else if (loggedUSer.role == "agent" || loggedUSer.role == "user") {
      return _agentItems(context);
    } else {
      return Container();
    }
  }

  Scaffold _adminItems(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      appBar: Header(title: _currentPageName),
      drawer: SideMenu(
        logedUser: loggedUSer,
        currentPage: _currentPageName,
        callback: (val) {
          if (val == "dashboard") {
            _onItemTapped(0);
            setState(() {
              _currentPageName = "داشبورد";
            });
          }
          if (val == "settings") {
            _onItemTapped(1);
            setState(() {
              _currentPageName = "تنظیمات";
            });
          }
          if (val == "configs") {
            _onItemTapped(2);
            setState(() {
              _currentPageName = "کانفیگ ها";
            });
          }
          if (val == "transactions") {
            _onItemTapped(3);
            setState(() {
              _currentPageName = "تراکنش ها";
            });
          }
          if (val == "botUsers") {
            _onItemTapped(4);
            setState(() {
              _currentPageName = "کاربران";
            });
          }
          if (val == "logs") {
            _onItemTapped(5);
            setState(() {
              _currentPageName = "رخدادها";
            });
          }
          if (val == "reports") {
            _onItemTapped(6);
            setState(() {
              _currentPageName = "گزارشات";
            });
          }

          context
              .read<MenuAppController>()
              .scaffoldKey
              .currentState!
              .closeDrawer();
        },
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(
                  logedUser: loggedUSer,
                  currentPage: _currentPageName,
                  callback: (val) {
                    if (val == "dashboard") {
                      _onItemTapped(0);
                      setState(() {
                        _currentPageName = "داشبورد";
                      });
                    }
                    if (val == "settings") {
                      _onItemTapped(1);
                      setState(() {
                        _currentPageName = "تنظیمات";
                      });
                    }
                    if (val == "configs") {
                      _onItemTapped(2);
                      setState(() {
                        _currentPageName = "کانفیگ‌ها";
                      });
                    }
                    if (val == "transactions") {
                      _onItemTapped(3);
                      setState(() {
                        _currentPageName = "تراکنش‌ها";
                      });
                    }
                    if (val == "botUsers") {
                      _onItemTapped(4);
                      setState(() {
                        _currentPageName = "کاربران";
                      });
                    }
                    if (val == "logs") {
                      _onItemTapped(5);
                      setState(() {
                        _currentPageName = "رخدادها";
                      });
                    }
                    if (val == "reports") {
                      _onItemTapped(6);
                      setState(() {
                        _currentPageName = "گزارشات";
                      });
                    }
                  },
                ),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: _adminPages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }

  Scaffold _agentItems(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      appBar: Header(title: _currentPageName),
      drawer: SideMenu(
        logedUser: loggedUSer,
        currentPage: _currentPageName,
        callback: (val) {
          if (val == "dashboard") {
            _onItemTapped(0);
            setState(() {
              _currentPageName = "داشبورد";
            });
          }

          context
              .read<MenuAppController>()
              .scaffoldKey
              .currentState!
              .closeDrawer();
        },
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(
                  logedUser: loggedUSer,
                  currentPage: _currentPageName,
                  callback: (val) {
                    if (val == "dashboard") {
                      _onItemTapped(0);
                      setState(() {
                        _currentPageName = "داشبورد";
                      });
                    }
                  },
                ),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: loggedUSer.role == "agent"
                  ? _agentPages[_selectedIndex]
                  : _userPages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _fillData() async {
    //     if (context.mounted) {
    // }
    setState(() {
      _selectedIndex = widget.selectedPage;

      loggedUSer =
          Provider.of<AuthChangeController>(context, listen: false).getUser();
    });
    await getlogedUserData().then((onValue) {
      if (onValue != false) {
        // when a have a user page, wee have to remove if statement

        setState(() {
          Provider.of<AuthChangeController>(context, listen: false)
              .setUser(onValue);
          loggedUSer = Provider.of<AuthChangeController>(context, listen: false)
              .getUser();
        });
      } else {
        logOut().then((value) {
          if (!mounted) return;
          if (value == true) {
            clearSharedPrfrence();
            Navigator.pushReplacementNamed(context, '/login');
          } else {
            Navigator.pushReplacementNamed(context, '/login');

            showMsg(msg: "خطا", context: context, type: "error");
          }
        });
      }
    });
  }
}
