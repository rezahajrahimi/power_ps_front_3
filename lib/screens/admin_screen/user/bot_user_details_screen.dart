import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/models/details_info.dart';
import 'package:powerps/provider/prodct_provider.dart';
import 'package:powerps/repositories/account_ballance_repository.dart';
import 'package:powerps/repositories/bot_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/log/recent_events_list_widget.dart';
import 'package:powerps/widgets/product_details/config_details_with_category_info_item_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/details_info_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:powerps/widgets/transaction/transaction_info_item_widget.dart';

class BotUserDetailsScreen extends StatefulWidget {
  const BotUserDetailsScreen({super.key, required this.id});
  final BigInt id;
  @override
  State<BotUserDetailsScreen> createState() => _BotUserDetailsScreenState();
}

class _BotUserDetailsScreenState extends State<BotUserDetailsScreen> {
  BotUser? _botUser;
  bool _showData = false;
  final _ballanceController = TextEditingController();

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _showData = false;
    _ballanceController.dispose();
    _botUser = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(context: context, title: "اطلاعات کاربر"),
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _showData == false
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _content(context),
          ),
        ),
        // bottomNavigationBar: Responsive.isMobile(context)
        //     ? _buildBottomNavigationBar(context)
        //     : const Opacity(opacity: 1),
      ),
    );
  }

  void _fillData() async {
    await getBotUserByID(id: widget.id.toInt()).then((value) {
      if (value != null && value != false) {
        setStateIfMounted(() {
          _botUser = value;
          _showData = true;
        });
      }
    }).onError((e, s) {
      debugPrint(e.toString());
      if (!mounted) return;

      Navigator.of(context).pop();
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  _content(BuildContext context) {
    Provider.of<ProductProvider>(context, listen: false);
    _fillData();
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _mainInfoItemCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    if (Responsive.isMobile(context))
                      _accountBallanceInfoCard(context),
                    if (Responsive.isMobile(context))
                      SizedBox(height: AppStyle.defaultPadding),
                    _productInfoItemCard(context),
                    if (Responsive.isMobile(context))
                      SizedBox(height: AppStyle.defaultPadding),
                    if (Responsive.isMobile(context))
                      _operationInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    _transactionInfoItemCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    RecentEvents(type: "fullList", events: _botUser!.logs!),
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
                    _accountBallanceInfoCard(context),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  _operationInfoCard(BuildContext context) {
    List<Widget> actionsWidgetList = [];

    setStateIfMounted(() {
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          await _showAddNewProductDialog(context);
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text("خرید کانفیگ جدید"),
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

  _mainInfoItemCard(BuildContext context) {
    List<Widget> mainInfoWidgetList = [];
    setState(() {
      mainInfoWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
              icon: const Icon(Icons.info),
              itemName: "Account Id",
              itemValue: _botUser!.accountId.toString())));
      mainInfoWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
              icon: const Icon(Icons.info),
              itemName: "نام کاربری",
              itemValue: _botUser!.username.toString())));
      mainInfoWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
              icon: const Icon(Icons.info),
              itemName: "نام",
              itemValue: "${_botUser!.firstName} ${_botUser!.lastName}")));
      mainInfoWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
              icon: const Icon(Icons.info),
              itemName: "تاریخ عضویت",
              itemValue: _botUser!.createdAt)));
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
            "مشخصات کاربر",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: mainInfoWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: mainInfoWidgetList),
              desktop: widgetsGridview(
                  importedList: mainInfoWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _productInfoItemCard(BuildContext context) {
    List<Widget> mainInfoWidgetList = [];
    setState(() {
      for (var i in _botUser!.products!) {
        mainInfoWidgetList.add(ConfigDetailsWithCatInfoItemWidget(
          item: i,
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
            "کانفیگ های خریداری شده",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: mainInfoWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: mainInfoWidgetList),
              desktop: widgetsGridview(
                  importedList: mainInfoWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _transactionInfoItemCard(BuildContext context) {
    List<Widget> mainInfoWidgetList = [];
    if (_botUser!.transactions != null) {
      setState(() {
        for (var i in _botUser!.transactions!) {
          mainInfoWidgetList.add(TransactionInfoItemCardWidget(
            item: i,
          ));
        }
      });
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
            "تراکنش ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: mainInfoWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: mainInfoWidgetList),
              desktop: widgetsGridview(
                  importedList: mainInfoWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _accountBallanceInfoCard(BuildContext context) {
    List<Widget> mainWidgetList = [];
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
          await _editAccuntBallanceDialog(context);
        },
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش موجودی کیف"),
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
          await _editDollarAccuntBallanceDialog(context);
        },
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش موجودی دلاری کیف"),
      ));
      mainWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        icon: const Icon(Icons.wallet),
        itemName: "موجودی کیف پول",
        itemValue: _botUser!.ballance != null
            ? "${thousandSeperatorFormatter(_botUser!.ballance!.ballance.toString())} تومان "
            : "0 تومان",
      )));
      mainWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        icon: const Icon(Icons.wallet),
        itemName: "موجودی دلاری کیف پول",
        itemValue: _botUser!.ballance != null
            ? "${thousandSeperatorFormatter(_botUser!.ballance!.accountBallanceIndollar.toString())} دلار "
            : "0 دلار",
      )));
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
            "کیف پول کاربر",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  crossAxisCount: 1,
                  importedList: mainWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 1,
                  importedList: mainWidgetList),
              desktop: widgetsGridview(
                  importedList: mainWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 1),
            ),
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

  _editAccuntBallanceDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
                child: AlertDialog(
              title: const Text("ویرایش موجودی کیف پول"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("لطفا مبلغ مورد نظر خود را وارد کنید"),
                  SizedBox(height: AppStyle.defaultPadding),
                  CustomTextFromFieldWidget(
                    controller: _ballanceController,
                    textHint: "میزان موجودی",
                    validationError: "میزان موجودی را وارد کنید",
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("انصراف"),
                ),
                TextButton(
                  onPressed: () async {
                    await setNewAccountBallance(
                            ballance: int.parse(_ballanceController.text),
                            userID: _botUser!.accountId.toInt())
                        .then((value) {
                      if (value) {
                        if (!context.mounted) return;

                        setState(() {
                          _botUser!.ballance!.ballance =
                              BigInt.from(int.parse(_ballanceController.text));
                        });
                        showMsg(
                            context: context,
                            msg: "موجودی با موفقیت ویرایش شد");
                        Navigator.pop(context);
                        _fillData();
                      } else {
                        if (!context.mounted) return;

                        showMsg(context: context, msg: "خطا", type: "error");
                      }
                    });
                  },
                  child: const Text("تایید"),
                )
              ],
            ))));
  }

  _editDollarAccuntBallanceDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
                child: AlertDialog(
              title: const Text("ویرایش موجودی دلاری کیف پول"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("لطفا مبلغ مورد نظر خود را وارد کنید"),
                  SizedBox(height: AppStyle.defaultPadding),
                  CustomTextFromFieldWidget(
                    controller: _ballanceController,
                    textHint: "میزان موجودی",
                    validationError: "میزان موجودی را وارد کنید",
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("انصراف"),
                ),
                TextButton(
                  onPressed: () async {
                    await setNewDollarAccountBallance(
                            ballance: double.parse(_ballanceController.text),
                            userID: _botUser!.accountId.toInt())
                        .then((value) {
                      if (value) {
                        if (!context.mounted) return;

                        setState(() {
                          _botUser!.ballance!.accountBallanceIndollar =
                              double.parse(_ballanceController.text);
                        });
                        showMsg(
                            context: context,
                            msg: "موجودی با موفقیت ویرایش شد");
                        Navigator.pop(context);
                        _fillData();
                      } else {
                        if (!context.mounted) return;

                        showMsg(context: context, msg: "خطا", type: "error");
                      }
                    });
                  },
                  child: const Text("تایید"),
                )
              ],
            ))));
  }

  _showAddNewProductDialog(BuildContext context) async {
    EasyLoading.show();
    List<ProductCategory> productCategoryList = [];
    List<String> productCategoryItemList = [];
    String selectedItem = "";
    final nameEditText = TextEditingController();

    await getAllProdctCategory().then((res) {
      if (res != null && res != false) {
        productCategoryList = res;
        for (var i in productCategoryList) {
          productCategoryItemList.add("${i.id} - ${i.categoryName}");
        }
        selectedItem = productCategoryItemList[0];
      }
    }).whenComplete(() async {
      EasyLoading.dismiss();
      if (!context.mounted) return;

      showDialog(
          context: context,
          builder: (context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                scrollable: true,
                contentPadding: EdgeInsets.zero,
                title: const Text("کانفیگ جدید"),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    child: Column(
                      children: [
                        const Text("نام کانفیگ را وارد کنید."),
                        TextFormField(
                          controller: nameEditText,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "نام کانفیگ جدید"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text("کانفیگ را انتخاب کنید"),
                        DropdownButtonFormField(
                          isExpanded: true,
                          hint: const Text('کانفیگ'),
                          value: selectedItem,
                          alignment: Alignment.centerRight,
                          onChanged: (newValue) {
                            setState(() {
                              selectedItem = newValue.toString();
                            });
                          },
                          items: productCategoryItemList.map((clType) {
                            return DropdownMenuItem(
                              value: clType,
                              alignment: Alignment.centerRight,
                              child: Text(clType),
                            );
                          }).toList(),
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
                            EasyLoading.show();
                            int prcatID =
                                int.parse(selectedItem.split(" - ")[0]);
                            await buyProductByAdmin(
                              productID: prcatID,
                              remark: nameEditText.text,
                              username: _botUser!.username,
                              userID: _botUser!.id.toInt(),
                              accountId: _botUser!.accountId.toInt(),
                            ).then((val) {
                              if (!context.mounted) return;

                              if (val != null) {
                                EasyLoading.dismiss();
                                Navigator.pop(context);
                                showMsg(
                                    context: context,
                                    msg: "خرید با موفقیت انجام شد");
                                _fillData();
                              } else {
                                EasyLoading.dismiss();
                                showMsg(
                                    context: context,
                                    msg: "خطا",
                                    type: "error");
                              }
                            }).onError((error, stackTrace) {
                              if (!context.mounted) return;

                              EasyLoading.dismiss();
                              debugPrint(error.toString());
                              showMsg(
                                  context: context, msg: "خطا", type: "error");
                            });
                          },
                          child: const Text(
                            "خرید",
                          )),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("لغو")),
                    ],
                  ),
                ],
              )));
    }).onError((error, stackTrace) {
      EasyLoading.dismiss();
      debugPrint(error.toString());
      if (context.mounted) {
        // setStateIfMounted(() {
        //   _showData = false;
        // });
        showMsg(msg: "خطا", context: context, type: "error");
      }
    });
  }
}
