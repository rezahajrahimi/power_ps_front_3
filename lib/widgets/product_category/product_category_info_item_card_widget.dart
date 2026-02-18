import 'package:powerps/helper/public.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/screens/admin_screen/product/products_details_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

class ProductCategoryInfoItemCardWidget extends StatefulWidget {
  const ProductCategoryInfoItemCardWidget({
    super.key,
    required this.item,
    this.onTap,
  });
// return functon
  final Function()? onTap;
  final ProductCategory item;
  @override
  State<ProductCategoryInfoItemCardWidget> createState() =>
      _ProductCategoryInfoItemCardWidgetState();
}

class _ProductCategoryInfoItemCardWidgetState
    extends State<ProductCategoryInfoItemCardWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                selectedProductCategory: widget.item,
              ),
            )).then((value) {
          widget.onTap!();
        });
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
}
