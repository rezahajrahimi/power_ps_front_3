import 'package:powerps/helper/public.dart';
import 'package:powerps/models/hiffify_config_model.dart';
import 'package:powerps/models/sanaei_config_model.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/repositories/bot_user_repository.dart';
import 'package:powerps/screens/admin_screen/user/bot_user_bougth_product_details.dart';

import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

class ConfigDetailsWithCatInfoItemWidget extends StatefulWidget {
  const ConfigDetailsWithCatInfoItemWidget({super.key, required this.item});

  final ProductDetails item;
  @override
  State<ConfigDetailsWithCatInfoItemWidget> createState() =>
      _ConfigDetailsWithCatInfoItemWidgetState();
}

class _ConfigDetailsWithCatInfoItemWidgetState
    extends State<ConfigDetailsWithCatInfoItemWidget> {
  @override
  void initState() {
    _fillData();
    super.initState();
  }

  HiddifyConfig? _hiddifyConfig;
  SanaeiConfig? _sanaeiConfig;

  bool _showdata = false;
  @override
  void dispose() {
    _showdata = false;
    // _hiddifyConfig = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.item.createdAt != "حذف شده") {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BotUserBoughtProductDetailsScreen(
                    productDetails: widget.item,
                    callback: (text) {
                      setState(() {
                        widget.item.createdAt = "حذف شده";
                      });
                    }),
              )).whenComplete(() => setState(() {}));
        } else {
          showMsg(
              msg: "این کانفیگ قبلا حذف شده", context: context, type: "error");
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
                child: (widget.item.productCategory?.pannel?.type == "sanaei"
                        ? (_sanaeiConfig?.enable ?? false)
                        : (_hiddifyConfig?.isActive ?? false))
                    ? Icon(Icons.code, color: AppStyle.primaryColor)
                    : const Icon(Icons.code_off, color: Colors.red),
              ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.item.productCategory!.categoryName.length > 30
                              ? widget.item.productCategory!.categoryName
                                  .substring(0, 30)
                              : widget.item.productCategory!.categoryName,
                          // maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.item.updatedAt.length > 10
                              ? widget.item.updatedAt.substring(0, 10)
                              : widget.item.updatedAt,
                          maxLines: 1,
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
                        if (_showdata)
                          Text(
                            widget.item.productCategory?.pannel?.type ==
                                    "sanaei"
                                ? "${_sanaeiConfig?.currentUsageGB.toStringAsFixed(2)} / ${_sanaeiConfig?.usageLimitGB.toStringAsFixed(2)} GB"
                                : "${_hiddifyConfig?.currentUsageGB.toStringAsFixed(2)} / ${_hiddifyConfig?.usageLimitGB.toStringAsFixed(2)} GB",
                            maxLines: 1,
                            textDirection: TextDirection.ltr,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.white70),
                          ),
                        Text(
                          widget.item.remark!.length > 30
                              ? "${widget.item.remark!.substring(0, 27)}..."
                              : widget.item.remark!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void _fillData() async {
    await getProductBoughtedByProductId(productID: widget.item.id.toInt())
        .then((value) {
      if (value != null && value != false && value is Map<String, dynamic>) {
        setStateIfMounted(() {
          // Check if it's Sanaei or Hiddify based on the keys in the response
          // Sanaei has 'client' or 'inbound' keys which Hiddify doesn't
          if (value.containsKey('client') || value.containsKey('inbound')) {
            _sanaeiConfig = SanaeiConfig.fromJson(value);
            // Also set hiddify config for compatibility if needed
            _hiddifyConfig = HiddifyConfig(
              uuid: "",
              currentUsageGB: _sanaeiConfig!.currentUsageGB,
              usageLimitGB: _sanaeiConfig!.usageLimitGB,
              name: "",
              packageDays: _sanaeiConfig!.packageDays,
              isActive: _sanaeiConfig!.enable,
            );
          } else {
            _hiddifyConfig = HiddifyConfig.fromJson(value);
          }
          _showdata = true;
        });
      }
    }).onError((e, s) {
      debugPrint(e.toString());
    });
  }
}
