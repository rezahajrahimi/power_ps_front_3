import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helpers/sanaei_inbound_sync.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/models/user_group_model.dart';
import 'package:powerps/provider/product_category_provider.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/repositories/user_group_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class EditProductDetailsScreen extends StatefulWidget {
  const EditProductDetailsScreen(
      {super.key, required this.selectedProductCategory});
  final ProductCategory selectedProductCategory;

  @override
  State<EditProductDetailsScreen> createState() =>
      _EditProductDetailsScreenState();
}

class _EditProductDetailsScreenState extends State<EditProductDetailsScreen> {
  bool _showData = false;
  final _formKey = GlobalKey<FormState>();
  final List<Widget> _productDetailsWidgetLIst = [];
  final List<String> _pannelNameList = [];
  late String _selectedPannelName;
  final _nameEditText = TextEditingController();
  final _priceEditText = TextEditingController();
  final _priceInDollarEditText = TextEditingController();
  final _expireDayEditText = TextEditingController();
  final _volumeEditText = TextEditingController();
  final _inboundIdEditText = TextEditingController();
  final _ipLimitEditText = TextEditingController();
  final _sampleInboundEditText = TextEditingController();

  bool _rechargable = true;
  bool _showSubscriptionLink = true;
  bool _showPannelLink = true;
  bool _sendConfigToUser = true;
  bool _isActive = true;
  List<UserGroup> _userGroups = [];
  final Set<int> _allowedGroupIds = {};
  List<ProductCategory> _allCategories = [];
  int? _upsellCategoryId;

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _nameEditText.dispose();
    _priceEditText.dispose();
    _priceInDollarEditText.dispose();
    _expireDayEditText.dispose();
    _volumeEditText.dispose();
    _inboundIdEditText.dispose();
    _ipLimitEditText.dispose();
    _sampleInboundEditText.dispose();
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
            title: "ویرایش ${widget.selectedProductCategory.categoryName}",
          ),
          body: SingleChildScrollView(
            primary: false,
            child: Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: Column(
                children: [
                  // const Header(title: "ویرایش بسته"),
                  SizedBox(height: AppStyle.defaultPadding),
                  _showData == false
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppStyle.primaryColor,
                            ),
                          ),
                        )
                      : _content(context),
                ],
              ),
            ),
          ),
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

  _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () => _submitData(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppStyle.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.save),
          label: const Text("ثبت تغییرات"),
        ),
      ),
    );
  }

  void _fillData() async {
    try {
      List<Pannel>? resPannel = await getPannels();
      final groupsData = await getUserGroups(roleType: 'user');
      final categories = await getAllProdctCategory();

      setStateIfMounted(() {
        _nameEditText.text = widget.selectedProductCategory.categoryName;
        _priceEditText.text = widget.selectedProductCategory.price.toString();
        _priceInDollarEditText.text =
            widget.selectedProductCategory.priceInDollar.toString();
        _expireDayEditText.text =
            widget.selectedProductCategory.expireDay.toString();
        _volumeEditText.text = widget.selectedProductCategory.volume.toString();
        _inboundIdEditText.text =
            widget.selectedProductCategory.inboundId?.toString() ?? "";
        _ipLimitEditText.text =
            widget.selectedProductCategory.ipLimit?.toString() ?? "0";
        _sampleInboundEditText.text =
            widget.selectedProductCategory.sampleInbound?.toString() ?? "";
        _rechargable = widget.selectedProductCategory.rechargable;
        _showSubscriptionLink =
            widget.selectedProductCategory.showSubscriptionLink;
        _showPannelLink = widget.selectedProductCategory.showPannelLink;
        _sendConfigToUser = widget.selectedProductCategory.sendConfigToUser;
        _isActive = widget.selectedProductCategory.isActive;
        _userGroups = (groupsData?['groups'] as List<UserGroup>?) ?? [];
        _allowedGroupIds
          ..clear()
          ..addAll(widget.selectedProductCategory.allowedUserGroupIds ?? const []);
        _upsellCategoryId = widget.selectedProductCategory.upsellCategoryId;
        _allCategories = categories is List<ProductCategory> ? categories : [];

        if (resPannel != null && resPannel.isNotEmpty) {
          _pannelNameList.clear();
          for (var i in resPannel) {
            _pannelNameList
                .add("${i.id}: ${getPannelName(name: i.type)} - ${i.location}");
          }

          _selectedPannelName =
              "${widget.selectedProductCategory.pannel!.id}: ${getPannelName(name: widget.selectedProductCategory.pannel!.type)} - ${widget.selectedProductCategory.pannel!.location}";
        } else {
          _selectedPannelName = "";
        }

        _showData = true;
      });
    } catch (e) {
      if (mounted) {
        showMsg(
            msg: "خطا در دریافت اطلاعات پنل ها",
            context: context,
            type: "error");
      }
    }
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
                    _productInfoTabCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                )),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            // side windows
            if (!Responsive.isMobile(context))
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _operationInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  _operationInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
              Icon(Icons.settings, color: AppStyle.primaryColor),
              const SizedBox(width: 10),
              Text(
                "عملیات ها",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Divider(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyle.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _submitData(context),
              icon: const Icon(Icons.save),
              label: const Text("ثبت تغییرات"),
            ),
          ),
        ],
      ),
    );
  }

  _productInfoTabCard(BuildContext context) {
    _productDetailsWidgetLIst.clear();
    bool isSanaei = getPanelTypeFromDropdownLabel(_selectedPannelName) == 'sanaei';
    bool isHiddify = _selectedPannelName.contains("Hiddify");
    bool supportsConfigToggle = panelDropdownSupportsConfigToggle(_selectedPannelName);

    _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
      controller: _nameEditText,
      textHint: "نام بسته",
      validationError: "نام بسته را وارد کنید.",
      keyboardType: TextInputType.text,
    ));
    _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
      controller: _priceEditText,
      textHint: "قیمت بسته (تومان)",
      validationError: "قیمت بسته را وارد کنید.",
      keyboardType: TextInputType.number,
    ));
    _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
      controller: _priceInDollarEditText,
      textHint: "قیمت بسته (دلار)",
      validationError: "قیمت دلاری بسته را وارد کنید.",
      keyboardType: TextInputType.number,
    ));
    _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
      controller: _expireDayEditText,
      textHint: "مدت زمان اعتبار (روز)",
      validationError: "مدت زمان اعتبار را وارد کنید.",
      keyboardType: TextInputType.number,
    ));
    _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
      controller: _volumeEditText,
      textHint: "حجم بسته (گیگابایت)",
      validationError: "حجم بسته را وارد کنید.",
      keyboardType: TextInputType.number,
    ));

    if (isSanaei) {
      _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
        controller: _inboundIdEditText,
        textHint: "Inbound ID",
        validationError: "Inbound ID را وارد کنید.",
        keyboardType: TextInputType.number,
      ));
      _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
        controller: _ipLimitEditText,
        textHint: "محدودیت IP (0 برای بدون محدودیت)",
        validationError: "محدودیت IP را وارد کنید.",
        keyboardType: TextInputType.number,
      ));
      _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
        controller: _sampleInboundEditText,
        textHint: "کانفیگ نمونه",
        validationError: "",
        keyboardType: TextInputType.text,
      ));
      _productDetailsWidgetLIst.add(
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              final id = int.tryParse(_selectedPannelName.split(':')[0]);
              if (id == null) return;
              runSanaeiInboundSync(
                context,
                pannelId: id,
                inboundIdController: _inboundIdEditText,
              );
            },
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('انتخاب Inbound از پنل'),
          ),
        ),
      );
    }

    // همیشه sampleInbound را نمایش بده

    _productDetailsWidgetLIst.add(Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppStyle.primaryColor.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue:
              _selectedPannelName.isNotEmpty ? _selectedPannelName : null,
          decoration: const InputDecoration(
            labelText: "انتخاب پنل",
            border: InputBorder.none,
          ),
          onChanged: (newValue) {
            setStateIfMounted(() {
              _selectedPannelName = newValue!;
            });
          },
          items: _pannelNameList.map((clType) {
            return DropdownMenuItem(
              value: clType,
              child: Text(clType, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
        ),
      ),
    ));

    _productDetailsWidgetLIst.add(_buildSwitchTile(
      title: "نمایش لینک سابسکریپشن",
      value: isHiddify ? true : _showSubscriptionLink,
      onChanged: isHiddify
          ? null
          : (val) => setStateIfMounted(() => _showSubscriptionLink = val),
    ));

    if (isHiddify) {
      _productDetailsWidgetLIst.add(_buildSwitchTile(
        title: "نمایش لینک پنل",
        value: _showPannelLink,
        onChanged: (val) => setStateIfMounted(() => _showPannelLink = val),
      ));
    }

    if (supportsConfigToggle) {
      _productDetailsWidgetLIst.add(_buildSwitchTile(
        title: "ارسال کانفیگ به کاربر",
        value: _sendConfigToUser,
        onChanged: (val) => setStateIfMounted(() => _sendConfigToUser = val),
      ));
    }

    _productDetailsWidgetLIst.add(_buildSwitchTile(
      title: "قابلیت شارژ مجدد",
      value: _selectedPannelName.contains("دیگر") ? false : _rechargable,
      onChanged: _selectedPannelName.contains("دیگر")
          ? null
          : (val) => setStateIfMounted(() => _rechargable = val),
    ));

    _productDetailsWidgetLIst.add(_buildSwitchTile(
      title: "قابلیت خرید (فعال)",
      value: _isActive,
      onChanged: (val) => setStateIfMounted(() => _isActive = val),
    ));

    _productDetailsWidgetLIst.add(_allowedGroupsWidget(context));
    _productDetailsWidgetLIst.add(_upsellCategoryWidget(context));

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: AppStyle.primaryColor),
                const SizedBox(width: 10),
                Text(
                  "اطلاعات بسته",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 30),
            SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.8,
                    context: context,
                    crossAxisCount: 1,
                    importedList: _productDetailsWidgetLIst),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.0,
                    crossAxisCount: 2,
                    importedList: _productDetailsWidgetLIst),
                desktop: widgetsGridview(
                    importedList: _productDetailsWidgetLIst,
                    context: context,
                    childAspectRatio: 4.5,
                    crossAxisCount: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppStyle.primaryColor.withValues(alpha: 0.1)),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppStyle.primaryColor,
      ),
    );
  }

  Widget _allowedGroupsWidget(BuildContext context) {
    final groups = _userGroups.where((g) => !g.isDefault).toList();
    final theme = Theme.of(context);

    String helper;
    if (_allowedGroupIds.isEmpty) {
      helper = 'همه گروه‌ها می‌توانند ببینند/بخرند';
    } else {
      helper = 'فقط گروه‌های انتخاب‌شده نمایش داده می‌شود';
    }

    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppStyle.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('محدودیت گروه کاربری (اختیاری)',
              style: theme.textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(helper, style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('بدون گروه'),
                selected: _allowedGroupIds.contains(0),
                onSelected: (v) => setStateIfMounted(() {
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
                  onSelected: (v) => setStateIfMounted(() {
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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _allowedGroupIds.isEmpty
                  ? null
                  : () => setStateIfMounted(() => _allowedGroupIds.clear()),
              child: const Text('حذف محدودیت (همه)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _upsellCategoryWidget(BuildContext context) {
    final currentPannelId = widget.selectedProductCategory.pannelId;
    final options = _allCategories
        .where((c) =>
            c.id != widget.selectedProductCategory.id &&
            c.pannelId == currentPannelId &&
            c.isActive)
        .toList();

    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppStyle.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('پیشنهاد ارتقا (Upsell)',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(
            'بسته پیشنهادی هنگام خرید این بسته در ربات نمایش داده می‌شود',
            style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 12),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int?>(
            value: _upsellCategoryId,
            decoration: const InputDecoration(
              labelText: 'بسته پیشنهادی',
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
            onChanged: (v) => setStateIfMounted(() => _upsellCategoryId = v),
          ),
        ],
      ),
    );
  }

  _submitData(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    EasyLoading.show(status: 'در حال بروزرسانی...');
    try {
      int pannelID = 1;
      if (_selectedPannelName != "") {
        pannelID = int.parse(_selectedPannelName.split(":")[0]);
      }

      final isHiddify = _selectedPannelName.contains("Hiddify");
      final supportsConfigToggle =
          panelDropdownSupportsConfigToggle(_selectedPannelName);

      var res = await editProductCategory(
          name: _nameEditText.text,
          price: int.parse(_priceEditText.text),
          priceInDollar: double.parse(_priceInDollarEditText.text),
          pannelID: pannelID,
          expDay: int.parse(_expireDayEditText.text),
          volume: int.parse(_volumeEditText.text),
          rechargable: _rechargable,
          showPannelLink: isHiddify ? _showPannelLink : false,
          showSubscriptionLink: _showSubscriptionLink,
          sendConfigToUser: supportsConfigToggle ? _sendConfigToUser : false,
          isActive: _isActive,
          allowedUserGroupIds:
              _allowedGroupIds.isEmpty ? null : _allowedGroupIds.toList(),
          id: widget.selectedProductCategory.id.toInt(),
          inboundId: _inboundIdEditText.text.isNotEmpty
              ? int.tryParse(_inboundIdEditText.text)
              : null,
          ipLimit: _ipLimitEditText.text.isNotEmpty
              ? int.tryParse(_ipLimitEditText.text)
              : 0,
          sampleInbound: _sampleInboundEditText.text,
          upsellCategoryId: _upsellCategoryId);

      if (res) {
        if (context.mounted) {
          showMsg(
              msg: "تغییرات با موفقیت ذخیره شد",
              context: context,
              type: "success");
          context.read<ProductCategoryProvider>().setChanged(true);
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          showMsg(
              msg: "خطا در بروزرسانی اطلاعات", context: context, type: "error");
        }
      }
    } catch (e) {
      if (context.mounted) {
        showMsg(msg: "خطای غیرمنتظره رخ داد", context: context, type: "error");
      }
    } finally {
      EasyLoading.dismiss();
    }
  }
}
