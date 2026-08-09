import 'package:powerps/helper/public.dart';
import 'package:powerps/models/product_details_model.dart';
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
  String get _categoryLabel {
    final name = widget.item.productCategory?.categoryName.trim();
    if (name != null && name.isNotEmpty) {
      return name.length > 25 ? '${name.substring(0, 25)}...' : name;
    }
    return 'کانفیگ ${widget.item.id}';
  }

  String get _remarkLabel {
    final remark = widget.item.remark?.trim();
    if (remark == null || remark.isEmpty) {
      return '—';
    }
    return remark.length > 30 ? '${remark.substring(0, 27)}...' : remark;
  }

  TextStyle _secondaryTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ) ??
        const TextStyle(color: Colors.white70, fontSize: 12);
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
                color: AppStyle.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.code, color: AppStyle.primaryColor, size: 24),
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
                          _categoryLabel,
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
                          style: _secondaryTextStyle(context),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _remarkLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _secondaryTextStyle(context),
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
}
