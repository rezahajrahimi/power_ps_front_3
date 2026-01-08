import 'package:flutter/material.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/repositories/product_categoy_repository.dart'
    // ignore: library_prefixes
    as productCategoyRepository;
import 'package:powerps/repositories/report_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:data_table_2/data_table_2.dart';

class ConfigsReportTab extends StatefulWidget {
  const ConfigsReportTab({super.key});

  @override
  State<ConfigsReportTab> createState() => _ConfigsReportTabState();
}

class _ConfigsReportTabState extends State<ConfigsReportTab>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  List<dynamic> _products = [];
  List<ProductCategory> _categories = [];
  int? _selectedCategoryId;
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _loadCategories();
    _fetchData();
    super.initState();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await productCategoyRepository.getAllProdctCategory();
      if (cats is List<ProductCategory>) {
        setState(() => _categories = cats);
      }
    } catch (e) {
      debugPrint("Error loading categories: $e");
    }
  }

  Future<void> _fetchData({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _currentPage = page;
    });
    try {
      final data = await ReportRepository.getProductReport(
        categoryId: _selectedCategoryId,
        count: 15,
        page: page,
      );
      if (mounted) {
        setState(() {
          _products = data['data'] ?? [];
          _currentPage = data['current_page'] ?? 1;
          _lastPage = data['last_page'] ?? 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching product report: $e");
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
          _buildFilterHeader(),
          SizedBox(height: AppStyle.defaultPadding),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(child: _buildProductTable()),
                      _buildPagination(),
                    ],
                  ),
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
          const Icon(Icons.filter_alt_outlined, color: Colors.white70),
          const SizedBox(width: 10),
          const Text("فیلتر دسته بندی:",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(width: 15),
          Expanded(
            child: DropdownButton<int>(
              value: _selectedCategoryId,
              hint: const Text("همه دسته‌ها",
                  style: TextStyle(color: Colors.grey)),
              dropdownColor: AppStyle.secondaryColor,
              isExpanded: true,
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text("همه دسته‌ها"),
                ),
                ..._categories.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat.id,
                    child: Text(cat.categoryName),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() => _selectedCategoryId = val);
                _fetchData();
              },
            ),
          ),
          IconButton(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh),
            color: AppStyle.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildProductTable() {
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
          DataColumn2(label: Text("دسته بندی"), size: ColumnSize.L),
          DataColumn2(label: Text("نام نمایشی (Remark)"), size: ColumnSize.L),
          DataColumn2(label: Text("وضعیت"), size: ColumnSize.M),
          DataColumn2(label: Text("تاریخ"), size: ColumnSize.M),
        ],
        rows: _products.map((p) {
          final bool isActive =
              p['isActive'].toString() == "1" || p['isActive'] == true;
          return DataRow(cells: [
            DataCell(Text(
                p['user']?['username'] ?? p['account_id']?.toString() ?? "-")),
            DataCell(Text(p['product_category']?['category_name'] ?? "-")),
            DataCell(Text(p['remark'] ?? "-")),
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                isActive ? "فعال" : "غیرفعال",
                style: TextStyle(
                    color: isActive ? Colors.green : Colors.red, fontSize: 12),
              ),
            )),
            DataCell(Text(p['created_at']?.toString().split('T')[0] ?? "-")),
          ]);
        }).toList(),
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
}
