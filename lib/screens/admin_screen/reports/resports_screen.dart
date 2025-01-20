import 'package:flutter/material.dart';
import 'package:powerps/screens/admin_screen/reports/report_tabs/configs_report_tab_screen.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(AppStyle.defaultPadding),
                decoration: BoxDecoration(
                  color: AppStyle.secondaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: AppStyle.secondaryColor,
                      automaticallyImplyLeading: true,
                      title: Text(
                        'گزارشگیری از بسته ها و درآمدها',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      bottom: const TabBar(
                          tabs: [Tab(text: 'بسته‌ها'), Tab(text: 'درآمدها')]),
                    ),
                    body: const TabBarView(
                      children: [
                        ConfigsReportTab(),
                        Text("Accounting"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
