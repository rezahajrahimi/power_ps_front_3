import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/models/details_info.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/provider/product_category_provider.dart';
import 'package:powerps/screens/admin_screen/product/edit_product_details_screen.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/repositories/product_details_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/product_details/config_details_info_item_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/details_info_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:powerps/widgets/users/bot_user_info_item_widget.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductCategory selectedProductCategory;

  const ProductDetailsScreen(
      {super.key, required this.selectedProductCategory});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _showdata = false;
  final _newConfigsEditText = TextEditingController();
  final _newSubscriptionLinkEditText = TextEditingController();
  final _newPaneLinkEditText = TextEditingController();
  final List<Widget> _productDetailsInfoItemList = [];
  final List<Widget> _lastUserBoughtWidgetList = [];
  late Map<dynamic, dynamic> selledSummaryCount;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fillData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
            context: context,
            title: widget.selectedProductCategory.categoryName,
          ),
          body: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _showdata == false
                ? const Text(
                    "درحال دریافت اطلاعات",
                    textDirection: TextDirection.rtl,
                  )
                : Column(
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
                                _lastUserBoughtInfoTabCard(context),
                                SizedBox(height: AppStyle.defaultPadding),
                                if (widget
                                        .selectedProductCategory.pannel!.type ==
                                    "custome")
                                  _activeConfigCardData(context),
                                SizedBox(height: AppStyle.defaultPadding),
                                if (Responsive.isMobile(context))
                                  SizedBox(height: AppStyle.defaultPadding),
                                if (Responsive.isMobile(
                                    context)) // side bar mobile
                                  Column(
                                    children: [
                                      SizedBox(height: AppStyle.defaultPadding),
                                      _summaryCountInfoCard(context),
                                    ],
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
                                  _summaryCountInfoCard(context),
                                ],
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
          ),
          bottomNavigationBar: Responsive.isMobile(context)
              ? _buildBottomNavigationBar(context)
              : const Opacity(opacity: 1),
        ),
      ),
    );
  }

  Future<void> _fillData() async {
    if (!mounted) return;
    setState(() => _showdata = false);

    try {
      await getActiveProductsByProductCatID(
          productCategoryypeID: widget.selectedProductCategory.id);

      final summaryRes = await getCountOfProductSelledSummeryByCatID(
          id: widget.selectedProductCategory.id.toInt());

      final userListRes = await getLastBuyersByCatIdAndCount(
          catID: widget.selectedProductCategory.id.toInt(), count: 10);

      if (mounted) {
        setState(() {
          if (userListRes != false) {
            _lastUserBoughtWidgetList.clear();
            for (var i in userListRes) {
              _lastUserBoughtWidgetList.add(BotUserInfoItemCardWidget(
                item: BotUser(
                    id: i.id,
                    accountId: i.accountId,
                    username: i.username,
                    firstName: i.firstName,
                    lastName: i.lastName,
                    createdAt: i.createdAt,
                    updatedAt: i.updatedAt),
              ));
            }
          }
          if (summaryRes != false && summaryRes != null) {
            selledSummaryCount = summaryRes;
          }
          _showdata = true;
        });
      }
    } catch (e) {
      debugPrint("Error in _fillData: $e");
      if (mounted) {
        showMsg(msg: "خطا در دریافت اطلاعات", context: context, type: "error");
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _openAddNewProductDialog({required BuildContext context}) async {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppStyle.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppStyle.primaryColor.withValues(alpha: 0.1),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'افزودن ردیف جدید',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppStyle.primaryColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildDetailTextField(
                        controller: _newConfigsEditText,
                        label: 'کانفیگ(ها)',
                        icon: Icons.code,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailTextField(
                        controller: _newSubscriptionLinkEditText,
                        label: 'لینک سابسکریپشن',
                        icon: Icons.link,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailTextField(
                        controller: _newPaneLinkEditText,
                        label: 'لینک پنل',
                        icon: Icons.admin_panel_settings,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_newConfigsEditText.text.isNotEmpty &&
                                _newPaneLinkEditText.text.isNotEmpty &&
                                _newSubscriptionLinkEditText.text.isNotEmpty) {
                              EasyLoading.show(status: 'در حال ثبت...');
                              try {
                                bool res = await addNewProductDetails(
                                    productCatID: widget
                                        .selectedProductCategory.id
                                        .toInt(),
                                    configs: _newConfigsEditText.text,
                                    panelLink: _newPaneLinkEditText.text,
                                    subscriptionLink:
                                        _newSubscriptionLinkEditText.text);

                                if (res) {
                                  productNotifier.value = "productCardChanged";
                                  _newConfigsEditText.clear();
                                  _newPaneLinkEditText.clear();
                                  _newSubscriptionLinkEditText.clear();

                                  if (context.mounted) {
                                    showMsg(
                                        msg: "با موفقیت افزوده شد",
                                        context: context,
                                        type: "success");
                                    Navigator.pop(context);
                                    _fillData();
                                  }
                                } else {
                                  if (context.mounted) {
                                    showMsg(
                                        msg: "خطا در ثبت",
                                        context: context,
                                        type: "error");
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  showMsg(
                                      msg: "خطای غیرمنتظره",
                                      context: context,
                                      type: "error");
                                }
                              } finally {
                                EasyLoading.dismiss();
                              }
                            } else {
                              showMsg(
                                  msg: "لطفا تمامی فیلدها را پر کنید",
                                  context: context,
                                  type: "warning");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyle.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('افزودن',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: AppStyle.primaryColor, size: 20),
        filled: true,
        fillColor: AppStyle.bgColor.withValues(alpha: 0.3),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppStyle.primaryColor)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  _operationInfoCard(BuildContext context) {
    List<Widget> actionsWidgetList = [];

    if (widget.selectedProductCategory.pannel!.type == "custome") {
      actionsWidgetList.add(ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyle.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _openAddNewProductDialog(context: context),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text("کانفیگ جدید"),
      ));
    }

    actionsWidgetList.add(ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orangeAccent.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProductDetailsScreen(
                selectedProductCategory: widget.selectedProductCategory,
              ),
            )).whenComplete(() => _fillData());
      },
      icon: const Icon(Icons.edit_outlined),
      label: const Text("ویرایش بسته"),
    ));

    if (_lastUserBoughtWidgetList.isEmpty) {
      actionsWidgetList.add(ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _showDeleteDialog(context),
        icon: const Icon(Icons.delete_outline),
        label: const Text("حذف بسته"),
      ));
    }

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.amber, size: 22),
              const SizedBox(width: 10),
              Text(
                "عملیات سریع",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 30),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 4,
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

  _summaryCountInfoCard(BuildContext context) {
    List<Widget> widgetList = [];

    for (var element in selledSummaryCount.entries) {
      widgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: element.key,
        itemValue: "${element.value} عدد",
        icon:
            const Icon(Icons.shopping_bag_outlined, color: Colors.purpleAccent),
      )));
    }

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined,
                  color: Colors.white70, size: 22),
              const SizedBox(width: 10),
              Text(
                "آمار فروش",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 30),
          if (widgetList.isEmpty)
            const Center(
                child: Text("آماری موجود نیست",
                    style: TextStyle(color: Colors.white38)))
          else
            SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 3.5,
                    context: context,
                    crossAxisCount: 1,
                    importedList: widgetList),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 5,
                    crossAxisCount: 1,
                    importedList: widgetList),
                desktop: widgetsGridview(
                    importedList: widgetList,
                    context: context,
                    childAspectRatio: 5,
                    crossAxisCount: 1),
              ),
            ),
        ],
      ),
    );
  }

  _productInfoTabCard(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    List<Widget> factoryWidgetList = [];

    factoryWidgetList.add(DetailsInfoItemWidget(
        item: DetailsInfoItem(
      itemName: "نام بسته",
      itemValue: widget.selectedProductCategory.categoryName,
      icon: const Icon(Icons.info_outline, color: Colors.blueAccent),
    )));
    factoryWidgetList.add(DetailsInfoItemWidget(
        item: DetailsInfoItem(
      itemName: "مدت زمان",
      itemValue: "${widget.selectedProductCategory.expireDay} روز",
      icon: const Icon(Icons.calendar_today, color: Colors.orangeAccent),
    )));
    factoryWidgetList.add(DetailsInfoItemWidget(
        item: DetailsInfoItem(
      itemName: "حجم بسته",
      itemValue: "${widget.selectedProductCategory.volume} گیگابایت",
      icon: const Icon(Icons.data_usage, color: Colors.greenAccent),
    )));
    factoryWidgetList.add(DetailsInfoItemWidget(
        item: DetailsInfoItem(
      itemName: "قیمت",
      itemValue:
          "${thousandSeperatorFormatter(widget.selectedProductCategory.price.toString())} تومان",
      icon: const Icon(Icons.payments_outlined, color: Colors.lightGreenAccent),
    )));
    factoryWidgetList.add(DetailsInfoItemWidget(
        item: DetailsInfoItem(
      itemName: "نوع پنل",
      itemValue:
          getPannelName(name: widget.selectedProductCategory.pannel!.type),
      icon: const Icon(Icons.dns_outlined, color: Colors.purpleAccent),
    )));
    factoryWidgetList.add(DetailsInfoItemWidget(
        item: DetailsInfoItem(
      itemName: "وضعیت",
      itemValue: widget.selectedProductCategory.isActive ? "فعال" : "غیر فعال",
      icon: Icon(
        widget.selectedProductCategory.isActive
            ? Icons.check_circle_outline
            : Icons.error_outline,
        color:
            widget.selectedProductCategory.isActive ? Colors.green : Colors.red,
      ),
    )));

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  color: Colors.white70, size: 22),
              const SizedBox(width: 10),
              Text(
                "اطلاعات پایه بسته",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 30),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3.5,
                  context: context,
                  importedList: factoryWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 6,
                  importedList: factoryWidgetList),
              desktop: widgetsGridview(
                  importedList: factoryWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 4 : 5.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _lastUserBoughtInfoTabCard(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline, color: Colors.white70, size: 22),
              const SizedBox(width: 10),
              Text(
                "آخرین خریداران",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 30),
          if (_lastUserBoughtWidgetList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("هنوز خریداری برای این بسته ثبت نشده است",
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
                    importedList: _lastUserBoughtWidgetList),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 6,
                    importedList: _lastUserBoughtWidgetList),
                desktop: widgetsGridview(
                    importedList: _lastUserBoughtWidgetList,
                    context: context,
                    childAspectRatio: size.width < 1400 ? 4 : 5.5,
                    crossAxisCount: 2),
              ),
            ),
        ],
      ),
    );
  }

  _activeConfigCardData(BuildContext context) {
    _productDetailsInfoItemList.clear();
    for (var i in productDetailsList) {
      _productDetailsInfoItemList.add(ConfigDetailsInfoItemWidget(
        item: i,
        isActive: true,
      ));
    }
    final Size size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_input_component_outlined,
                  color: Colors.white70, size: 22),
              const SizedBox(width: 10),
              Text(
                "کانفیگ‌های موجود",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 30),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder(
                valueListenable: productNotifier,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  if (value == "productCardChanged") {
                    _retryActiveConfigCardData(context);
                  }

                  if (_productDetailsInfoItemList.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("هیچ کانفیگ فعالی یافت نشد",
                            style: TextStyle(color: Colors.white38)),
                      ),
                    );
                  }

                  return Responsive(
                    mobile: widgetsGridview(
                        childAspectRatio: 3.2,
                        context: context,
                        importedList: _productDetailsInfoItemList),
                    tablet: widgetsGridview(
                        context: context,
                        childAspectRatio: 6,
                        importedList: _productDetailsInfoItemList),
                    desktop: widgetsGridview(
                        context: context,
                        importedList: _productDetailsInfoItemList,
                        childAspectRatio: size.width < 1400 ? 4.5 : 6,
                        crossAxisCount: 2),
                  );
                }),
          ),
        ],
      ),
    );
  }

  void _retryActiveConfigCardData(BuildContext context) {
    _productDetailsInfoItemList.clear();
    productChangedToken = "aaa";

    for (var i in productDetailsList) {
      _productDetailsInfoItemList.add(ConfigDetailsInfoItemWidget(
        item: i,
        isActive: true,
      ));
    }
  }

  void _showDeleteDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppStyle.secondaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                SizedBox(width: 10),
                Text("حذف بسته", style: TextStyle(color: Colors.white)),
              ],
            ),
            content: const Text(
                "آیا از حذف این بسته اطمینان دارید؟ این عمل غیرقابل بازگشت است.",
                style: TextStyle(color: Colors.white70)),
            actions: <Widget>[
              TextButton(
                child: const Text("انصراف",
                    style: TextStyle(color: Colors.white38)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("بله، حذف شود"),
                onPressed: () async {
                  EasyLoading.show(status: 'در حال حذف...');
                  try {
                    final value = await deleteProductCategoryByID(
                      id: widget.selectedProductCategory.id,
                    );
                    if (!context.mounted) return;
                    if (value) {
                      showMsg(
                          msg: "بسته با موفقیت حذف شد",
                          context: context,
                          type: "success");
                      Provider.of<ProductCategoryProvider>(context,
                              listen: false)
                          .setChanged(true);
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to previous screen
                    } else {
                      showMsg(
                          msg: "خطا در حذف بسته",
                          context: context,
                          type: "error");
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showMsg(
                          msg: "خطای غیرمنتظره رخ داد",
                          context: context,
                          type: "error");
                    }
                  } finally {
                    EasyLoading.dismiss();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProductDetailsScreen(
                        selectedProductCategory: widget.selectedProductCategory,
                      ),
                    )).whenComplete(() => _fillData());
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
              icon: const Icon(Icons.edit_outlined, size: 20),
              label: const Text("ویرایش",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_lastUserBoughtWidgetList.isEmpty) {
                  _showDeleteDialog(context);
                } else {
                  showMsg(
                      msg: "این بسته دارای خریدار می‌باشد و قابل حذف نیست",
                      context: context,
                      type: "warning");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.delete_forever_outlined, size: 20),
              label: const Text("حذف بسته",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
