import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helpers/sanaei_inbound_sync.dart';
import 'package:powerps/helpers/marzban_inbound_sync.dart';
import 'package:powerps/helper/license_helper.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/models/user_group_model.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/repositories/user_group_repository.dart';
import 'package:powerps/screens/admin_screen/product/fast_edit_product_categories_screen.dart';
import 'package:powerps/screens/admin_screen/product/inventory_import_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/product_category/product_category_info_item_card_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class ProductCategoryScreen extends StatefulWidget {
  const ProductCategoryScreen({super.key});

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  bool _showData = false;
  bool _showFilters = false;

  final List<Widget> _productCatWidgetLIst = [];
  List<ProductCategory> _productCategoryList = [];
  final List _selectedPanelIDFiltered = [];
  final List<String> _pannelNameList = [];
  String _selectedPannelName = "";
  List<UserGroup> _userGroups = [];

  // String _selectedCategoryType = "";
  // List<CategoryTypeModel> _fetchedCategoryType = [];
  final _nameEditText = TextEditingController();
  final _priceEditText = TextEditingController();
  final _priceInDollarEditText = TextEditingController();
  final _expireDayEditText = TextEditingController();
  final _volumeEditText = TextEditingController();
  final _inboundIdEditText = TextEditingController();
  final _marzbanInboundsEditText = TextEditingController();
  final _ipLimitEditText = TextEditingController();
  final _sampleInboundEditText = TextEditingController();

  bool _rechargable = true;
  bool _showSubscriptionLink = true;
  bool _showPannelLink = true;
  bool _sendConfigToUser = true;
  final Set<int> _allowedGroupIds = {};
  int? _upsellCategoryId;
  bool _isGoldLicense = false;
  // create a form key
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _loadLicense();
    _fillData();
    super.initState();
  }

  Future<void> _loadLicense() async {
    final license = await getLicenseType();
    if (mounted) {
      setState(() => _isGoldLicense = LicenseHelper.isGold(license));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameEditText.dispose();
    _priceEditText.dispose();
    _priceInDollarEditText.dispose();
    _expireDayEditText.dispose();
    _volumeEditText.dispose();
    _inboundIdEditText.dispose();
    _marzbanInboundsEditText.dispose();
    _ipLimitEditText.dispose();
    _sampleInboundEditText.dispose();
    _selectedPannelName = "";
    _pannelNameList.clear();
    // _categoryTypeListName.clear();
    // _selectedCategoryType = "";
    _productCatWidgetLIst.clear();
    _productCategoryList.clear();
    _showData = false;
    _rechargable = true;
    _showSubscriptionLink = true;
    _showPannelLink = true;
    _sendConfigToUser = true;
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of<ProductCategoryProvider>(context, listen: false);
    // // _fillData();
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SingleChildScrollView(
              primary: false,
              child: Padding(
                padding: EdgeInsets.all(AppStyle.defaultPadding),
                child: Column(
                  children: [
                    _content(context),
                  ],
                ),
              )),
          bottomNavigationBar: Responsive.isMobile(context)
              ? _buildBottomNavigationBar(context)
              : const Opacity(opacity: 1),
        ),
      ),
    );
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<void> _fillData() async {
    if (!mounted) return;

    setStateIfMounted(() {
      _showData = false;
      _showFilters = false;
    });

    try {
      final res = await getAllProdctCategory();
      if (res != null && res != false) {
        _productCategoryList = res;
        _productCatWidgetLIst.clear();
        _selectedPanelIDFiltered.clear();

        for (var i in _productCategoryList) {
          _productCatWidgetLIst.add(ProductCategoryInfoItemCardWidget(
            onTap: () => _fillData(),
            item: i,
          ));

          if (!_selectedPanelIDFiltered.contains(i.pannelId.toString())) {
            _selectedPanelIDFiltered.add(i.pannelId.toString());
          }
        }
      }

      final resPannel = await getPannels();
      if (resPannel != false && resPannel != null && resPannel.isNotEmpty) {
        _pannelNameList.clear();
        for (var i in resPannel) {
          _pannelNameList
              .add("${i.id}: ${getPannelName(name: i.type)} - ${i.location}");
        }
        _selectedPannelName =
            "${resPannel[0].id}: ${getPannelName(name: resPannel[0].type)} - ${resPannel[0].location}";
      }

      final groupsData = await getUserGroups(roleType: 'user');
      _userGroups = (groupsData?['groups'] as List<UserGroup>?) ?? [];

      setStateIfMounted(() {
        _showData = true;
        _showFilters = true;
      });
    } catch (error) {
      debugPrint("Error in _fillData: $error");
      if (mounted) {
        showMsg(msg: "خطا در دریافت اطلاعات", context: context, type: "error");
      }
    }
  }

  _buildBottomNavigationBar(BuildContext context) {
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
      child: Row(
        children: <Widget>[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () =>
                  _openAddNewProductCategoryDialog(context: context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyle.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text("بسته جدید",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_pannelNameList.isNotEmpty) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FastEditProductCategoriesScreen(
                                productCategoryList: _productCategoryList,
                              )));
                } else {
                  showMsg(
                      msg: "هیچ پنلی ثبت نشده است. ابتدا یک پنل ثبت کنید.",
                      context: context,
                      type: "error");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyle.primaryColor.withValues(alpha: 0.2),
                foregroundColor: AppStyle.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppStyle.primaryColor)),
              ),
              icon: const Icon(Icons.edit_note, size: 20),
              label: const Text("ویرایش سریع",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  _content(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _showData == true
                      ? _productInfoTabCard(context)
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                ],
              ),
            ),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            if (!Responsive.isMobile(context))
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _operationInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    _showFilters == true
                        ? _panelNameFilters(context)
                        : const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
          ],
        )
      ],
    );
  }

  _productInfoTabCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.category_outlined,
                      color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "بسته‌های تعریف شده",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon:
                    const Icon(Icons.refresh, color: Colors.white70, size: 20),
                onPressed: () => _fillData(),
                tooltip: 'بروزرسانی',
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          if (_productCatWidgetLIst.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Text("هیچ بسته‌ای یافت نشد",
                    style: TextStyle(color: Colors.white38)),
              ),
            )
          else
            SizedBox(
                width: double.infinity,
                child: Responsive(
                  mobile: widgetsGridview(
                      childAspectRatio: 3.2,
                      context: context,
                      importedList: _productCatWidgetLIst),
                  tablet: widgetsGridview(
                      context: context,
                      childAspectRatio: 4.5,
                      importedList: _productCatWidgetLIst),
                  desktop: widgetsGridview(
                      importedList: _productCatWidgetLIst,
                      context: context,
                      childAspectRatio: 4.5,
                      crossAxisCount: 2),
                )),
        ],
      ),
    );
  }

  _operationInfoCard(BuildContext context) {
    List<Widget> actionsWidgetList = [];

    setState(() {
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          _pannelNameList.isNotEmpty
              ? _openAddNewProductCategoryDialog(context: context)
              : showMsg(
                  msg:
                      "هیچ پنلی ثبت نشده است، ابتدا می بایست به بخش تنظیمات پنل بروید و یک پنل ثبت کنید.",
                  context: context,
                  type: "error");
        },
        icon: const Icon(Icons.add),
        label: const Text("کانفیگ جدید"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          _pannelNameList.isNotEmpty
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FastEditProductCategoriesScreen(
                            productCategoryList: _productCategoryList,
                          )))
              : showMsg(
                  msg:
                      "هیچ پنلی ثبت نشده است، ابتدا می بایست به بخش تنظیمات پنل بروید و یک پنل ثبت کنید.",
                  context: context,
                  type: "error");
        },
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش سریع"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InventoryImportScreen(),
            ),
          ).whenComplete(_fillData);
        },
        icon: const Icon(Icons.table_view),
        label: const Text("import اکسل"),
      ));
    });
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
            "عملیات ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 5,
                  context: context,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              desktop: widgetsGridview(
                  importedList: actionsWidgetList,
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddNewProductCategoryDialog(
      {required BuildContext context}) async {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth =
        screenSize.width > 600 ? 550.0 : screenSize.width * 0.95;
    _allowedGroupIds.clear();
    _upsellCategoryId = null;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppStyle.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: screenSize.height * 0.9,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppStyle.primaryColor.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'تعریف بسته جدید',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppStyle.primaryColor,
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTextField(
                                controller: _nameEditText,
                                label: 'نام بسته',
                                hint: 'مثال: یک ماهه 50 گیگ',
                                icon: Icons.label_outline,
                                validator: (v) =>
                                    v!.isEmpty ? 'نام بسته الزامی است' : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _priceEditText,
                                      label: 'قیمت (تومان)',
                                      hint: '0',
                                      icon: Icons.payments_outlined,
                                      keyboardType: TextInputType.number,
                                      validator: (v) =>
                                          v!.isEmpty ? 'قیمت الزامی است' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _priceInDollarEditText,
                                      label: 'قیمت (دلار)',
                                      hint: '0.0',
                                      icon: Icons.attach_money,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      validator: (v) => v!.isEmpty
                                          ? 'قیمت دلاری الزامی است'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _expireDayEditText,
                                      label: 'مدت (روز)',
                                      hint: '30',
                                      icon: Icons.timer_outlined,
                                      keyboardType: TextInputType.number,
                                      validator: (v) =>
                                          v!.isEmpty ? 'مدت الزامی است' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _volumeEditText,
                                      label: 'حجم (گیگابایت)',
                                      hint: '50',
                                      icon: Icons.data_usage,
                                      keyboardType: TextInputType.number,
                                      validator: (v) =>
                                          v!.isEmpty ? 'حجم الزامی است' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue:
                                    _pannelNameList.contains(_selectedPannelName)
                                        ? _selectedPannelName
                                        : (_pannelNameList.isNotEmpty
                                            ? _pannelNameList.first
                                            : null),
                                dropdownColor: AppStyle.secondaryColor,
                                decoration: _inputDecoration(
                                    'انتخاب پنل', Icons.dns_outlined),
                                items: _pannelNameList.map((clType) {
                                  return DropdownMenuItem(
                                    value: clType,
                                    child: Text(clType,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(
                                      () => _selectedPannelName = newValue!);
                                },
                              ),
                              if (_selectedPannelName.contains("Sanaei")) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _inboundIdEditText,
                                        label: 'Inbound IDs',
                                        hint: 'مثال: 1, 2, 3',
                                        icon: Icons.numbers,
                                        keyboardType: TextInputType.text,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _ipLimitEditText,
                                        label: 'IP Limit',
                                        icon: Icons.devices,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: _selectedPannelName.isEmpty
                                        ? null
                                        : () {
                                            final id = int.tryParse(
                                                _selectedPannelName
                                                    .split(':')[0]);
                                            if (id == null) return;
                                            runSanaeiInboundSync(
                                              context,
                                              pannelId: id,
                                              inboundIdController:
                                                  _inboundIdEditText,
                                            );
                                          },
                                    icon: const Icon(Icons.sync, size: 18),
                                    label: const Text('انتخاب Inboundها از پنل'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _sampleInboundEditText,
                                  label: 'کانفیگ نمونه',
                                  icon: Icons.text_fields,
                                  keyboardType: TextInputType.text,
                                ),
                              ],
                              if (isMarzbanCompatiblePanel(
                                  getPanelTypeFromDropdownLabel(
                                      _selectedPannelName))) ...[
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _marzbanInboundsEditText,
                                  label: 'Inboundهای Marzban/PasarGuard',
                                  hint: 'JSON: {"vless":["TAG1"]}',
                                  icon: Icons.hub_outlined,
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: _selectedPannelName.isEmpty
                                        ? null
                                        : () {
                                            final id = int.tryParse(
                                                _selectedPannelName
                                                    .split(':')[0]);
                                            if (id == null) return;
                                            runMarzbanInboundSync(
                                              context,
                                              pannelId: id,
                                              inboundsController:
                                                  _marzbanInboundsEditText,
                                              panelType:
                                                  getPanelTypeFromDropdownLabel(
                                                      _selectedPannelName),
                                            );
                                          },
                                    icon: const Icon(Icons.sync, size: 18),
                                    label: const Text('انتخاب Inboundها از پنل'),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppStyle.bgColor.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Column(
                                  children: [
                                    _buildSwitchTile(
                                      'نمایش لینک سابسکریپشن',
                                      _selectedPannelName.contains("Hiddify")
                                          ? true
                                          : _showSubscriptionLink,
                                      _selectedPannelName.contains("Hiddify")
                                          ? null
                                          : (v) => setState(
                                              () => _showSubscriptionLink = v),
                                    ),
                                    if (_selectedPannelName.contains("Hiddify"))
                                      _buildSwitchTile(
                                        'نمایش لینک پنل',
                                        _showPannelLink,
                                        (v) =>
                                            setState(() => _showPannelLink = v),
                                      ),
                                    if (panelDropdownSupportsConfigToggle(
                                        _selectedPannelName))
                                      _buildSwitchTile(
                                        'ارسال کانفیگ به کاربر',
                                        _sendConfigToUser,
                                        (v) => setState(
                                            () => _sendConfigToUser = v),
                                      ),
                                    _buildSwitchTile(
                                      'قابلیت شارژ مجدد',
                                      _selectedPannelName.contains("دیگر")
                                          ? false
                                          : _rechargable,
                                      _selectedPannelName.contains("دیگر")
                                          ? null
                                          : (v) =>
                                              setState(() => _rechargable = v),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _upsellCategoryWidget(context, setState),
                              _allowedGroupsWidget(context, setState),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await _submitData(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppStyle.primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 5,
                              ),
                              child: const Text('ثبت و ذخیره',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: _inputDecoration(label, icon, hint: hint),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: AppStyle.primaryColor, size: 20),
      filled: true,
      fillColor: AppStyle.bgColor.withValues(alpha: 0.3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppStyle.primaryColor)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool)? onChanged) {
    return SwitchListTile(
      title: Text(title,
          style: const TextStyle(color: Colors.white70, fontSize: 13)),
      value: value,
      activeThumbColor: AppStyle.primaryColor,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      dense: true,
    );
  }

  Widget _upsellCategoryWidget(
      BuildContext context, void Function(void Function()) setDialogState) {
    if (!_isGoldLicense) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppStyle.bgColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.workspace_premium,
                color: Colors.amber.shade400, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'پیشنهاد ارتقا (Upsell) در لایسنس طلایی فعال می‌شود.',
                style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final pannelId = _selectedPannelName.isNotEmpty
        ? int.tryParse(_selectedPannelName.split(':')[0])
        : null;
    final options = _productCategoryList
        .where((c) => c.pannelId == pannelId && c.isActive)
        .toList();
    final upsellDropdownValue = _upsellCategoryId != null &&
            options.any((c) => c.id == _upsellCategoryId)
        ? _upsellCategoryId
        : null;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('پیشنهاد ارتقا (Upsell)'),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            initialValue: upsellDropdownValue,
            decoration: const InputDecoration(
              labelText: 'بسته پیشنهادی هنگام خرید',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('بدون پیشنهاد ارتقا'),
              ),
              ...options.map(
                (c) => DropdownMenuItem<int?>(
                  value: c.id,
                  child: Text('${c.categoryName} (${c.price} تومان)'),
                ),
              ),
            ],
            onChanged: (v) => setDialogState(() => _upsellCategoryId = v),
          ),
        ],
      ),
    );
  }

  Widget _allowedGroupsWidget(
      BuildContext context, void Function(VoidCallback fn) setDialogState) {
    final theme = Theme.of(context);
    final groups = _userGroups.where((g) => !g.isDefault).toList();

    String helper;
    if (_allowedGroupIds.isEmpty) {
      helper = 'اگر چیزی انتخاب نکنید، برای همه نمایش داده می‌شود';
    } else {
      helper = 'فقط گروه‌های انتخاب‌شده نمایش داده می‌شود';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('محدودیت گروه کاربری (اختیاری)',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(helper,
              style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('بدون گروه'),
                selected: _allowedGroupIds.contains(0),
                onSelected: (v) => setDialogState(() {
                  if (v) {
                    _allowedGroupIds.add(0);
                  } else {
                    _allowedGroupIds.remove(0);
                  }
                }),
              ),
              ...groups.map((g) {
                final selected = _allowedGroupIds.contains(g.id);
                return FilterChip(
                  label: Text(g.name),
                  selected: selected,
                  onSelected: (v) => setDialogState(() {
                    if (v) {
                      _allowedGroupIds.add(g.id);
                    } else {
                      _allowedGroupIds.remove(g.id);
                    }
                  }),
                );
              }),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _allowedGroupIds.isEmpty
                  ? null
                  : () => setDialogState(() => _allowedGroupIds.clear()),
              child: const Text('حذف محدودیت (همه)'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitData(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    EasyLoading.show(status: 'در حال ثبت...');
    try {
      int pannelID = 1;
      if (_selectedPannelName.isNotEmpty) {
        pannelID = int.parse(_selectedPannelName.split(":")[0]);
      }

      final inboundIds = parseInboundIdsFromText(_inboundIdEditText.text);
      final marzbanInbounds =
          parseMarzbanInboundsFromText(_marzbanInboundsEditText.text);

      final val = await addNewProductCategory(
        name: _nameEditText.text,
        price: int.parse(_priceEditText.text),
        priceInDollar: double.parse(_priceInDollarEditText.text),
        pannelID: pannelID,
        expDay: int.parse(_expireDayEditText.text),
        volume: int.parse(_volumeEditText.text),
        rechargable: _rechargable,
        showPannelLink:
            _selectedPannelName.contains("Hiddify") ? _showPannelLink : false,
        showSubscriptionLink: _showSubscriptionLink,
        sendConfigToUser: panelDropdownSupportsConfigToggle(_selectedPannelName)
            ? _sendConfigToUser
            : false,
        allowedUserGroupIds:
            _allowedGroupIds.isEmpty ? null : _allowedGroupIds.toList(),
        inboundId: inboundIds.isNotEmpty ? inboundIds.first : null,
        inboundIds: inboundIds.isEmpty ? null : inboundIds,
        marzbanInbounds:
            marzbanInbounds.isEmpty ? null : marzbanInbounds,
        ipLimit: _ipLimitEditText.text.isNotEmpty
            ? int.tryParse(_ipLimitEditText.text)
            : 0,
        sampleInbound: _sampleInboundEditText.text,
        upsellCategoryId: _upsellCategoryId,
      );

      if (val) {
        if (context.mounted) {
          showMsg(
              msg: "بسته با موفقیت افزوده شد.",
              context: context,
              type: "success");
          Navigator.pop(context);
          _fillData();
        }
      } else {
        if (context.mounted) {
          showMsg(
              msg: "خطا در ثبت بسته. لطفا دوباره تلاش کنید.",
              context: context,
              type: "error");
        }
      }
    } catch (e) {
      debugPrint("Error in _submitData: $e");
      if (context.mounted) {
        showMsg(msg: "خطای غیرمنتظره رخ داد.", context: context, type: "error");
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  _panelNameFilters(BuildContext context) {
    List<Widget> list = [];
    for (var panelName in _pannelNameList) {
      int pannelID = int.parse(panelName.split(":")[0]);
      list.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppStyle.bgColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CheckboxListTile(
            value: _selectedPanelIDFiltered.contains(pannelID),
            activeColor: AppStyle.primaryColor,
            checkColor: Colors.white,
            onChanged: (bool? value) {
              setStateIfMounted(() {
                _showData = false;
              });
              if (value!) {
                _selectedPanelIDFiltered.add(pannelID);
              } else {
                _selectedPanelIDFiltered.remove(pannelID);
              }
              setStateIfMounted(() {
                _productCatWidgetLIst.clear();

                for (var i in _productCategoryList) {
                  if (_selectedPanelIDFiltered.contains(i.pannelId)) {
                    _productCatWidgetLIst.add(ProductCategoryInfoItemCardWidget(
                      onTap: () => _fillData(),
                      item: i,
                    ));
                  }
                }
                _showData = true;
              });
            },
            title: Text(
              panelName,
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                "فیلتر پنل‌ها",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          ...list,
        ],
      ),
    );
  }
}
