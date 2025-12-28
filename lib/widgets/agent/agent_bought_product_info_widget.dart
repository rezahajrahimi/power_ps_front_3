import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  late dynamic _config;
  bool _showdata = false;
  @override
  void initState() {
    _config = null;
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _showdata = false;
    _config = null;
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
                child: _config!.isActive
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
                            "${_config!.currentUsageGB.toStringAsFixed(2)} / ${_config!.usageLimitGB.toStringAsFixed(2)} GB",
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

  void _showDialog(BuildContext context, dynamic config) async {
    // show a dialog with a input box
    return await showDialog(
        context: context,
        builder: (dialogContext) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Column(
                children: [
                  Text(widget.boughtProductDetailsModel.remark!),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (config is HiddifyConfig)
                        config.lastOnline.toString() != "0001-01-01 00:00:00"
                            ? Text(
                                "آخرین زمان اتصال: ${_getLastOnlineDiffrence(config)}",
                                style: AppStyle.thirdTitleStyle,
                              )
                            : Container(),
                      SizedBox(width: AppStyle.defaultPadding),
                      Text(
                          "حجم مصرفی: ${config.currentUsageGB.toStringAsFixed(2)}GB",
                          style: AppStyle.thirdTitleStyle),
                      SizedBox(width: AppStyle.defaultPadding),
                      Text("زمان باقیمانده: ${_getRemindDate(config)}",
                          style: AppStyle.thirdTitleStyle),
                      SizedBox(width: AppStyle.defaultPadding),
                      Text(
                          "وضعیت: ${config.isActive == true ? "فعال" : "غیر فعال"}",
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
                                  if (!dialogContext.mounted) return;
                                  if (val == true) {
                                    // open val as a link in a new window
                                    showMsg(
                                        msg:
                                            "شارژ مجدد بسته با موفقیت انجام گرفت",
                                        context: context);
                                    EasyLoading.dismiss();
                                    Navigator.of(dialogContext).pop();
                                  } else if (val
                                      .toString()
                                      .contains("Reached")) {
                                    Navigator.of(dialogContext).pop();

                                    EasyLoading.dismiss();
                                    showMsg(
                                        msg: "$val",
                                        context: context,
                                        type: "error");
                                  } else {
                                    Navigator.of(dialogContext).pop();

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
                                  if (!dialogContext.mounted) return;
                                  if (val == true) {
                                    // open val as a link in a new window
                                    showMsg(
                                        msg:
                                            "شارژ مجدد بسته با موفقیت انجام گرفت",
                                        context: context);
                                    EasyLoading.dismiss();
                                    Navigator.of(dialogContext).pop();
                                  } else if (val
                                      .toString()
                                      .contains("Reached")) {
                                    Navigator.of(dialogContext).pop();

                                    EasyLoading.dismiss();
                                    showMsg(
                                        msg: "$val",
                                        context: context,
                                        type: "error");
                                  } else {
                                    Navigator.of(dialogContext).pop();

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
                              _showRenameDialog(context);
                            },
                            child: const Text('تغییر نام')),
                        ElevatedButton(
                            onPressed: () async {
                              EasyLoading.show();
                              await getBoughtProductsPannelLinkFromServerById(
                                      productID: widget
                                          .boughtProductDetailsModel.id
                                          .toInt())
                                  .then((link) {
                                if (!dialogContext.mounted) return;
                                if (link != false && link != null) {
                                  if (widget.boughtProductDetailsModel
                                              .productCategory?.pannel?.type ==
                                          "sanaei" ||
                                      link.startsWith("vless://") ||
                                      link.startsWith("vmess://") ||
                                      link.startsWith("trojan://")) {
                                    EasyLoading.dismiss();
                                    _showConfigDialog(context, link);
                                  } else {
                                    launchUrl(Uri.parse(link));
                                    EasyLoading.dismiss();
                                  }
                                  // Navigator.of(dialogContext).pop();
                                } else {
                                  Navigator.of(dialogContext).pop();

                                  EasyLoading.dismiss();
                                  showMsg(
                                      msg: "خطا",
                                      context: context,
                                      type: "error");
                                }
                              });
                            },
                            child: widget.boughtProductDetailsModel
                                        .productCategory?.pannel?.type ==
                                    "sanaei"
                                ? Text('مشاهده در پنل')
                                : Text('مشاهده کانفیگ')),

                        // ElevatedButton(
                        //     onPressed: () {
                        //       Navigator.of(dialogContext).pop();
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
                                      enable: !config.isActive,
                                      productID: widget
                                          .boughtProductDetailsModel.id
                                          .toInt())
                                  .then((res) {
                                if (!dialogContext.mounted) return;
                                EasyLoading.dismiss();

                                if (res.runtimeType == bool) {
                                  if (res == true) {
                                    showMsg(msg: "انجام شد", context: context);
                                    Navigator.of(dialogContext).pop();
                                    Provider.of<AgentProvider>(context,
                                            listen: false)
                                        .setChanged(true);
                                  } else {
                                    showMsg(
                                        msg: "خطا",
                                        context: context,
                                        type: "error");
                                    Navigator.of(dialogContext).pop();
                                  }
                                } else {
                                  showMsg(
                                      msg: "$res",
                                      context: context,
                                      type: "error");
                                  Navigator.of(dialogContext).pop();
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
                                  if (!dialogContext.mounted) return;
                                  if (val != false && val != null) {
                                    // open val as a link in a new window
                                    showMsg(msg: "حذف گردید", context: context);
                                    EasyLoading.dismiss();

                                    Navigator.of(dialogContext).pop();
                                  } else {
                                    Navigator.of(dialogContext).pop();

                                    EasyLoading.dismiss();
                                    showMsg(
                                        msg: "خطا",
                                        context: context,
                                        type: "error");
                                  }
                                }).then((val) {
                                  if (!dialogContext.mounted) return;
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
                                  if (!dialogContext.mounted) return;
                                  if (val != false && val != null) {
                                    // open val as a link in a new window
                                    showMsg(msg: "حذف گردید", context: context);
                                    EasyLoading.dismiss();

                                    Navigator.of(dialogContext).pop();
                                  } else {
                                    Navigator.of(dialogContext).pop();

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

                              Navigator.of(dialogContext).pop();
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

  _getLastOnlineDiffrence(dynamic config) {
    var diff =
        DateTime.now().difference(DateTime.parse(config.lastOnline!)).abs();
    if (diff.inSeconds < 60) {
      return "هم اکنون";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} دقیقه پیش";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} ساعت پیش";
    } else {
      return DateTime.parse(config.lastOnline!).toPersianDate();
    }
  }

  void _fillData() async {
    setState(() {
      _showdata = false;
      _config = null;
    });
    await getBoughtProductsStatusFromServerById(
            productID: widget.boughtProductDetailsModel.id.toInt())
        .then((value) {
      if (value != null && value != false) {
        setState(() {
          _config = value;
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

  void _showRenameDialog(BuildContext context) {
    String newName = widget.boughtProductDetailsModel.remark ?? "";
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text("تغییر نام بسته"),
          content: TextField(
            decoration: const InputDecoration(
              hintText: "نام جدید را وارد کنید",
              labelText: "نام بسته",
            ),
            controller: TextEditingController(text: newName),
            onChanged: (value) => newName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("انصراف"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newName.isEmpty) return;
                EasyLoading.show();
                await renameHiddifyRemark(
                  productID: widget.boughtProductDetailsModel.id.toInt(),
                  remark: newName,
                ).then((res) {
                  if (!context.mounted) return;
                  EasyLoading.dismiss();
                  if (res == true) {
                    showMsg(msg: "نام با موفقیت تغییر کرد", context: context);
                    Navigator.pop(context); // Close rename dialog
                    Navigator.pop(context); // Close info dialog
                    _fillData();
                    if (widget.userRole == "agent") {
                      Provider.of<AgentProvider>(context, listen: false)
                          .setChanged(true);
                    } else {
                      Provider.of<UserProvider>(context, listen: false)
                          .setChanged(true);
                    }
                  } else {
                    showMsg(msg: "خطا در تغییر نام", context: context);
                  }
                });
              },
              child: const Text("تغییر نام"),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfigDialog(BuildContext context, String config) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('کانفیگ خریداری شده'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QrImageView(
                    data: config,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  SelectableText(
                    config,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: config));
                showMsg(msg: "کپی شد", context: context, type: "info");
              },
              child: const Text('کپی'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('بستن'),
            ),
          ],
        ),
      ),
    );
  }
}

_getRemindDate(dynamic config) {
  try {
    if (config.startDate != null &&
        config.startDate != "null" &&
        config.startDate != "") {
      DateTime expireDate = DateTime.parse(config.startDate!)
          .add(Duration(days: config.packageDays));

      var diff = expireDate.difference(DateTime.now());
      if (diff.inDays < 1) {
        if (diff.inHours > 0) {
          return "${diff.inHours} ساعت دیگر";
        }
        return "منقضی شده";
      } else {
        return "${diff.inDays} روز دیگر";
      }
    } else {
      return "${config.packageDays} روز دیگر";
    }
  } catch (e) {
    return "${config.packageDays} روز دیگر";
  }
}
