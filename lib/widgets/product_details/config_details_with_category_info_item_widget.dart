import 'package:powerps/helper/public.dart';
import 'package:powerps/helpers/bought_product_status_helper.dart';
import 'package:powerps/models/sanaei_config_model.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
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

  dynamic _panelConfig;
  String? get _panelType => widget.item.productCategory?.pannel?.type;

  bool _showdata = false;
  @override
  void dispose() {
    _showdata = false;
    super.dispose();
  }

  bool get _isActive {
    if (!_showdata || _panelConfig == null) {
      return false;
    }
    if (_panelType == 'sanaei' && _panelConfig is SanaeiConfig) {
      return (_panelConfig as SanaeiConfig).enable;
    }
    return boughtProductStatusIsActive(_panelConfig);
  }

  String? get _usageLabel {
    if (!_showdata || _panelConfig == null) {
      return null;
    }
    if (_panelType == 'sanaei' && _panelConfig is SanaeiConfig) {
      final config = _panelConfig as SanaeiConfig;
      return '${config.currentUsageGB.toStringAsFixed(2)} / ${config.usageLimitGB.toStringAsFixed(2)} GB';
    }
    return boughtProductStatusUsageLabel(_panelConfig);
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
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
          border: Border.all(
            color: AppStyle.primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (_showdata && !_isActive)
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppStyle.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: _showdata == false
                  ? Icon(Icons.code, color: AppStyle.primaryColor, size: 24)
                  : _isActive
                      ? Icon(Icons.code, color: AppStyle.primaryColor, size: 24)
                      : const Icon(Icons.code_off, color: Colors.red, size: 24),
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
                          widget.item.productCategory!.categoryName.length > 25
                              ? "${widget.item.productCategory!.categoryName.substring(0, 25)}..."
                              : widget.item.productCategory!.categoryName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
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
                        if (_showdata && _usageLabel != null)
                          Text(
                            _usageLabel!,
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
      if (value != null && value != false && value is Map) {
        setStateIfMounted(() {
          _panelConfig = parseBoughtProductStatusJson(
            Map<String, dynamic>.from(value),
          );
          _showdata = true;
        });
      }
    }).onError((e, s) {
      debugPrint(e.toString());
    });
  }
}
