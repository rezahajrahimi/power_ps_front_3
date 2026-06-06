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
import 'package:powerps/widgets/agent/agent_limits_info_card_widget.dart';
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
  bool _loadError = false;
  Timer? _retriveDataTimer;
  AgentProvider? _agentProvider;

  int _lastPageBougthProduct = 1;
  int selectedPageBougthProduct = 1;
  bool _showBougthProductData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _agentProvider = context.read<AgentProvider>();
      _agentProvider!.addListener(_onAgentProviderChanged);
      _bindAgentDashboardScreenData();
    });
    _retriveDataTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) _bindAgentDashboardScreenData(silent: true);
    });
  }

  void _onAgentProviderChanged() {
    if (!mounted || _agentProvider == null) return;
    if (!_agentProvider!.changed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bindAgentDashboardScreenData(silent: true);
    });
  }

  @override
  void dispose() {
    _retriveDataTimer?.cancel();
    _agentProvider?.removeListener(_onAgentProviderChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _showdata == false && !_loadError
          ? const Center(child: CircularProgressIndicator())
          : _loadError
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: () => _bindAgentDashboardScreenData(),
                  child: SingleChildScrollView(
                    primary: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(AppStyle.defaultPadding),
                    child: _content(context),
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.white38),
          const SizedBox(height: 12),
          const Text("خطا در بارگذاری داشبورد"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _bindAgentDashboardScreenData(),
            child: const Text("تلاش مجدد"),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final dashboard = context.watch<AgentProvider>().agentDashboard;
    final permission = dashboard.permission;

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
                  if (Responsive.isMobile(context))
                    const AgentBallanceInfoItemCardWidget(),
                  if (Responsive.isMobile(context) && permission != null) ...[
                    SizedBox(height: AppStyle.defaultPadding),
                    AgentLimitsInfoCardWidget(permission: permission),
                  ],
                  if (Responsive.isMobile(context))
                    SizedBox(height: AppStyle.defaultPadding),
                  RecentEvents(
                    type: "dashboard",
                    events: dashboard.logs ?? [],
                  ),
                  if (Responsive.isMobile(context))
                    SizedBox(height: AppStyle.defaultPadding),
                ],
              ),
            ),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            if (!Responsive.isMobile(context))
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const AgentBallanceInfoItemCardWidget(),
                    if (permission != null) ...[
                      SizedBox(height: AppStyle.defaultPadding),
                      AgentLimitsInfoCardWidget(permission: permission),
                    ],
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        )
      ],
    );
  }

  Future<void> _bindAgentDashboardScreenData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _showdata = false;
        _loadError = false;
      });
    }

    try {
      final value = await getAgentDashboardData();
      if (!mounted) return;

      if (value != null) {
        Provider.of<AgentProvider>(context, listen: false)
            .updateDashboard(dashboard: value, clearChanged: true);

        Provider.of<AgentBallanceProvider>(context, listen: false)
            .setAgentBallenceInDollar(value.ballance!.accountBallanceIndollar);
        Provider.of<AgentBallanceProvider>(context, listen: false)
            .setAgentBallenceInToman(value.ballance!.ballance.toInt());
      } else if (!silent) {
        setState(() => _loadError = true);
      }

      final paginationResult = await getAgentSelledProductsByPagination();
      if (!mounted) return;
      if (paginationResult.isNotEmpty) {
        setState(() => _lastPageBougthProduct = lastPageBougthProduct);
      }
      setState(() {
        _showBougthProductData = true;
        _showdata = true;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!silent && mounted) {
        setState(() {
          _loadError = true;
          _showdata = true;
        });
      }
    }
  }

  Widget _agentProductsInfoTabCard(BuildContext context) {
    final products =
        Provider.of<AgentProvider>(context, listen: false).agentDashboard.agentProducts ?? [];

    final botUserWidgetLIst = products.map((i) {
      return AgentProductCategoryItemWidget(
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
          priceInDollar: i.priceInDollar,
        ),
      );
    }).toList();

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
            "بسته‌های کانفیگ (${products.length})",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (botUserWidgetLIst.isEmpty)
            const Text("بسته‌ای برای فروش تعریف نشده")
          else
            SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: botUserWidgetLIst,
                ),
                tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: botUserWidgetLIst,
                ),
                desktop: widgetsGridview(
                  importedList: botUserWidgetLIst,
                  context: context,
                  childAspectRatio: 4,
                  crossAxisCount: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _agentBoughtProductsInfoTabCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _showBougthProductData
                  ? AgentBougthProductsListInfoCardWidget(
                      title: "خریدهای شما",
                      products: boughtProducts,
                      lggedUSerRole: "agent",
                    )
                  : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
                  if (!mounted) return;
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
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(38),
                    ),
                  ),
                ),
                inactiveTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
