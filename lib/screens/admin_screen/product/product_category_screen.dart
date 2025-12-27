import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/screens/admin_screen/product/fast_edit_product_categories_screen.dart';
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

  // String _selectedCategoryType = "";
  // List<CategoryTypeModel> _fetchedCategoryType = [];
  final _nameEditText = TextEditingController();
  final _priceEditText = TextEditingController();
  final _priceInDollarEditText = TextEditingController();
  final _expireDayEditText = TextEditingController();
  final _volumeEditText = TextEditingController();

  bool _rechargable = true;
  bool _showSubscriptionLink = true;
  bool _showPannelLink = true;
  // create a form key
  final _formKey = GlobalKey<FormState>();

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
    // _categoryTypeListName.clear();
    // _selectedCategoryType = "";
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
                    _content(context),
                  ],
                ),
              )),
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
    // await getAllCategoryType().then((resCategoryType) {
    //   setStateIfMounted(() {
    //     if (resCategoryType.isNotEmpty) {
    //       setStateIfMounted(() {
    //         _fetchedCategoryType = resCategoryType;
    //         _categoryTypeListName.clear();
    //         for (var i in resCategoryType) {
    //           _categoryTypeListName.add(i.name);
    //         }
    //         _selectedCategoryType = resCategoryType[0].name;
    //       });
    //     }
    //   });
    // });
    if (mounted) {
      await getAllProdctCategory().then((res) {
        if (res != null && res != false) {
          setStateIfMounted(() {
            _showData = false;
            _productCategoryList = res;
            _productCatWidgetLIst.clear();
            _selectedPanelIDFiltered.clear();
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

              // check if i.pannelId is now in _selectedPanelNameFiltered, add to _selectedPanelNameFiltered
              if (_selectedPanelIDFiltered.contains(i.pannelId.toString())) {
                _selectedPanelIDFiltered.add(i.pannelId.toString());
              }
            }
          });
        }
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        if (mounted) {
          showMsg(msg: "خطا", context: context, type: "error");
        }
      }).whenComplete(() async {
        await getPannels().then((resPannel) {
          setStateIfMounted(() {
            if (resPannel != false &&
                resPannel != null &&
                resPannel.isNotEmpty) {
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
            setStateIfMounted(() {
              _showData = true;
              _showFilters = true;
            });
          });
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
          Flexible(
            flex: 1,
            child: ElevatedButton(
              onPressed: () async {
                _pannelNameList.isNotEmpty
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FastEditProductCategoriesScreen(
                                  productCategoryList: _productCategoryList,
                                )))
                    : showMsg(
                        msg:
                            "هیچ پنلی ثبت نشده است، ابتدا می بایست به بخش تنظیمات پنل بروید و یک پنل ثبت کنید.",
                        context: context,
                        type: "error");
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
                      "ویرایش سریع",
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
                  _showData == true
                      ? _productInfoTabCard(context)
                      : const Center(child: CircularProgressIndicator()),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "کانفیگ ها",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: () {
                  _fillData();
                },
              ),
            ],
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
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width > 600 ? 550.0 : screenSize.width * 0.9;

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: screenSize.height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'بسته جدید',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'نام بسته جدید را وارد کنید.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 4.0),
                          TextFormField(
                            controller: _nameEditText,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            maxLines: null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'لطفا نام بسته را وارد کنید';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'نام بسته جدید',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'قیمت بسته جدید را به تومان وارد کنید.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 4.0),
                          TextFormField(
                            controller: _priceEditText,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            maxLines: null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'لطفا قیمت بسته را وارد کنید';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'قیمت بسته جدید',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              prefixIcon: const Icon(Icons.attach_money_rounded,
                                  size: 20),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'قیمت دلاری بسته جدید را وارد کنید.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 4.0),
                          TextFormField(
                            controller: _priceInDollarEditText,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            maxLines: null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'لطفا قیمت دلاری بسته را وارد کنید';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'قیمت دلاری بسته جدید',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              prefixText: '\$ ',
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'مدت زمان اعتبار (روز) بسته را وارد کنید.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 4.0),
                          TextFormField(
                            controller: _expireDayEditText,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            maxLines: null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'لطفا مدت زمان اعتبار را وارد کنید';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'مدت زمان اعتبار (روز)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              suffixIcon:
                                  const Icon(Icons.calendar_today, size: 20),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'حجم بسته را به گیگابایت وارد کنید',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 4.0),
                          TextFormField(
                            controller: _volumeEditText,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            maxLines: null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'لطفا حجم بسته را وارد کنید';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'حجم بسته (گیگابایت)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              suffixText: 'GB',
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'نوع دسته را انتخاب کنید',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          // const SizedBox(height: 4.0),
                          // DropdownButtonFormField(
                          //   isExpanded: true,
                          //   hint: const Text('نوع دسته'),
                          //   initialValue: _selectedCategoryType,
                          //   alignment: Alignment.centerRight,
                          //   decoration: InputDecoration(
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(8.0),
                          //     ),
                          //     contentPadding: const EdgeInsets.symmetric(
                          //       horizontal: 12.0,
                          //       vertical: 8.0,
                          //     ),
                          //   ),
                          //   onChanged: (newValue) {
                          //     setState(() {
                          //       _selectedCategoryType = newValue.toString();
                          //     });
                          //   },
                          //   items: _categoryTypeListName.map((clType) {
                          //     return DropdownMenuItem(
                          //       value: clType,
                          //       alignment: Alignment.centerRight,
                          //       child: Text(clType),
                          //     );
                          //   }).toList(),
                          // ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'پنل را انتخاب کنید',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 4.0),
                          DropdownButtonFormField(
                            isExpanded: true,
                            hint: const Text('پنل'),
                            initialValue: _selectedPannelName,
                            alignment: Alignment.centerRight,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                            ),
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
                          const SizedBox(height: 16.0),
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text(
                                        'نمایش لینک سابسکریپشن به کاربر'),
                                    value: _selectedPannelName
                                                .contains("Hiddify") !=
                                            true
                                        ? _showSubscriptionLink
                                        : true,
                                    onChanged: _selectedPannelName
                                                .contains("Hiddify") !=
                                            true
                                        ? (bool value) {
                                            setState(() {
                                              _showSubscriptionLink = value;
                                            });
                                          }
                                        : null,
                                  ),
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title:
                                        const Text('نمایش لینک پنل به کاربر'),
                                    value: _showPannelLink,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _showPannelLink = value;
                                      });
                                    },
                                  ),
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text(
                                        'قابلیت شارژ مجدد توسط ربات'),
                                    value:
                                        _selectedPannelName.contains("دیگر") !=
                                                true
                                            ? _rechargable
                                            : false,
                                    onChanged:
                                        _selectedPannelName.contains("دیگر") !=
                                                true
                                            ? (bool value) {
                                                setState(() {
                                                  _rechargable = value;
                                                });
                                              }
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    side: BorderSide(color: theme.primaryColor),
                                  ),
                                  child: const Text('انصراف'),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      EasyLoading.show();

                                      await _submitData(context);
                                      _formKey.currentState!.save();
                                      _nameEditText.clear();
                                      _priceEditText.clear();
                                      _priceInDollarEditText.clear();
                                      _expireDayEditText.clear();
                                      _volumeEditText.clear();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text('افزودن'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  _submitData(BuildContext context) async {
    EasyLoading.show();
    int pannelID = 1;
    if (_selectedPannelName != "") {
      pannelID = int.parse(_selectedPannelName.split(":")[0]);
    }

    await addNewProductCategory(
      name: _nameEditText.text,
      price: int.parse(_priceEditText.text),
      priceInDollar: double.parse(_priceInDollarEditText.text),
      pannelID: pannelID,
      // categoryTypeId: _fetchedCategoryType
      //     .firstWhere((element) => element.name == _selectedCategoryType)
      //     .id,
      expDay: int.parse(_expireDayEditText.text),
      volume: int.parse(_volumeEditText.text),
      rechargable: _rechargable,
      showPannelLink: _showPannelLink,
      showSubscriptionLink: _showSubscriptionLink,
    ).then((val) {
      if (val) {
        if (context.mounted) {
          showMsg(msg: "افزوده شد.", context: context);
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          showMsg(msg: "خطا", context: context, type: "error");
        }
      }
    }).whenComplete(() {
      EasyLoading.dismiss();
      _fillData();
    }).catchError((onError) {
      EasyLoading.dismiss();
      if (context.mounted) {
        showMsg(msg: "خطا", context: context, type: "error");
      }
    });
  }

  _panelNameFilters(BuildContext context) {
    List<Widget> list = [];
    for (var panelName in _pannelNameList) {
      int pannelID = int.parse(panelName.split(":")[0]);
      list.add(SizedBox(
        child: CheckboxListTile(
          value: _selectedPanelIDFiltered.contains(pannelID),
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
              }
              _showData = true;
            });
          },
          title: Text(panelName),
        ),
      ));
    }
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
            "پنل‌ها",
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
                  importedList: list),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 1,
                  importedList: list),
              desktop: widgetsGridview(
                  importedList: list,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 1),
            ),
          ),
        ],
      ),
    );
  }
}
