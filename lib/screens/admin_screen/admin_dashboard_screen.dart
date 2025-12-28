import 'dart:async';

import 'package:powerps/helper/public.dart';
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
  int _unconfirmedPage = 1;
  bool _isLoadingMoreUnconfirmed = false;
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
      child: _showdata == false
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "درحال دریافت اطلاعات داشبورد...",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              primary: false,
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _financialSummaryCard(context),
                            SizedBox(height: AppStyle.defaultPadding),
                            _botUserInfoTabCard(context),
                            SizedBox(height: AppStyle.defaultPadding),
                            _pannelsStatusCard(context),
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

  void _bindAdminDashboardScreenData({int? page}) async {
    if (page != null) {
      if (!mounted) return;
      setState(() {
        _isLoadingMoreUnconfirmed = true;
      });
    }
    await getDashboardAnalytics(unconfirmedPage: page ?? _unconfirmedPage)
        .then((value) {
      if (null != value) {
        if (!mounted) return;
        setState(() {
          _dashboard = value;
          _showdata = true;
          _isLoadingMoreUnconfirmed = false;
          _unconfirmedPage = value.unConTransactionsCurrentPage;
        });
      }
    }).onError((error, stackTrace) {
      if (!mounted) return;
      setState(() {
        _isLoadingMoreUnconfirmed = false;
      });
    });
  }

  _financialSummaryCard(BuildContext context) {
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
              Icon(Icons.account_balance_wallet_outlined,
                  color: AppStyle.primaryColor),
              const SizedBox(width: 10),
              Text(
                "خلاصه وضعیت مالی (تراکنش‌های تایید شده)",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          Row(
            children: [
              Expanded(
                child: _financialItem(
                  title: "فروش امروز",
                  value: _dashboard!.financialSummary['today'].toString(),
                  color: Colors.greenAccent,
                ),
              ),
              SizedBox(width: AppStyle.defaultPadding),
              Expanded(
                child: _financialItem(
                  title: "فروش هفته",
                  value: _dashboard!.financialSummary['week'].toString(),
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(width: AppStyle.defaultPadding),
              Expanded(
                child: _financialItem(
                  title: "فروش ماه",
                  value: _dashboard!.financialSummary['month'].toString(),
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _financialItem(
      {required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              "${formatPrice(value)} تومان",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _pannelsStatusCard(BuildContext context) {
    List<Widget> pannelWidgets = [];
    for (var pannel in _dashboard!.pannelsStatus) {
      pannelWidgets.add(
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: (pannel['is_online'] == true ? Colors.green : Colors.red)
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        pannel['type'] == 'hiddify'
                            ? Icons.security
                            : Icons.settings_input_component,
                        size: 16,
                        color: AppStyle.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pannel['location'] ?? 'نامشخص',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pannel['is_online'] == true
                          ? Colors.green
                          : Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: (pannel['is_online'] == true
                                  ? Colors.green
                                  : Colors.red)
                              .withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("کل کاربران",
                          style:
                              TextStyle(color: Colors.white54, fontSize: 10)),
                      Text("${pannel['total_users']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("آنلاین",
                          style:
                              TextStyle(color: Colors.white54, fontSize: 10)),
                      Text("${pannel['online_users']}",
                          style: TextStyle(
                              color: AppStyle.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

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
                  Icon(Icons.dns_outlined, color: AppStyle.primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    "وضعیت پنل‌ها",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Text(
                "${_dashboard!.pannelsStatus.length} پنل فعال",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                childAspectRatio: 1.8,
                context: context,
                importedList: pannelWidgets,
                crossAxisCount: 2,
              ),
              tablet: widgetsGridview(
                childAspectRatio: 2.2,
                context: context,
                importedList: pannelWidgets,
                crossAxisCount: 3,
              ),
              desktop: widgetsGridview(
                childAspectRatio: 2.5,
                context: context,
                importedList: pannelWidgets,
                crossAxisCount: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _last10SelledproductInfoItemCard(BuildContext context) {
    List<Widget> mainInfoWidgetList = [];
    for (var i in _dashboard!.last10ProductSelled) {
      mainInfoWidgetList.add(ConfigDetailsWithCatInfoItemWidget(
        item: i,
      ));
    }

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
              Icon(Icons.shopping_cart_outlined, color: AppStyle.primaryColor),
              const SizedBox(width: 10),
              Text(
                "آخرین کانفیگ های فروخته شده",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
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
                  Icon(Icons.people_outline, color: AppStyle.primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    "آخرین کاربران",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              IconButton(
                  onPressed: () {
                    _bindAdminDashboardScreenData();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white70))
            ],
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
                  Icon(Icons.pending_actions, color: Colors.orangeAccent),
                  const SizedBox(width: 10),
                  Text(
                    "تراکنش‌های تایید نشده",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              if (_isLoadingMoreUnconfirmed)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.orangeAccent,
                  ),
                ),
            ],
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
          if (_dashboard!.unConTransactionsLastPage > 1)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed:
                        _unconfirmedPage > 1 && !_isLoadingMoreUnconfirmed
                            ? () => _bindAdminDashboardScreenData(
                                page: _unconfirmedPage - 1)
                            : null,
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    color: AppStyle.primaryColor,
                  ),
                  Text(
                    "صفحه $_unconfirmedPage از ${_dashboard!.unConTransactionsLastPage}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  IconButton(
                    onPressed: _unconfirmedPage <
                                _dashboard!.unConTransactionsLastPage &&
                            !_isLoadingMoreUnconfirmed
                        ? () => _bindAdminDashboardScreenData(
                            page: _unconfirmedPage + 1)
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    color: AppStyle.primaryColor,
                  ),
                ],
              ),
            ),
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
              Icon(Icons.check_circle_outline, color: Colors.greenAccent),
              const SizedBox(width: 10),
              Text(
                "تراکنش‌های تایید شده",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
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
