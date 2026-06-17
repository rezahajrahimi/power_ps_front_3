import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/repositories/inventory_import_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/inventory/inventory_stock_item_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class InventoryImportScreen extends StatefulWidget {
  const InventoryImportScreen({super.key});

  @override
  State<InventoryImportScreen> createState() => _InventoryImportScreenState();
}

class _InventoryImportScreenState extends State<InventoryImportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  List<Pannel> _inventoryPanels = [];
  Pannel? _selectedPanel;
  File? _selectedFile;
  bool _loadingPanels = true;

  bool _loadingStock = false;
  List<ProductDetails> _stockItems = [];
  Map<String, int> _summary = {'active': 0, 'sold': 0, 'total': 0};
  int _currentPage = 1;
  int _lastPage = 1;
  int _stockTotal = 0;

  String _statusFilter = 'all';
  String _sort = 'created_at_desc';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadPanels();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && !_tabController.indexIsChanging) {
      _loadStock(resetPage: true);
    }
    setState(() {});
  }

  EdgeInsets _screenPadding(BuildContext context) {
    return EdgeInsets.all(AppStyle.defaultPadding);
  }

  int _stockGridColumns(BuildContext context) {
    if (Responsive.isDesktop(context)) return 3;
    if (Responsive.isTablet(context)) return 2;
    return 1;
  }

  BoxDecoration _sectionDecoration() {
    return BoxDecoration(
      color: AppStyle.secondaryColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    );
  }

  Future<void> _loadPanels() async {
    final panels = await getInventoryPanels();
    if (!mounted) return;
    setState(() {
      _inventoryPanels = panels;
      _selectedPanel = panels.isNotEmpty ? panels.first : null;
      _loadingPanels = false;
    });
    if (_tabController.index == 1 && _selectedPanel != null) {
      _loadStock(resetPage: true);
    }
  }

  Future<void> _loadStock({bool resetPage = false, int? page}) async {
    if (_selectedPanel == null) return;

    if (resetPage) {
      _currentPage = 1;
    } else if (page != null) {
      _currentPage = page;
    }

    setState(() => _loadingStock = true);

    final response = await getInventoryStock(
      panelId: int.parse(_selectedPanel!.id),
      status: _statusFilter,
      sort: _sort,
      search: _searchController.text,
      page: _currentPage,
    );

    if (!mounted) return;

    setState(() {
      _loadingStock = false;
      if (response != null) {
        if (_currentPage <= 1) {
          _stockItems = response.items;
        } else {
          _stockItems = [..._stockItems, ...response.items];
        }
        _summary = response.summary;
        _currentPage = response.currentPage;
        _lastPage = response.lastPage;
        _stockTotal = response.total;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
            context: context,
            title: 'موجودی و import اکسل',
          ),
          body: _loadingPanels
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(context),
          bottomNavigationBar: isMobile && _inventoryPanels.isNotEmpty
              ? (_tabController.index == 0 ? _mobileImportBottomBar() : null)
              : null,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_inventoryPanels.isEmpty) {
      return SingleChildScrollView(
        padding: _screenPadding(context),
        child: Responsive(
          mobile: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _infoCard(),
              SizedBox(height: AppStyle.defaultPadding),
              _emptyPanelCard(),
            ],
          ),
          desktop: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _infoCard(),
                  SizedBox(height: AppStyle.defaultPadding),
                  _emptyPanelCard(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppStyle.defaultPadding,
              AppStyle.defaultPadding,
              AppStyle.defaultPadding,
              0,
            ),
            child: _panelSelector(),
          ),
          _tabBar(),
          Expanded(child: _tabBarView(context)),
        ],
      );
    }

    return Padding(
      padding: _screenPadding(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _desktopMainHeader(context),
                const SizedBox(height: 12),
                Expanded(child: _tabBarView(context)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: Responsive.isDesktop(context) ? 300 : 260,
            child: _sidebar(context),
          ),
        ],
      ),
    );
  }

  Widget _desktopMainHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Row(
        children: [
          Expanded(child: _tabBar(inCard: true)),
          const SizedBox(width: 16),
          SizedBox(width: 260, child: _panelSelector(dense: true)),
        ],
      ),
    );
  }

  Widget _tabBar({bool inCard = false}) {
    return TabBar(
      controller: _tabController,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: inCard ? AppStyle.primaryColor : null,
      tabs: const [
        Tab(
          icon: Icon(Icons.upload_file_outlined, size: 20),
          text: 'بارگذاری',
        ),
        Tab(
          icon: Icon(Icons.inventory_2_outlined, size: 20),
          text: 'تاریخچه موجودی',
        ),
      ],
    );
  }

  Widget _tabBarView(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        _importTab(context),
        _historyTab(context),
      ],
    );
  }

  Widget _sidebar(BuildContext context) {
    final isImportTab = _tabController.index == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isImportTab) ...[
          _infoCard(),
          SizedBox(height: AppStyle.defaultPadding),
          _importActionsCard(context),
        ] else ...[
          _summaryCards(vertical: true),
          SizedBox(height: AppStyle.defaultPadding),
          _historyFilters(),
        ],
      ],
    );
  }

  Widget _importTab(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: isMobile ? _screenPadding(context) : EdgeInsets.zero,
      child: Responsive(
        mobile: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _infoCard(),
            SizedBox(height: AppStyle.defaultPadding),
            _fileCard(context),
            SizedBox(height: AppStyle.defaultPadding),
            _importActions(),
          ],
        ),
        tablet: _importDesktopLayout(context),
        desktop: _importDesktopLayout(context),
      ),
    );
  }

  Widget _importDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _fileCard(context, expanded: true),
        ),
        SizedBox(width: AppStyle.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _formatGuideCard(),
              SizedBox(height: AppStyle.defaultPadding),
              OutlinedButton.icon(
                onPressed: _downloadTemplate,
                icon: const Icon(Icons.download),
                label: const Text('دانلود فایل نمونه'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _historyTab(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final columns = _stockGridColumns(context);
    final useGrid = columns > 1;

    return RefreshIndicator(
      onRefresh: () => _loadStock(resetPage: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (isMobile) ...[
            SliverPadding(
              padding: _screenPadding(context),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _summaryCards(),
                  SizedBox(height: AppStyle.defaultPadding),
                  _historyFilters(),
                  SizedBox(height: AppStyle.defaultPadding),
                ]),
              ),
            ),
          ] else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _historyListHeader(context),
              ),
            ),
          ],
          if (_loadingStock)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_stockItems.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: isMobile ? _screenPadding(context) : EdgeInsets.zero,
                child: _emptyStockCard(),
              ),
            )
          else if (useGrid)
            SliverPadding(
              padding: isMobile ? _screenPadding(context) : EdgeInsets.zero,
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: Responsive.isDesktop(context) ? 1.15 : 1.05,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _stockItemTile(_stockItems[index], compact: true),
                  childCount: _stockItems.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: _screenPadding(context),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _stockItemTile(_stockItems[index], compact: false),
                  childCount: _stockItems.length,
                ),
              ),
            ),
          if (!_loadingStock && _currentPage < _lastPage)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppStyle.defaultPadding),
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _loadStock(page: _currentPage + 1),
                    icon: const Icon(Icons.expand_more),
                    label: const Text('بارگذاری بیشتر'),
                  ),
                ),
              ),
            ),
          if (!_loadingStock && _stockTotal > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'نمایش ${_stockItems.length} از $_stockTotal مورد — صفحه $_currentPage از $_lastPage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _historyListHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyle.defaultPadding,
        vertical: AppStyle.defaultPadding / 2,
      ),
      decoration: _sectionDecoration(),
      child: Row(
        children: [
          Icon(Icons.list_alt, color: AppStyle.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'لیست کانفیگ‌ها ($_stockTotal)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (_loadingStock)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _stockItemTile(ProductDetails item, {required bool compact}) {
    return InventoryStockItemWidget(
      item: item,
      compact: compact,
      onCopy: () {
        if (!mounted) return;
        showMsg(msg: 'کانفیگ کپی شد', context: context, type: 'success');
      },
      onEdit: () => _openEditDialog(item),
      onDelete: () => _confirmDelete(item),
    );
  }

  Widget _summaryCards({bool vertical = false}) {
    final tiles = [
      _summaryTile('موجود فعال', _summary['active'] ?? 0, Colors.green),
      _summaryTile('فروخته‌شده', _summary['sold'] ?? 0, Colors.orange),
      _summaryTile('کل', _summary['total'] ?? 0, Colors.blue),
    ];

    if (vertical) {
      return Container(
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: _sectionDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('خلاصه موجودی', style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: AppStyle.defaultPadding),
            ...tiles.map(
              (tile) => Padding(
                padding: EdgeInsets.only(bottom: AppStyle.defaultPadding / 2),
                child: tile,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: tiles[0]),
        SizedBox(width: AppStyle.defaultPadding / 2),
        Expanded(child: tiles[1]),
        SizedBox(width: AppStyle.defaultPadding / 2),
        Expanded(child: tiles[2]),
      ],
    );
  }

  Widget _summaryTile(String label, int value, Color color) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(label, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyFilters() {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('فیلتر و جستجو', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppStyle.defaultPadding),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'جستجو (دسته / کانفیگ)',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _loadStock(resetPage: true),
              ),
            ),
            onSubmitted: (_) => _loadStock(resetPage: true),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _statusDropdown(),
          SizedBox(height: AppStyle.defaultPadding),
          _sortDropdown(),
        ],
      ),
    );
  }

  Widget _statusDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _statusFilter,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'وضعیت',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(
          value: 'all',
          child: Text('همه', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: 'active',
          child: Text('موجود فعال', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: 'sold',
          child: Text('فروخته‌شده', overflow: TextOverflow.ellipsis),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _statusFilter = value);
        _loadStock(resetPage: true);
      },
    );
  }

  Widget _sortDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _sort,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'مرتب‌سازی',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(
          value: 'created_at_desc',
          child: Text('جدیدترین', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: 'created_at_asc',
          child: Text('قدیمی‌ترین', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: 'updated_at_desc',
          child: Text('آخرین تغییر', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: 'category_asc',
          child: Text('دسته (الف-ی)', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: 'category_desc',
          child: Text('دسته (ی-الف)', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: 'price_desc',
          child: Text('قیمت (بیشترین)', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: 'price_asc',
          child: Text('قیمت (کمترین)', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: 'status',
          child: Text('وضعیت موجودی', overflow: TextOverflow.ellipsis),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _sort = value);
        _loadStock(resetPage: true);
      },
    );
  }

  Widget _emptyStockCard() {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding * 2),
      decoration: _sectionDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.white38),
          SizedBox(height: AppStyle.defaultPadding),
          const Text(
            'هنوز کانفیگی برای این پنل ثبت نشده است.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppStyle.primaryColor, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'فایل باید شامل ستون‌های دسته‌بندی، قیمت (تومان) و کانفیگ باشد. '
              'در تب تاریخچه، موجودی فعال و فروخته‌شده قابل مشاهده و مرتب‌سازی است.',
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formatGuideCard() {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ستون‌های فایل', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppStyle.defaultPadding / 2),
          _formatRow('دسته‌بندی', 'الزامی'),
          _formatRow('قیمت (تومان)', 'الزامی'),
          _formatRow('کانفیگ', 'الزامی'),
          _formatRow('لینک سابسکریپشن', 'اختیاری'),
          _formatRow('لینک پنل', 'اختیاری'),
        ],
      ),
    );
  }

  Widget _formatRow(String label, String badge) {
    final isRequired = badge == 'الزامی';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (isRequired ? Colors.blue : Colors.grey)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 11,
                color: isRequired ? Colors.blueAccent : Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyPanelCard() {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding * 1.5),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 40, color: Colors.orangeAccent.shade200),
          SizedBox(height: AppStyle.defaultPadding),
          const Text(
            'هیچ پنل موجودی (نوع «دیگر») ثبت نشده است. ابتدا از تنظیمات پنل، یک پنل از نوع دیگر بسازید.',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _panelSelector({bool dense = false}) {
    return DropdownButtonFormField<Pannel>(
      initialValue: _selectedPanel,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'پنل موجودی',
        border: const OutlineInputBorder(),
        contentPadding: dense
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : null,
      ),
      items: _inventoryPanels
          .map(
            (panel) => DropdownMenuItem(
              value: panel,
              child: Text(panel.location ?? 'پنل ${panel.id}'),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() => _selectedPanel = value);
        if (_tabController.index == 1) {
          _loadStock(resetPage: true);
        }
      },
    );
  }

  Widget _fileCard(BuildContext context, {bool expanded = false}) {
    final fileName = _selectedFile?.path.split(Platform.pathSeparator).last ??
        'فایلی انتخاب نشده است';
    final hasFile = _selectedFile != null;

    return Container(
      padding: EdgeInsets.all(
        expanded ? AppStyle.defaultPadding * 1.5 : AppStyle.defaultPadding,
      ),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('بارگذاری فایل', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppStyle.defaultPadding),
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(
                expanded
                    ? AppStyle.defaultPadding * 2
                    : AppStyle.defaultPadding,
              ),
              decoration: BoxDecoration(
                color: AppStyle.bgColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasFile
                      ? AppStyle.primaryColor.withValues(alpha: 0.5)
                      : Colors.white24,
                  style: hasFile ? BorderStyle.solid : BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    hasFile
                        ? Icons.check_circle_outline
                        : Icons.cloud_upload_outlined,
                    size: expanded ? 56 : 40,
                    color: hasFile ? Colors.greenAccent : AppStyle.primaryColor,
                  ),
                  SizedBox(height: AppStyle.defaultPadding),
                  Text(
                    fileName,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontWeight: hasFile ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: AppStyle.defaultPadding / 2),
                  Text(
                    'فرمت‌های مجاز: xlsx, csv',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                  SizedBox(height: AppStyle.defaultPadding),
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('انتخاب فایل'),
                  ),
                ],
              ),
            ),
          ),
          if (!Responsive.isMobile(context) && !expanded) ...[
            SizedBox(height: AppStyle.defaultPadding),
            ElevatedButton.icon(
              onPressed: _selectedFile == null || _selectedPanel == null
                  ? null
                  : _importFile,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('شروع import'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _importActionsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('عملیات', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppStyle.defaultPadding),
          ..._importActionButtons(),
        ],
      ),
    );
  }

  Widget _importActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _importActionButtons(),
    );
  }

  List<Widget> _importActionButtons() {
    return [
      OutlinedButton.icon(
        onPressed: _downloadTemplate,
        icon: const Icon(Icons.download),
        label: const Text('دانلود فایل نمونه'),
      ),
      SizedBox(height: AppStyle.defaultPadding / 2),
      ElevatedButton.icon(
        onPressed: _selectedFile == null || _selectedPanel == null
            ? null
            : _importFile,
        icon: const Icon(Icons.cloud_upload),
        label: const Text('شروع import'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ];
  }

  Widget? _mobileImportBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _downloadTemplate,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('نمونه'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _selectedFile == null || _selectedPanel == null
                    ? null
                    : _importFile,
                icon: const Icon(Icons.cloud_upload, size: 18),
                label: const Text('شروع import'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    setState(() {
      _selectedFile = File(result.files.single.path!);
    });
  }

  Future<void> _downloadTemplate() async {
    EasyLoading.show(status: 'در حال دانلود...');
    try {
      final directory = await getTemporaryDirectory();
      final savePath =
          '${directory.path}/inventory-import-template-${DateTime.now().millisecondsSinceEpoch}.csv';
      final path = await downloadInventoryImportTemplate(savePath: savePath);
      EasyLoading.dismiss();

      if (!mounted) return;
      if (path != null) {
        showMsg(
          msg: 'فایل نمونه ذخیره شد:\n$path',
          context: context,
          type: 'success',
        );
      } else {
        showMsg(
          msg: 'خطا در دانلود فایل نمونه',
          context: context,
          type: 'error',
        );
      }
    } catch (_) {
      EasyLoading.dismiss();
      if (!mounted) return;
      showMsg(
        msg: 'خطا در دانلود فایل نمونه',
        context: context,
        type: 'error',
      );
    }
  }

  Future<void> _importFile() async {
    if (_selectedFile == null || _selectedPanel == null) {
      return;
    }

    EasyLoading.show(status: 'در حال پردازش فایل...');
    final result = await importInventoryExcel(
      panelId: int.parse(_selectedPanel!.id),
      filePath: _selectedFile!.path,
    );
    EasyLoading.dismiss();

    if (!mounted) return;

    if (result == null) {
      showMsg(msg: 'خطا در import فایل', context: context, type: 'error');
      return;
    }

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>? ?? {};
      showMsg(
        msg: 'import انجام شد.\n'
            'دسته جدید: ${data['categories_created'] ?? 0}\n'
            'دسته به‌روز: ${data['categories_updated'] ?? 0}\n'
            'کانفیگ جدید: ${data['configs_imported'] ?? 0}\n'
            'کانفیگ تکراری: ${data['duplicate_configs'] ?? 0}\n'
            'ردیف ردشده: ${data['skipped_rows'] ?? 0}',
        context: context,
        type: 'success',
      );
      setState(() => _selectedFile = null);
      if (_tabController.index == 1) {
        _loadStock(resetPage: true);
      }
    } else {
      showMsg(
        msg: result['message']?.toString() ?? 'خطا در import فایل',
        context: context,
        type: 'error',
      );
    }
  }

  Future<void> _openEditDialog(ProductDetails item) async {
    if (_selectedPanel == null) return;

    final isSold = item.isActive != true;
    final configController = TextEditingController(text: item.configs);
    final subscriptionController =
        TextEditingController(text: item.subscriptionLink);
    final panelLinkController = TextEditingController(text: item.panelLink);
    final isMobile = Responsive.isMobile(context);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(isSold ? 'ویرایش لینک‌ها' : 'ویرایش کانفیگ'),
            content: SizedBox(
              width: isMobile ? null : 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSold)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'این کانفیگ فروخته شده است. فقط لینک‌ها قابل ویرایش هستند.',
                          style: TextStyle(
                              color: Colors.orangeAccent, fontSize: 12),
                        ),
                      ),
                    TextField(
                      controller: configController,
                      readOnly: isSold,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'کانفیگ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subscriptionController,
                      decoration: const InputDecoration(
                        labelText: 'لینک سابسکریپشن',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: panelLinkController,
                      decoration: const InputDecoration(
                        labelText: 'لینک پنل',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('ذخیره'),
              ),
            ],
          ),
        );
      },
    );

    if (saved != true || !mounted) {
      configController.dispose();
      subscriptionController.dispose();
      panelLinkController.dispose();
      return;
    }

    EasyLoading.show(status: 'در حال ذخیره...');
    final result = await updateInventoryStockItem(
      productId: item.id.toInt(),
      panelId: int.parse(_selectedPanel!.id),
      configs: configController.text.trim(),
      subscriptionLink: subscriptionController.text.trim(),
      panelLink: panelLinkController.text.trim(),
    );
    configController.dispose();
    subscriptionController.dispose();
    panelLinkController.dispose();
    EasyLoading.dismiss();

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      showMsg(msg: 'با موفقیت ویرایش شد', context: context, type: 'success');
      _loadStock(resetPage: true);
    } else {
      showMsg(
        msg: result?['message']?.toString() ?? 'خطا در ویرایش',
        context: context,
        type: 'error',
      );
    }
  }

  Future<void> _confirmDelete(ProductDetails item) async {
    if (_selectedPanel == null) return;

    final isSold = item.isActive != true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف کانفیگ'),
            content: Text(
              isSold
                  ? 'این کانفیگ فروخته شده است. حذف آن از تاریخچه خرید کاربر نیز پاک می‌شود. ادامه می‌دهید؟'
                  : 'آیا از حذف این کانفیگ از موجودی مطمئن هستید؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    EasyLoading.show(status: 'در حال حذف...');
    final result = await deleteInventoryStockItem(
      productId: item.id.toInt(),
      panelId: int.parse(_selectedPanel!.id),
    );
    EasyLoading.dismiss();

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      showMsg(msg: 'با موفقیت حذف شد', context: context, type: 'success');
      _loadStock(resetPage: true);
    } else {
      showMsg(
        msg: result?['message']?.toString() ?? 'خطا در حذف',
        context: context,
        type: 'error',
      );
    }
  }
}
