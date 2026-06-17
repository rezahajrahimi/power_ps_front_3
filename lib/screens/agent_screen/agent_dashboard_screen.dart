import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/provider/agent/agent_ballance_provider.dart';
import 'package:powerps/provider/agent/agent_provider.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/agent/agent_ballance_widget_info_card_widget.dart';
import 'package:powerps/widgets/agent/agent_bougth_products_list_info_card_widget.dart';
import 'package:powerps/widgets/agent/agent_limits_info_card_widget.dart';
import 'package:powerps/widgets/agent/agent_product_category_item_widget.dart';
import 'package:powerps/widgets/dashboard/dashboard_action_handler.dart';
import 'package:powerps/widgets/dashboard/dashboard_section_card.dart';
import 'package:powerps/widgets/log/recent_events_list_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:provider/provider.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  bool _showdata = false;
  bool _loadError = false;
  bool _isRefreshing = false;
  Timer? _retriveDataTimer;
  AgentProvider? _agentProvider;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _productsSectionKey = GlobalKey();
  final GlobalKey _historySectionKey = GlobalKey();
  final GlobalKey _walletSectionKey = GlobalKey();

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
    _scrollController.dispose();
    super.dispose();
  }

  DashboardActionHandler _actionHandler(BuildContext context) {
    return DashboardActionHandler(
      context: context,
      scrollController: _scrollController,
      productsSectionKey: _productsSectionKey,
      historySectionKey: _historySectionKey,
      walletSectionKey: _walletSectionKey,
      onBalanceChanged: () => _bindAgentDashboardScreenData(silent: true),
    );
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
                    controller: _scrollController,
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
          const Text('خطا در بارگذاری داشبورد'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _bindAgentDashboardScreenData(),
            child: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final dashboard = context.watch<AgentProvider>().agentDashboard;
    final permission = dashboard.permission;
    final limitUsage = dashboard.limitUsage;
    final logs = dashboard.logs ?? [];

    return Column(
      children: [
        if (_isRefreshing)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        const DashboardWelcomeHeader(),
        SizedBox(height: AppStyle.defaultPadding),
        DashboardQuickActionsSection(
          onAction: (key) => _actionHandler(context).handle(key),
        ),
        SizedBox(height: AppStyle.defaultPadding),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _agentProductsSection(context),
                  SizedBox(height: AppStyle.defaultPadding),
                  _agentBoughtProductsSection(context),
                  if (Responsive.isMobile(context)) ...[
                    SizedBox(height: AppStyle.defaultPadding),
                    _sidebarContent(permission, limitUsage),
                  ],
                  SizedBox(height: AppStyle.defaultPadding),
                  DashboardSectionCard(
                    title: 'آخرین فعالیت‌ها',
                    icon: Icons.history_toggle_off,
                    child: RecentEvents(type: 'dashboard', events: logs),
                  ),
                ],
              ),
            ),
            if (!Responsive.isMobile(context)) ...[
              SizedBox(width: AppStyle.defaultPadding),
              Expanded(
                flex: 2,
                child: _sidebarContent(permission, limitUsage),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _sidebarContent(permission, limitUsage) {
    return Column(
      children: [
        KeyedSubtree(
          key: _walletSectionKey,
          child: const AgentBallanceInfoItemCardWidget(),
        ),
        if (permission != null) ...[
          SizedBox(height: AppStyle.defaultPadding),
          AgentLimitsInfoCardWidget(
            permission: permission,
            usage: limitUsage,
          ),
        ],
      ],
    );
  }

  Widget _agentProductsSection(BuildContext context) {
    final products =
        Provider.of<AgentProvider>(context, listen: false).agentDashboard.agentProducts ?? [];

    final productWidgets = products.map((i) {
      return AgentProductCategoryItemWidget(
        item: ProductCategory(
          isActive: i.productCategories!.isActive,
          volume: i.productCategories!.volume,
          rechargable: i.productCategories!.rechargable,
          showPannelLink: i.productCategories!.showPannelLink,
          showSubscriptionLink: i.productCategories!.showSubscriptionLink,
          sendConfigToUser: i.productCategories!.sendConfigToUser,
          pannelId: i.productCategories!.pannelId,
          id: i.productCategories!.id,
          categoryName: i.productCategories!.categoryName,
          expireDay: i.productCategories!.expireDay,
          price: i.price,
          priceInDollar: i.priceInDollar,
        ),
      );
    }).toList();

    return DashboardSectionCard(
      sectionKey: _productsSectionKey,
      title: 'بسته‌های کانفیگ (${products.length})',
      icon: Icons.inventory_2_outlined,
      child: productWidgets.isEmpty
          ? const Text('بسته‌ای برای فروش تعریف نشده', style: TextStyle(color: Colors.white54))
          : SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: productWidgets,
                ),
                tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: productWidgets,
                ),
                desktop: widgetsGridview(
                  importedList: productWidgets,
                  context: context,
                  childAspectRatio: 4,
                  crossAxisCount: 2,
                ),
              ),
            ),
    );
  }

  Widget _agentBoughtProductsSection(BuildContext context) {
    return KeyedSubtree(
      key: _historySectionKey,
      child: Column(
        children: [
          _showBougthProductData
              ? AgentBougthProductsListInfoCardWidget(
                  title: 'خریدهای شما',
                  products: boughtProducts,
                  lggedUSerRole: 'agent',
                )
              : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          if (_lastPageBougthProduct > 1) ...[
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
              nextIcon: const Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 14),
              previousIcon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 14),
              activeTextStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              activeBtnStyle: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blue),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
                ),
              ),
              inactiveBtnStyle: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
                ),
              ),
              inactiveTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _bindAgentDashboardScreenData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _showdata = false;
        _loadError = false;
      });
    } else {
      setState(() => _isRefreshing = true);
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
        _isRefreshing = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!silent && mounted) {
        setState(() {
          _loadError = true;
          _showdata = true;
          _isRefreshing = false;
        });
      } else if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }
}
