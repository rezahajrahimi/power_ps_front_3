import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/provider/agent/agent_provider.dart';
import 'package:powerps/repositories/agent_manage_repository.dart';
import 'package:powerps/repositories/agent_permission_repository.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/repositories/panel_user_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/agent/agent_select_category_with_inputs_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
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
  bool _minusBallance = false;
  bool _deleteProducts = false;
  final TextEditingController _maxTrafficLimitationTxtController =
      TextEditingController();
  final TextEditingController _maxProdouctLimitationTxtController =
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
            title: widget.isCreate ? "افزودن دستیار فروش" : "ویرایش دستیار فروش",
          ),
          body: !_showData
              ? const Center(child: CircularProgressIndicator())
              : _loadError
                  ? _buildErrorState()
                  : RefreshIndicator(
                      onRefresh: _fillData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(AppStyle.defaultPadding),
                        child: _content(context),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _agentInfoCard(context),
              SizedBox(height: AppStyle.defaultPadding),
              if (widget.isCreate) ...[
                _copyFromAgentCard(context),
                SizedBox(height: AppStyle.defaultPadding),
              ],
              if (_selectedUser != null || !widget.isCreate) ...[
                UserGroupSelectorWidget(
                  userId: widget.isCreate ? _selectedUser!.id : widget.agent!.id,
                  roleType: 'agent',
                  currentGroupId:
                      widget.isCreate ? _selectedUser?.userGroupId : widget.agent?.userGroupId,
                ),
                SizedBox(height: AppStyle.defaultPadding),
              ],
              _productInfoCard(context),
              SizedBox(height: AppStyle.defaultPadding),
              _productAddedCard(context),
            ],
          ),
        ),
        if (!Responsive.isMobile(context)) ...[
          SizedBox(width: AppStyle.defaultPadding),
          Expanded(flex: 2, child: _operationCard(context)),
        ],
      ],
    );
  }

  Widget _agentInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ورود اطلاعات دستیار فروش",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (widget.isCreate) ...[
            Text(
              "کاربر را انتخاب کنید",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: AppStyle.defaultPadding / 2),
            SizedBox(
              height: 280,
              child: SearchableList<User>(
                initialList: _userList,
                shrinkWrap: false,
                itemBuilder: (user) => ListTile(
                  selected: _selectedUser?.id == user.id,
                  selectedTileColor:
                      AppStyle.primaryColor.withValues(alpha: 0.15),
                  leading: const Icon(Icons.person),
                  title: Text(user.name),
                  subtitle: Text("شناسه: ${user.accountId}"),
                  onTap: () => setState(() => _selectedUser = user),
                ),
                filter: (q) => _userList
                    .where((u) =>
                        u.name.contains(q) ||
                        u.accountId.toString().contains(q))
                    .toList(),
                emptyWidget: const Center(child: Text("کاربری یافت نشد")),
                inputDecoration: const InputDecoration(
                  labelText: "جستجوی کاربر",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ] else
            Text(
              "در حال ویرایش مشخصات ${widget.agent!.name} (شناسه: ${widget.agent!.accountId})",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          SizedBox(height: AppStyle.defaultPadding),
          SwitchListTile(
            title: const Text("موجودی حساب منفی"),
            subtitle: const Text("آیا دستیار فروش می‌تواند موجودی منفی داشته باشد؟"),
            value: _minusBallance,
            onChanged: (val) => setState(() => _minusBallance = val),
          ),
          SwitchListTile(
            title: const Text("حذف اکانت‌های کم‌مصرف"),
            subtitle: const Text(
                "حذف اکانت‌های با مصرف کمتر از 0.5GB"),
            value: _deleteProducts,
            onChanged: (val) => setState(() => _deleteProducts = val),
          ),
          SizedBox(height: AppStyle.defaultPadding / 2),
          CustomTextFromFieldWidget(
            controller: _maxProdouctLimitationTxtController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: false),
            textHint: "محدودیت تعداد فروش کانفیگ",
            validationError: "تعداد کانفیگ قابل فروش را وارد کنید",
          ),
          SizedBox(height: AppStyle.defaultPadding / 2),
          CustomTextFromFieldWidget(
            controller: _maxTrafficLimitationTxtController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textHint: "محدودیت ترافیک (ترابایت)",
            validationError: "ترافیک قابل فروش به ترابایت را وارد کنید",
          ),
        ],
      ),
    );
  }

  Widget _copyFromAgentCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "کپی تنظیمات از دستیار دیگر",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding / 2),
          const Text(
            "با انتخاب یک دستیار، مجوزها و بسته‌های او به فرم اعمال می‌شود.",
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          ElevatedButton.icon(
            onPressed: _showCopyFromAgentDialog,
            icon: const Icon(Icons.copy),
            label: Text(
              _copySourceAgent != null
                  ? "کپی از: ${_copySourceAgent!.name}"
                  : "انتخاب دستیار برای کپی",
            ),
          ),
        ],
      ),
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
      builder: (ctx) => AlertDialog(
        title: const Text("کپی تنظیمات"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: agents.length,
            itemBuilder: (_, i) {
              final agent = agents[i];
              return ListTile(
                title: Text(agent.name),
                subtitle: Text("شناسه: ${agent.accountId}"),
                onTap: () {
                  Navigator.pop(ctx);
                  _applyCopyFromAgent(agent);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("لغو"),
          ),
        ],
      ),
    );
  }

  Future<void> _applyCopyFromAgent(User agent) async {
    EasyLoading.show();
    final detail = await getAgentDetailById(id: agent.id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (detail == null) {
      showMsg(msg: "خطا در دریافت تنظیمات دستیار", context: context, type: "error");
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
            productCategories: cat,
            price: cat.price,
            newPrice: null,
            priceInDollar: cat.priceInDollar,
            newPriceInDollar: null,
          ));
        }
      }
    }
    provider.setFormCategories(
      available: available,
      added: detail.products,
    );

    if (detail.permission != null) {
      setState(() {
        _copySourceAgent = agent;
        _minusBallance = detail.permission!.minusBallance;
        _deleteProducts = detail.permission!.deleteProducts;
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

  Widget _productInfoCard(BuildContext context) {
    final agentCategories = context.watch<AgentProvider>().agentCategories;
    final widgets = agentCategories
        .map((i) => AgentSelectCategoryWithPriceInputWidget(type: "add", item: i))
        .toList();

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "بسته‌های قابل انتخاب (${agentCategories.length})",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (agentCategories.isNotEmpty)
                TextButton.icon(
                  onPressed: _selectAllWithDefaultPrice,
                  icon: const Icon(Icons.select_all, size: 18),
                  label: const Text("انتخاب همه"),
                ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (widgets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text("تمام بسته‌ها انتخاب شده‌اند."),
            )
          else
            ...widgets,
        ],
      ),
    );
  }

  void _selectAllWithDefaultPrice() {
    Provider.of<AgentProvider>(context, listen: false)
        .selectAllCategoriesWithDefaultPrice();
  }

  Widget _productAddedCard(BuildContext context) {
    final added = context.watch<AgentProvider>().agentCategoriesAdded;
    final widgets = added
        .map((i) =>
            AgentSelectCategoryWithPriceInputWidget(type: "remove", item: i))
        .toList();

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "بسته‌های انتخاب شده (${added.length})",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (widgets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text("هیچ بسته‌ای انتخاب نشده است."),
            )
          else
            ...widgets,
        ],
      ),
    );
  }

  Widget _operationCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("عملیات", style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _submitData(context),
              icon: Icon(widget.isCreate ? Icons.add : Icons.done),
              label: Text(widget.isCreate ? "افزودن دستیار" : "ذخیره تغییرات"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fillData() async {
    if (!mounted) return;
    setState(() {
      _showData = false;
      _loadError = false;
    });

    final provider = Provider.of<AgentProvider>(context, listen: false);

    try {
      if (widget.isCreate) {
        final categories = await getAllProdctCategory();
        final users = await getNormalUsers();
        if (!mounted) return;

        final list = categories != null
            ? categories
                .map((i) => AgentAddCategoriyModel(
                      id: i.id,
                      productCategories: i,
                      price: i.price,
                      newPrice: null,
                      priceInDollar: i.priceInDollar,
                      newPriceInDollar: null,
                    ))
                .toList()
            : <AgentAddCategoriyModel>[];
        provider.setFormCategories(available: list, added: []);

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
        final notSelected =
            await getAgentProductsWithNotSelectedByUserID(userID: agent.id);
        final selected = await getAgentProductsByUserID(userID: agent.id);
        final permission =
            await getUserPremissionByAgentID(userID: agent.id);

        if (!mounted) return;

        if (permission == false) {
          showMsg(
            type: "error",
            msg: "شما مجوز دسترسی به این صفحه را ندارید",
            context: context,
          );
          Navigator.pop(context);
          return;
        }

        final available = notSelected != null && notSelected is List
            ? notSelected
                .map((i) => AgentAddCategoriyModel(
                      id: i.id,
                      price: i.price,
                      productCategories: i,
                      newPrice: null,
                      priceInDollar: i.priceInDollar,
                      newPriceInDollar: null,
                    ))
                .toList()
            : <AgentAddCategoriyModel>[];
        final added = selected != null
            ? List<AgentAddCategoriyModel>.from(selected)
            : <AgentAddCategoriyModel>[];
        provider.setFormCategories(available: available, added: added);

        if (permission is AgentPermisson) {
          _minusBallance = permission.minusBallance;
          _deleteProducts = permission.deleteProducts;
          _maxProdouctLimitationTxtController.text =
              permission.productLimitation.toString();
          _maxTrafficLimitationTxtController.text =
              permission.trafficLimitationTB.toString();
        }
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
      showMsg(msg: "لطفا یک کاربر را انتخاب کنید", context: context, type: "error");
      return;
    }

    final productLimit =
        int.tryParse(_maxProdouctLimitationTxtController.text);
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

    final selectedProducts =
        Provider.of<AgentProvider>(context, listen: false).getAgentCategoriesAdded();
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
      showMsg(msg: "خطا در برقراری ارتباط با سرور", context: context, type: "error");
    }
  }
}
