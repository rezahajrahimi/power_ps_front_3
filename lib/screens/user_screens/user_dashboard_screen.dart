import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/provider/agent/agent_ballance_provider.dart';
import 'package:powerps/provider/user_provider.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/agent/agent_ballance_widget_info_card_widget.dart';
import 'package:powerps/widgets/dashboard/dashboard_action_handler.dart';
import 'package:powerps/widgets/dashboard/dashboard_product_catalog_section.dart';
import 'package:powerps/widgets/dashboard/dashboard_purchase_history_section.dart';
import 'package:powerps/widgets/dashboard/dashboard_section_card.dart';
import 'package:powerps/widgets/log/recent_events_list_widget.dart';
import 'package:provider/provider.dart';

class USerDasboardScreen extends StatefulWidget {
  const USerDasboardScreen({super.key});

  @override
  State<USerDasboardScreen> createState() => _USerDasboardScreenState();
}

class _USerDasboardScreenState extends State<USerDasboardScreen> {
  bool _showdata = false;
  bool _loadError = false;
  bool _isRefreshing = false;
  Timer? _retriveDataTimer;
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
    _bindUSerDashboardScreenData();
    _retriveDataTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) _bindUSerDashboardScreenData(silent: true);
    });
  }

  @override
  void dispose() {
    _retriveDataTimer?.cancel();
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
      onBalanceChanged: () => _bindUSerDashboardScreenData(silent: true),
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
                  onRefresh: () => _bindUSerDashboardScreenData(),
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
            onPressed: () => _bindUSerDashboardScreenData(),
            child: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final changed = context.watch<UserProvider>().changed;
    if (changed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _bindUSerDashboardScreenData(silent: true);
      });
    }

    final logs = Provider.of<UserProvider>(context, listen: false)
            .userDashboard
            .logs ??
        [];

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
                    products: Provider.of<UserProvider>(context, listen: false)
                            .userDashboard
                            .prdoducts ??
                        [],
                    userRole: 'user',
                    onPurchased: () => _bindUSerDashboardScreenData(silent: true),
                  ),
                  SizedBox(height: AppStyle.defaultPadding),
                  _userBoughtProductsSection(context),
                  if (Responsive.isMobile(context)) ...[
                    SizedBox(height: AppStyle.defaultPadding),
                    _walletSection(),
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
                child: _walletSection(),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _walletSection() {
    return KeyedSubtree(
      key: _walletSectionKey,
      child: const AgentBallanceInfoItemCardWidget(),
    );
  }

  Widget _userBoughtProductsSection(BuildContext context) {
    if (!_showBougthProductData) {
      return KeyedSubtree(
        key: _historySectionKey,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return DashboardPurchaseHistorySection(
      sectionKey: _historySectionKey,
      products: boughtProducts,
      userRole: 'user',
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
                  await getUserSelledProductsByPagination(page: page);
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

  Future<void> _bindUSerDashboardScreenData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _showdata = false;
        _loadError = false;
      });
    } else {
      setState(() => _isRefreshing = true);
    }

    try {
      final value = await getUserDashboardAnalytics();
      if (!mounted) return;

      if (value != null) {
        Provider.of<UserProvider>(context, listen: false).setUserDashboard(value);
        Provider.of<AgentBallanceProvider>(context, listen: false)
            .setAgentBallenceInDollar(value.ballance!.accountBallanceIndollar);
        Provider.of<AgentBallanceProvider>(context, listen: false)
            .setAgentBallenceInToman(value.ballance!.ballance.toInt());
        Provider.of<UserProvider>(context, listen: false).setChanged(false);
      } else if (!silent) {
        setState(() => _loadError = true);
      }

      final paginationResult = await getUserSelledProductsByPagination();
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
