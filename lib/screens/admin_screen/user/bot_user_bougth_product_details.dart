import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persian_datetimepickers/persian_datetimepickers.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/models/details_info.dart';
import 'package:powerps/models/hiffify_config_model.dart';
import 'package:powerps/models/marzban_config_model.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/provider/prodct_provider.dart';
import 'package:powerps/repositories/bot_user_repository.dart';
import 'package:powerps/repositories/marzban_repository.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/details_info_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:url_launcher/url_launcher.dart';

class BotUserBoughtProductDetailsScreen extends StatefulWidget {
  const BotUserBoughtProductDetailsScreen(
      {super.key, required this.productDetails, required this.callback});
  final ProductDetails productDetails;
  final MyCallback callback;

  @override
  State<BotUserBoughtProductDetailsScreen> createState() =>
      _BotUserBoughtProductDetailsScreenState();
}

class _BotUserBoughtProductDetailsScreenState
    extends State<BotUserBoughtProductDetailsScreen> {
  bool _showdata = false;
  Pannel? _pannel;
  HiddifyConfig? _hiddifyInfo;
  MarzbanConfig? _marzbanConfig;
  String? _url;
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
            title: widget.productDetails.productCategory?.categoryName ??
                " محصول خریداری شده"),
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
                                if (_pannel!.type == "hiddify")
                                  _hiddifyConfigCardData(context),
                                if (_pannel!.type == "marzban")
                                  _marzbanConfigCardData(context),
                                SizedBox(height: AppStyle.defaultPadding),
                                if (Responsive.isMobile(context))
                                  SizedBox(height: AppStyle.defaultPadding),
                                if (Responsive.isMobile(
                                    context)) // side bar mobile
                                  Column(
                                    children: [
                                      SizedBox(height: AppStyle.defaultPadding),
                                      // _summaryCountInfoCard(context),
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
                                  // _operationInfoCard(context),
                                  SizedBox(height: AppStyle.defaultPadding),
                                ],
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _fillData() async {
    try {
      await getPannelById(
              pannelId: widget.productDetails.productCategory!.pannelId.toInt())
          .then((value) async {
        if (value != null) {
          setState(() {
            _pannel = value;
          });
          if (_pannel!.type == "hiddify") {
            await getProductBoughtedByProductId(
                    productID: widget.productDetails.id.toInt())
                .then((value) {
              if (value != null && value != false) {
                setState(() {
                  _hiddifyInfo = value;
                });
              } else {
                if (!mounted) return;

                Navigator.pop(context);
                showMsg(
                    msg:
                        "خطا در دریافت اطلاعات از سرور هیدیفای، آیا این اکانت را بصورت دستی از پنل حذف کردید؟",
                    context: context,
                    type: "error");
              }
            });
            setState(() {
              _showdata = true;
            });
          } else if (_pannel!.type == "marzban") {
            _url = getMarzbanConfigApiUrl(adminUrl: _pannel!.urlPort!);

            await getMarzbanUserInfo(
                    url: _url!,
                    admin: _pannel!.username,
                    password: _pannel!.password,
                    username: widget.productDetails.remark)
                .then((value) {
              setState(() {
                _marzbanConfig = value;
              });
            });
            setState(() {
              _showdata = true;
            });
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        Navigator.pop(context);
        showMsg(context: context, msg: e.toString());
      }
    }
  }

  _productInfoTabCard(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    List<Widget> factoryWidgetList = [];

    setState(() {
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نام بسته",
        itemValue: widget.productDetails.productCategory!.categoryName.length >
                30
            ? "${widget.productDetails.productCategory!.categoryName.substring(0, 30)}..."
            : widget.productDetails.productCategory!.categoryName,
        icon: const Icon(Icons.info),
      )));
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "مدت زمان بسته",
        itemValue: widget.productDetails.productCategory!.expireDay
                    .toString()
                    .length >
                30
            ? "${widget.productDetails.productCategory!.expireDay.toString().substring(0, 30)}..."
            : "${widget.productDetails.productCategory!.expireDay} روز",
        icon: const Icon(Icons.date_range),
      )));
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "حجم بسته",
        itemValue: "${widget.productDetails.productCategory!.volume} گیگا بایت",
        icon: const Icon(Icons.info),
      )));
      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "قیمت بسته",
        itemValue:
            "${thousandSeperatorFormatter(widget.productDetails.productCategory!.price.toString())} تومان",
        icon: const Icon(Icons.price_change),
      )));

      factoryWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نوع پنل",
        itemValue: _pannel!.type.length > 30
            ? "${getPannelName(name: _pannel!.type).substring(0, 30)}..."
            : getPannelName(name: _pannel!.type),
        icon: const Icon(Icons.info),
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
                  childAspectRatio: 2.9,
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

  _hiddifyConfigCardData(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    List<Widget> pannelWidgetList = [];
    List<Widget> actionWidgetList = [];
    setState(() {
      pannelWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نام",
        itemValue: _hiddifyInfo!.name.length > 30
            ? "${_hiddifyInfo!.name.substring(0, 30)}..."
            : _hiddifyInfo!.name,
        icon: const Icon(Icons.info),
      )));
      pannelWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "میزان حجم استفاده شده",
        itemValue: _hiddifyInfo!.currentUsageGB.toString().length > 30
            ? "${_hiddifyInfo!.currentUsageGB.toString().substring(0, 30)}..."
            : "${_hiddifyInfo!.currentUsageGB.toStringAsFixed(2)} GB",
        icon: const Icon(Icons.data_usage),
      )));
      pannelWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "آخرین زمان استفاده شده",
        itemValue: _hiddifyInfo!.lastOnline!.contains("1-01-01")
            ? "استفاده نشده"
            : DateTime.parse(_hiddifyInfo!.lastOnline!).toPersianDate(),
        icon: const Icon(Icons.date_range),
      )));
      pannelWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "وضعیت بسته",
        itemValue: _hiddifyInfo!.isActive ? "فعال" : "غیر فعال",
        icon: _hiddifyInfo!.isActive
            ? const Icon(Icons.code)
            : const Icon(Icons.code_off),
      )));
      actionWidgetList.add(ElevatedButton.icon(
          onPressed: () async {
            EasyLoading.show();
            await getBoughtProductsPannelLinkFromServerByIdAdminMode(
                    productID: widget.productDetails.id.toInt())
                .then((link) {
              if (link != false && link != null) {
                launchUrl(Uri.parse(link));
                EasyLoading.dismiss();
                // Navigator.of(context).pop();
              } else {
                if (!context.mounted) return;

                EasyLoading.dismiss();
                showMsg(msg: "خطا", context: context, type: "error");
              }
            });
          },
          icon: const Icon(Icons.info),
          label: const Text("مشاهده در پنل")));
      actionWidgetList.add(ElevatedButton.icon(
          onPressed: () async {
            EasyLoading.show();
            await reChargeProductByAdminWithPrID(
                    productID: widget.productDetails.id.toInt())
                .then((value) {
              if (!context.mounted) return;

              if (value) {
                EasyLoading.dismiss();
                showMsg(msg: "با موفقیت انجام شد", context: context);
                Provider.of<ProductProvider>(context, listen: false)
                    .setChanged(true);
              } else {
                EasyLoading.dismiss();
                showMsg(msg: "خطا", context: context, type: "error");
              }
            });
          },
          icon: const Icon(Icons.update),
          label: const Text("ریست کردن بسته")));
      actionWidgetList.add(ElevatedButton.icon(
          onPressed: () async {
            _showDeleteDialog(context: context);
          },
          icon: const Icon(Icons.delete_forever, color: Colors.red),
          label: const Text("حذف بسته", style: TextStyle(color: Colors.red))));
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
            "وضعیت بسته خریداری شده",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: pannelWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 6,
                  importedList: pannelWidgetList),
              desktop: widgetsGridview(
                  importedList: pannelWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 4 : 5.5,
                  crossAxisCount: 2),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: actionWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 6,
                  importedList: actionWidgetList),
              desktop: widgetsGridview(
                  importedList: actionWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 4 : 5.5,
                  crossAxisCount: 4),
            ),
          ),
        ],
      ),
    );
  }

  _marzbanConfigCardData(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    List<Widget> pannelWidgetList = [];
    List<Widget> actionWidgetList = [];
    setState(() {
      pannelWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نام",
        itemValue: _marzbanConfig!.username!.length > 30
            ? "${_marzbanConfig!.username!.substring(0, 30)}..."
            : _marzbanConfig!.username!,
        icon: const Icon(Icons.info),
      )));
      pannelWidgetList.add(DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "میزان حجم استفاده شده",
        itemValue: "${(_marzbanConfig!.usedTraffic) / 1024} GB",
        icon: const Icon(Icons.data_usage),
      )));
      // pannelWidgetList.add(DetailsInfoItemWidget(
      //     item: DetailsInfoItem(
      //   itemName: "آخرین زمان استفاده شده",
      //   itemValue: _marzbanConfig!.onlineAt!.contains("1-01-01")
      //       ? "استفاده نشده"
      //       : DateTime.parse(_marzbanConfig!.onlineAt!).toPersianDate(),
      //   icon: const Icon(Icons.date_range),
      // )));
      actionWidgetList.add(ElevatedButton.icon(
          onPressed: () async {
            await resetMarzbanUser(
                    url: _url!,
                    admin: _pannel!.username,
                    password: _pannel!.password,
                    username: widget.productDetails.remark)
                .then((value) {
              if (!context.mounted) return;

              if (value) {
                showMsg(msg: "با موفقیت انجام شد", context: context);
              } else {
                showMsg(msg: "خطا", context: context, type: "error");
              }
            });
          },
          icon: const Icon(Icons.update),
          label: const Text("ریست کردن بسته")));
      actionWidgetList.add(ElevatedButton.icon(
          onPressed: () async {
            _showDeleteDialog(context: context);
            // await deleteMarzbanUser(
            //         url: _url!,
            //         admin: _pannel!.username,
            //         password: _pannel!.password,
            //         username: widget.productDetails.remark,
            //         productID: widget.productDetails.id.toInt())
            //     .then((value) {
            //   if (value) {
            //     showMsg(msg: "با موفقیت انجام شد", context: context);
            //     Navigator.pop(context);
            //   } else {
            //     showMsg(msg: "خطا", context: context, type: "error");
            //   }
            // });
          },
          icon: const Icon(Icons.delete_forever, color: Colors.red),
          label: const Text("حذف بسته", style: TextStyle(color: Colors.red))));
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
            "وضعیت بسته خریداری شده",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: pannelWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 6,
                  importedList: pannelWidgetList),
              desktop: widgetsGridview(
                  importedList: pannelWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 4 : 5.5,
                  crossAxisCount: 2),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: actionWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 6,
                  importedList: actionWidgetList),
              desktop: widgetsGridview(
                  importedList: actionWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 4 : 5.5,
                  crossAxisCount: 4),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text("حذف بسته"),
              content: const Text("از حذف بسته اطمینان دارید؟"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("انصراف")),
                TextButton(
                    child: const Text("تایید"),
                    onPressed: () async {
                      EasyLoading.show();

                      if (_pannel!.type == "marzban") {
                        await deleteMarzbanUser(
                                url: _url!,
                                admin: _pannel!.username,
                                password: _pannel!.password,
                                username: widget.productDetails.remark,
                                productID: widget.productDetails.id.toInt())
                            .then((value) {
                          if (value) {
                            if (!context.mounted) return;

                            showMsg(
                                msg: "با موفقیت انجام شد", context: context);
                            EasyLoading.dismiss();
                            Provider.of<ProductProvider>(context, listen: false)
                                .setChanged(true);

                            Navigator.pop(context);
                          } else {
                            EasyLoading.dismiss();
                            if (!context.mounted) return;

                            showMsg(
                                msg: "خطا", context: context, type: "error");
                          }
                        });
                      } else if (_pannel!.type == "hiddify") {
                        await softDeleteProductByAgentWithPrIDAdminMOde(
                                productID: widget.productDetails.id.toInt())
                            .then((value) {
                          if (!context.mounted) return;

                          if (value) {
                            EasyLoading.dismiss();

                            showMsg(
                                msg: "با موفقیت انجام شد", context: context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          } else {
                            EasyLoading.dismiss();

                            showMsg(
                                msg: "خطا", context: context, type: "error");
                            Navigator.pop(context);
                          }
                        });
                      }
                    })
              ]);
        });
  }
}
