import 'package:flutter/material.dart';
import 'package:powerps/screens/admin_screen/reports/report_tabs/configs_report_tab_screen.dart';
import 'package:powerps/screens/admin_screen/reports/report_tabs/users_report_tab_screen.dart';
import 'package:powerps/screens/admin_screen/reports/report_tabs/financial_report_tab_screen.dart';
import 'package:powerps/screens/admin_screen/reports/report_tabs/summary_report_tab_screen.dart';
import 'package:powerps/styles/app_theme.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.all(AppStyle.defaultPadding),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppStyle.secondaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: DefaultTabController(
                    length: 4,
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        title: Row(
                          children: [
                            Icon(Icons.analytics, color: AppStyle.primaryColor),
                            const SizedBox(width: 10),
                            const Text('مرکز گزارشات و آمار'),
                          ],
                        ),
                        bottom: TabBar(
                          isScrollable: true,
                          indicatorColor: AppStyle.primaryColor,
                          labelColor: AppStyle.primaryColor,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Tab(
                                text: 'خلاصه وضعیت',
                                icon: Icon(Icons.dashboard_outlined)),
                            Tab(
                                text: 'کاربران',
                                icon: Icon(Icons.people_outline)),
                            Tab(
                                text: 'تراکنش‌ها',
                                icon: Icon(
                                    Icons.account_balance_wallet_outlined)),
                            Tab(
                                text: 'جستجوی کانفیگ',
                                icon: Icon(Icons.search_outlined)),
                          ],
                        ),
                      ),
                      body: const TabBarView(
                        children: [
                          SummaryReportTab(),
                          UsersReportTab(),
                          FinancialReportTab(),
                          ConfigsReportTab(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
