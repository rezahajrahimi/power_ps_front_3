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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(
          context: context,
          title: widget.selectedProductCategory.categoryName,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
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
        ),
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : const Opacity(opacity: 1),
      ),
    );
  }

  void _fillData() async {
    try {
      if (mounted) {
        await getActiveProductsByProductCatID(
            productCategoryypeID: widget.selectedProductCategory.id);
        var summaryRes = await getCountOfProductSelledSummeryByCatID(
            id: widget.selectedProductCategory.id.toInt());
        var userListRes = await getLastBuyersByCatIdAndCount(
            catID: widget.selectedProductCategory.id.toInt(), count: 10);
        if (userListRes != false) {
          setState(() {
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
          });
        }
        if (summaryRes != false && summaryRes != null) {
          setState(() {
            selledSummaryCount = summaryRes;
          });
        }
        setState(() {
          _showdata = true;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  _openAddNewProductDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                title: const Text("ردیف جدید"),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    child: Column(
                      children: [
                        const Text("کانفیگ(ها)."),
                        TextFormField(
                          controller: _newConfigsEditText,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration:
                              const InputDecoration(labelText: "کانفیگ"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text("subscription link"),
                        TextFormField(
                          controller: _newSubscriptionLinkEditText,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "subscription link"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text("panel link"),
                        TextFormField(
                          controller: _newPaneLinkEditText,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration:
                              const InputDecoration(labelText: "panel link"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          onPressed: () async {
                            if (_newConfigsEditText.text.isNotEmpty &&
                                _newPaneLinkEditText.text.isNotEmpty &&
                                _newSubscriptionLinkEditText.text.isNotEmpty) {
                              bool res = false;
                              res = await addNewProductDetails(
                                  productCatID:
                                      widget.selectedProductCategory.id.toInt(),
                                  configs: _newConfigsEditText.text,
                                  panelLink: _newPaneLinkEditText.text,
                                  subscriptionLink:
                                      _newSubscriptionLinkEditText.text);

                              if (res) {
                                setState(() {
                                  productChangedToken = "productCardChanged";
                                });

                                setState(() {
                                  _newPaneLinkEditText.text = "";
                                  _newConfigsEditText.text = "";
                                  _newSubscriptionLinkEditText.text = "";
                                });
                                _showdata = true;

                                if (context.mounted) {
                                  showMsg(
                                    context: context,
                                    msg: "افزوده شد.",
                                  );
                                  productNotifier.changedProductData();

                                  Navigator.pop(context);
                                }
                              }
                            } else {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: const Text(
                            "افزودن",
                            style: TextStyle(color: Colors.red),
                          )),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("لغو")),
                    ],
                  ),
                ],
              ),
            )));
  }

  _operationInfoCard(BuildContext context) {
    List<Widget> actionsWidgetList = [];

    setState(() {
      if (widget.selectedProductCategory.pannel!.type == "custome") {
        actionsWidgetList.add(ElevatedButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyle.defaultPadding * 1.5,
              vertical: AppStyle.defaultPadding /
                  (Responsive.isMobile(context) ? 2 : 1),
            ),
          ),
          onPressed: () async {
            await _openAddNewProductDialog(context: context);
          },
          icon: const Icon(Icons.add),
          label: const Text("کانفیگ جدید"),
        ));
      }
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductDetailsScreen(
                  selectedProductCategory: widget.selectedProductCategory,
                ),
              )).whenComplete(() => _fillData());
        },
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش بسته"),
      ));
      if (_lastUserBoughtWidgetList.isEmpty) {
        actionsWidgetList.add(ElevatedButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyle.defaultPadding * 1.5,
              vertical: AppStyle.defaultPadding /
                  (Responsive.isMobile(context) ? 2 : 1),
            ),
          ),
          onPressed: () async {
            _showDeleteDialog(context);
          },
          icon: const Icon(
            Icons.delete_forever,
            color: Colors.red,
          ),
          label: const Text("حذف بسته"),
        ));
      }
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

  _summaryCountInfoCard(BuildContext context) {
    List<Widget> widgetList = [];

    setState(() {
      // final every = selledSummaryCount.keys.any((element) => false);
      for (var element in selledSummaryCount.entries) {
        widgetList.add(DetailsInfoItemWidget(
            item: DetailsInfoItem(
          itemName: element.key,
          itemValue: "${element.value} عدد",
          icon: const Icon(Icons.sell, color: Colors.purple),
        )));
      }
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
            "میزان فروش بسته",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3.2,
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

    setState(() {
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نام بسته",
        itemValue: widget.selectedProductCategory.categoryName.length > 30
            ? "${widget.selectedProductCategory.categoryName.substring(0, 30)}..."
            : widget.selectedProductCategory.categoryName,
        icon: const Icon(Icons.info),
      )));
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "مدت زمان بسته",
        itemValue: widget.selectedProductCategory.expireDay.toString().length >
                30
            ? "${widget.selectedProductCategory.expireDay.toString().substring(0, 30)}..."
            : "${widget.selectedProductCategory.expireDay} روز",
        icon: const Icon(Icons.date_range),
      )));
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "حجم بسته",
        itemValue: "${widget.selectedProductCategory.volume} گیگا بایت",
        icon: const Icon(Icons.info),
      )));
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "قیمت بسته",
        itemValue:
            "${thousandSeperatorFormatter(widget.selectedProductCategory.price.toString())} تومان",
        icon: const Icon(Icons.price_change),
      )));

      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نوع پنل",
        itemValue: widget.selectedProductCategory.pannel!.type.length > 30
            ? "${getPannelName(name: widget.selectedProductCategory.pannel!.type).substring(0, 30)}..."
            : getPannelName(name: widget.selectedProductCategory.pannel!.type),
        icon: const Icon(Icons.info),
      )));
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "وضعیت بسته",
        itemValue:
            widget.selectedProductCategory.isActive ? "فعال" : "غیر فعال",
        icon: widget.selectedProductCategory.isActive
            ? const Icon(Icons.code)
            : const Icon(Icons.code_off),
      )));
    });
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "اطلاعات بسته",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3.2,
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
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "آخرین خریداران بسته",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
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
    setState(() {
      _productDetailsInfoItemList.clear();
      for (var i in productDetailsList) {
        _productDetailsInfoItemList.add(ConfigDetailsInfoItemWidget(
          item: i,
          isActive: true,
        ));
      }
    });
    final Size size = MediaQuery.of(context).size;

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
            "کانفیگ‌های موجود",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder(
                valueListenable: productNotifier,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  if (value == "productCardChanged") {
                    _retryActiveConfigCardData(context);
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
    // return a dialog to confirm delete action
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("حذف بسته"),
          content: const Text("از حذف بسته اطمینان دارید؟"),
          actions: <Widget>[
            TextButton(
              child: const Text("خیر"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: const Text("بله"),
                onPressed: () async {
                  EasyLoading.show();
                  await deleteProductCategoryByID(
                    id: widget.selectedProductCategory.id,
                  ).then((value) {
                    if (!context.mounted) return;
                    if (value) {
                      showMsg(msg: "با موفقیت انجام شد", context: context);
                      Provider.of<ProductCategoryProvider>(context,
                              listen: false)
                          .setChanged(true);

                      EasyLoading.dismiss();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    } else {
                      showMsg(msg: "خطا", context: context);
                      EasyLoading.dismiss();
                    }
                  });
                }),
          ],
        );
      },
    );
  }

  _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProductDetailsScreen(
                        selectedProductCategory: widget.selectedProductCategory,
                      ),
                    )).whenComplete(() => _fillData());
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.secondaryColor),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "ویرایش بسته",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                if (_lastUserBoughtWidgetList.isEmpty) {
                  _showDeleteDialog(context);
                } else {
                  showMsg(
                      msg: "این بسته داری خریدار می باشد و قابل حذف نمی باشد",
                      context: context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.secondaryColor),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "حذف بسته",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
