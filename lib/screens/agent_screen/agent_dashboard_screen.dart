import 'dart:async';

import 'package:pagination_flutter/pagination.dart';
import 'package:powerps/widgets/agent/agent_bougth_products_list_info_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/provider/agent/agent_ballance_provider.dart';
import 'package:powerps/provider/agent/agent_provider.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:powerps/widgets/agent/agent_ballance_widget_info_card_widget.dart';
import 'package:powerps/widgets/agent/agent_product_category_item_widget.dart';
import 'package:powerps/widgets/log/recent_events_list_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  bool _showdata = false;
  Timer? _retriveDataTimer;

  int _lastPageBougthProduct = 1;
  int selectedPageBougthProduct = 1;
  bool _showBougthProductData = false;
  // AgentDashboard? _dashboard;
  @override
  void initState() {
    _bindAgentDashboardScreenData();

    _retriveDataTimer = Timer.periodic(const Duration(seconds: 20), ((timer) {
      _bindAgentDashboardScreenData();
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
        child: _showdata == false ? Container() : _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    bool changed = context.watch<AgentProvider>().changed;
    if (changed) {
      _bindAgentDashboardScreenData();
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _agentProductsInfoTabCard(context),
                  SizedBox(height: AppStyle.defaultPadding),
                  _agentBoughtProductsInfoTabCard(context),
                  SizedBox(height: AppStyle.defaultPadding),
                  // _confirmedInfoTabCard(context),
                  SizedBox(height: AppStyle.defaultPadding),
                  if (Responsive.isMobile(context)) // side bar mobile
                    const AgentBallanceInfoItemCardWidget(),
                  if (Responsive.isMobile(context)) // side bar mobile
                    SizedBox(height: AppStyle.defaultPadding),
                  RecentEvents(
                      type: "dashboard",
                      events: Provider.of<AgentProvider>(context, listen: false)
                          .agentDashboard
                          .logs!),
                  if (Responsive.isMobile(context))
                    SizedBox(height: AppStyle.defaultPadding),
                  if (Responsive.isMobile(context)) // side bar mobile
                    Column(
                      children: [
                        // AgentBallanceInfoItemCardWidget(),
                        SizedBox(height: AppStyle.defaultPadding),
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
                    const AgentBallanceInfoItemCardWidget(),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        )
      ],
    );
  }

  void _bindAgentDashboardScreenData() async {
    // String token = await LoggingPreference().getToken();
    // print(token);

    await getAgentDashboardData().then((value) {
      if (null != value) {
        setState(() {
          _showdata = false;
        });

        setState(() {
          Provider.of<AgentProvider>(context, listen: false)
              .setNewAgentDashboardData(value);

          Provider.of<AgentBallanceProvider>(context, listen: false)
              .setAgentBallenceInDollar(
                  Provider.of<AgentProvider>(context, listen: false)
                      .agentDashboard
                      .ballance!
                      .accountBallanceIndollar);
          Provider.of<AgentBallanceProvider>(context, listen: false)
              .setAgentBallenceInToman(
                  Provider.of<AgentProvider>(context, listen: false)
                      .agentDashboard
                      .ballance!
                      .ballance
                      .toInt());

          Provider.of<AgentProvider>(context, listen: false).setChanged(false);
        });
      }
    }).whenComplete(() {
      setState(() {
        _showdata = true;
      });
    }).onError((error, stackTrace) {
      setState(() {
        _showdata = true;
      });
      debugPrint(error.toString());
    });

    await getAgentSelledProductsByPagination().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          _lastPageBougthProduct = lastPageBougthProduct;
        });
      } else {
        // showMsg(msg: "خطا", context: context, type: "error");
        debugPrint("error on dashboard biding $value");
      }
    }).whenComplete(() {
      setState(() {
        _showBougthProductData = true;
      });
    }).onError((error, stackTrace) {
      setState(() {
        _showdata = true;
      });
      debugPrint(error.toString());
    });
  }

  _agentProductsInfoTabCard(BuildContext context) {
    List<Widget> botUserWidgetLIst = [];
    // todo
    // create a specefic widget
    for (var i in Provider.of<AgentProvider>(context, listen: false)
        .agentDashboard
        .agentProducts!) {
      botUserWidgetLIst.add(AgentProductCategoryItemWidget(
          item: ProductCategory(
              isActive: i.productCategories!.isActive,
              volume: i.productCategories!.volume,
              rechargable: i.productCategories!.rechargable,
              showPannelLink: i.productCategories!.showPannelLink,
              showSubscriptionLink: i.productCategories!.showSubscriptionLink,
              pannelId: i.productCategories!.pannelId,
              id: i.productCategories!.id,
              categoryName: i.productCategories!.categoryName,
              expireDay: i.productCategories!.expireDay,
              price: i.price,
              priceInDollar: i.priceInDollar)));
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
            "بسته‌های کانفیگ",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.9,
                    context: context,
                    importedList: botUserWidgetLIst),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: botUserWidgetLIst),
                desktop: widgetsGridview(
                    importedList: botUserWidgetLIst,
                    context: context,
                    childAspectRatio: 4,
                    crossAxisCount: 2),
              )),
        ],
      ),
    );
  }

  _agentBoughtProductsInfoTabCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 5,
            child: Column(children: [
              _showBougthProductData
                  ? AgentBougthProductsListInfoCardWidget(
                      title: "خریدهای شما",
                      products: boughtProducts,
                      lggedUSerRole: "agent",
                    )
                  : const SizedBox(),
              SizedBox(height: AppStyle.defaultPadding),
              Pagination(
                numOfPages: _lastPageBougthProduct,
                selectedPage: selectedPageBougthProduct,
                pagesVisible: 4,
                onPageChanged: (page) async {
                  setState(() {
                    selectedPageBougthProduct = page;
                    _showBougthProductData = false;
                  });
                  await getAgentSelledProductsByPagination(page: page);
                  setState(() {
                    _lastPageBougthProduct = lastPageBougthProduct;

                    _showBougthProductData = true;
                  });
                },
                nextIcon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.blue,
                  size: 14,
                ),
                previousIcon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.blue,
                  size: 14,
                ),
                activeTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                activeBtnStyle: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(38),
                    ),
                  ),
                ),
                inactiveBtnStyle: ButtonStyle(
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(38),
                  )),
                ),
                inactiveTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              )
            ])),
      ],
    );
  }
}
