import 'package:flutter/material.dart';
import 'package:powerps/repositories/report_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../widgets/public/widgets_gridview_widget_v4.dart';

class SummaryReportTab extends StatefulWidget {
  const SummaryReportTab({super.key});

  @override
  State<SummaryReportTab> createState() => _SummaryReportTabState();
}

class _SummaryReportTabState extends State<SummaryReportTab>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  List<dynamic> _recentSales = [];
  Map<String, dynamic> _stats = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final sales = await ReportRepository.getRecentSales(count: 10);
      final stats = await ReportRepository.getDashboardStats();
      if (mounted) {
        setState(() {
          _recentSales = sales;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching summary data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _fetchData,
      color: AppStyle.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "خلاصه وضعیت سیستم",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildQuickStats(),
            const SizedBox(height: 30),
            if (_stats['monthly_sales'] != null) ...[
              Text(
                "روند فروش (۶ ماه اخیر)",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildSalesChart(),
              const SizedBox(height: 30),
            ],
            Text(
              "آخرین فروش‌ها",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildRecentSalesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    final List<dynamic> monthlySales = _stats['monthly_sales'] ?? [];
    if (monthlySales.isEmpty) return const SizedBox();

    // Reverse to show chronological order (oldest to newest)
    final displayData = monthlySales.reversed.toList();

    double maxVal = 0;
    for (var m in displayData) {
      final rawVal = m['amount'] ?? m['count'] ?? 0;
      final double val = double.tryParse(rawVal.toString()) ?? 0.0;
      if (val > maxVal) maxVal = val;
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final month = displayData[groupIndex]['month'];
                final val = rod.toY;
                return BarTooltipItem(
                  "$month\n${val.toStringAsFixed(0)}",
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < displayData.length) {
                    String monthStr = displayData[index]['month'].toString();
                    // If format is YYYY-MM, take MM
                    if (monthStr.contains('-')) {
                      monthStr = monthStr.split('-')[1];
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        monthStr,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(displayData.length, (index) {
            final rawVal = displayData[index]['amount'] ??
                displayData[index]['count'] ??
                0;
            final double val = double.tryParse(rawVal.toString()) ?? 0.0;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: val,
                  color: AppStyle.primaryColor,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    List<Widget> stats = [
      _buildStatCard(
        "فروش امروز",
        "${_stats['total_revenue_today'] ?? 0} تومان",
        Icons.monetization_on,
        Colors.orange,
      ),
      _buildStatCard(
        "کاربران جدید امروز",
        "${_stats['new_users_today'] ?? 0}",
        Icons.person_add,
        Colors.blue,
      ),
      _buildStatCard(
        "کانفیگ‌های فروخته شده",
        "${_stats['active_configs'] ?? 0}",
        Icons.vpn_key,
        Colors.green,
      ),
      _buildStatCard(
        "کل درآمد",
        "${_stats['total_revenue'] ?? 0} تومان",
        Icons.account_balance,
        Colors.purple,
      ),
    ];

    return Responsive(
      mobile: widgetsGridview(
        context: context,
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        importedList: stats,
      ),
      tablet: widgetsGridview(
        context: context,
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        importedList: stats,
      ),
      desktop: widgetsGridview(
        context: context,
        crossAxisCount: 4,
        childAspectRatio: 2.0,
        importedList: stats,
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRecentSalesList() {
    if (_recentSales.isEmpty) {
      return const Center(child: Text("داده‌ای یافت نشد"));
    }

    return Container(
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentSales.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final sale = _recentSales[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppStyle.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.shopping_cart,
                  color: AppStyle.primaryColor, size: 20),
            ),
            title: Text(
                sale['product_category']?['category_name'] ?? "بسته نامشخص"),
            subtitle: Text(
                "کاربر: ${sale['user']?['username'] ?? sale['account_id']}"),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${sale['product_category']?['price'] ?? 0} تومان",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
                Text(sale['created_at']?.toString().split('T')[0] ?? "",
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
