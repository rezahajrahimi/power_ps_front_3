import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/web_app_menu_item_model.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

typedef DashboardMenuAction = void Function(String key);

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({
    super.key,
    required this.menuItems,
    required this.onAction,
  });

  final List<WebAPPMenuItemModel> menuItems;
  final DashboardMenuAction onAction;

  static IconData iconForKey(String key) {
    switch (key) {
      case 'buy_subscription':
        return Icons.shopping_cart_outlined;
      case 'subscription_history':
        return Icons.history;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'how_to_use':
        return Icons.school_outlined;
      case 'support':
        return Icons.support_agent_outlined;
      case 'trial_account':
        return Icons.science_outlined;
      case 'gift_card':
        return Icons.card_giftcard_outlined;
      case 'app_download':
        return Icons.download_outlined;
      case 'referral':
        return Icons.share_outlined;
      default:
        return Icons.touch_app_outlined;
    }
  }

  static Color colorForKey(String key) {
    switch (key) {
      case 'buy_subscription':
        return Colors.greenAccent;
      case 'subscription_history':
        return Colors.blueAccent;
      case 'wallet':
        return Colors.amberAccent;
      case 'how_to_use':
        return Colors.cyanAccent;
      case 'support':
        return Colors.orangeAccent;
      case 'trial_account':
        return Colors.purpleAccent;
      case 'gift_card':
        return Colors.pinkAccent;
      case 'app_download':
        return Colors.tealAccent;
      case 'referral':
        return Colors.lightGreenAccent;
      default:
        return AppStyle.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (menuItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDesktop = Responsive.isDesktop(context);
    final tiles = menuItems
        .map(
          (item) => _QuickActionTile(
            title: item.title,
            subtitle: item.subtitle,
            icon: iconForKey(item.key),
            color: colorForKey(item.key),
            compact: isDesktop,
            onTap: () => onAction(item.key),
          ),
        )
        .toList();

    if (isDesktop) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tiles
            .map(
              (tile) => SizedBox(
                width: 190,
                height: 64,
                child: tile,
              ),
            )
            .toList(),
      );
    }

    return Responsive(
      mobile: widgetsGridview(
        context: context,
        importedList: tiles,
        childAspectRatio: 1.35,
        crossAxisCount: 2,
      ),
      tablet: widgetsGridview(
        context: context,
        importedList: tiles,
        childAspectRatio: 1.5,
        crossAxisCount: 3,
      ),
      desktop: widgetsGridview(
        context: context,
        importedList: tiles,
        childAspectRatio: 2.8,
        crossAxisCount: 5,
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 16.0 : 20.0;
    final iconPadding = compact ? 6.0 : 8.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        child: Container(
          padding: EdgeInsets.all(compact ? 10 : 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(compact ? 12 : 16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: compact
              ? Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: iconSize),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: iconSize),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
