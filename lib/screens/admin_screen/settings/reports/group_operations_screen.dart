import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/hiffify_config_model.dart';
import 'package:powerps/provider/panel_controller.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/repositories/hiddify_repository.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/product_details/hiddify_config_details_with_check_box_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:searchable_listview/searchable_listview.dart';

class GroupOperationsScreen extends StatefulWidget {
  const GroupOperationsScreen({super.key});

  @override
  State<GroupOperationsScreen> createState() => _GroupOperationsScreenState();
}

class _GroupOperation {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GroupOperation({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _GroupOperationsScreenState extends State<GroupOperationsScreen> {
  bool _showData = false;
  bool _showPannelData = false;
  bool _loadingUsers = false;
  final List<String> _pannelNameList = [];
  String _selectedPannelName = "";
  List<HiddifyConfig> _usersList = [];

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  @override
  void dispose() {
    _usersList.clear();
    _pannelNameList.clear();
    _selectedPannelName = "";
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fillData();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final selectedCount =
        context.watch<PannelChangeController>().obtinedConfigList.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgColor,
        appBar: appBarWithBackButton(context: context, title: "عملیات گروهی"),
        body: SafeArea(
          child: !_showData
              ? const Center(child: CircularProgressIndicator())
              : isMobile
                  ? _buildMobileBody(context, selectedCount)
                  : _buildDesktopBody(context, selectedCount),
        ),
        bottomNavigationBar: isMobile && _showData
            ? _buildMobileBottomBar(context, selectedCount)
            : null,
      ),
    );
  }

  Widget _buildMobileBody(BuildContext context, int selectedCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: Responsive.adminPagePadding(context),
          child: _buildPanelSelector(context, compact: true),
        ),
        if (_showPannelData) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
            child: _buildStatsRow(selectedCount),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
            child: _buildFilterChips(context),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildConfigList(context)),
        ] else
          Expanded(child: _buildEmptyState()),
      ],
    );
  }

  Widget _buildDesktopBody(BuildContext context, int selectedCount) {
    return Padding(
      padding: Responsive.adminPagePadding(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPanelSelector(context, compact: false),
                const SizedBox(height: 12),
                if (_showPannelData) ...[
                  _buildStatsRow(selectedCount),
                  const SizedBox(height: 12),
                  _buildFilterChips(context),
                  const SizedBox(height: 12),
                  Expanded(child: _buildConfigList(context)),
                ] else
                  Expanded(child: _buildEmptyState()),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: Responsive.isTablet(context) ? 300 : 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSelectedConfigsCard(context, selectedCount),
                const SizedBox(height: 12),
                Expanded(child: _buildOperationsCard(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomBar(BuildContext context, int selectedCount) {
    return Material(
      elevation: 12,
      color: AppStyle.secondaryColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppStyle.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 18, color: AppStyle.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      '$selectedCount انتخاب',
                      style: TextStyle(
                        color: AppStyle.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: selectedCount == 0
                    ? null
                    : () => _showMobileOperationsSheet(context),
                icon: const Icon(Icons.bolt_outlined, size: 20),
                label: const Text('اجرای عملیات'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppStyle.primaryColor,
                  disabledBackgroundColor: Colors.white12,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMobileOperationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppStyle.secondaryColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.layers_outlined, color: AppStyle.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'انتخاب عملیات',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _buildOperationsGrid(
                  ctx,
                  crossAxisCount: 2,
                  beforeTap: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPanelSelector(BuildContext context, {required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.dns_outlined,
            title: 'انتخاب پنل',
            subtitle: 'پنل مورد نظر را انتخاب و لیست کانفیگ‌ها را بارگذاری کنید',
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedPannelName.isEmpty ? null : _selectedPannelName,
            decoration: InputDecoration(
              labelText: 'پنل',
              filled: true,
              fillColor: AppStyle.bgColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: _pannelNameList
                .map((name) => DropdownMenuItem(
                      value: name,
                      child: Text(name, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedPannelName = value;
                _showPannelData = false;
                _usersList = [];
              });
              Provider.of<PannelChangeController>(context, listen: false)
                  .clearConfigList();
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loadingUsers ? null : _loadPanelUsers,
              icon: _loadingUsers
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_download_outlined),
              label: Text(_loadingUsers ? 'در حال بارگذاری...' : 'دریافت لیست کانفیگ‌ها'),
              style: FilledButton.styleFrom(
                backgroundColor: AppStyle.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int selectedCount) {
    return Row(
      children: [
        _statChip(
          icon: Icons.people_outline,
          label: 'کل کانفیگ‌ها',
          value: '${_usersList.length}',
          color: Colors.blueAccent,
        ),
        const SizedBox(width: 8),
        _statChip(
          icon: Icons.check_circle_outline,
          label: 'انتخاب‌شده',
          value: '$selectedCount',
          color: AppStyle.primaryColor,
        ),
        const SizedBox(width: 8),
        _statChip(
          icon: Icons.toggle_on_outlined,
          label: 'فعال',
          value: '${_usersList.where((e) => e.isActive).length}',
          color: Colors.greenAccent,
        ),
      ],
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = <({String label, IconData icon, VoidCallback onTap})>[
      (
        label: 'همه',
        icon: Icons.select_all,
        onTap: () => _selectAll(),
      ),
      (
        label: 'فعال‌ها',
        icon: Icons.check_circle_outline,
        onTap: () => _selectWhere((c) => c.isActive),
      ),
      (
        label: 'غیرفعال‌ها',
        icon: Icons.block,
        onTap: () => _selectWhere((c) => !c.isActive),
      ),
      (
        label: 'بدون مصرف',
        icon: Icons.data_usage,
        onTap: () => _selectWhere((c) => c.currentUsageGB == 0),
      ),
      (
        label: 'پاک کردن',
        icon: Icons.clear_all,
        onTap: () => Provider.of<PannelChangeController>(context, listen: false)
            .clearConfigList(),
      ),
      (
        label: 'پیشرفته',
        icon: Icons.tune,
        onTap: () => _showAdvancedSelectionSheet(context),
      ),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = filters[index];
          return ActionChip(
            avatar: Icon(f.icon, size: 16, color: AppStyle.primaryColor),
            label: Text(f.label),
            backgroundColor: AppStyle.bgColor,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            onPressed: f.onTap,
          );
        },
      ),
    );
  }

  Widget _buildConfigList(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.list_alt,
            title: 'کانفیگ‌های پنل',
            subtitle: 'کانفیگ‌های مورد نظر را انتخاب کنید',
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SearchableList<HiddifyConfig>(
              initialList: _usersList,
              shrinkWrap: false,
              textStyle: const TextStyle(fontSize: 16),
              itemBuilder: (config) =>
                  HiddifyConfigDetailsWithCheckBoxWidget(item: config),
              loadingWidget: const Center(child: CircularProgressIndicator()),
              errorWidget: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 32),
                    SizedBox(height: 8),
                    Text('خطا در بارگذاری'),
                  ],
                ),
              ),
              filter: (q) => _usersList
                  .where((e) => e.name.toLowerCase().contains(q.toLowerCase()))
                  .toList(),
              textAlign: TextAlign.right,
              emptyWidget: const _EmptyView(),
              onRefresh: () async {},
              sortPredicate: (a, b) => a.name.compareTo(b.name),
              displayClearIcon: true,
              inputDecoration: InputDecoration(
                hintText: 'جستجوی کانفیگ...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: AppStyle.bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedConfigsCard(BuildContext context, int selectedCount) {
    final configs =
        context.watch<PannelChangeController>().obtinedConfigList;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.playlist_add_check,
            title: 'انتخاب‌شده ($selectedCount)',
            subtitle: selectedCount == 0
                ? 'هنوز کانفیگی انتخاب نشده'
                : '$selectedCount کانفیگ برای عملیات آماده است',
          ),
          const SizedBox(height: 10),
          if (configs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppStyle.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.touch_app_outlined,
                      size: 32, color: Colors.white38),
                  SizedBox(height: 8),
                  Text(
                    'از لیست سمت چپ کانفیگ انتخاب کنید',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: configs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final item = configs[index];
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppStyle.bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppStyle.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.isActive
                              ? Icons.circle
                              : Icons.circle_outlined,
                          size: 10,
                          color: item.isActive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          '${item.packageDays}روز / ${item.usageLimitGB}GB',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (configs.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Provider.of<PannelChangeController>(context,
                      listen: false)
                  .clearConfigList(),
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('پاک کردن انتخاب‌ها'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOperationsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.bolt_outlined,
            title: 'عملیات گروهی',
            subtitle: 'عملیات روی کانفیگ‌های انتخاب‌شده اعمال می‌شود',
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: _buildOperationsGrid(context, crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsGrid(
    BuildContext context, {
    required int crossAxisCount,
    VoidCallback? beforeTap,
  }) {
    final ops = _operationItems(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: crossAxisCount == 2 ? 1.55 : 2.2,
      ),
      itemCount: ops.length,
      itemBuilder: (context, index) {
        final op = ops[index];
        return Material(
          color: AppStyle.bgColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              beforeTap?.call();
              op.onTap();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: op.color.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: op.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(op.icon, color: op.color, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    op.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<_GroupOperation> _operationItems(BuildContext context) {
    return [
      _GroupOperation(
        label: 'افزایش روز/حجم',
        icon: Icons.add_circle_outline,
        color: Colors.greenAccent,
        onTap: () => _submitIncOprDialog(context, opr: 'inc'),
      ),
      _GroupOperation(
        label: 'کاهش روز/حجم',
        icon: Icons.remove_circle_outline,
        color: Colors.orangeAccent,
        onTap: () => _submitIncOprDialog(context, opr: 'dec'),
      ),
      _GroupOperation(
        label: 'تغییر روز/حجم',
        icon: Icons.edit_outlined,
        color: Colors.blueAccent,
        onTap: () => _showChangeDialog(context),
      ),
      _GroupOperation(
        label: 'فعال / غیرفعال',
        icon: Icons.power_settings_new,
        color: Colors.cyanAccent,
        onTap: () => _showChangeActivationDialog(context),
      ),
      _GroupOperation(
        label: 'ریست مصرف',
        icon: Icons.restart_alt,
        color: Colors.amberAccent,
        onTap: () => _showResetDialog(context),
      ),
      _GroupOperation(
        label: 'حذف کانفیگ',
        icon: Icons.delete_forever_outlined,
        color: Colors.redAccent,
        onTap: () => _showDeleteDialog(context),
      ),
    ];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: _cardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_queue_outlined,
                size: 56, color: AppStyle.primaryColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'لیست کانفیگ‌ها بارگذاری نشده',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'ابتدا یک پنل انتخاب کنید و دکمه «دریافت لیست کانفیگ‌ها» را بزنید',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppStyle.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppStyle.primaryColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _selectAll() {
    final ctrl = Provider.of<PannelChangeController>(context, listen: false);
    for (final config in _usersList) {
      ctrl.addNewConfig(config);
    }
  }

  void _selectWhere(bool Function(HiddifyConfig) predicate) {
    final ctrl = Provider.of<PannelChangeController>(context, listen: false);
    for (final config in _usersList) {
      if (predicate(config)) {
        ctrl.addNewConfig(config);
      }
    }
  }

  void _showAdvancedSelectionSheet(BuildContext context) {
    final dayGroup =
        _usersList.map((e) => e.packageDays).toSet().toList()..sort();
    final capacityGroup =
        _usersList.map((e) => e.usageLimitGB).toSet().toList()..sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppStyle.secondaryColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (_, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'انتخاب پیشرفته',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Divider(color: Colors.white10),
                if (dayGroup.isNotEmpty) ...[
                  const Text('بر اساس روز',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dayGroup.map((days) {
                      return ActionChip(
                        label: Text('$days روز'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _selectWhere((c) => c.packageDays == days);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                if (capacityGroup.isNotEmpty) ...[
                  const Text('بر اساس حجم',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: capacityGroup.map((gb) {
                      return ActionChip(
                        label: Text('$gb GB'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _selectWhere((c) => c.usageLimitGB == gb);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadPanelUsers() async {
    final pannelID = _selectedPanelId();
    if (pannelID <= 0) {
      showMsg(
          msg: 'یک پنل معتبر انتخاب کنید.',
          context: context,
          type: 'error');
      return;
    }

    Provider.of<PannelChangeController>(context, listen: false)
        .clearConfigList();
    setState(() {
      _loadingUsers = true;
      _showPannelData = false;
    });

    try {
      final res = await getHiddifyPanelUsersByPannelID(pannelID: pannelID);
      if (!mounted) return;
      if (res != null && res != false) {
        setState(() {
          _usersList = res;
          _showPannelData = true;
        });
      } else {
        showMsg(
            msg: 'خطا در دریافت لیست کانفیگ‌ها',
            context: context,
            type: 'error');
      }
    } catch (_) {
      if (!mounted) return;
      showMsg(
          msg: 'خطا در دریافت لیست کانفیگ‌ها',
          context: context,
          type: 'error');
    } finally {
      if (mounted) {
        setState(() => _loadingUsers = false);
      }
    }
  }

  void _fillData() async {
    if (!context.mounted) return;
    try {
      final onValue = await getPannels();
      if (!mounted) return;
      if (onValue.isEmpty) return;

      final supportedPanels = onValue
          .where((panel) => panelSupportsGroupOperations(panel.type))
          .toList();

      if (supportedPanels.isEmpty) {
        showMsg(
            msg: 'هیچ پنل قابل پشتیبانی برای عملیات گروهی یافت نشد.',
            context: context,
            type: 'error');
        Navigator.of(context).pop();
        return;
      }

      setState(() {
        _pannelNameList
          ..clear()
          ..addAll(supportedPanels.map((i) =>
              '${i.id}: ${getPannelName(name: i.type)} - ${i.location}'));
        _selectedPannelName =
            '${supportedPanels[0].id}: ${getPannelName(name: supportedPanels[0].type)} - ${supportedPanels[0].location}';
        _showData = true;
      });
    } catch (_) {
      if (!mounted) return;
      showMsg(msg: 'خطا', context: context, type: 'error');
      Navigator.of(context).pop();
    }
  }

  int _selectedPanelId() {
    if (_selectedPannelName.isEmpty) return 0;
    return int.parse(_selectedPannelName.split(':')[0]);
  }

  bool _ensureConfigsSelected(BuildContext context) {
    final configs =
        Provider.of<PannelChangeController>(context, listen: false)
            .obtinedConfigList;
    if (configs.isEmpty) {
      showMsg(
          msg: 'حداقل یک کانفیگ انتخاب کنید.',
          context: context,
          type: 'error');
      return false;
    }
    return true;
  }

  Future<void> _submitIncOprDialog(BuildContext context,
      {required String opr}) async {
    if (!_ensureConfigsSelected(context)) return;

    final input = TextEditingController();
    const options = ['روز', 'حجم'];
    var selectedOption = 'روز';
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return Form(
          key: formKey,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppStyle.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(opr == 'inc'
                  ? 'افزایش روز یا حجم'
                  : 'کاهش روز یا حجم'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedOption,
                    decoration: const InputDecoration(
                      labelText: 'نوع تغییر',
                      border: OutlineInputBorder(),
                    ),
                    items: options
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) => selectedOption = v ?? 'روز',
                  ),
                  const SizedBox(height: 12),
                  CustomTextFromFieldWidget(
                    controller: input,
                    textHint: 'مقدار',
                    validationError: 'مقدار را وارد کنید.',
                    validatorType: 'text',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('لغو'),
                ),
                FilledButton(
                  onPressed: () => _runBatchAction(
                    dialogContext,
                    formKey: formKey,
                    action: opr == 'inc'
                        ? (selectedOption == 'روز' ? 'inc_days' : 'inc_vol')
                        : (selectedOption == 'روز' ? 'dec_days' : 'dec_vol'),
                    day: int.tryParse(input.text) ?? 0,
                    vol: input.text,
                  ),
                  child: const Text('اعمال'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangeActivationDialog(BuildContext context) {
    if (!_ensureConfigsSelected(context)) return;

    const options = ['فعال سازی', 'غیر فعال سازی'];
    var selectedOption = options.first;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppStyle.secondaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('تغییر وضعیت'),
            content: DropdownButtonFormField<String>(
              value: selectedOption,
              decoration: const InputDecoration(
                labelText: 'عملیات',
                border: OutlineInputBorder(),
              ),
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) => selectedOption = v ?? options.first,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('لغو'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _executeBatch(
                    action:
                        selectedOption == 'فعال سازی' ? 'active' : 'deactive',
                  );
                },
                child: const Text('اعمال'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    if (!_ensureConfigsSelected(context)) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppStyle.secondaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            title: const Text('حذف کانفیگ‌ها'),
            content: const Text(
              'این عمل غیرقابل بازگشت است. آیا از حذف کانفیگ‌های انتخاب‌شده مطمئن هستید؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('انصراف'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _executeBatch(action: 'delete');
                },
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChangeDialog(BuildContext context) {
    if (!_ensureConfigsSelected(context)) return;

    final input = TextEditingController();
    const options = ['روز', 'حجم'];
    var selectedOption = 'روز';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Form(
          key: formKey,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppStyle.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('تغییر روز یا حجم'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedOption,
                    decoration: const InputDecoration(
                      labelText: 'نوع تغییر',
                      border: OutlineInputBorder(),
                    ),
                    items: options
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) => selectedOption = v ?? 'روز',
                  ),
                  const SizedBox(height: 12),
                  CustomTextFromFieldWidget(
                    controller: input,
                    textHint: 'مقدار جدید',
                    validationError: 'مقدار را وارد کنید.',
                    validatorType: 'text',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('لغو'),
                ),
                FilledButton(
                  onPressed: () => _runBatchAction(
                    dialogContext,
                    formKey: formKey,
                    action: selectedOption == 'روز' ? 'modify_days' : 'modify_vol',
                    day: int.tryParse(input.text) ?? 0,
                    vol: input.text,
                  ),
                  child: const Text('اعمال'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResetDialog(BuildContext context) {
    if (!_ensureConfigsSelected(context)) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppStyle.secondaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('ریست مصرف'),
            content: const Text(
              'مصرف فعلی کانفیگ‌ها صفر می‌شود و دوره از امروز مجدداً شروع می‌شود. ادامه می‌دهید؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('انصراف'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _executeBatch(action: 'reset');
                },
                child: const Text('ریست'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _runBatchAction(
    BuildContext dialogContext, {
    required GlobalKey<FormState> formKey,
    required String action,
    required int day,
    required String vol,
  }) {
    if (!formKey.currentState!.validate()) return;
    final pannelID = _selectedPanelId();
    if (pannelID <= 0) {
      showMsg(
          msg: 'یک پنل معتبر انتخاب کنید.',
          context: dialogContext,
          type: 'error');
      return;
    }
    Navigator.pop(dialogContext);
    _executeBatch(action: action, day: day, vol: vol);
  }

  Future<void> _executeBatch({
    required String action,
    int day = 0,
    String vol = '0',
  }) async {
    final pannelID = _selectedPanelId();
    if (pannelID <= 0) {
      showMsg(
          msg: 'یک پنل معتبر انتخاب کنید.',
          context: context,
          type: 'error');
      return;
    }

    EasyLoading.show(status: 'در حال ارسال درخواست...');
    try {
      final value = await batchExistSubscriptionJobDayOpr(
        action: action,
        day: day,
        vol: vol,
        panelId: pannelID,
        hiddifyConfig:
            Provider.of<PannelChangeController>(context, listen: false)
                .obtinedConfigList,
      );
      EasyLoading.dismiss();
      if (!mounted) return;
      if (value == true) {
        showMsg(
            msg: 'درخواست ثبت شد و در صف اجرا قرار گرفت.',
            context: context);
      } else {
        showMsg(msg: 'خطا در ثبت درخواست', context: context, type: 'error');
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (!mounted) return;
      showMsg(msg: 'خطا', context: context, type: 'error');
    }
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, color: Colors.white38, size: 40),
        SizedBox(height: 8),
        Text('نتیجه‌ای یافت نشد', style: TextStyle(color: Colors.white54)),
      ],
    );
  }
}
