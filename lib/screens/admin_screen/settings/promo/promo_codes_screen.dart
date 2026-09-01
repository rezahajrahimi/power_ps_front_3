import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persian_datetimepickers/persian_datetimepickers.dart';
import 'package:powerps/helper/license_helper.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/models/user_group_model.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/repositories/promo_code_repository.dart';
import 'package:powerps/repositories/user_group_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class PromoCodesScreen extends StatefulWidget {
  const PromoCodesScreen({super.key});

  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen> {
  List<dynamic> _items = [];
  List<ProductCategory> _categories = [];
  List<UserGroup> _userGroups = [];
  bool _loading = true;
  String _licenseType = '';
  bool _licenseChecked = false;

  bool get _isGold => LicenseHelper.isGold(_licenseType);
  bool get _isSilverOrAbove => LicenseHelper.isSilverOrAbove(_licenseType);

  String _pad2(int n) => n.toString().padLeft(2, '0');

  /// Backend expects `YYYY-MM-DD HH:MM:SS` and timezone is configured as `Asia/Tehran`.
  /// We format the selected date using the local DateTime values from the picker.
  String _formatDateTimeForBackend(DateTime dt) {
    return '${dt.year}-${_pad2(dt.month)}-${_pad2(dt.day)} '
        '${_pad2(dt.hour)}:${_pad2(dt.minute)}:${_pad2(dt.second)}';
  }

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    final license = await getLicenseType();
    if (!mounted) return;
    setState(() {
      _licenseType = license;
      _licenseChecked = true;
    });
    if (_isSilverOrAbove) {
      _load();
      _loadFormData();
    } else {
      setState(() => _loading = false);
    }
  }

  List<int> _parseIdList(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => int.tryParse(e.toString())).whereType<int>().toList();
  }

  Future<void> _loadFormData() async {
    final cats = await getAllProdctCategory();
    final groupsData = await getUserGroups(roleType: 'user');
    if (!mounted) return;
    setState(() {
      _categories = cats is List<ProductCategory> ? cats : [];
      _userGroups = (groupsData?['groups'] as List<UserGroup>?) ?? [];
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await PromoCodeRepository.getAll();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      );

  Widget _sectionHeader(BuildContext context, String title,
      {Widget? trailing}) {
    return Row(
      children: [
        Icon(Icons.local_offer, color: AppStyle.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Future<void> _showUsages(int id, String code) async {
    await showDialog(
      context: context,
      builder: (ctx) => PromoUsagesDialog(promoId: id, code: code),
    );
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف کد تخفیف'),
        content: Text('کد ${item['code']} حذف شود؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('انصراف')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    EasyLoading.show();
    final success = await PromoCodeRepository.delete(item['id'] as int);
    EasyLoading.dismiss();
    if (!mounted) return;
    showMsg(
      msg: success ? 'حذف شد' : 'خطا در حذف',
      context: context,
      type: success ? 'success' : 'error',
    );
    if (success) _load();
  }

  Widget _buildFormFields({
    required BuildContext dialogContext,
    required bool isWide,
    required bool isGold,
    required TextEditingController codeCtrl,
    required TextEditingController valueCtrl,
    required TextEditingController maxUsesCtrl,
    required TextEditingController maxPerUserCtrl,
    required TextEditingController minOrderCtrl,
    required TextEditingController startsCtrl,
    required TextEditingController expiresCtrl,
    required String type,
    required ValueChanged<String?> onTypeChanged,
    required bool isActive,
    required ValueChanged<bool> onActiveChanged,
    required Set<int> selectedCategories,
    required Set<int> selectedGroups,
    required void Function(void Function()) setDialogState,
  }) {
    Future<void> pickStartDate() async {
      final date = await showPersianDatePicker(
        context: dialogContext,
      );
      if (!mounted || date == null) return;

      // Set fixed start time: 00:00
      final dt = DateTime(date.year, date.month, date.day, 0, 0, 0);
      setDialogState(() {
        startsCtrl.text = _formatDateTimeForBackend(dt);
      });
    }

    Future<void> pickExpiresDate() async {
      final date = await showPersianDatePicker(
        context: dialogContext,
      );
      if (!mounted || date == null) return;

      // Set fixed end time: 23:59:59
      final dt = DateTime(date.year, date.month, date.day, 23, 59, 59);
      setDialogState(() {
        expiresCtrl.text = _formatDateTimeForBackend(dt);
      });
    }

    final basicFields = <Widget>[
      TextField(
        controller: codeCtrl,
        decoration: const InputDecoration(labelText: 'کد'),
      ),
      DropdownButtonFormField<String>(
        initialValue: type,
        items: [
          const DropdownMenuItem(value: 'percent', child: Text('درصدی')),
          const DropdownMenuItem(
              value: 'fixed_toman', child: Text('مبلغ ثابت (تومان)')),
          if (isGold)
            const DropdownMenuItem(
                value: 'fixed_dollar', child: Text('مبلغ ثابت (دلار)')),
        ],
        onChanged: onTypeChanged,
        decoration: const InputDecoration(labelText: 'نوع'),
      ),
      TextField(
        controller: valueCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'مقدار'),
      ),
      TextField(
        controller: maxUsesCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'حداکثر استفاده کل (خالی = نامحدود)',
        ),
      ),
      TextField(
        controller: maxPerUserCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'حداکثر استفاده هر کاربر'),
      ),
      TextField(
        controller: minOrderCtrl,
        keyboardType: TextInputType.number,
        decoration:
            const InputDecoration(labelText: 'حداقل مبلغ سفارش (تومان)'),
      ),
      TextField(
        controller: startsCtrl,
        readOnly: true,
        enableInteractiveSelection: false,
        onTap: pickStartDate,
        decoration: const InputDecoration(
          labelText: 'شروع (شمسی، ساعت 00:00)',
        ),
      ),
      TextField(
        controller: expiresCtrl,
        readOnly: true,
        enableInteractiveSelection: false,
        onTap: pickExpiresDate,
        decoration: const InputDecoration(
          labelText: 'انقضا (شمسی، ساعت 23:59:59)',
        ),
      ),
    ];

    Widget basicSection;
    if (isWide) {
      basicSection = GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.2,
        children: basicFields,
      );
    } else {
      basicSection = Column(
        children: basicFields
            .map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: w,
                ))
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        basicSection,
        if (isGold) ...[
          const SizedBox(height: 8),
          const Text('محدودیت بسته (خالی = همه)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _categories.where((c) => c.isActive).map((c) {
              final selected = selectedCategories.contains(c.id);
              return FilterChip(
                label:
                    Text(c.categoryName, style: const TextStyle(fontSize: 12)),
                selected: selected,
                onSelected: (v) => setDialogState(() {
                  if (v) {
                    selectedCategories.add(c.id);
                  } else {
                    selectedCategories.remove(c.id);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text('محدودیت گروه کاربری (خالی = همه)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FilterChip(
                label: const Text('بدون گروه', style: TextStyle(fontSize: 12)),
                selected: selectedGroups.contains(0),
                onSelected: (v) => setDialogState(() {
                  if (v) {
                    selectedGroups.add(0);
                  } else {
                    selectedGroups.remove(0);
                  }
                }),
              ),
              ..._userGroups.where((g) => !g.isDefault).map((g) {
                final selected = selectedGroups.contains(g.id);
                return FilterChip(
                  label: Text(g.name, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (v) => setDialogState(() {
                    if (v) {
                      selectedGroups.add(g.id);
                    } else {
                      selectedGroups.remove(g.id);
                    }
                  }),
                );
              }),
            ],
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'محدودیت بسته/گروه و نوع دلاری در لایسنس طلایی فعال می‌شود.',
            style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 12),
          ),
        ],
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('فعال'),
          value: isActive,
          onChanged: onActiveChanged,
        ),
      ],
    );
  }

  Future<void> _showForm({Map<String, dynamic>? item}) async {
    if (!_isSilverOrAbove) return;
    if (item == null &&
        !_isGold &&
        _items.length >= LicenseHelper.silverPromoMax) {
      showMsg(
        msg:
            'در لایسنس نقره‌ای حداکثر ${LicenseHelper.silverPromoMax} کد تخفیف مجاز است.',
        context: context,
        type: 'error',
      );
      return;
    }

    final codeCtrl =
        TextEditingController(text: item?['code']?.toString() ?? '');
    final valueCtrl =
        TextEditingController(text: item?['value']?.toString() ?? '10');
    final maxUsesCtrl =
        TextEditingController(text: item?['max_uses']?.toString() ?? '');
    final maxPerUserCtrl = TextEditingController(
        text: item?['max_uses_per_user']?.toString() ?? '1');
    final minOrderCtrl = TextEditingController(
        text: item?['min_order_amount']?.toString() ?? '');
    final startsCtrl =
        TextEditingController(text: item?['starts_at']?.toString() ?? '');
    final expiresCtrl =
        TextEditingController(text: item?['expires_at']?.toString() ?? '');
    String type = item?['type']?.toString() ?? 'percent';
    bool isActive = item?['is_active'] == true || item == null;
    final selectedCategories =
        _parseIdList(item?['allowed_category_ids']).toSet();
    final selectedGroups =
        _parseIdList(item?['allowed_user_group_ids']).toSet();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isWide = !Responsive.isMobile(ctx);
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(item == null ? 'کد تخفیف جدید' : 'ویرایش کد تخفیف'),
            content: SizedBox(
              width: isWide ? 720 : null,
              child: SingleChildScrollView(
                child: _buildFormFields(
                  dialogContext: ctx,
                  isWide: isWide,
                  isGold: _isGold,
                  codeCtrl: codeCtrl,
                  valueCtrl: valueCtrl,
                  maxUsesCtrl: maxUsesCtrl,
                  maxPerUserCtrl: maxPerUserCtrl,
                  minOrderCtrl: minOrderCtrl,
                  startsCtrl: startsCtrl,
                  expiresCtrl: expiresCtrl,
                  type: type,
                  onTypeChanged: (v) =>
                      setDialogState(() => type = v ?? 'percent'),
                  isActive: isActive,
                  onActiveChanged: (v) => setDialogState(() => isActive = v),
                  selectedCategories: selectedCategories,
                  selectedGroups: selectedGroups,
                  setDialogState: setDialogState,
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('انصراف')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('ذخیره')),
            ],
          ),
        );
      },
    );

    if (ok != true || !mounted) return;

    final parsedValue = parseLocalizedNumber(valueCtrl.text) ?? 0;
    if (type == 'percent' && (parsedValue < 0 || parsedValue > 100)) {
      showMsg(
        msg: 'درصد تخفیف باید بین ۰ تا ۱۰۰ باشد',
        context: context,
        type: 'error',
      );
      return;
    }

    EasyLoading.show();
    final payload = <String, dynamic>{
      'code': codeCtrl.text.trim().toUpperCase(),
      'type': type,
      'value': parsedValue,
      'is_active': isActive,
      'max_uses_per_user': int.tryParse(maxPerUserCtrl.text) ?? 1,
    };
    if (_isGold) {
      if (selectedCategories.isNotEmpty) {
        payload['allowed_category_ids'] = selectedCategories.toList();
      }
      if (selectedGroups.isNotEmpty) {
        payload['allowed_user_group_ids'] = selectedGroups.toList();
      }
    }
    if (maxUsesCtrl.text.trim().isNotEmpty) {
      payload['max_uses'] = int.tryParse(maxUsesCtrl.text);
    }
    if (minOrderCtrl.text.trim().isNotEmpty) {
      payload['min_order_amount'] = double.tryParse(minOrderCtrl.text);
    }
    if (startsCtrl.text.trim().isNotEmpty) {
      payload['starts_at'] = startsCtrl.text.trim();
    }
    if (expiresCtrl.text.trim().isNotEmpty) {
      payload['expires_at'] = expiresCtrl.text.trim();
    }

    final success = item == null
        ? await PromoCodeRepository.create(payload)
        : await PromoCodeRepository.update(item['id'] as int, payload);
    EasyLoading.dismiss();
    if (!mounted) return;
    showMsg(
      msg: success ? 'ذخیره شد' : 'خطا در ذخیره',
      context: context,
      type: success ? 'success' : 'error',
    );
    if (success) _load();
  }

  Widget _promoCard(Map<String, dynamic> item) {
    final catCount = _parseIdList(item['allowed_category_ids']).length;
    final grpCount = _parseIdList(item['allowed_user_group_ids']).length;
    final active = item['is_active'] == true;

    return Container(
      decoration: _cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _showForm(item: item),
          onLongPress: () => _deleteItem(item),
          child: Padding(
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['code']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      active ? Icons.check_circle : Icons.cancel,
                      color: active ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${item['type']} — ${item['value']}',
                  style: TextStyle(color: AppStyle.deactiveStatus),
                ),
                const SizedBox(height: 4),
                Text(
                  'استفاده: ${item['used_count'] ?? 0}'
                  '${item['max_uses'] != null ? ' / ${item['max_uses']}' : ''}',
                  style:
                      TextStyle(color: AppStyle.deactiveStatus, fontSize: 13),
                ),
                if (catCount > 0 || grpCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${catCount > 0 ? '$catCount بسته' : ''}'
                    '${catCount > 0 && grpCount > 0 ? ' · ' : ''}'
                    '${grpCount > 0 ? '$grpCount گروه' : ''}',
                    style:
                        TextStyle(color: AppStyle.primaryColor, fontSize: 12),
                  ),
                ],
                const Spacer(),
                if (_isGold)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _showUsages(
                        item['id'] as int,
                        item['code']?.toString() ?? '',
                      ),
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('تاریخچه'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _operationCard(BuildContext context) {
    final activeCount = _items.where((e) => e['is_active'] == true).length;
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(context, 'عملیات'),
          const Divider(height: 24),
          Text('کل کدها: ${_items.length}',
              style: TextStyle(color: AppStyle.deactiveStatus)),
          Text('فعال: $activeCount',
              style: TextStyle(color: AppStyle.deactiveStatus)),
          if (!_isGold)
            Text(
              'حداکثر ${LicenseHelper.silverPromoMax} کد در نقره‌ای',
              style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 12),
            ),
          SizedBox(height: AppStyle.defaultPadding),
          ElevatedButton.icon(
            onPressed: () => _showForm(),
            icon: const Icon(Icons.add),
            label: const Text('کد تخفیف جدید'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyle.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listSection(BuildContext context) {
    if (_items.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppStyle.defaultPadding * 2),
        decoration: _cardDecoration,
        child: Center(
          child: Column(
            children: [
              Icon(Icons.local_offer_outlined,
                  size: 48, color: AppStyle.deactiveStatus),
              const SizedBox(height: 12),
              const Text('هنوز کد تخفیفی ثبت نشده است.'),
              const SizedBox(height: 16),
              if (Responsive.isMobile(context))
                ElevatedButton(
                  onPressed: () => _showForm(),
                  child: const Text('ایجاد اولین کد'),
                ),
            ],
          ),
        ),
      );
    }

    final cards = _items.map((item) => _promoCard(item)).toList();
    final crossCount = Responsive.isDesktop(context)
        ? 3
        : Responsive.isTablet(context)
            ? 2
            : 1;

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            context,
            'لیست کدهای تخفیف',
            trailing: Text('${_items.length} مورد',
                style: TextStyle(color: AppStyle.deactiveStatus)),
          ),
          const Divider(height: 24),
          widgetsGridview(
            context: context,
            crossAxisCount: crossCount,
            childAspectRatio: Responsive.isMobile(context) ? 2.4 : 1.35,
            importedList: cards,
          ),
        ],
      ),
    );
  }

  Widget _silverBanner() {
    if (_isGold) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppStyle.defaultPadding,
        AppStyle.defaultPadding,
        AppStyle.defaultPadding,
        0,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Text(
        'نسخه نقره‌ای: حداکثر ${LicenseHelper.silverPromoMax} کد ساده. '
        'برای محدودیت بسته/گروه، تاریخچه و نوع دلاری به طلایی ارتقا دهید.',
        style: TextStyle(
            color: AppStyle.deactiveStatus, height: 1.5, fontSize: 13),
      ),
    );
  }

  Widget _lockedView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppStyle.defaultPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AppStyle.deactiveStatus),
            const SizedBox(height: 16),
            const Text('کدهای تخفیف',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'این بخش از لایسنس نقره‌ای به بالا فعال است.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppStyle.deactiveStatus),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (Responsive.isMobile(context)) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          _silverBanner(),
          Padding(
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _listSection(context),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      child: Column(
        children: [
          _silverBanner(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _listSection(context)),
              SizedBox(width: AppStyle.defaultPadding),
              Expanded(flex: 2, child: _operationCard(context)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(context: context, title: 'کدهای تخفیف'),
          floatingActionButton: Responsive.isMobile(context) && _isSilverOrAbove
              ? FloatingActionButton(
                  onPressed: () => _showForm(),
                  child: const Icon(Icons.add),
                )
              : null,
          body: !_licenseChecked
              ? const Center(child: CircularProgressIndicator())
              : !_isSilverOrAbove
                  ? _lockedView()
                  : _body(context),
        ),
      ),
    );
  }
}

class PromoUsagesDialog extends StatefulWidget {
  const PromoUsagesDialog({
    super.key,
    required this.promoId,
    required this.code,
  });

  final int promoId;
  final String code;

  @override
  State<PromoUsagesDialog> createState() => _PromoUsagesDialogState();
}

class _PromoUsagesDialogState extends State<PromoUsagesDialog> {
  static const int _perPage = 15;

  List<dynamic> _usages = [];
  int _page = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

  Future<void> _loadPage(int page) async {
    setState(() => _loading = true);
    try {
      final result = await PromoCodeRepository.getUsages(
        widget.promoId,
        page: page,
        perPage: _perPage,
      );
      if (!mounted) return;
      setState(() {
        _usages = List<dynamic>.from(result['data'] ?? const []);
        _page = result['current_page'] as int? ?? 1;
        _lastPage = result['last_page'] as int? ?? 1;
        _total = result['total'] as int? ?? 0;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _formatJalaliDateTime(dynamic raw) {
    if (raw == null) return '—';
    final text = raw.toString().trim();
    if (text.isEmpty || text == 'null') return '—';

    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;

    final local = parsed.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.toPersianDate()} $hour:$minute';
  }

  String _formatDiscount(dynamic raw) {
    final amount = parseLocalizedNumber(raw?.toString() ?? '0') ?? 0;
    final formatted = thousandSeperatorFormatter(amount.toStringAsFixed(0));
    return '$formatted تومان';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final maxWidth = size.width > 600 ? 520.0 : size.width - 32;
    final maxHeight = (size.height * 0.65).clamp(280.0, 520.0);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text('استفاده‌های ${widget.code}'),
      content: SizedBox(
        width: maxWidth,
        height: maxHeight,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _total == 0
                    ? 'هنوز استفاده‌ای ثبت نشده.'
                    : 'مجموع $_total مورد',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _usages.isEmpty
                      ? const Center(child: Text('موردی در این صفحه نیست.'))
                      : ListView.separated(
                          itemCount: _usages.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final u = _usages[i] as Map? ?? {};
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'کاربر ${u['account_id'] ?? '—'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${_formatJalaliDateTime(u['applied_at'])}\n'
                                'تخفیف: ${_formatDiscount(u['discount_amount'])}',
                              ),
                              isThreeLine: true,
                            );
                          },
                        ),
            ),
            if (_lastPage > 1) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    tooltip: 'صفحه قبل',
                    onPressed: !_loading && _page > 1
                        ? () => _loadPage(_page - 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                  Expanded(
                    child: Text(
                      'صفحه $_page از $_lastPage',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    tooltip: 'صفحه بعد',
                    onPressed: !_loading && _page < _lastPage
                        ? () => _loadPage(_page + 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بستن'),
        ),
      ],
    );
  }
}
