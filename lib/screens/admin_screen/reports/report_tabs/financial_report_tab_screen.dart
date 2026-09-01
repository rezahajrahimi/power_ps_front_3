import 'package:flutter/material.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:powerps/repositories/report_repository.dart';
import 'package:powerps/models/transaction_model.dart';
import 'package:powerps/screens/admin_screen/transaction/transaction_details_screen.dart';

class FinancialReportTab extends StatefulWidget {
  const FinancialReportTab({super.key});

  @override
  State<FinancialReportTab> createState() => _FinancialReportTabState();
}

class _FinancialReportTabState extends State<FinancialReportTab>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  Map<String, dynamic> _stats = {};
  double _filteredTotal = 0;
  String? _startDate;
  String? _endDate;
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _currentPage = page;
    });
    try {
      final data = await ReportRepository.getFinancialReport(
        startDate: _startDate,
        endDate: _endDate,
        count: 15,
        page: page,
      );
      if (mounted) {
        setState(() {
          final txData = data['transactions'];
          _transactions = txData['data'] ?? [];
          _currentPage = txData['current_page'] ?? 1;
          _lastPage = txData['last_page'] ?? 1;
          _filteredTotal =
              double.tryParse(data['total_amount'].toString()) ?? 0;
          _stats = data['stats'] ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching financial data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      child: Column(
        children: [
          _buildSummaryCards(),
          SizedBox(height: AppStyle.defaultPadding),
          _buildFilterHeader(),
          SizedBox(height: AppStyle.defaultPadding),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(child: _buildTransactionTable()),
                      _buildPagination(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "درآمد امروز",
            "${_stats['today_revenue'] ?? 0} ت",
            Icons.today,
            Colors.green,
          ),
        ),
        SizedBox(width: AppStyle.defaultPadding),
        Expanded(
          child: _buildStatCard(
            "این ماه",
            "${_stats['this_month'] ?? 0} ت",
            Icons.calendar_month,
            Colors.blue,
          ),
        ),
        SizedBox(width: AppStyle.defaultPadding),
        Expanded(
          child: _buildStatCard(
            "کل درآمد",
            "${_stats['total_revenue'] ?? 0} ت",
            Icons.account_balance,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () => _fetchData(page: _currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text("صفحه $_currentPage از $_lastPage"),
          IconButton(
            onPressed: _currentPage < _lastPage
                ? () => _fetchData(page: _currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.white70),
          const SizedBox(width: 10),
          const Text("فیلتر زمانی:", style: TextStyle(color: Colors.white70)),
          const Spacer(),
          if (_startDate != null)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "مجموع بازه: ${_filteredTotal.toStringAsFixed(0)} ت",
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          TextButton.icon(
            onPressed: () => _selectDateRange(context),
            icon: const Icon(Icons.date_range),
            label: Text(_startDate == null
                ? "انتخاب بازه"
                : "$_startDate تا $_endDate"),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
          ),
          if (_startDate != null)
            IconButton(
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
                _fetchData();
              },
              icon: const Icon(Icons.clear, color: Colors.redAccent),
            ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: AppStyle.secondaryColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start.toIso8601String().split('T')[0];
        _endDate = picked.end.toIso8601String().split('T')[0];
      });
      _fetchData();
    }
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTable() {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        columns: const [
          DataColumn2(label: Text("کاربر"), size: ColumnSize.L),
          DataColumn2(label: Text("مبلغ (تومان)"), size: ColumnSize.M),
          DataColumn2(label: Text("نوع پرداخت"), size: ColumnSize.M),
          DataColumn2(label: Text("تاریخ"), size: ColumnSize.M),
        ],
        rows: _transactions.map((tx) {
          return DataRow(
            onSelectChanged: (_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetailsScreen(
                    item: Transaction.fromJson(tx),
                  ),
                ),
              );
            },
            cells: [
              DataCell(
                  Text(tx['user']?['username'] ?? tx['account_id'].toString())),
              DataCell(Text(tx['amount'].toString())),
              DataCell(Text(tx['payment_types']?['name'] ?? "-")),
              DataCell(Text(tx['created_at']?.toString().split('T')[0] ?? "-")),
            ],
          );
        }).toList(),
      ),
    );
  }
}
