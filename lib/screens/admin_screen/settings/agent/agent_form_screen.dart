import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/agent_limit_usage_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/provider/agent/agent_provider.dart';
import 'package:powerps/repositories/agent_manage_repository.dart';
import 'package:powerps/repositories/agent_permission_repository.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/repositories/panel_user_repository.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/agent/agent_screen_shared.dart';
import 'package:powerps/widgets/agent/agent_select_category_with_inputs_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/bot_user_admin_alias_widget.dart';
import 'package:powerps/widgets/public/user_group_selector_widget.dart';
import 'package:searchable_listview/searchable_listview.dart';

enum AgentFormMode { create, edit }

class AgentFormScreen extends StatefulWidget {
  const AgentFormScreen({
    super.key,
    required this.mode,
    this.agent,
    this.copyFromAgent,
  });

  final AgentFormMode mode;
  final User? agent;
  final User? copyFromAgent;

  bool get isCreate => mode == AgentFormMode.create;

  @override
  State<AgentFormScreen> createState() => _AgentFormScreenState();
}

class _AgentFormScreenState extends State<AgentFormScreen> {
  bool _showData = false;
  bool _loadError = false;
  final List<User> _userList = [];
  User? _selectedUser;
  User? _copySourceAgent;
  User? _agentProfile;
  AgentLimitUsage? _agentLimitUsage;
  List<Pannel> _panels = [];
  int? _selectedPanelId;
  bool _minusBallance = false;
  bool _deleteProducts = false;
  final TextEditingController _maxTrafficLimitationTxtController =
      TextEditingController();
  final TextEditingController _maxProdouctLimitationTxtController =
      TextEditingController();
  final TextEditingController _minusBallanceLimitTxtController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isCreate) {
      _maxTrafficLimitationTxtController.text = "10";
      _maxProdouctLimitationTxtController.text = "1000";
      _copySourceAgent = widget.copyFromAgent;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fillData();
    });
  }

  @override
  void dispose() {
    _maxTrafficLimitationTxtController.dispose();
    _maxProdouctLimitationTxtController.dispose();
    _minusBallanceLimitTxtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
            context: context,
            title:
                widget.isCreate ? "افزودن دستیار فروش" : "ویرایش دستیار فروش",
          ),
          body: !_showData
              ? const Center(child: CircularProgressIndicator())
              : _loadError
                  ? _buildErrorState()
                  : RefreshIndicator(
                      onRefresh: _fillData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: agentScreenPadding(context),
                        child: agentCenteredContent(
                          context,
                          child: _content(context),
                        ),
                      ),
                    ),
          bottomNavigationBar: Responsive.isMobile(context)
              ? _buildBottomNavigationBar(context)
              : null,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text("خطا در بارگذاری اطلاعات"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fillData,
            child: const Text("تلاش مجدد"),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () => _submitData(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyle.secondaryColor,
          shape: const RoundedRectangleBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.isCreate ? Icons.add : Icons.done, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              widget.isCreate ? "افزودن" : "ذخیره",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);
    final gap = SizedBox(height: AppStyle.defaultPadding);

    final mainColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _agentInfoCard(context),
        gap,
        if (widget.isCreate) ...[
          _copyFromAgentCard(context),
          gap,
        ],
        if (_selectedUser != null || !widget.isCreate) ...[
          UserGroupSelectorWidget(
            userId: widget.isCreate ? _selectedUser!.id : widget.agent!.id,
            roleType: 'agent',
            currentGroupId: widget.isCreate
                ? _selectedUser?.userGroupId
                : widget.agent?.userGroupId,
          ),
          gap,
        ],
        if (!widget.isCreate && _agentProfile != null) ...[
          AdminAliasEditorWidget(
            botUserId: _agentProfile!.botUserId,
            accountId: _agentProfile!.botUserId == null
                ? _agentProfile!.accountId
                : null,
            adminAlias: _agentProfile!.adminAlias,
            onChanged: _fillData,
          ),
          gap,
        ],
        if (_panels.isNotEmpty) ...[
          _panelFilterCard(context),
          gap,
        ],
        if (isDesktop)
          _productsSectionDesktop(context)
        else ...[
          _productInfoCard(context),
          gap,
          _productAddedCard(context),
        ],
        if (isMobile) ...[
          gap,
          _operationCard(context),
        ],
      ],
    );

    if (isMobile) return mainColumn;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: mainColumn),
        SizedBox(width: AppStyle.defaultPadding),
        SizedBox(width: 260, child: _operationCard(context)),
      ],
    );
  }

  Widget _productsSectionDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _productInfoCard(context)),
        const SizedBox(width: 16),
        Expanded(child: _productAddedCard(context)),
      ],
    );
  }

  Widget _agentInfoCard(BuildContext context) {
    final userListHeight = Responsive.isMobile(context) ? 240.0 : 320.0;

    return AgentSectionCard(
      title: 'ورود اطلاعات دستیار فروش',
      children: [
        if (widget.isCreate) ...[
          Text(
            'کاربر را انتخاب کنید',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding / 2),
          SizedBox(
            height: userListHeight,
            child: SearchableList<User>(
              initialList: _userList,
              shrinkWrap: false,
              itemBuilder: (user) => ListTile(
                selected: _selectedUser?.id == user.id,
                selectedTileColor:
                    AppStyle.primaryColor.withValues(alpha: 0.15),
                leading: const Icon(Icons.person),
                title: Text(user.name, textAlign: TextAlign.right),
                subtitle: Text(
                  'شناسه: ${user.accountId}${user.adminAlias != null && user.adminAlias!.isNotEmpty ? ' | مستعار: ${user.adminAlias}' : ''}',
                  textAlign: TextAlign.right,
                ),
                onTap: () => setState(() => _selectedUser = user),
              ),
              filter: (q) => _userList
                  .where((u) =>
                      u.name.contains(q) ||
                      u.accountId.toString().contains(q) ||
                      (u.adminAlias?.contains(q) ?? false))
                  .toList(),
              emptyWidget: const Center(child: Text('کاربری یافت نشد')),
              inputDecoration: agentRtlInputDecoration(
                label: 'جستجوی کاربر',
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ] else
          Text(
            'در حال ویرایش مشخصات ${widget.agent!.name} (شناسه: ${widget.agent!.accountId})',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        SizedBox(height: AppStyle.defaultPadding),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('موجودی حساب منفی', textAlign: TextAlign.right),
          subtitle: const Text(
            'آیا دستیار فروش می‌تواند موجودی منفی داشته باشد؟',
            textAlign: TextAlign.right,
          ),
          value: _minusBallance,
          onChanged: (val) => setState(() => _minusBallance = val),
        ),
        if (_minusBallance) ...[
          SizedBox(height: AppStyle.defaultPadding / 2),
          CustomTextFromFieldWidget(
            controller: _minusBallanceLimitTxtController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            textHint: 'سقف بدهی (تومان) — خالی = بدون محدودیت',
            validationError: 'سقف بدهی باید عددی بزرگتر از صفر باشد',
          ),
          if (!widget.isCreate && _agentLimitUsage != null)
            _debtUsageSummary(context),
        ],
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title:
              const Text('حذف اکانت‌های کم‌مصرف', textAlign: TextAlign.right),
          subtitle: const Text(
            'حذف اکانت‌های با مصرف کمتر از 0.5GB',
            textAlign: TextAlign.right,
          ),
          value: _deleteProducts,
          onChanged: (val) => setState(() => _deleteProducts = val),
        ),
        SizedBox(height: AppStyle.defaultPadding / 2),
        if (Responsive.isMobile(context))
          Column(
            children: [
              CustomTextFromFieldWidget(
                controller: _maxProdouctLimitationTxtController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                textHint: 'محدودیت تعداد فروش کانفیگ',
                validationError: 'تعداد کانفیگ قابل فروش را وارد کنید',
              ),
              SizedBox(height: AppStyle.defaultPadding / 2),
              CustomTextFromFieldWidget(
                controller: _maxTrafficLimitationTxtController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textHint: 'محدودیت ترافیک (ترابایت)',
                validationError: 'ترافیک قابل فروش به ترابایت را وارد کنید',
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: CustomTextFromFieldWidget(
                  controller: _maxProdouctLimitationTxtController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  textHint: 'محدودیت تعداد فروش کانفیگ',
                  validationError: 'تعداد کانفیگ قابل فروش را وارد کنید',
                ),
              ),
              SizedBox(width: AppStyle.defaultPadding),
              Expanded(
                child: CustomTextFromFieldWidget(
                  controller: _maxTrafficLimitationTxtController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textHint: 'محدودیت ترافیک (ترابایت)',
                  validationError: 'ترافیک قابل فروش به ترابایت را وارد کنید',
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _debtUsageSummary(BuildContext context) {
    final usage = _agentLimitUsage!;
    final limit = usage.minusBallanceLimit;
    final debt = usage.currentDebt;
    final hasLimit = limit != null && limit > 0;

    return Padding(
      padding: EdgeInsets.only(top: AppStyle.defaultPadding / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasLimit)
            Text(
              'بدهی فعلی: ${thousandSeperatorFormatter(debt.toStringAsFixed(0))} از ${thousandSeperatorFormatter(limit.toStringAsFixed(0))} تومان (${usage.debtUsagePercent.toStringAsFixed(1)}%)',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: usage.debtUsagePercent >= 100
                        ? Colors.redAccent
                        : usage.debtUsagePercent >= 80
                            ? Colors.orangeAccent
                            : Colors.greenAccent,
                  ),
            )
          else
            Text(
              debt > 0
                  ? 'بدهی فعلی: ${thousandSeperatorFormatter(debt.toStringAsFixed(0))} تومان (بدون سقف)'
                  : 'بدهی فعلی: بدون بدهی',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (usage.currentBalance != null) ...[
            const SizedBox(height: 4),
            Text(
              'موجودی فعلی: ${thousandSeperatorFormatter(usage.currentBalance!.toStringAsFixed(0))} تومان',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _copyFromAgentCard(BuildContext context) {
    return AgentSectionCard(
      title: 'کپی تنظیمات از دستیار دیگر',
      subtitle:
          'با انتخاب یک دستیار، مجوزها و بسته‌های او به فرم اعمال می‌شود.',
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showCopyFromAgentDialog,
            icon: const Icon(Icons.copy),
            label: Text(
              _copySourceAgent != null
                  ? 'کپی از: ${_copySourceAgent!.name}'
                  : 'انتخاب دستیار برای کپی',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCopyFromAgentDialog() async {
    final agents = await getAgents();
    if (!mounted) return;
    if (agents == null || agents.isEmpty) {
      showMsg(msg: "دستیار فروشی برای کپی یافت نشد", context: context);
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('کپی تنظیمات', textAlign: TextAlign.right),
          content: SizedBox(
            width: Responsive.isMobile(context) ? double.maxFinite : 480,
            height: Responsive.isMobile(context) ? 360 : 420,
            child: ListView.separated(
              primary: false,
              itemCount: agents.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final agent = agents[i];
                return ListTile(
                  title: Text(agent.name, textAlign: TextAlign.right),
                  subtitle: Text(
                    'شناسه: ${agent.accountId}',
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _applyCopyFromAgent(agent);
                  },
                );
              },
            ),
          ),
          actionsAlignment: MainAxisAlignment.start,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('لغو'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyCopyFromAgent(User agent) async {
    EasyLoading.show();
    final detail = await getAgentDetailById(id: agent.id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (detail == null) {
      showMsg(
          msg: "خطا در دریافت تنظیمات دستیار", context: context, type: "error");
      return;
    }

    final provider = Provider.of<AgentProvider>(context, listen: false);
    final allCategories = await getAllProdctCategory();
    final available = <AgentAddCategoriyModel>[];
    if (allCategories != null) {
      final selectedIds =
          detail.products.map((p) => p.productCategories?.id).toSet();
      for (final cat in allCategories) {
        if (!selectedIds.contains(cat.id)) {
          available.add(AgentAddCategoriyModel(
            id: cat.id,
            productCategoriesId: cat.id,
            productCategories: cat,
            price: cat.price,
            newPrice: null,
            priceInDollar: cat.priceInDollar,
            newPriceInDollar: null,
          ));
        }
      }
    }
    provider.setFormCategoriesFromDynamic(
      available: available,
      added: detail.products,
    );

    if (detail.permission != null) {
      setState(() {
        _copySourceAgent = agent;
        _minusBallance = detail.permission!.minusBallance;
        _deleteProducts = detail.permission!.deleteProducts;
        _minusBallanceLimitTxtController.text =
            detail.permission!.minusBallanceLimit?.toStringAsFixed(0) ?? '';
        _maxProdouctLimitationTxtController.text =
            detail.permission!.productLimitation.toString();
        _maxTrafficLimitationTxtController.text =
            detail.permission!.trafficLimitationTB.toString();
      });
    }
    if (mounted) {
      showMsg(msg: "تنظیمات ${agent.name} اعمال شد", context: context);
    }
  }

  int? _itemPanelId(AgentAddCategoriyModel item) {
    final pc = item.productCategories;
    if (pc == null) return null;
    if (pc.pannelId != 0) return pc.pannelId;
    return int.tryParse(pc.pannel?.id ?? '');
  }

  bool _matchesPanelFilter(AgentAddCategoriyModel item) {
    if (_selectedPanelId == null) return true;
    return _itemPanelId(item) == _selectedPanelId;
  }

  String _panelLabel(Pannel panel) {
    final location = panel.location != null && panel.location!.isNotEmpty
        ? ' - ${panel.location}'
        : '';
    return '${getPannelName(name: panel.type)}$location';
  }

  String? _selectedPanelLabel() {
    if (_selectedPanelId == null) return null;
    for (final panel in _panels) {
      if (int.tryParse(panel.id) == _selectedPanelId) {
        return _panelLabel(panel);
      }
    }
    return 'پنل $_selectedPanelId';
  }

  Widget _panelFilterCard(BuildContext context) {
    return AgentSectionCard(
      title: 'فیلتر بر اساس پنل',
      subtitle:
          'پنل مورد نظر را انتخاب کنید تا فقط بسته‌های همان پنل نمایش داده شوند.',
      children: [
        DropdownButtonFormField<int?>(
          initialValue: _selectedPanelId,
          isExpanded: true,
          decoration: agentRtlInputDecoration(label: 'پنل'),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('همه پنل‌ها'),
            ),
            ..._panels.map(
              (p) => DropdownMenuItem<int?>(
                value: int.tryParse(p.id),
                child: Text('${p.id}: ${_panelLabel(p)}'),
              ),
            ),
          ],
          onChanged: (val) => setState(() => _selectedPanelId = val),
        ),
      ],
    );
  }

  Widget _productInfoCard(BuildContext context) {
    final agentCategories = context.watch<AgentProvider>().agentCategories;
    final filtered = agentCategories.where(_matchesPanelFilter).toList();
    final selectedLabel = _selectedPanelLabel();
    final panelSuffix = selectedLabel != null ? ' ($selectedLabel)' : '';

    return AgentSectionCard(
      title:
          'بسته‌های قابل انتخاب$panelSuffix (${filtered.length}/${agentCategories.length})',
      trailing: filtered.isNotEmpty
          ? TextButton.icon(
              onPressed: _selectAllWithDefaultPrice,
              icon: const Icon(Icons.select_all, size: 18),
              label: Text(
                _selectedPanelId == null ? 'انتخاب همه' : 'انتخاب همه این پنل',
              ),
            )
          : null,
      children: [
        if (filtered.isEmpty)
          Text(
            _selectedPanelId == null
                ? 'تمام بسته‌ها انتخاب شده‌اند.'
                : 'بسته‌ای برای این پنل در لیست قابل انتخاب نیست.',
            textAlign: TextAlign.right,
          )
        else
          agentScrollableList(
            context: context,
            itemCount: filtered.length,
            itemBuilder: (_, index) => AgentSelectCategoryWithPriceInputWidget(
              type: 'add',
              item: filtered[index],
            ),
          ),
      ],
    );
  }

  void _selectAllWithDefaultPrice() {
    final provider = Provider.of<AgentProvider>(context, listen: false);
    final filtered =
        provider.agentCategories.where(_matchesPanelFilter).toList();
    provider.selectCategoriesWithDefaultPrice(filtered);
  }

  Widget _productAddedCard(BuildContext context) {
    final added = context.watch<AgentProvider>().agentCategoriesAdded;
    final filtered = added.where(_matchesPanelFilter).toList();
    final selectedLabel = _selectedPanelLabel();
    final panelSuffix = selectedLabel != null ? ' ($selectedLabel)' : '';

    return AgentSectionCard(
      title:
          'بسته‌های انتخاب شده$panelSuffix (${filtered.length}/${added.length})',
      children: [
        if (filtered.isEmpty)
          Text(
            _selectedPanelId == null
                ? 'هیچ بسته‌ای انتخاب نشده است.'
                : 'بسته‌ای از این پنل انتخاب نشده است.',
            textAlign: TextAlign.right,
          )
        else
          agentScrollableList(
            context: context,
            itemCount: filtered.length,
            itemBuilder: (_, index) => AgentSelectCategoryWithPriceInputWidget(
              type: 'remove',
              item: filtered[index],
            ),
          ),
      ],
    );
  }

  Widget _operationCard(BuildContext context) {
    return AgentSectionCard(
      title: 'عملیات',
      subtitle: widget.isCreate
          ? 'پس از تکمیل فرم، دستیار جدید ایجاد می‌شود'
          : 'تغییرات روی دستیار فعلی ذخیره می‌شود',
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _submitData(context),
            icon: Icon(widget.isCreate ? Icons.add : Icons.done),
            label: Text(
              widget.isCreate ? 'افزودن دستیار' : 'ذخیره تغییرات',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _fillData() async {
    if (!mounted) return;
    setState(() {
      _showData = false;
      _loadError = false;
    });

    final provider = Provider.of<AgentProvider>(context, listen: false);
    final panelsResult = await getPannels();

    try {
      if (widget.isCreate) {
        final categories = await getAllProdctCategory();
        final users = await getNormalUsers();
        if (!mounted) return;

        if (panelsResult is List<Pannel>) {
          _panels = panelsResult;
        }

        final List<AgentAddCategoriyModel> list =
            categories is List<ProductCategory>
                ? categories
                    .map(
                      (i) => AgentAddCategoriyModel(
                        id: i.id,
                        productCategoriesId: i.id,
                        productCategories: i,
                        price: i.price,
                        newPrice: null,
                        priceInDollar: i.priceInDollar,
                        newPriceInDollar: null,
                      ),
                    )
                    .toList()
                : <AgentAddCategoriyModel>[];
        provider.setFormCategories(available: list, added: const []);

        if (users != null && users.isNotEmpty) {
          setState(() {
            _userList
              ..clear()
              ..addAll(users);
            _selectedUser ??= users.first;
          });
        }

        if (widget.copyFromAgent != null && _copySourceAgent == null) {
          await _applyCopyFromAgent(widget.copyFromAgent!);
        }
      } else {
        final agent = widget.agent!;
        final detail = await getAgentDetailById(id: agent.id);
        final notSelected =
            await getAgentProductsWithNotSelectedByUserID(userID: agent.id);
        final selected = await getAgentProductsByUserID(userID: agent.id);
        final permission = await getUserPremissionByAgentID(userID: agent.id);

        if (!mounted) return;

        if (panelsResult is List<Pannel>) {
          _panels = panelsResult;
        }

        if (permission == false) {
          showMsg(
            type: "error",
            msg: "شما مجوز دسترسی به این صفحه را ندارید",
            context: context,
          );
          Navigator.pop(context);
          return;
        }

        final List<AgentAddCategoriyModel> available =
            notSelected is List<ProductCategory>
                ? notSelected
                    .map(
                      (i) => AgentAddCategoriyModel(
                        id: i.id,
                        productCategoriesId: i.id,
                        price: i.price,
                        productCategories: i,
                        newPrice: null,
                        priceInDollar: i.priceInDollar,
                        newPriceInDollar: null,
                      ),
                    )
                    .toList()
                : <AgentAddCategoriyModel>[];
        final List<AgentAddCategoriyModel> added =
            selected is List<AgentAddCategoriyModel>
                ? List<AgentAddCategoriyModel>.from(selected)
                : <AgentAddCategoriyModel>[];
        provider.setFormCategories(available: available, added: added);

        if (permission is AgentPermisson) {
          _minusBallance = permission.minusBallance;
          _deleteProducts = permission.deleteProducts;
          _minusBallanceLimitTxtController.text =
              permission.minusBallanceLimit?.toStringAsFixed(0) ?? '';
          _maxProdouctLimitationTxtController.text =
              permission.productLimitation.toString();
          _maxTrafficLimitationTxtController.text =
              permission.trafficLimitationTB.toString();
        }

        _agentProfile = detail?.user ?? agent;
        _agentLimitUsage = detail?.user.agentLimitUsage;
      }
    } catch (e) {
      debugPrint("Error loading agent form: $e");
      if (mounted) setState(() => _loadError = true);
      return;
    }

    if (mounted) {
      setState(() => _showData = true);
    }
  }

  Future<void> _submitData(BuildContext context) async {
    if (widget.isCreate && _selectedUser == null) {
      showMsg(
          msg: "لطفا یک کاربر را انتخاب کنید", context: context, type: "error");
      return;
    }

    final productLimit = int.tryParse(_maxProdouctLimitationTxtController.text);
    final trafficLimit =
        double.tryParse(_maxTrafficLimitationTxtController.text);

    if (productLimit == null || productLimit <= 0) {
      showMsg(
        msg: "محدودیت تعداد کانفیگ باید عددی بزرگتر از صفر باشد",
        context: context,
        type: "error",
      );
      return;
    }
    if (trafficLimit == null || trafficLimit <= 0) {
      showMsg(
        msg: "محدودیت ترافیک باید عددی بزرگتر از صفر باشد",
        context: context,
        type: "error",
      );
      return;
    }

    double? minusBallanceLimit;
    final limitText = _minusBallanceLimitTxtController.text.trim();
    if (_minusBallance && limitText.isNotEmpty) {
      minusBallanceLimit = double.tryParse(limitText.replaceAll(',', ''));
      if (minusBallanceLimit == null || minusBallanceLimit <= 0) {
        showMsg(
          msg: "سقف بدهی باید عددی بزرگتر از صفر باشد",
          context: context,
          type: "error",
        );
        return;
      }
    }

    final selectedProducts = Provider.of<AgentProvider>(context, listen: false)
        .getAgentCategoriesAdded();
    if (selectedProducts.isEmpty) {
      showMsg(
        msg: "حداقل یک بسته باید انتخاب شود",
        context: context,
        type: "error",
      );
      return;
    }

    final userId =
        widget.isCreate ? _selectedUser!.accountId : widget.agent!.accountId;

    EasyLoading.show();
    try {
      final result = await createAndEditBatchOfUserAgentProduct(
        agentPermisson: AgentPermisson(
          userId: 0,
          createProducts: false,
          deleteProducts: _deleteProducts,
          minusBallance: _minusBallance,
          minusBallanceLimit: minusBallanceLimit,
          productLimitation: productLimit,
          trafficLimitationTB: trafficLimit,
        ),
        userID: userId,
        gentAddCategoriyList: selectedProducts,
      );

      EasyLoading.dismiss();
      if (!context.mounted) return;

      if (result == true) {
        showMsg(
          msg: widget.isCreate
              ? "دستیار فروش با موفقیت ایجاد شد"
              : "دستیار فروش با موفقیت ویرایش شد",
          context: context,
        );
        Navigator.pop(context, true);
        return;
      }

      showMsg(
        msg: result is String ? result : "خطا در ذخیره دستیار فروش",
        context: context,
        type: "error",
      );
    } catch (e) {
      EasyLoading.dismiss();
      if (!context.mounted) return;
      showMsg(
          msg: "خطا در برقراری ارتباط با سرور",
          context: context,
          type: "error");
    }
  }
}
