import 'package:flutter/material.dart';
import 'package:powerps/models/web_app_menu_item_model.dart';
import 'package:powerps/provider/auth_provider.dart';
import 'package:powerps/repositories/web_app_menu_item_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/dashboard/dashboard_feature_sheets.dart';
import 'package:powerps/widgets/dashboard/dashboard_quick_actions.dart';
import 'package:powerps/widgets/dashboard/dashboard_section_card.dart';
import 'package:provider/provider.dart';

class DashboardActionHandler {
  DashboardActionHandler({
    required this.context,
    required this.scrollController,
    this.productsSectionKey,
    this.historySectionKey,
    this.walletSectionKey,
    this.onBalanceChanged,
  });

  final BuildContext context;
  final ScrollController scrollController;
  final GlobalKey? productsSectionKey;
  final GlobalKey? historySectionKey;
  final GlobalKey? walletSectionKey;
  final VoidCallback? onBalanceChanged;

  Future<void> handle(String key) async {
    switch (key) {
      case 'buy_subscription':
        await _scrollToSection(productsSectionKey);
        break;
      case 'subscription_history':
        await _scrollToSection(historySectionKey);
        break;
      case 'wallet':
        await _scrollToSection(walletSectionKey);
        break;
      case 'how_to_use':
        await DashboardFeatureSheets.showFaqSheet(context);
        break;
      case 'support':
        await DashboardFeatureSheets.showSupportSheet(context);
        break;
      case 'trial_account':
        await DashboardFeatureSheets.showTestAccountSheet(
          context,
          onSuccess: onBalanceChanged,
        );
        break;
      case 'gift_card':
        await DashboardFeatureSheets.showGiftCardSheet(
          context,
          onSuccess: onBalanceChanged,
        );
        break;
      case 'app_download':
        await DashboardFeatureSheets.showAppDownloadSheet(context);
        break;
      case 'referral':
        await DashboardFeatureSheets.showReferralSheet(context);
        break;
    }
  }

  Future<void> _scrollToSection(GlobalKey? key) async {
    if (key?.currentContext == null) return;
    await Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }
}

class DashboardWelcomeHeader extends StatelessWidget {
  const DashboardWelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthChangeController>().getUser();
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppStyle.primaryColor.withValues(alpha: 0.25),
            AppStyle.secondaryColor,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppStyle.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppStyle.primaryColor.withValues(alpha: 0.2),
            child: Icon(Icons.person, color: AppStyle.primaryColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سلام، ${user.name.isNotEmpty ? user.name : 'کاربر گرامی'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.role == 'agent' ? 'پنل نمایندگی' : 'پنل کاربری',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardQuickActionsSection extends StatefulWidget {
  const DashboardQuickActionsSection({
    super.key,
    required this.onAction,
  });

  final DashboardMenuAction onAction;

  @override
  State<DashboardQuickActionsSection> createState() =>
      _DashboardQuickActionsSectionState();
}

class _DashboardQuickActionsSectionState
    extends State<DashboardQuickActionsSection> {
  List<WebAPPMenuItemModel> _menuItems = [];
  bool _loading = true;
  bool _usedFallback = false;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    setState(() {
      _loading = true;
      _usedFallback = false;
    });

    var usedFallback = false;
    final items = await getAllActiveWebAppMenuItems(
      onMeta: (fallback) => usedFallback = fallback,
    );
    if (!mounted) return;

    setState(() {
      _menuItems = items;
      _loading = false;
      _usedFallback = usedFallback;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'دسترسی سریع',
      icon: Icons.apps_outlined,
      trailing: IconButton(
        tooltip: 'بارگذاری مجدد',
        onPressed: _loading ? null : _loadMenuItems,
        icon: const Icon(Icons.refresh, size: 20, color: Colors.white70),
      ),
      child: _loading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_usedFallback)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'لیست پیش‌فرض نمایش داده می‌شود. برای همگام‌سازی با سرور دوباره تلاش کنید.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.amberAccent,
                          ),
                    ),
                  ),
                DashboardQuickActions(
                  menuItems: _menuItems,
                  onAction: widget.onAction,
                ),
              ],
            ),
    );
  }
}
