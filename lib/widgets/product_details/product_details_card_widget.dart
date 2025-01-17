import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/repositories/product_details_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/product_details/config_details_info_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:flutter/material.dart';

class ProductDetailsCardWidget extends StatefulWidget {
  final List<ProductDetails> productProductDetailsList;
  final String title;

  const ProductDetailsCardWidget({
    super.key,
    required this.productProductDetailsList,
    required this.title,
  });

  @override
  State<ProductDetailsCardWidget> createState() =>
      _ProductDetailsCardWidgetState();
}

class _ProductDetailsCardWidgetState extends State<ProductDetailsCardWidget> {
  List<Widget> productDetailsInfoItemList = [];
  @override
  void initState() {
    super.initState();
    _fillData();
  }

  @override
  void dispose() {
    // productDetailsInfoItemList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

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
            widget.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder(
                valueListenable: productNotifier,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  if (value == "productCardChanged") {
                    _retryProductCardData();
                  }

                  return Responsive(
                    mobile: widgetsGridview(
                        childAspectRatio: 3.2,
                        context: context,
                        importedList: productDetailsInfoItemList),
                    tablet: widgetsGridview(
                        context: context,
                        childAspectRatio: 6,
                        importedList: productDetailsInfoItemList),
                    desktop: widgetsGridview(
                        context: context,
                        importedList: productDetailsInfoItemList,
                        childAspectRatio: size.width < 1400 ? 4.5 : 6,
                        crossAxisCount: 2),
                  );
                }),
          ),
        ],
      ),
    );
  }

  void _fillData() {
    if (context.mounted) {
      setState(() {
        productDetailsInfoItemList.clear();
        for (var i in productDetailsList) {
          productDetailsInfoItemList.add(ConfigDetailsInfoItemWidget(
            item: i,
            isActive: true,
          ));
        }
      });
    }
  }

  void _retryProductCardData() {
    productDetailsInfoItemList.clear();
    productChangedToken = "aaa";
    for (var i in productDetailsList) {
      productDetailsInfoItemList.add(ConfigDetailsInfoItemWidget(
        item: i,
        isActive: true,
      ));
    }
  }
}
