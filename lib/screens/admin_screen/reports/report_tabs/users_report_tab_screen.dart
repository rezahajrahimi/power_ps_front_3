import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powerps/repositories/report_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:data_table_2/data_table_2.dart';

class UsersReportTab extends StatefulWidget {
  const UsersReportTab({super.key});

  @override
  State<UsersReportTab> createState() => _UsersReportTabState();
}

class _UsersReportTabState extends State<UsersReportTab>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  List<dynamic> _users = [];
  Map<String, dynamic> _stats = {};
  String _searchQuery = "";
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
      final response = await ReportRepository.getUserReport(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        count: 15,
        page: page,
      );
      if (mounted) {
        setState(() {
          // The backend now returns { users: { data: [...], ... }, stats: { ... } }
          final userData = response['users'];
          _users = userData['data'] ?? [];
          _currentPage = userData['current_page'] ?? 1;
          _lastPage = userData['last_page'] ?? 1;
          _stats = response['stats'] ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
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
          _buildHeader(),
          SizedBox(height: AppStyle.defaultPadding),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(child: _buildUserTable(_users)),
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
            "کل کاربران",
            _stats['total_users']?.toString() ?? "0",
            Icons.people,
            Colors.blue,
          ),
        ),
        SizedBox(width: AppStyle.defaultPadding),
        Expanded(
          child: _buildStatCard(
            "امروز",
            _stats['new_today']?.toString() ?? "0",
            Icons.person_add,
            Colors.green,
          ),
        ),
        SizedBox(width: AppStyle.defaultPadding),
        Expanded(
          child: _buildStatCard(
            "دارای موجودی",
            _stats['with_balance']?.toString() ?? "0",
            Icons.account_balance_wallet,
            Colors.orange,
          ),
        ),
      ],
    );
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
          Icon(icon, color: color, size: 30),
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onSubmitted: (value) {
                setState(() => _searchQuery = value);
                _fetchData();
              },
              decoration: InputDecoration(
                hintText: "جستجو در کاربران (Enter برای جستجو)...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppStyle.bgColor.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 15),
          IconButton(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh),
            style: IconButton.styleFrom(
              backgroundColor: AppStyle.primaryColor.withValues(alpha: 0.1),
              foregroundColor: AppStyle.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable(List<dynamic> users) {
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
          DataColumn2(label: Text("شناسه عددی"), size: ColumnSize.M),
          DataColumn2(label: Text("نام کاربری"), size: ColumnSize.L),
          DataColumn2(label: Text("نام"), size: ColumnSize.L),
          DataColumn2(label: Text("موجودی"), size: ColumnSize.M),
          DataColumn2(label: Text("تاریخ عضویت"), size: ColumnSize.M),
        ],
        rows: users.map((user) {
          final balance =
              double.tryParse(user['wallet_balance']?.toString() ?? "0") ?? 0;
          return DataRow(
            onSelectChanged: (_) => _showUserDetails(user),
            cells: [
              DataCell(Text(user['account_id']?.toString() ?? "-")),
              DataCell(Text(user['username']?.toString() ?? "-")),
              DataCell(Text(
                  "${user['first_name'] ?? ""} ${user['last_name'] ?? ""}")),
              DataCell(Text(
                "${balance.toStringAsFixed(0)} ت",
                style: TextStyle(
                  color: balance > 0 ? Colors.green : Colors.white70,
                  fontWeight: balance > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              )),
              DataCell(
                  Text(user['created_at']?.toString().split('T')[0] ?? "-")),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showUserDetails(dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppStyle.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppStyle.primaryColor,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                "${user['first_name'] ?? 'کاربر'} ${user['last_name'] ?? ''}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow("شناسه عددی:", user['account_id']?.toString(),
                    trailing: IconButton(
                      icon:
                          const Icon(Icons.copy, size: 18, color: Colors.blue),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: user['account_id'].toString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("شناسه کپی شد")),
                        );
                      },
                    )),
                _buildDetailRow("نام کاربری:",
                    user['username'] != null ? "@${user['username']}" : "-"),
                _buildDetailRow(
                    "زبان:", user['language_code']?.toString().toUpperCase()),
                _buildDetailRow("تاریخ عضویت:",
                    user['created_at']?.toString().split('T')[0]),
                const Divider(color: Colors.white24, height: 30),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("موجودی کیف پول:",
                          style: TextStyle(color: Colors.green)),
                      Text(
                        "${user['wallet_balance'] ?? 0} تومان",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("بستن", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Placeholder for future functionality
              Navigator.pop(context);
            },
            icon: const Icon(Icons.history),
            label: const Text("تاریخچه خرید"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
              textAlign: TextAlign.left,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
