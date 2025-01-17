import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
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
  final List<Widget> _productCatWidgetLIst = [];
  List<ProductCategory> _productCategoryList = [];
  final List<String> _pannelNameList = [];
  String _selectedPannelName = "";
  final _nameEditText = TextEditingController();
  final _priceEditText = TextEditingController();
  final _priceInDollarEditText = TextEditingController();
  final _expireDayEditText = TextEditingController();
  final _volumeEditText = TextEditingController();

  bool _rechargable = true;
  bool _showSubscriptionLink = true;
  bool _showPannelLink = true;
  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _nameEditText.dispose();
    _priceEditText.dispose();
    _priceInDollarEditText.dispose();
    _expireDayEditText.dispose();
    _volumeEditText.dispose();
    _selectedPannelName = "";
    _pannelNameList.clear();
    _productCatWidgetLIst.clear();
    _productCategoryList.clear();
    _showData = false;
    _rechargable = true;
    _showSubscriptionLink = true;
    _showPannelLink = true;
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of<ProductCategoryProvider>(context, listen: false);
    // // _fillData();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            child: Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: Column(
                children: [
                  // const Header(title: "کانفیگ ها"),
                  // SizedBox(height: AppStyle.defaultPadding),
                  _showData == false
                      ? const SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: CircularProgressIndicator()))
                      : _content(context),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : const Opacity(opacity: 1),
      ),
    );
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void _fillData() async {
    if (mounted) {
      // Provider.of<ProductCategoryProvider>(context, listen: false)
      //     .setChanged(false);
      // debugPrint("ccccccccccccccccc");
      await getAllProdctCategory().then((res) {
        if (res != null && res != false) {
          setStateIfMounted(() {
            _showData = false;
            _productCategoryList = res;
            _productCatWidgetLIst.clear();
            for (var i in _productCategoryList) {
              _productCatWidgetLIst.add(ProductCategoryInfoItemCardWidget(
                onTap: () {
                  _fillData();
                },
                item: ProductCategory(
                    categoryName: i.categoryName,
                    pannelId: i.pannelId,
                    expireDay: i.expireDay,
                    priceInDollar: i.priceInDollar,
                    id: i.id,
                    price: i.price,
                    volume: i.volume,
                    pannel: i.pannel,
                    rechargable: i.rechargable,
                    showPannelLink: i.showPannelLink,
                    isActive: i.isActive,
                    showSubscriptionLink: i.showSubscriptionLink),
              ));
            }
            _showData = true;
          });
        }
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        if (mounted) {
          setStateIfMounted(() {
            _showData = false;
          });
          showMsg(msg: "خطا", context: context, type: "error");
        }
      }).whenComplete(() async {
        await getPannels().then((resPannel) {
          if (mounted) {
            if (resPannel != false && resPannel != null) {
              setStateIfMounted(() {
                _pannelNameList.clear();
                for (var i in resPannel) {
                  _pannelNameList.add(
                      "${i.id}: ${getPannelName(name: i.type)} - ${i.location}");
                }
                _selectedPannelName =
                    "${resPannel[0].id}: ${getPannelName(name: resPannel[0].type)} - ${resPannel[0].location}";
              });
            }
          }
        });
      });
    }
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
                _openAddNewProductCategoryDialog(context: context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.secondaryColor),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "کانفیگ جدید",
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

  _content(BuildContext context) {
    // Provider.of<ProductCategoryProvider>(context, listen: false);

    // _fillData();

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
                ],
              ),
            ),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            // On Mobile means if the screen is less than 850 we dont want to show it
            if (!Responsive.isMobile(context)) // side windows
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _operationInfoCard(context),
                  ],
                ),
              ),
          ],
        )
      ],
    );
  }

  _productInfoTabCard(BuildContext context) {
    // if (changed) {
    //   _fillData();
    // }

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
            "کانفیگ ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
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

  _openAddNewProductCategoryDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                scrollable: true,
                contentPadding: EdgeInsets.zero,
                title: const Text("بسته جدید"),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    child: Column(
                      children: [
                        const Text("نام بسته جدید را وارد کنید."),
                        TextFormField(
                          controller: _nameEditText,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration:
                              const InputDecoration(labelText: "نام بسته جدید"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text("قیمت بسته جدید را به تومان وارد کنید."),
                        TextFormField(
                          controller: _priceEditText,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "قیمت بسته جدید"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: _priceInDollarEditText,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "قیمت دلاری بسته جدید"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text("مدت زمان اعتبار (روز) بسته را وارد کنید."),
                        TextFormField(
                          controller: _expireDayEditText,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "مدت زمان اعتبار (روز)"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text("حجم بسته را به گیگابایت وارد کنید"),
                        TextFormField(
                          controller: _volumeEditText,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "حجم بسته (گیگابایت)"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text("پنل را انتخاب کنید"),
                        DropdownButtonFormField(
                          isExpanded: true,
                          hint: const Text('پنل'),
                          value: _selectedPannelName,
                          alignment: Alignment.centerRight,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedPannelName = newValue.toString();
                            });
                          },
                          items: _pannelNameList.map((clType) {
                            return DropdownMenuItem(
                              value: clType,
                              alignment: Alignment.centerRight,
                              child: Text(clType),
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SwitchListTile(
                          value: _selectedPannelName.contains("Hiddify") != true
                              ? _showSubscriptionLink
                              : true,
                          onChanged:
                              _selectedPannelName.contains("Hiddify") != true
                                  ? (bool value) {
                                      setState(() {
                                        _showSubscriptionLink = value;
                                      });
                                    }
                                  : null,
                          title: const Text("نمایش لینک سابسکریپشن به کاربر"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SwitchListTile(
                          value: _showPannelLink,
                          onChanged: (bool value) {
                            setState(() {
                              _showPannelLink = value;
                            });
                          },
                          title: const Text("نمایش لینک پنل به کاربر"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SwitchListTile(
                          value: _selectedPannelName.contains("دیگر") != true
                              ? _rechargable
                              : false,
                          onChanged:
                              _selectedPannelName.contains("دیگر") != true
                                  ? (bool value) {
                                      setState(() {
                                        _rechargable = value;
                                      });
                                    }
                                  : null,
                          title: const Text("قابلیت شارژ مجدد توسط ربات"),
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
                            await _submitData(context);
                          },
                          child: const Text(
                            "افزودن",
                          )),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("لغو")),
                    ],
                  ),
                ],
              );
            })));
  }

  _submitData(BuildContext context) async {
    EasyLoading.show();
    int pannelID = 1;
    if (_selectedPannelName != "") {
      pannelID = int.parse(_selectedPannelName.split(":")[0]);
    }
    if (_nameEditText.text.isNotEmpty &&
        _priceEditText.text.isNotEmpty &&
        _expireDayEditText.text.isNotEmpty &&
        _volumeEditText.text.isNotEmpty) {
      var res = await addNewProductCategory(
        name: _nameEditText.text,
        price: int.parse(_priceEditText.text),
        priceInDollar: double.parse(_priceInDollarEditText.text),
        pannelID: pannelID,
        expDay: int.parse(_expireDayEditText.text),
        volume: int.parse(_volumeEditText.text),
        rechargable: _rechargable,
        showPannelLink: _showPannelLink,
        showSubscriptionLink: _showSubscriptionLink,
      );
      if (res) {
        if (context.mounted) {
          showMsg(msg: "افزوده شد.", context: context);
          Navigator.pop(context);
        }
        _fillData();
      } else {
        if (context.mounted) {
          showMsg(msg: "خطا", context: context, type: "error");
        }
      }
    } else {
      showMsg(msg: "اطلاعات درخواست شده را وارد کنید.", context: context);
    }
    EasyLoading.dismiss();
  }
}
