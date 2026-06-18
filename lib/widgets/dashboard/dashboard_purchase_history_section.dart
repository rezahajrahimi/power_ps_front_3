import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/bought_product_details_model.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/agent/agent_bought_product_info_widget.dart';
import 'package:powerps/widgets/dashboard/dashboard_filter_bar.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class DashboardPurchaseHistorySection extends StatefulWidget {
  const DashboardPurchaseHistorySection({
    super.key,
    required this.products,
    required this.userRole,
    required this.sectionKey,
    required this.childAfterList,
  });

  final List<BoughtProductDetailsModel> products;
  final String userRole;
  final GlobalKey sectionKey;
  final Widget childAfterList;

  @override
  State<DashboardPurchaseHistorySection> createState() =>
      _DashboardPurchaseHistorySectionState();
}

class _DashboardPurchaseHistorySectionState
    extends State<DashboardPurchaseHistorySection> {
  String _search = '';
  String? _location;
  String? _panel;
  String? _day;
  String? _volume;
  String _status = 'all';

  List<BoughtProductDetailsModel> get _filtered {
    return widget.products.where((p) {
      final q = _search.trim().toLowerCase();
      if (q.isNotEmpty) {
        final remark = (p.remark ?? '').toLowerCase();
        final category = p.productCategory?.categoryName.toLowerCase() ?? '';
        if (!remark.contains(q) && !category.contains(q)) return false;
      }

      if (_location != null && _location!.isNotEmpty) {
        if (p.productCategory?.pannel?.location != _location) return false;
      }

      final category = p.productCategory;
      if (_panel != null && category?.pannelId.toString() != _panel) {
        return false;
      }
      if (_day != null && category?.expireDay.toString() != _day) return false;
      if (_volume != null && category?.volume.toString() != _volume) {
        return false;
      }

      if (_status == 'active' && p.isActive != true) return false;
      if (_status == 'inactive' && p.isActive != false) return false;

      return true;
    }).toList();
  }

  List<String> get _locations => widget.products
      .map((p) => p.productCategory?.pannel?.location)
      .whereType<String>()
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<MapEntry<String, String>> get _panelOptions {
    final map = <String, String>{};
    for (final product in widget.products) {
      final category = product.productCategory;
      final panel = category?.pannel;
      if (category == null || panel == null) continue;
      map[category.pannelId.toString()] = _panelLabel(panel);
    }
    return map.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
  }

  List<MapEntry<String, String>> get _dayOptions {
    final days = widget.products
        .map((p) => p.productCategory?.expireDay)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();
    return days.map((day) => MapEntry(day.toString(), '$day روز')).toList();
  }

  List<MapEntry<String, String>> get _volumeOptions {
    final volumes = widget.products
        .map((p) => p.productCategory?.volume)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();
    return volumes
        .map((volume) => MapEntry(volume.toString(), '$volume GB'))
        .toList();
  }

  String _panelLabel(Pannel panel) {
    final location = (panel.location ?? '').trim();
    final name = getPannelName(name: panel.type);
    return location.isEmpty ? name : '$name - $location';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final tiles = filtered
        .map(
          (p) => AgentBoughtProductInfoWidget(
            boughtProductDetailsModel: p,
            userRole: widget.userRole,
          ),
        )
        .toList();

    return KeyedSubtree(
      key: widget.sectionKey,
      child: Container(
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
                Icon(Icons.receipt_long_outlined, color: AppStyle.primaryColor),
                const SizedBox(width: 10),
                Text(
                  'سابقه خرید (${filtered.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: AppStyle.defaultPadding),
            DashboardFilterBar(
              searchHint: 'جستجو در خریدها...',
              searchQuery: _search,
              onSearchChanged: (v) => setState(() => _search = v),
              locationOptions: _locations,
              selectedLocation: _location ?? 'همه',
              onLocationChanged: (v) => setState(() => _location = v),
              panelOptions: _panelOptions,
              selectedPanel: _panel ?? 'همه',
              onPanelChanged: (v) => setState(() => _panel = v),
              dayOptions: _dayOptions,
              selectedDay: _day ?? 'همه',
              onDayChanged: (v) => setState(() => _day = v),
              volumeOptions: _volumeOptions,
              selectedVolume: _volume ?? 'همه',
              onVolumeChanged: (v) => setState(() => _volume = v),
              statusOptions: const [
                MapEntry('all', 'همه'),
                MapEntry('active', 'فعال'),
                MapEntry('inactive', 'غیرفعال'),
              ],
              selectedStatus: _status,
              onStatusChanged: (v) => setState(() => _status = v ?? 'all'),
            ),
            SizedBox(height: AppStyle.defaultPadding),
            if (tiles.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text('موردی یافت نشد', style: TextStyle(color: Colors.white54)),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: Responsive(
                  mobile: widgetsGridview(
                    childAspectRatio: 2.6,
                    context: context,
                    importedList: tiles,
                  ),
                  tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 3.5,
                    importedList: tiles,
                    crossAxisCount: 2,
                  ),
                  desktop: widgetsGridview(
                    importedList: tiles,
                    context: context,
                    childAspectRatio: 4,
                    crossAxisCount: 2,
                  ),
                ),
              ),
            widget.childAfterList,
          ],
        ),
      ),
    );
  }
}
