import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/provider/user_provider.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProductCategoryInfoItemWidget extends StatefulWidget {
  const UserProductCategoryInfoItemWidget(
      {super.key, this.onTap, required this.item});
  final Function()? onTap;
  final ProductCategory item;

  @override
  State<UserProductCategoryInfoItemWidget> createState() =>
      _UserProductCategoryInfoItemWidgetState();
}

class _UserProductCategoryInfoItemWidgetState
    extends State<UserProductCategoryInfoItemWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _showDialog(context);
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
            widget.item.isActive == true
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: Icon(Icons.code),
                  )
                : const SizedBox(
                    height: 20,
                    width: 20,
                    child: Icon(Icons.code_off),
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
                          widget.item.categoryName.length > 30
                              ? "${widget.item.categoryName.substring(30)}..."
                              : widget.item.categoryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        widget.item.pannel != null
                            ? Text(
                                "${widget.item.pannel!.location}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.white70),
                              )
                            : Container(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${thousandSeperatorFormatter(widget.item.price.toString())} تومان",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                        Text(
                          "${thousandSeperatorFormatter(widget.item.priceInDollar.toString())}\$",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                        Text(
                          "${widget.item.expireDay} روزه",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                        Text(
                          "${widget.item.volume} گیگابایت",
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

  void _showDialog(BuildContext context) async {
    String remark = "";
    return await showDialog(
        context: context,
        builder: (dialogContext) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('نام بسته'),
              content: TextField(
                decoration: const InputDecoration(
                    hintText: 'یک نام برای این بسته بنویسید'),
                onChanged: (value) {
                  remark = value;
                },
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      if (remark.isEmpty) {
                        showMsg(
                            msg: "نام را وارد کنید.",
                            context: dialogContext,
                            type: "error");
                        return;
                      }
                      EasyLoading.show();

                      await buyProductByUserWithPrID(
                              productID: widget.item.id, remark: remark)
                          .then((val) {
                        if (!dialogContext.mounted) return;
                        if (val != false && val != null) {
                          // open val as a link in a new window
                          if (widget.item.pannel?.type == "sanaei" ||
                              val.startsWith("vless://") ||
                              val.startsWith("vmess://") ||
                              val.startsWith("trojan://")) {
                            EasyLoading.dismiss();
                            Navigator.of(dialogContext).pop();
                            _showConfigDialog(context, val);
                          } else if (val.contains("https://") ||
                              val.contains("http://")) {
                            launchUrl(Uri.parse(val),
                                mode: LaunchMode.externalApplication);
                            EasyLoading.dismiss();

                            Navigator.of(dialogContext).pop();
                          } else {
                            Navigator.of(dialogContext).pop();

                            EasyLoading.dismiss();
                            showMsg(
                                msg: "$val", context: context, type: "error");
                          }
                        } else {
                          EasyLoading.dismiss();
                          showMsg(
                              msg: "خطا در برقراری ارتباط با سرور",
                              context: context,
                              type: "error");
                          Navigator.of(dialogContext).pop();
                        }
                      }).then((val) {
                        // لیست خریدها را آپدیت کن
                      }).whenComplete(() {
                        if (!context.mounted) return;
                        Provider.of<UserProvider>(context, listen: false)
                            .setChanged(true);
                      });
                    },
                    child: const Text('خرید')),
                TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('بستن'))
              ],
            ),
          );
        });
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
