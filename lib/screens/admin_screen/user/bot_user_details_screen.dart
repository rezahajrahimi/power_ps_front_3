import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/repositories/blocked_user_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/repositories/product_details_repository.dart';
import 'package:powerps/repositories/referral_setting_repository.dart';
import 'package:powerps/widgets/product_details/user_bougth_products_info_card_widget.dart';
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
  bool _showBoughtProduct = false;
  int _lastPageOfUserBought = 1;
  int selectedPageOfUserBought = 1;

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
      if (!mounted) return;
      showMsg(msg: "خطا", context: context, type: "error");
      Navigator.of(context).pop();
    });
    await getUserProductsHistoryByAccountIDWithPagination(
            userID: widget.id.toInt())
        .then((value) {
      if (!mounted) return;
      if (value != false && value != null) {
        setState(() {
          _lastPageOfUserBought = lastPageOfUserBought;

          _showBoughtProduct = true;
        });
      } else {
        showMsg(msg: "خطا", context: context, type: "error");
        debugPrint("error on dashboard biding $value");
      }
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  _content(BuildContext context) {
    bool changed = context.watch<ProductProvider>().changed;
    if (changed) {
      _fillData();
    }
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
                      _referralBallanceInfoCard(context),
                    if (Responsive.isMobile(context))
                      SizedBox(height: AppStyle.defaultPadding),
                    _showBoughtProduct
                        ? _productInfoItemCard(context)
                        : Container(),
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
                    SizedBox(height: AppStyle.defaultPadding),
                    _referralBallanceInfoCard(context),
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
     actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          if(_botUser!.blockedUser != null){
            await unblockUser(widget.id.toString());
          }else{
            final reasonController = TextEditingController();
            String? reason = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('دلیل بلاک'),
                  content: TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      hintText: 'دلیل بلاک',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                          Navigator.of(context).pop(reasonController.text);
                      },
                      child: Text('تایید'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('انصراف'),
                    ),

                  ],
                );
              },
            );
            if (reason != null) {
              EasyLoading.show(status: "در حال بلاکی کردن کاربر");
              await blockUser(_botUser!.accountId.toString(), reason).then((value) {
                if (value) {
                  EasyLoading.dismiss();
                }else{
                  EasyLoading.dismiss();
                  if (!context.mounted) return;
                  showMsg(msg: "خطا", context: context, type: "error");
                }
              }).onError((e, s) {
                if (!context.mounted) return;
                EasyLoading.dismiss();
                showMsg(msg: "خطا", context: context, type: "error");
              });
            }
          }
        },
        icon: _botUser!.blockedUser != null? const Icon(Icons.block): const Icon(Icons.block_flipped),
        label:_botUser!.blockedUser != null? const Text("Unblock"): const Text("Block"),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "مشخصات کاربر",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                  onPressed: () {
                    _fillData();
                  },
                  icon: const Icon(Icons.refresh))
            ],
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
    return Column(
      children: [
        UserBougthProductsInfoCardWidget(
          title: "کانفیگ‌های خریداری شده",
          products: userBoughtProductList,
        ),
        SizedBox(height: AppStyle.defaultPadding),
        Pagination(
          numOfPages: _lastPageOfUserBought,
          selectedPage: selectedPageOfUserBought,
          pagesVisible: 4,
          onPageChanged: (page) async {
            setState(() {
              selectedPageOfUserBought = page;
              _showBoughtProduct = false;
            });
            await getUserProductsHistoryByAccountIDWithPagination(
                page: page, userID: widget.id.toInt());

            setStateIfMounted(() {
              _lastPageOfUserBought = lastPageOfUserBought;

              _showBoughtProduct = true;
            });
          },
          nextIcon: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
            size: 14,
          ),
          previousIcon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
            size: 14,
          ),
          activeTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          activeBtnStyle: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.blue),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(38),
              ),
            ),
          ),
          inactiveBtnStyle: ButtonStyle(
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(38),
            )),
          ),
          inactiveTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (Responsive.isMobile(context))
          SizedBox(height: AppStyle.defaultPadding),
        if (Responsive.isMobile(context)) // side bar mobile
          Column(
            children: [
              SizedBox(height: AppStyle.defaultPadding),
            ],
          ),
      ],
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
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          await _incAccuntBallanceDialog(context, type: "toman");
        },
        icon: const Icon(FontAwesomeIcons.plus),
        label: const Text("افزایش موجودی تومان"),
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
          await _decAccuntBallanceDialog(context, type: "toman");
        },
        icon: const Icon(FontAwesomeIcons.minus),
        label: const Text("کاهش موجودی تومان"),
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
          await _incAccuntBallanceDialog(context, type: "dollar");
        },
        icon: const Icon(FontAwesomeIcons.plus),
        label: const Text("افزایش موجودی دلاری"),
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
          await _decAccuntBallanceDialog(context, type: "dollar");
        },
        icon: const Icon(FontAwesomeIcons.minus),
        label: const Text("کاهش موجودی دلاری"),
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

  _referralBallanceInfoCard(BuildContext context) {
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
          await _editReferralBallanceDialog(context);
        },
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش موجودی کیف پول همکاری"),
      ));

      // actionsWidgetList.add(ElevatedButton.icon(
      //   style: TextButton.styleFrom(
      //     padding: EdgeInsets.symmetric(
      //       horizontal: AppStyle.defaultPadding * 1.5,
      //       vertical: AppStyle.defaultPadding /
      //           (Responsive.isMobile(context) ? 2 : 1),
      //     ),
      //   ),
      //   onPressed: () async {
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) => ReferralReportScreen(
      //                   accountId: _botUser!.accountId,
      //                 )));
      //   },
      //   icon: const Icon(Icons.report),
      //   label: const Text("گزارش کیف پول همکاری"),
      // ));
      mainWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        icon: const Icon(Icons.wallet),
        itemName: "موجودی کیف پول همکاری",
        itemValue: _botUser!.referralWallet != null
            ? "${thousandSeperatorFormatter(_botUser!.referralWallet!.amount.toString())} تومان "
            : "0 تومان",
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
            "کیف پول همکاری",
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
                    EasyLoading.show();
                    await setNewAccountBallance(
                            ballance: int.parse(_ballanceController.text),
                            userID: _botUser!.accountId.toInt())
                        .then((value) {
                      if (!context.mounted) return;
                      if (value) {
                        setState(() {
                          _botUser!.ballance!.ballance =
                              BigInt.from(int.parse(_ballanceController.text));
                        });
                        EasyLoading.dismiss();
                        showMsg(
                            context: context,
                            msg: "موجودی با موفقیت ویرایش شد");
                        _ballanceController.clear();

                        Navigator.pop(context);
                        _fillData();
                      } else {
                        EasyLoading.dismiss();
                        showMsg(context: context, msg: "خطا", type: "error");
                      }
                    });
                  },
                  child: const Text("تایید"),
                )
              ],
            ))));
  }

  _editReferralBallanceDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
                child: AlertDialog(
              title: const Text("ویرایش موجودی کیف پول همکاری"),
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
                    EasyLoading.show();
                    await setNewReferralBallance(
                            ballance: int.parse(_ballanceController.text),
                            userID: _botUser!.accountId.toInt())
                        .then((value) {
                      if (!context.mounted) return;
                      if (value) {
                        setState(() {
                          _botUser!.ballance!.ballance =
                              BigInt.from(int.parse(_ballanceController.text));
                        });
                        EasyLoading.dismiss();
                        showMsg(
                            context: context,
                            msg: "موجودی با موفقیت ویرایش شد");
                        Navigator.pop(context);
                        _ballanceController.clear();
                        _fillData();
                      } else {
                        EasyLoading.dismiss();
                        showMsg(context: context, msg: "خطا", type: "error");
                      }
                    });
                  },
                  child: const Text("تایید"),
                )
              ],
            ))));
  }

  _incAccuntBallanceDialog(BuildContext context, {required String type}) async {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
                child: AlertDialog(
              title: const Text("افزایش موجودی کیف پول"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("لطفا مقدار مورد نظر خود را وارد کنید"),
                  SizedBox(height: AppStyle.defaultPadding),
                  CustomTextFromFieldWidget(
                    controller: _ballanceController,
                    textHint: "مقدار مورد نظر",
                    validationError: "مقدار مورد نظر را وارد کنید",
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
                    EasyLoading.show();
                    await increaseUserAccuntBalanceByUserID(
                            ballance: double.parse(_ballanceController.text),
                            userID: _botUser!.id.toInt(),
                            type: type)
                        .then((value) {
                      if (!context.mounted) return;
                      if (value.toString() != "false") {
                        setState(() {
                          if (type == "toman") {
                            _botUser!.ballance!.ballance =
                                BigInt.from(int.parse(value));
                          } else {
                            _botUser!.ballance!.accountBallanceIndollar =
                                double.parse(value);
                          }
                        });
                        EasyLoading.dismiss();
                        showMsg(
                            context: context,
                            msg: "موجودی با موفقیت ویرایش شد");
                        _ballanceController.clear();

                        Navigator.pop(context);
                        _fillData();
                      } else {
                        EasyLoading.dismiss();
                        showMsg(context: context, msg: "خطا", type: "error");
                      }
                    });
                  },
                  child: const Text("تایید"),
                )
              ],
            ))));
  }

  _decAccuntBallanceDialog(BuildContext context, {required String type}) async {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
                child: AlertDialog(
              title: const Text("کاهش موجودی کیف پول"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("لطفا مقدار مورد نظر خود را وارد کنید"),
                  SizedBox(height: AppStyle.defaultPadding),
                  CustomTextFromFieldWidget(
                    controller: _ballanceController,
                    textHint: "مقدار مورد نظر",
                    validationError: "مقدار مورد نظر را وارد کنید",
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
                    EasyLoading.show();
                    await decreaseUserAccuntBalanceByUserID(
                            ballance: double.parse(_ballanceController.text),
                            userID: _botUser!.id.toInt(),
                            type: type)
                        .then((value) {
                      if (!context.mounted) return;
                      if (value.toString() != "false") {
                        setState(() {
                          if (type == "toman") {
                            _botUser!.ballance!.ballance =
                                BigInt.from(int.parse(value));
                          } else {
                            _botUser!.ballance!.accountBallanceIndollar =
                                double.parse(value);
                          }
                        });
                        EasyLoading.dismiss();
                        showMsg(
                            context: context,
                            msg: "موجودی با موفقیت ویرایش شد");
                        _ballanceController.clear();

                        Navigator.pop(context);
                        _fillData();
                      } else {
                        EasyLoading.dismiss();
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
                    EasyLoading.show();
                    await setNewDollarAccountBallance(
                            ballance: double.parse(_ballanceController.text),
                            userID: _botUser!.accountId.toInt())
                        .then((value) {
                      if (!context.mounted) return;
                      if (value) {
                        setState(() {
                          _botUser!.ballance!.accountBallanceIndollar =
                              double.parse(_ballanceController.text);
                        });
                        EasyLoading.dismiss();
                        showMsg(
                            context: context,
                            msg: "موجودی با موفقیت ویرایش شد");
                        _ballanceController.clear();

                        Navigator.pop(context);
                        _fillData();
                      } else {
                        EasyLoading.dismiss();
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
      if (!context.mounted) return;
      EasyLoading.dismiss();

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
      if (!context.mounted) return;
      // setStateIfMounted(() {
      //   _showData = false;
      // });
      showMsg(msg: "خطا", context: context, type: "error");
    });
  }
}
