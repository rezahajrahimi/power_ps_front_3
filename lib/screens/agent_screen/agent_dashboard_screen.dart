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
import 'package:powerps/widgets/agent/agent_limits_info_card_widget.dart';
import 'package:powerps/widgets/dashboard/dashboard_action_handler.dart';
import 'package:powerps/widgets/dashboard/dashboard_product_catalog_section.dart';
import 'package:powerps/widgets/dashboard/dashboard_purchase_history_section.dart';
import 'package:powerps/widgets/dashboard/dashboard_section_card.dart';
import 'package:powerps/widgets/log/recent_events_list_widget.dart';
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
                  DashboardProductCatalogSection(
                    sectionKey: _productsSectionKey,
                    products: _agentProductCategories(context),
                    userRole: 'agent',
                    onPurchased: () => _bindAgentDashboardScreenData(silent: true),
                  ),
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

  List<ProductCategory> _agentProductCategories(BuildContext context) {
    final products =
        Provider.of<AgentProvider>(context, listen: false).agentDashboard.agentProducts ?? [];

    return products.map((i) {
      final cat = i.productCategories!;
      return ProductCategory(
        isActive: cat.isActive,
        volume: cat.volume,
        rechargable: cat.rechargable,
        showPannelLink: cat.showPannelLink,
        showSubscriptionLink: cat.showSubscriptionLink,
        sendConfigToUser: cat.sendConfigToUser,
        pannelId: cat.pannelId,
        id: cat.id,
        categoryName: cat.categoryName,
        expireDay: cat.expireDay,
        price: i.price,
        priceInDollar: i.priceInDollar,
        pannel: cat.pannel,
      );
    }).toList();
  }

  Widget _agentBoughtProductsSection(BuildContext context) {
    if (!_showBougthProductData) {
      return KeyedSubtree(
        key: _historySectionKey,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return DashboardPurchaseHistorySection(
      sectionKey: _historySectionKey,
      products: boughtProducts,
      userRole: 'agent',
      childAfterList: _lastPageBougthProduct > 1
          ? Padding(
              padding: EdgeInsets.only(top: AppStyle.defaultPadding),
              child: Pagination(
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
            )
          : const SizedBox.shrink(),
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
