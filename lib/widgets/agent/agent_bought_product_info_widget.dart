import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persian_datetimepickers/persian_datetimepickers.dart';
import 'package:powerps/provider/user_provider.dart';
import 'package:powerps/repositories/bot_user_repository.dart';
import 'package:powerps/screens/admin_screen/user/bot_user_bougth_product_details.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/bought_product_details_model.dart';
import 'package:powerps/models/hiffify_config_model.dart';
import 'package:powerps/provider/agent/agent_provider.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentBoughtProductInfoWidget extends StatefulWidget {
  final BoughtProductDetailsModel boughtProductDetailsModel;
  final String userRole;
  const AgentBoughtProductInfoWidget(
      {super.key,
      required this.boughtProductDetailsModel,
      this.userRole = "user"});

  @override
  State<AgentBoughtProductInfoWidget> createState() =>
      _AgentBoughtProductInfoWidgetState();
}

class _AgentBoughtProductInfoWidgetState
    extends State<AgentBoughtProductInfoWidget> {
  late HiddifyConfig? _hiddifyConfig;
  bool _showdata = false;
  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _showdata = false;
    _hiddifyConfig = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        EasyLoading.show();
        if (widget.userRole == "agent") {
          await getBoughtProductsStatusFromServerById(
                  productID: widget.boughtProductDetailsModel.id.toInt())
              .then((value) {
            if (!context.mounted) return;
            if (value != false) {
              EasyLoading.dismiss();

              _showDialog(context, value);
            } else {
              EasyLoading.dismiss();

              showMsg(
                  msg: "خطا در دریافت اطلاعات",
                  context: context,
                  type: "error");
            }
          });
        } else {
          await getProductBoughtedByProductIdUserMode(
                  productID: widget.boughtProductDetailsModel.id.toInt())
              .then((value) {
            if (!context.mounted) return;
            if (value != false) {
              EasyLoading.dismiss();

              _showDialog(context, value);
            } else {
              EasyLoading.dismiss();

              showMsg(
                  msg: "خطا در دریافت اطلاعات",
                  context: context,
                  type: "error");
            }
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: Row(
          children: [
            if (_showdata == false)
              Icon(Icons.code, color: AppStyle.primaryColor),
            if (_showdata)
              SizedBox(
                height: 20,
                width: 20,
                child: _hiddifyConfig!.isActive
                    ? Icon(Icons.code, color: AppStyle.primaryColor)
                    : const Icon(Icons.code_off, color: Colors.red),
              ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.boughtProductDetailsModel.remark!.length > 30
                              ? "${widget.boughtProductDetailsModel.remark!.substring(25)}..."
                              : widget.boughtProductDetailsModel.remark!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_showdata)
                          Text(
                            "${_hiddifyConfig!.currentUsageGB.toStringAsFixed(2)} / ${_hiddifyConfig!.usageLimitGB.toStringAsFixed(2)} GB",
                            maxLines: 1,
                            textDirection: TextDirection.ltr,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.white70),
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.boughtProductDetailsModel.productCategory!
                              .categoryName
                              .toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                        Text(
                          "${widget.boughtProductDetailsModel.productCategory!.expireDay} روزه",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                        Text(
                          "${widget.boughtProductDetailsModel.productCategory!.volume} گیگابایت",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, HiddifyConfig hiddifyConfig) async {
    // show a dialog with a input box
    return await showDialog(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Column(
                children: [
                  Text(widget.boughtProductDetailsModel.remark!),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      hiddifyConfig.lastOnline.toString() !=
                              "0001-01-01 00:00:00"
                          ? Text(
                              "آخرین زمان اتصال: ${_getLastOnlineDiffrence(hiddifyConfig)}",
                              style: AppStyle.thirdTitleStyle,
                            )
                          : Container(),
                      SizedBox(width: AppStyle.defaultPadding),
                      Text(
                          "حجم مصرفی: ${hiddifyConfig.currentUsageGB.toStringAsFixed(2)}GB",
                          style: AppStyle.thirdTitleStyle),
                      SizedBox(width: AppStyle.defaultPadding),
                      Text("زمان باقیمانده: ${_getRemindDate(hiddifyConfig)}",
                          style: AppStyle.thirdTitleStyle),
                      SizedBox(width: AppStyle.defaultPadding),
                      Text(
                          "وضعیت: ${hiddifyConfig.isActive == true ? "فعال" : "غیر فعال"}",
                          style: AppStyle.thirdTitleStyle)
                    ],
                  ),
                ],
              ),
              // content: TextField(
              //   decoration: const InputDecoration(
              //       hintText: 'نام بسته (می تواند نام مشتری باشد)'),
              //   onChanged: (value) {
              //     remark = value;
              //   },
              // ),
              actions: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              EasyLoading.show();
                              if (widget.userRole == "agent") {
                                await reChargeProductByAgentWithPrID(
                                  productID: widget.boughtProductDetailsModel.id
                                      .toInt(),
                                ).then((val) {
                                  if (!context.mounted) return;
                                  if (val == true) {
                                    // open val as a link in a new window
                                    showMsg(
                                        msg:
                                            "شارژ مجدد بسته با موفقیت انجام گرفت",
                                        context: context);
                                    EasyLoading.dismiss();
                                    Navigator.of(context).pop();
                                  } else if (val
                                      .toString()
                                      .contains("Reached")) {
                                    Navigator.of(context).pop();

                                    EasyLoading.dismiss();
                                    showMsg(
                                        msg: "$val",
                                        context: context,
                                        type: "error");
                                  } else {
                                    Navigator.of(context).pop();

                                    EasyLoading.dismiss();
                                    showMsg(
                                        msg: "خطا",
                                        context: context,
                                        type: "error");
                                  }
                                }).then((val) {
                                  if (val == true) {}
                                  // لیست خریدها را آپدیت کن
                                }).whenComplete(() {
                                  if (!context.mounted) return;
                                  Provider.of<AgentProvider>(context,
                                          listen: false)
                                      .setChanged(true);
                                });
                              } else {
                                await reChargeProductByUserWithPrID(
                                  productID: widget.boughtProductDetailsModel.id
                                      .toInt(),
                                ).then((val) {
                                  if (!context.mounted) return;
                                  if (val == true) {
                                    // open val as a link in a new window
                                    showMsg(
                                        msg:
                                            "شارژ مجدد بسته با موفقیت انجام گرفت",
                                        context: context);
                                    EasyLoading.dismiss();
                                    Navigator.of(context).pop();
                                  } else if (val
                                      .toString()
                                      .contains("Reached")) {
                                    Navigator.of(context).pop();

                                    EasyLoading.dismiss();
                                    showMsg(
                                        msg: "$val",
                                        context: context,
                                        type: "error");
                                  } else {
                                    Navigator.of(context).pop();

                                    EasyLoading.dismiss();
                                    showMsg(
                                        msg: "خطا",
                                        context: context,
                                        type: "error");
                                  }
                                }).then((val) {
                                  if (val == true) {}
                                  // لیست خریدها را آپدیت کن
                                }).whenComplete(() {
                                  if (!context.mounted) return;
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .setChanged(true);
                                });
                              }
                            },
                            child: const Text('شارژ مجدد')),
                        if (widget.userRole == "agent")
                          ElevatedButton(
                              onPressed: () async {
                                _showChangeProductsDialog(context);
                              },
                              child: const Text('تغییر بسته')),
                        ElevatedButton(
                            onPressed: () async {
                              EasyLoading.show();
                              await getBoughtProductsPannelLinkFromServerById(
                                      productID: widget
                                          .boughtProductDetailsModel.id
                                          .toInt())
                                  .then((link) {
                                if (!context.mounted) return;
                                if (link != false && link != null) {
                                  launchUrl(Uri.parse(link));
                                  EasyLoading.dismiss();
                                  // Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pop();

                                  EasyLoading.dismiss();
                                  showMsg(
                                      msg: "خطا",
                                      context: context,
                                      type: "error");
                                }
                              });
                            },
                            child: const Text('مشاهده در پنل')),

                        // ElevatedButton(
                        //     onPressed: () {
                        //       Navigator.of(context).pop();
                        //     },
                        //     child: const Text('غیر فعال کردن بسته')),
                      ],
                    ),
                    SizedBox(
                      height: AppStyle.defaultPadding,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              EasyLoading.show();

                              await changeActivationOfHiddifyUserByAgent(
                                      enable: !hiddifyConfig.isActive,
                                      productID: widget
                                          .boughtProductDetailsModel.id
                                          .toInt())
                                  .then((res) {
                                if (!context.mounted) return;
                                EasyLoading.dismiss();

                                if (res.runtimeType == bool) {
                                  if (res == true) {
                                    showMsg(msg: "انجام شد", context: context);
                                    Navigator.of(context).pop();
                                    Provider.of<AgentProvider>(context,
                                            listen: false)
                                        .setChanged(true);
                                  } else {
                                    showMsg(
                                        msg: "خطا",
                                        context: context,
                                        type: "error");
                                    Navigator.of(context).pop();
                                  }
                                } else {
                                  showMsg(
                                      msg: "$res",
                                      context: context,
                                      type: "error");
                                  Navigator.of(context).pop();
                                }
                              }).whenComplete(() {
                                _fillData();
                              });
                            },
                            child: const Text('تغییر وضعیت بسته')),
                        ElevatedButton(
                            onPressed: () async {
                              EasyLoading.show();
                              if (widget.userRole == "agent") {
                                await softDeleteProductByAgentWithPrID(
                                  productID: widget.boughtProductDetailsModel.id
                                      .toInt(),
                                ).then((val) {
                                  if (!context.mounted) return;
                                  if (val != false && val != null) {
                                    // open val as a link in a new window
                                    showMsg(msg: "حذف گردید", context: context);
                                    EasyLoading.dismiss();

                                    Navigator.of(context).pop();
                                  } else {
                                    Navigator.of(context).pop();

                                    EasyLoading.dismiss();
                                    showMsg(
                                        msg: "خطا",
                                        context: context,
                                        type: "error");
                                  }
                                }).then((val) {
                                  if (!context.mounted) return;
                                  // لیست خریدها را آپدیت کن
                                }).whenComplete(() {
                                  if (!context.mounted) return;
                                  Provider.of<AgentProvider>(context,
                                          listen: false)
                                      .setChanged(true);
                                });
                              } else {
                                await softDeleteProductByUserWithPrID(
                                  productID: widget.boughtProductDetailsModel.id
                                      .toInt(),
                                ).then((val) {
                                  if (!context.mounted) return;
                                  if (val != false && val != null) {
                                    // open val as a link in a new window
                                    showMsg(msg: "حذف گردید", context: context);
                                    EasyLoading.dismiss();

                                    Navigator.of(context).pop();
                                  } else {
                                    Navigator.of(context).pop();

                                    EasyLoading.dismiss();
                                    showMsg(
                                        msg: "خطا",
                                        context: context,
                                        type: "error");
                                  }
                                }).then((val) {
                                  // لیست خریدها را آپدیت کن
                                }).whenComplete(() {
                                  if (!context.mounted) return;
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .setChanged(true);
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('حذف')),
                        ElevatedButton(
                            onPressed: () {
                              _fillData();

                              Navigator.of(context).pop();
                            },
                            child: const Text('بستن'))
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }).then((value) {
      setState(() {});
    });
  }

  _getLastOnlineDiffrence(HiddifyConfig hiddifyConfig) {
    var diff = DateTime.now()
        .difference(DateTime.parse(hiddifyConfig.lastOnline!))
        .abs();
    if (diff.inSeconds < 60) {
      return "هم اکنون";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} دقیقه پیش";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} ساعت پیش";
    } else {
      return DateTime.parse(hiddifyConfig.lastOnline!).toPersianDate();
    }
  }

  void _fillData() async {
    setState(() {
      _showdata = false;
      _hiddifyConfig = null;
    });
    await getBoughtProductsStatusFromServerById(
            productID: widget.boughtProductDetailsModel.id.toInt())
        .then((value) {
      if (value != null && value != false) {
        setState(() {
          _hiddifyConfig = value;
          _showdata = true;
        });
      }
    }).onError((e, s) {
      debugPrint(e.toString());
    });
  }

  void _showChangeProductsDialog(BuildContext context) {
    EasyLoading.show();
    List<String> productCategoryItemList = [];

    for (var i in Provider.of<AgentProvider>(context, listen: false)
        .agentDashboard
        .agentProducts!) {
      if (i.productCategories!.pannelId ==
          widget.boughtProductDetailsModel.productCategory!.pannelId) {
        productCategoryItemList.add(
            "${i.productCategoriesId} - ${i.productCategories!.categoryName} - ${i.price} تومان");
      }
    }
    EasyLoading.dismiss();

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => ChangeCurrentProductToNewOne(
              productList: productCategoryItemList,
              currentProdoctId: widget.boughtProductDetailsModel.id.toInt(),
              actionType: "agent",
            ));
  }
}

_getRemindDate(HiddifyConfig hiddifyConfig) {
  try {
    if (hiddifyConfig.startDate != null || hiddifyConfig.startDate != "null") {
      DateTime expireDate = DateTime.parse(hiddifyConfig.startDate!)
          .add(Duration(days: hiddifyConfig.packageDays));

      var diff = DateTime.now().difference(expireDate).abs();
      if (diff.inDays < 1) {
        return "آخرین روز";
      } else {
        return "${diff.inDays} روز دیگر";
      }
    } else {
      return "${hiddifyConfig.packageDays} روز دیگر";
    }
  } catch (e) {
    return "${hiddifyConfig.packageDays} روز دیگر";
  }
}
