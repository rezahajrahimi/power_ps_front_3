import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/repositories/report_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class RetentionReportTab extends StatefulWidget {
  const RetentionReportTab({super.key});

  @override
  State<RetentionReportTab> createState() => _RetentionReportTabState();
}

class _RetentionReportTabState extends State<RetentionReportTab>
    with AutomaticKeepAliveClientMixin {
  bool _loading = true;
  Map<String, dynamic> _stats = {};
  List<dynamic> _topCategories = [];
  List<dynamic> _monthlySales = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final stats = await ReportRepository.getRetentionStats();
    final chart = await ReportRepository.getRetentionChart();
    if (mounted) {
      setState(() {
        _stats = stats;
        _topCategories = chart['top_categories'] as List<dynamic>? ?? [];
        _monthlySales = chart['monthly_sales'] as List<dynamic>? ?? [];
        _loading = false;
      });
    }
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _kpi(String title, String value) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppStyle.primaryColor,
              fontSize: Responsive.isMobile(context) ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppStyle.primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _monthlySalesContent() {
    if (_monthlySales.isEmpty) {
      return Text('داده‌ای موجود نیست.', style: TextStyle(color: AppStyle.deactiveStatus));
    }
    return Column(
      children: _monthlySales.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppStyle.bgColor.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['month']?.toString() ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('${item['sales_count'] ?? 0} فروش',
                        style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                '${item['amount'] ?? 0} تومان',
                style: TextStyle(color: AppStyle.primaryColor, fontSize: 13),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _topCategoriesContent() {
    if (_topCategories.isEmpty) {
      return Text('داده‌ای موجود نیست.', style: TextStyle(color: AppStyle.deactiveStatus));
    }
    return Column(
      children: _topCategories.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppStyle.bgColor.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(child: Text(item['category_name']?.toString() ?? '')),
              Text(
                '${item['sales_count'] ?? 0} فروش',
                style: TextStyle(color: AppStyle.primaryColor),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  int _kpiCrossCount(BuildContext context) {
    if (Responsive.isDesktop(context)) return 4;
    if (Responsive.isTablet(context)) return 2;
    return 2;
  }

  double _kpiAspectRatio(BuildContext context) {
    if (Responsive.isDesktop(context)) return 2.4;
    if (Responsive.isTablet(context)) return 2.6;
    return 2.1;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    final renewal = ((_stats['renewal_rate_30d'] ?? 0) as num) * 100;
    final kpis = [
      _kpi('نرخ تکرار خرید ۳۰ روز', '${renewal.toStringAsFixed(1)}%'),
      _kpi('خریدهای ناتمام امروز', '${_stats['abandoned_intents_today'] ?? 0}'),
      _kpi('خریدهای ناتمام باز', '${_stats['open_abandoned_intents'] ?? 0}'),
      _kpi('تخفیف امروز', '${_stats['promo_discount_today'] ?? 0}'),
    ];

    final chartsSection = Responsive.isMobile(context)
        ? Column(
            children: [
              _dataCard(
                context: context,
                title: 'فروش ماهانه (۶ ماه اخیر)',
                icon: Icons.bar_chart,
                children: [_monthlySalesContent()],
              ),
              SizedBox(height: AppStyle.defaultPadding),
              _dataCard(
                context: context,
                title: 'پرفروش‌ترین بسته‌ها',
                icon: Icons.leaderboard_outlined,
                children: [_topCategoriesContent()],
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _dataCard(
                  context: context,
                  title: 'فروش ماهانه (۶ ماه اخیر)',
                  icon: Icons.bar_chart,
                  children: [_monthlySalesContent()],
                ),
              ),
              SizedBox(width: AppStyle.defaultPadding),
              Expanded(
                child: _dataCard(
                  context: context,
                  title: 'پرفروش‌ترین بسته‌ها',
                  icon: Icons.leaderboard_outlined,
                  children: [_topCategoriesContent()],
                ),
              ),
            ],
          );

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        children: [
          widgetsGridview(
            context: context,
            crossAxisCount: _kpiCrossCount(context),
            childAspectRatio: _kpiAspectRatio(context),
            importedList: kpis,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          chartsSection,
        ],
      ),
    );
  }
}
