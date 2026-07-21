import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persian_datetimepickers/persian_datetimepickers.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/provider/agent/agent_provider.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
// import 'package:powerps/repositories/product_details_repository.dart';
// import 'package:powerps/widgets/product_details/add_reservation_dialog_widget.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/models/details_info.dart';
import 'package:powerps/models/hiffify_config_model.dart';
import 'package:powerps/models/marzban_config_model.dart';
import 'package:powerps/models/sanaei_config_model.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/provider/prodct_provider.dart';
import 'package:powerps/repositories/bot_user_repository.dart';
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
  // bool _hasReservetion = false;
  HiddifyConfig? _hiddifyInfo;
  MarzbanConfig? _marzbanConfig;
  SanaeiConfig? _sanaeiConfig;

  @override
  void initState() {
    super.initState();
    _fillData();
  }

  String? get _panelUsername {
    return resolveMarzbanUsernameFromProduct(
      configs: widget.productDetails.configs,
      remark: widget.productDetails.remark,
      panelLink: widget.productDetails.panelLink,
      subscriptionLink: widget.productDetails.subscriptionLink,
    );
  }

  bool get _isMarzbanUserActive {
    final status =
        _normalizeNullableText(_marzbanConfig?.status)?.toLowerCase();
    if (status == 'active') {
      return true;
    }
    if (status == 'disabled') {
      return false;
    }
    return widget.productDetails.isActive == true &&
        widget.productDetails.deactiveByAdmin != true;
  }

  String? _normalizeNullableText(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }

  String _formatTrafficUsage(int bytes) {
    return "${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB";
  }

  String _formatTrafficLimit(int bytes) {
    if (bytes <= 0) {
      return "نامحدود";
    }
    return _formatTrafficUsage(bytes);
  }

  String _formatPersianDateTimeFromString(
    String? value, {
    required String fallback,
  }) {
    final normalized = _normalizeNullableText(value);
    if (normalized == null ||
        normalized.contains('0001-01-01') ||
        normalized.contains('1-01-01')) {
      return fallback;
    }

    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) {
      return normalized;
    }

    final local = parsed.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return "${local.toPersianDate()} - $hour:$minute";
  }

  String _formatExpireDate(DateTime expire) {
    if (expire.millisecondsSinceEpoch <= 0 || expire.year <= 1970) {
      return "نامحدود";
    }
    final local = expire.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return "${local.toPersianDate()} - $hour:$minute";
  }

  String _getMarzbanStatusLabel(String? status) {
    switch (_normalizeNullableText(status)?.toLowerCase()) {
      case 'active':
        return 'فعال';
      case 'disabled':
        return 'غیرفعال';
      case 'limited':
        return 'محدود';
      case 'expired':
        return 'منقضی';
      case 'on_hold':
        return 'در انتظار';
      default:
        return 'نامشخص';
    }
  }

  Color _getMarzbanStatusColor(String? status) {
    switch (_normalizeNullableText(status)?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'disabled':
        return Colors.red;
      case 'limited':
        return Colors.orange;
      case 'expired':
        return Colors.deepOrange;
      case 'on_hold':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
              context: context,
              title: widget.productDetails.productCategory?.categoryName ??
                  " محصول خریداری شده"),
          body: _showdata == false
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "درحال دریافت اطلاعات...",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  primary: false,
                  padding: EdgeInsets.all(AppStyle.defaultPadding),
                  child: Column(
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
                                if (_pannel!.type == "sanaei")
                                  _sanaeiConfigCardData(context),
                                if (isMarzbanCompatiblePanel(_pannel!.type))
                                  _marzbanConfigCardData(context),
                                if (Responsive.isMobile(context)) ...[
                                  SizedBox(height: AppStyle.defaultPadding),
                                  _operationInfoCard(context),
                                ],
                              ],
                            ),
                          ),
                          if (!Responsive.isMobile(context)) ...[
                            SizedBox(width: AppStyle.defaultPadding),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _operationInfoCard(context),
                                ],
                              ),
                            ),
                          ],
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
              if (!mounted) return;

              if (value != null && value != false) {
                setState(() {
                  _hiddifyInfo = HiddifyConfig.fromJson(value);
                });
              } else {
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
          } else if (_pannel!.type == "sanaei") {
            await getProductBoughtedByProductId(
                    productID: widget.productDetails.id.toInt())
                .then((value) {
              if (!mounted) return;

              if (value != null && value != false) {
                setState(() {
                  _sanaeiConfig = SanaeiConfig.fromJson(value);
                });
              } else {
                Navigator.pop(context);
                showMsg(
                    msg:
                        "خطا در دریافت اطلاعات از سرور سنایی، آیا این اکانت را بصورت دستی از پنل حذف کردید؟",
                    context: context,
                    type: "error");
              }
            });
            setState(() {
              _showdata = true;
            });
          } else if (isMarzbanCompatiblePanel(_pannel!.type)) {
            await getProductBoughtedByProductId(
                    productID: widget.productDetails.id.toInt())
                .then((value) {
              if (!mounted) return;

              if (value != null && value != false) {
                try {
                  setState(() {
                    _marzbanConfig = MarzbanConfig.fromJson(
                      Map<String, dynamic>.from(value as Map),
                    );
                  });
                } catch (e) {
                  debugPrint('MarzbanConfig.fromJson: $e');
                  if (mounted) {
                    showMsg(
                        msg:
                            "خطا در پردازش اطلاعات پنل ${getMarzbanCompatiblePanelLabel(_pannel!.type)}.",
                        context: context,
                        type: "error");
                  }
                }
              } else if (mounted) {
                showMsg(
                    msg:
                        "خطا در دریافت اطلاعات از پنل ${getMarzbanCompatiblePanelLabel(_pannel!.type)}. آیا این اکانت را بصورت دستی از پنل حذف کردید؟",
                    context: context,
                    type: "error");
              }
            });
            setState(() {
              _showdata = true;
            });
          }
        }
      }).whenComplete(() async {
        setState(() {
          _showdata = true;
        });
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

    List<Widget> factoryWidgetList = [
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نام بسته",
        itemValue: widget.productDetails.productCategory!.categoryName.length >
                30
            ? "${widget.productDetails.productCategory!.categoryName.substring(0, 30)}..."
            : widget.productDetails.productCategory!.categoryName,
        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.blue),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "مدت زمان بسته",
        itemValue: "${widget.productDetails.productCategory!.expireDay} روز",
        icon: const Icon(Icons.timer_outlined, color: Colors.orange),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "حجم بسته",
        itemValue: "${widget.productDetails.productCategory!.volume} گیگا بایت",
        icon: const Icon(Icons.data_usage_outlined, color: Colors.green),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "قیمت بسته",
        itemValue:
            "${thousandSeperatorFormatter(widget.productDetails.productCategory!.price.toString())} تومان",
        icon: const Icon(Icons.payments_outlined, color: Colors.teal),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نوع پنل",
        itemValue: getPannelName(name: _pannel!.type),
        icon: const Icon(Icons.dns_outlined, color: Colors.purple),
      )),
    ];

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
              const Icon(Icons.info_outline, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                "اطلاعات بسته",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.8,
                  context: context,
                  importedList: factoryWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 5,
                  importedList: factoryWidgetList),
              desktop: widgetsGridview(
                  importedList: factoryWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 3.5 : 4.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _hiddifyConfigCardData(BuildContext context) {
    if (_hiddifyInfo == null) {
      return const SizedBox();
    }
    final Size size = MediaQuery.of(context).size;

    List<Widget> pannelWidgetList = [
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نام",
        itemValue: _hiddifyInfo!.name,
        icon: const Icon(Icons.person_outline, color: Colors.blue),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "میزان حجم استفاده شده",
        itemValue: "${_hiddifyInfo!.currentUsageGB.toStringAsFixed(2)} GB",
        icon: const Icon(Icons.data_usage_outlined, color: Colors.orange),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "آخرین زمان استفاده شده",
        itemValue: _hiddifyInfo!.lastOnline!.contains("1-01-01")
            ? "استفاده نشده"
            : DateTime.parse(_hiddifyInfo!.lastOnline!).toPersianDate(),
        icon: const Icon(Icons.history_outlined, color: Colors.green),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "وضعیت بسته",
        itemValue: _hiddifyInfo!.isActive ? "فعال" : "غیر فعال",
        icon: Icon(
          _hiddifyInfo!.isActive
              ? Icons.check_circle_outline
              : Icons.block_flipped,
          color: _hiddifyInfo!.isActive ? Colors.green : Colors.red,
        ),
      )),
    ];

    List<Widget> actionWidgetList = [
      _buildActionButton(
        context: context,
        label: "مشاهده در پنل",
        icon: Icons.open_in_new,
        onPressed: () async {
          EasyLoading.show();
          await getBoughtProductsPannelLinkFromServerByIdAdminMode(
                  productID: widget.productDetails.id.toInt())
              .then((link) {
            EasyLoading.dismiss();
            if (link != false && link != null) {
              launchUrl(Uri.parse(link));
            } else {
              if (!context.mounted) return;
              showMsg(
                  msg: "خطا در دریافت لینک", context: context, type: "error");
            }
          });
        },
      ),
      _buildActionButton(
        context: context,
        label: "ریست کردن بسته",
        icon: Icons.refresh,
        onPressed: () async {
          EasyLoading.show();
          await reChargeProductByAdminWithPrID(
                  productID: widget.productDetails.id.toInt())
              .then((value) {
            EasyLoading.dismiss();
            if (!context.mounted) return;
            if (value) {
              showMsg(msg: "با موفقیت انجام شد", context: context);
              Provider.of<ProductProvider>(context, listen: false)
                  .setChanged(true);
              _fillData();
            } else {
              showMsg(msg: "خطا در ریست کردن", context: context, type: "error");
            }
          });
        },
      ),
      _buildActionButton(
        context: context,
        label: _hiddifyInfo!.isActive ? "غیر فعال سازی" : "فعال سازی",
        icon: _hiddifyInfo!.isActive ? Icons.visibility_off : Icons.visibility,
        color: _hiddifyInfo!.isActive ? Colors.orange : Colors.green,
        onPressed: () async {
          EasyLoading.show();
          await changeActivationOfHiddifyUserByAdmin(
                  enable: !_hiddifyInfo!.isActive,
                  productID: widget.productDetails.id.toInt())
              .then((res) {
            EasyLoading.dismiss();
            if (!context.mounted) return;
            if (res) {
              showMsg(msg: "تغییر وضعیت با موفقیت انجام شد", context: context);
              _fillData();
            } else {
              showMsg(
                  msg: "خطا در تغییر وضعیت", context: context, type: "error");
            }
          });
        },
      ),
      _buildActionButton(
        context: context,
        label: "تغییر نام",
        icon: Icons.edit_outlined,
        onPressed: () => _showRenameDialog(context: context),
      ),
      _buildActionButton(
        context: context,
        label: "حذف بسته",
        icon: Icons.delete_forever,
        color: Colors.red,
        onPressed: () => _showDeleteDialog(context: context),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
              const Icon(Icons.settings_outlined, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                "وضعیت بسته خریداری شده (هیدیفای)",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.8,
                  context: context,
                  importedList: pannelWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 5,
                  importedList: pannelWidgetList),
              desktop: widgetsGridview(
                  importedList: pannelWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 3.5 : 4.5,
                  crossAxisCount: 2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "عملیات مدیریت",
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3.2,
                  context: context,
                  importedList: actionWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: actionWidgetList),
              desktop: widgetsGridview(
                  importedList: actionWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 3.5 : 4.5,
                  crossAxisCount: 4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color ?? Colors.white),
      label: Text(
        label,
        style: TextStyle(color: color ?? Colors.white, fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: (color ?? Colors.blue).withValues(alpha: 0.1),
        foregroundColor: color ?? Colors.white,
        side: BorderSide(color: (color ?? Colors.blue).withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  _sanaeiConfigCardData(BuildContext context) {
    if (_sanaeiConfig == null) {
      return const SizedBox();
    }
    final Size size = MediaQuery.of(context).size;

    List<Widget> pannelWidgetList = [
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "نام (ایمیل)",
        itemValue: _sanaeiConfig!.client?['email'] ?? "نامشخص",
        icon: const Icon(Icons.email_outlined, color: Colors.blue),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "میزان حجم استفاده شده",
        itemValue: "${_sanaeiConfig!.currentUsageGB.toStringAsFixed(2)} GB",
        icon: const Icon(Icons.data_usage_outlined, color: Colors.orange),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "حجم کل",
        itemValue: "${_sanaeiConfig!.usageLimitGB.toStringAsFixed(2)} GB",
        icon: const Icon(Icons.storage_outlined, color: Colors.green),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "تاریخ شروع",
        itemValue: _sanaeiConfig!.startDate == null ||
                _sanaeiConfig!.startDate!.isEmpty ||
                _sanaeiConfig!.startDate!.contains("1-01-01")
            ? "استفاده نشده"
            : DateTime.parse(_sanaeiConfig!.startDate!).toPersianDate(),
        icon: const Icon(Icons.calendar_today_outlined, color: Colors.purple),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "مدت زمان بسته",
        itemValue: "${_sanaeiConfig!.packageDays} روز",
        icon: const Icon(Icons.timer_outlined, color: Colors.blueGrey),
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        itemName: "وضعیت بسته",
        itemValue: _sanaeiConfig!.enable ? "فعال" : "غیر فعال",
        icon: Icon(
          _sanaeiConfig!.enable
              ? Icons.check_circle_outline
              : Icons.block_flipped,
          color: _sanaeiConfig!.enable ? Colors.green : Colors.red,
        ),
      )),
    ];

    List<Widget> actionWidgetList = [
      _buildActionButton(
        context: context,
        label: "مشاهده در پنل",
        icon: Icons.open_in_new,
        onPressed: () async {
          EasyLoading.show();
          await getBoughtProductsPannelLinkFromServerByIdAdminMode(
                  productID: widget.productDetails.id.toInt())
              .then((link) {
            EasyLoading.dismiss();
            if (!context.mounted) return;
            if (link != false && link != null) {
              launchUrl(Uri.parse(link));
            } else {
              showMsg(
                  msg: "خطا در دریافت لینک", context: context, type: "error");
            }
          });
        },
      ),
      _buildActionButton(
        context: context,
        label: "ریست کردن بسته",
        icon: Icons.refresh,
        onPressed: () async {
          EasyLoading.show();
          await reChargeProductByAdminWithPrID(
                  productID: widget.productDetails.id.toInt())
              .then((value) {
            if (!context.mounted) return;
            EasyLoading.dismiss();
            if (value) {
              showMsg(msg: "با موفقیت انجام شد", context: context);
              Provider.of<ProductProvider>(context, listen: false)
                  .setChanged(true);
              _fillData();
            } else {
              showMsg(msg: "خطا در ریست کردن", context: context, type: "error");
            }
          });
        },
      ),
      _buildActionButton(
        context: context,
        label: _sanaeiConfig!.enable ? "غیر فعال سازی" : "فعال سازی",
        icon: _sanaeiConfig!.enable ? Icons.visibility_off : Icons.visibility,
        color: _sanaeiConfig!.enable ? Colors.orange : Colors.green,
        onPressed: () async {
          EasyLoading.show();
          await changeActivationOfHiddifyUserByAdmin(
                  enable: !_sanaeiConfig!.enable,
                  productID: widget.productDetails.id.toInt())
              .then((res) {
            EasyLoading.dismiss();
            if (!context.mounted) return;
            if (res) {
              showMsg(msg: "تغییر وضعیت با موفقیت انجام شد", context: context);
              _fillData();
            } else {
              showMsg(
                  msg: "خطا در تغییر وضعیت", context: context, type: "error");
            }
          });
        },
      ),
      _buildActionButton(
        context: context,
        label: "تغییر نام (ایمیل)",
        icon: Icons.edit_outlined,
        onPressed: () => _showRenameDialog(context: context),
      ),
      _buildActionButton(
        context: context,
        label: "حذف بسته",
        icon: Icons.delete_forever,
        color: Colors.red,
        onPressed: () => _showDeleteDialog(context: context),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
              const Icon(Icons.settings_outlined, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                "وضعیت بسته خریداری شده (سنایی)",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.8,
                  context: context,
                  importedList: pannelWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 5,
                  importedList: pannelWidgetList),
              desktop: widgetsGridview(
                  importedList: pannelWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 3.5 : 4.5,
                  crossAxisCount: 2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "عملیات مدیریت",
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3.2,
                  context: context,
                  importedList: actionWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: actionWidgetList),
              desktop: widgetsGridview(
                  importedList: actionWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 3.5 : 4.5,
                  crossAxisCount: 4),
            ),
          ),
        ],
      ),
    );
  }

  _marzbanConfigCardData(BuildContext context) {
    if (_pannel == null || !isMarzbanCompatiblePanel(_pannel!.type)) {
      return const SizedBox();
    }
    final Size size = MediaQuery.of(context).size;
    final panelLabel = getMarzbanCompatiblePanelLabel(_pannel!.type);
    final hasPanelInfo = _marzbanConfig != null;

    List<Widget> pannelWidgetList = hasPanelInfo
        ? [
            DetailsInfoItemWidget(
                item: DetailsInfoItem(
              itemName: "نام کاربری",
              itemValue: _marzbanConfig!.username ?? _panelUsername ?? "نامشخص",
              icon: const Icon(Icons.person_outline, color: Colors.blue),
            )),
            DetailsInfoItemWidget(
                item: DetailsInfoItem(
              itemName: "میزان حجم استفاده شده",
              itemValue: _formatTrafficUsage(_marzbanConfig!.usedTraffic),
              icon: const Icon(Icons.data_usage_outlined, color: Colors.orange),
            )),
            DetailsInfoItemWidget(
                item: DetailsInfoItem(
              itemName: "حجم کل",
              itemValue: _formatTrafficLimit(_marzbanConfig!.dataLimit),
              icon: const Icon(Icons.storage_outlined, color: Colors.green),
            )),
            DetailsInfoItemWidget(
                item: DetailsInfoItem(
              itemName: "آخرین زمان آنلاین",
              itemValue: _formatPersianDateTimeFromString(
                _marzbanConfig!.onlineAt,
                fallback: "استفاده نشده",
              ),
              icon: const Icon(Icons.history_outlined, color: Colors.purple),
            )),
            DetailsInfoItemWidget(
                item: DetailsInfoItem(
              itemName: "تاریخ انقضا",
              itemValue: _formatExpireDate(_marzbanConfig!.expire),
              icon:
                  const Icon(Icons.calendar_today_outlined, color: Colors.teal),
            )),
            DetailsInfoItemWidget(
                item: DetailsInfoItem(
              itemName: "وضعیت",
              itemValue: _getMarzbanStatusLabel(_marzbanConfig!.status),
              icon: Icon(
                _isMarzbanUserActive
                    ? Icons.check_circle_outline
                    : Icons.block_flipped,
                color: _getMarzbanStatusColor(_marzbanConfig!.status),
              ),
            )),
          ]
        : [
            DetailsInfoItemWidget(
                item: DetailsInfoItem(
              itemName: "وضعیت دریافت اطلاعات",
              itemValue: _panelUsername == null
                  ? "نام کاربری اکانت در این بسته ثبت نشده است."
                  : "در حال حاضر اطلاعات این اکانت از پنل $panelLabel دریافت نشد.",
              icon:
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber),
            )),
          ];

    List<Widget> actionWidgetList = [
      _buildActionButton(
        context: context,
        label: "مشاهده در پنل",
        icon: Icons.open_in_new,
        onPressed: () async {
          EasyLoading.show();
          await getBoughtProductsPannelLinkFromServerByIdAdminMode(
                  productID: widget.productDetails.id.toInt())
              .then((link) {
            EasyLoading.dismiss();
            if (!context.mounted) return;
            if (link != false && link != null) {
              launchUrl(Uri.parse(link));
            } else {
              showMsg(
                  msg: "خطا در دریافت لینک", context: context, type: "error");
            }
          });
        },
      ),
      _buildActionButton(
        context: context,
        label: "ریست کردن بسته",
        icon: Icons.refresh,
        onPressed: () async {
          EasyLoading.show();
          await reChargeProductByAdminWithPrID(
                  productID: widget.productDetails.id.toInt())
              .then((value) {
            EasyLoading.dismiss();
            if (!context.mounted) return;
            if (value) {
              showMsg(msg: "با موفقیت انجام شد", context: context);
              Provider.of<ProductProvider>(context, listen: false)
                  .setChanged(true);
              _fillData();
            } else {
              showMsg(msg: "خطا در ریست کردن", context: context, type: "error");
            }
          });
        },
      ),
      _buildActionButton(
        context: context,
        label: _isMarzbanUserActive ? "غیر فعال سازی" : "فعال سازی",
        icon: _isMarzbanUserActive ? Icons.visibility_off : Icons.visibility,
        color: _isMarzbanUserActive ? Colors.orange : Colors.green,
        onPressed: () async {
          EasyLoading.show();
          await changeActivationOfHiddifyUserByAdmin(
                  enable: !_isMarzbanUserActive,
                  productID: widget.productDetails.id.toInt())
              .then((res) {
            EasyLoading.dismiss();
            if (!context.mounted) return;
            if (res) {
              showMsg(msg: "تغییر وضعیت با موفقیت انجام شد", context: context);
              _fillData();
            } else {
              showMsg(
                  msg: "خطا در تغییر وضعیت", context: context, type: "error");
            }
          });
        },
      ),
      _buildActionButton(
        context: context,
        label: "حذف بسته",
        icon: Icons.delete_forever,
        color: Colors.red,
        onPressed: () => _showDeleteDialog(context: context),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
              const Icon(Icons.settings_outlined, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                "وضعیت بسته خریداری شده ($panelLabel)",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.8,
                  context: context,
                  importedList: pannelWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 5,
                  importedList: pannelWidgetList),
              desktop: widgetsGridview(
                  importedList: pannelWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 3.5 : 4.5,
                  crossAxisCount: 2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "عملیات مدیریت",
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3.2,
                  context: context,
                  importedList: actionWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: actionWidgetList),
              desktop: widgetsGridview(
                  importedList: actionWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 3.5 : 4.5,
                  crossAxisCount: 4),
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog({required BuildContext context}) {
    final TextEditingController controller =
        TextEditingController(text: widget.productDetails.remark);
    showDialog(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppStyle.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text("تغییر نام کاربر",
                  style: TextStyle(color: Colors.white)),
              content: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "نام جدید",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("انصراف",
                        style: TextStyle(color: Colors.white60))),
                ElevatedButton(
                    onPressed: () async {
                      if (controller.text.isEmpty) return;
                      EasyLoading.show();
                      await renameHiddifyRemark(
                              productID: widget.productDetails.id.toInt(),
                              remark: controller.text)
                          .then((value) {
                        EasyLoading.dismiss();
                        if (!context.mounted) return;
                        if (value) {
                          showMsg(msg: "با موفقیت انجام شد", context: context);
                          setState(() {
                            widget.productDetails.remark = controller.text;
                          });
                          Navigator.pop(context);
                          _fillData();
                        } else {
                          showMsg(
                              msg: "خطا در تغییر نام",
                              context: context,
                              type: "error");
                        }
                      });
                    },
                    child: const Text("تایید")),
              ],
            ),
          );
        });
  }

  void _showDeleteDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
                backgroundColor: AppStyle.secondaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text("حذف بسته خریداری شده",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
                content: const Text(
                  "آیا از حذف این بسته اطمینان دارید؟ این عمل غیرقابل بازگشت است و دسترسی کاربر قطع خواهد شد.",
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("انصراف",
                          style: TextStyle(color: Colors.white60))),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text("تایید و حذف نهایی"),
                      onPressed: () async {
                        EasyLoading.show();
                        await softDeleteProductByAgentWithPrIDAdminMOde(
                                productID: widget.productDetails.id.toInt())
                            .then((value) {
                          if (!context.mounted) return;
                          EasyLoading.dismiss();
                          if (value) {
                            showMsg(
                                msg: "با موفقیت انجام شد", context: context);
                            Provider.of<ProductProvider>(context,
                                    listen: false)
                                .setChanged(true);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          } else {
                            showMsg(
                                msg: "خطا در حذف بسته",
                                context: context,
                                type: "error");
                            Navigator.pop(context);
                          }
                        });
                      })
                ]),
          );
        });
  }

  _operationInfoCard(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> operationWidgetList = [
      _buildActionButton(
        context: context,
        label: "تغییر بسته",
        icon: Icons.swap_horiz,
        color: Colors.blueAccent,
        onPressed: () => _showChangeProductsDialog(context),
      ),
    ];

    if (_pannel != null && isMarzbanCompatiblePanel(_pannel!.type)) {
      operationWidgetList.addAll([
        _buildActionButton(
          context: context,
          label: _isMarzbanUserActive ? "غیر فعال سازی" : "فعال سازی",
          icon: _isMarzbanUserActive ? Icons.visibility_off : Icons.visibility,
          color: _isMarzbanUserActive ? Colors.orange : Colors.green,
          onPressed: () async {
            EasyLoading.show();
            await changeActivationOfHiddifyUserByAdmin(
                    enable: !_isMarzbanUserActive,
                    productID: widget.productDetails.id.toInt())
                .then((res) {
              EasyLoading.dismiss();
              if (!context.mounted) return;
              if (res) {
                showMsg(
                    msg: "تغییر وضعیت با موفقیت انجام شد", context: context);
                _fillData();
              } else {
                showMsg(
                    msg: "خطا در تغییر وضعیت", context: context, type: "error");
              }
            });
          },
        ),
        _buildActionButton(
          context: context,
          label: "حذف بسته",
          icon: Icons.delete_forever,
          color: Colors.red,
          onPressed: () => _showDeleteDialog(context: context),
        ),
      ]);
    }

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
              const Icon(Icons.bolt, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                "عملیات سریع",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3.2,
                  context: context,
                  importedList: operationWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: operationWidgetList),
              desktop: widgetsGridview(
                  importedList: operationWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 3.5 : 4.5,
                  crossAxisCount: 1),
            ),
          ),
        ],
      ),
    );
  }

  _showChangeProductsDialog(BuildContext context) async {
    EasyLoading.show();
    List<ProductCategory> productCategoryList = [];
    List<String> productCategoryItemList = [];
    final userGroupId = widget.productDetails.botUser?.panelUser?.userGroupId;

    await getAllProdctCategory().then((res) {
      if (res != null && res != false) {
        productCategoryList = res;
        for (var i in productCategoryList) {
          if (i.pannelId == widget.productDetails.productCategory!.pannelId) {
            if (i.isAllowedForUserGroup(userGroupId)) {
              productCategoryItemList
                  .add("${i.id} - ${i.categoryName} - ${i.price} تومان");
            }
          }
        }
      }
    }).whenComplete(() async {
      EasyLoading.dismiss();
      if (!context.mounted) return;
      if (productCategoryItemList.isEmpty) {
        showMsg(
          msg: "برای گروه این کاربر، بسته‌ی جایگزین مجازی وجود ندارد",
          context: context,
          type: "warning",
        );
        return;
      }
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => ChangeCurrentProductToNewOne(
              productList: productCategoryItemList,
              currentProdoctId: widget.productDetails.id.toInt()));
    }).onError((error, stackTrace) {
      if (!context.mounted) return;
      EasyLoading.dismiss();
      // setStateIfMounted(() {
      //   _showData = false;
      // });
      showMsg(msg: "خطا", context: context, type: "error");
    });
  }

  // void _showAddReservetionDialog(BuildContext context) {
  //   showDialog(
  //       context: context,
  //       builder: (context) => AddOrRemoveReservationProductDialog(
  //             productId: widget.productDetails.id,
  //             hasReserved: _hasReservetion,
  //           ));
  // }
}

class ChangeCurrentProductToNewOne extends StatefulWidget {
  const ChangeCurrentProductToNewOne({
    super.key,
    required this.productList,
    required this.currentProdoctId,
    this.actionType = "admin",
  });
  final List<String> productList;
  final int currentProdoctId;
  final String actionType;
  @override
  State<ChangeCurrentProductToNewOne> createState() =>
      _ChangeCurrentProductToNewOneState();
}

class _ChangeCurrentProductToNewOneState
    extends State<ChangeCurrentProductToNewOne> {
  String _selectedItem = "";
  bool _recharge = true;
  bool _changeBallance = true;
  @override
  void initState() {
    _selectedItem = widget.productList[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppStyle.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.swap_horiz, color: Colors.blueAccent),
            const SizedBox(width: 10),
            const Text(
              "تغییر بسته خریداری شده",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "بسته جدید را انتخاب کنید:",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: AppStyle.secondaryColor,
                    value: _selectedItem,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedItem = newValue.toString();
                      });
                    },
                    items: widget.productList.map((clType) {
                      return DropdownMenuItem(
                        value: clType,
                        child: Text(
                          clType,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                title: "ریست کردن زمان و حجم",
                subtitle: "زمان باقی‌مانده و حجم مصرفی صفر شود؟",
                value: _recharge,
                onChanged: (val) => setState(() => _recharge = val),
              ),
              if (widget.actionType == "admin") ...[
                const SizedBox(height: 12),
                _buildSwitchTile(
                  title: "کسر مابه‌التفاوت",
                  subtitle: "تفاوت هزینه از کیف پول کاربر کسر شود؟",
                  value: _changeBallance,
                  onChanged: (val) => setState(() => _changeBallance = val),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.amber, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "تنها در صورتی مبلغ کسر می‌شود که قیمت بسته جدید بیشتر باشد.",
                          style: TextStyle(color: Colors.amber, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("انصراف", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: _handleConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("تایید و تغییر"),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirm() async {
    EasyLoading.show();
    int newprcatID = int.parse(_selectedItem.split(" - ")[0]);

    try {
      if (widget.actionType == "admin") {
        final val = await changeProductByAdminWithPrID(
          changeBallance: _changeBallance,
          recharge: _recharge,
          newPrCatID: newprcatID,
          id: widget.currentProdoctId,
        );
        if (!mounted) return;
        EasyLoading.dismiss();
        if (val != null) {
          Navigator.pop(context);
          showMsg(context: context, msg: "تغییر با موفقیت انجام شد");
        } else {
          showMsg(context: context, msg: "خطا در انجام عملیات", type: "error");
        }
      } else {
        final val = await changeProductByAgentWithPrID(
          recharge: _recharge,
          newPrCatID: newprcatID,
          id: widget.currentProdoctId,
        );
        if (!mounted) return;
        EasyLoading.dismiss();
        if (val == true) {
          Navigator.pop(context);
          showMsg(context: context, msg: "تغییر با موفقیت انجام شد");
          Provider.of<AgentProvider>(context, listen: false).setChanged(true);
        } else {
          showMsg(context: context, msg: "خطا در انجام عملیات", type: "error");
        }
      }
    } catch (e) {
      if (!mounted) return;
      EasyLoading.dismiss();
      debugPrint(e.toString());
      showMsg(context: context, msg: "خطای غیرمنتظره رخ داد", type: "error");
    }
  }
}
