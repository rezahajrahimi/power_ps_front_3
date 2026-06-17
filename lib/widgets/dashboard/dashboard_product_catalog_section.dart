import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/provider/purchase_cart_provider.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/dashboard/dashboard_filter_bar.dart';
import 'package:powerps/widgets/dashboard/dashboard_section_card.dart';
import 'package:powerps/widgets/dashboard/purchase_cart_sheet.dart';
import 'package:powerps/widgets/dashboard/purchase_flow_helper.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:provider/provider.dart';

class DashboardProductCatalogSection extends StatefulWidget {
  const DashboardProductCatalogSection({
    super.key,
    required this.products,
    required this.userRole,
    required this.sectionKey,
    required this.onPurchased,
  });

  final List<ProductCategory> products;
  final String userRole;
  final GlobalKey sectionKey;
  final VoidCallback onPurchased;

  @override
  State<DashboardProductCatalogSection> createState() =>
      _DashboardProductCatalogSectionState();
}

class _DashboardProductCatalogSectionState
    extends State<DashboardProductCatalogSection> {
  String _search = '';
  String? _location;
  String _sort = 'price_asc';

  List<ProductCategory> get _filtered {
    var list = widget.products.where((p) {
      final q = _search.trim().toLowerCase();
      if (q.isNotEmpty) {
        final name = p.categoryName.toLowerCase();
        final location = p.pannel?.location?.toLowerCase() ?? '';
        if (!name.contains(q) && !location.contains(q)) return false;
      }
      if (_location != null && _location!.isNotEmpty) {
        if (p.pannel?.location != _location) return false;
      }
      return true;
    }).toList();

    switch (_sort) {
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'volume_desc':
        list.sort((a, b) => b.volume.compareTo(a.volume));
        break;
      case 'name_asc':
        list.sort((a, b) => a.categoryName.compareTo(b.categoryName));
        break;
      default:
        list.sort((a, b) => a.price.compareTo(b.price));
    }
    return list;
  }

  List<String> get _locations => widget.products
      .map((p) => p.pannel?.location)
      .whereType<String>()
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final tiles = filtered
        .map((item) => _ProductTile(
              item: item,
              userRole: widget.userRole,
              onPurchased: widget.onPurchased,
            ))
        .toList();

    return DashboardSectionCard(
      sectionKey: widget.sectionKey,
      title: 'خرید اشتراک',
      icon: Icons.shopping_bag_outlined,
      trailing: Consumer<PurchaseCartProvider>(
        builder: (context, cart, _) {
          if (cart.count == 0) return const SizedBox.shrink();
          return TextButton.icon(
            onPressed: () => PurchaseCartSheet.show(
              context,
              userRole: widget.userRole,
              onCheckoutComplete: widget.onPurchased,
            ),
            icon: Badge(
              label: Text('${cart.count}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: const Text('سبد خرید'),
          );
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardFilterBar(
            searchHint: 'جستجو در بسته‌ها...',
            searchQuery: _search,
            onSearchChanged: (v) => setState(() => _search = v),
            locationOptions: _locations,
            selectedLocation: _location ?? 'همه',
            onLocationChanged: (v) => setState(() => _location = v),
            sortOptions: const [
              MapEntry('price_asc', 'ارزان‌ترین'),
              MapEntry('price_desc', 'گران‌ترین'),
              MapEntry('volume_desc', 'بیشترین حجم'),
              MapEntry('name_asc', 'نام'),
            ],
            selectedSort: _sort,
            onSortChanged: (v) => setState(() => _sort = v ?? 'price_asc'),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (tiles.isEmpty)
            const Text('بسته‌ای یافت نشد', style: TextStyle(color: Colors.white54))
          else
            SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                  childAspectRatio: 2.4,
                  context: context,
                  importedList: tiles,
                ),
                tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 3.2,
                  importedList: tiles,
                  crossAxisCount: 2,
                ),
                desktop: widgetsGridview(
                  importedList: tiles,
                  context: context,
                  childAspectRatio: 3.8,
                  crossAxisCount: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.item,
    required this.userRole,
    required this.onPurchased,
  });

  final ProductCategory item;
  final String userRole;
  final VoidCallback onPurchased;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<PurchaseCartProvider>();

    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding / 2),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppStyle.primaryColor.withValues(alpha: 0.15),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppStyle.defaultPadding),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                item.isActive ? Icons.shopping_bag_outlined : Icons.block,
                size: 18,
                color: AppStyle.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (item.pannel?.location != null)
                Text(
                  item.pannel!.location!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white60),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${thousandSeperatorFormatter(item.price.toString())} تومان • ${item.expireDay} روزه • ${item.volume} GB',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white70),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => PurchaseFlowHelper.showPurchaseDialog(
                    context: context,
                    product: item,
                    userRole: userRole,
                    onSuccess: onPurchased,
                    onAddToCart: (product, remark) =>
                        cart.add(product, remark: remark),
                  ),
                  child: const Text('خرید'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'افزودن به سبد',
                onPressed: () => PurchaseFlowHelper.showPurchaseDialog(
                  context: context,
                  product: item,
                  userRole: userRole,
                  onSuccess: onPurchased,
                  onAddToCart: (product, remark) =>
                      cart.add(product, remark: remark),
                ),
                icon: const Icon(Icons.add_shopping_cart_outlined, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
