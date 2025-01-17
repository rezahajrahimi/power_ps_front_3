import 'dart:async';

import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/dashboard_model.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/chart/last_month_imported_cubes_circle_diagram_widget.dart';
import 'package:powerps/widgets/log/recent_events_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:powerps/widgets/product_details/config_details_with_category_info_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:powerps/widgets/transaction/transaction_info_item_widget.dart';
import 'package:powerps/widgets/users/bot_user_info_item_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _showdata = false;
  Timer? _retriveDataTimer;
  Dashboard? _dashboard;
  @override
  void initState() {
    _bindAdminDashboardScreenData();

    _retriveDataTimer = Timer.periodic(const Duration(seconds: 30), ((timer) {
      _bindAdminDashboardScreenData();
    }));
    super.initState();
  }

  @override
  void dispose() {
    _retriveDataTimer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        child: _showdata == false
            ? const Text(
                "درحال دریافت اطلاعات",
                textDirection: TextDirection.rtl,
              )
            : Column(
                children: [
                  // const Header(
                  //   title: "داشبورد",
                  // ),
                  // SizedBox(height: AppStyle.defaultPadding),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _botUserInfoTabCard(context),
                            SizedBox(height: AppStyle.defaultPadding),
                            _last10SelledproductInfoItemCard(context),
                            SizedBox(height: AppStyle.defaultPadding),
                            _unconfirmedInfoTabCard(context),
                            SizedBox(height: AppStyle.defaultPadding),
                            _confirmedInfoTabCard(context),
                            SizedBox(height: AppStyle.defaultPadding),
                            RecentEvents(
                                type: "dashboard", events: _dashboard!.logs),
                            if (Responsive.isMobile(context))
                              SizedBox(height: AppStyle.defaultPadding),
                            if (Responsive.isMobile(context)) // side bar mobile
                              Column(
                                children: [
                                  SizedBox(height: AppStyle.defaultPadding),
                                  CirckeChartInfoCard(
                                    listData:
                                        _dashboard!.mostSelledProductCategory,
                                    title: "کانفیگهای فروش رفته",
                                    chartText:
                                        "کانفیگ از ${_dashboard!.mostSelledProductCategory.length} بسته",
                                  )
                                ],
                              ),
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
                              CirckeChartInfoCard(
                                listData: _dashboard!.mostSelledProductCategory,
                                title: "بیشترین فروش بسته ها",
                                chartText:
                                    "کانفیگ از ${_dashboard!.mostSelledProductCategory.length} بسته",
                              ),
                              SizedBox(height: AppStyle.defaultPadding),
                            ],
                          ),
                        ),
                    ],
                  )
                ],
              ),
      ),
    );
  }

  void _bindAdminDashboardScreenData() async {
    await getDashboardAnalytics().then((value) {
      if (null != value) {
        setState(() {
          _showdata = false;

          _dashboard = value;
          _showdata = true;
        });
      }
    }).onError((error, stackTrace) {});
  }

  _last10SelledproductInfoItemCard(BuildContext context) {
    List<Widget> mainInfoWidgetList = [];
    setState(() {
      for (var i in _dashboard!.last10ProductSelled) {
        mainInfoWidgetList.add(ConfigDetailsWithCatInfoItemWidget(
          item: i,
        ));
      }
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
            "آخرین کانفیگ های فروخته شده",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: mainInfoWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.3,
                  importedList: mainInfoWidgetList),
              desktop: widgetsGridview(
                  importedList: mainInfoWidgetList,
                  context: context,
                  childAspectRatio: 4.3,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _botUserInfoTabCard(BuildContext context) {
    List<Widget> botUserWidgetLIst = [];
    if (_dashboard!.users.isNotEmpty) {
      for (var i in _dashboard!.users) {
        botUserWidgetLIst.add(BotUserInfoItemCardWidget(
          item: i,
        ));
      }
    }
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
            "آخرین کاربران",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 3.2,
                    context: context,
                    importedList: botUserWidgetLIst),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: botUserWidgetLIst),
                desktop: widgetsGridview(
                    importedList: botUserWidgetLIst,
                    context: context,
                    childAspectRatio: 4.5,
                    crossAxisCount: 2),
              )),
        ],
      ),
    );
  }

  _unconfirmedInfoTabCard(BuildContext context) {
    List<Widget> widgetLIst = [];
    if (_dashboard!.unConTransactions.isNotEmpty) {
      for (var i in _dashboard!.unConTransactions) {
        widgetLIst.add(TransactionInfoItemCardWidget(
          item: i,
        ));
      }
    }
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
            "تراکنش‌های تایید نشده",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 3.2,
                    context: context,
                    importedList: widgetLIst),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: widgetLIst),
                desktop: widgetsGridview(
                    importedList: widgetLIst,
                    context: context,
                    childAspectRatio: 4.5,
                    crossAxisCount: 2),
              )),
        ],
      ),
    );
  }

  _confirmedInfoTabCard(BuildContext context) {
    List<Widget> widgetLIst = [];
    if (_dashboard!.conTransactions.isNotEmpty) {
      for (var i in _dashboard!.conTransactions) {
        widgetLIst.add(TransactionInfoItemCardWidget(
          item: i,
        ));
      }
    }
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
            "تراکنش‌های تایید شده",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 3.2,
                    context: context,
                    importedList: widgetLIst),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: widgetLIst),
                desktop: widgetsGridview(
                    importedList: widgetLIst,
                    context: context,
                    childAspectRatio: 4.5,
                    crossAxisCount: 2),
              )),
        ],
      ),
    );
  }
}
