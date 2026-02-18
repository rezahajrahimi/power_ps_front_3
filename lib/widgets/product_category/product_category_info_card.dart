import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/product_category/product_category_info_item_card_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:flutter/material.dart';

class ProductCategoryCardWidget extends StatefulWidget {
  final List<ProductCategory> productCategoryList;
  final String title;

  const ProductCategoryCardWidget({
    super.key,
    required this.productCategoryList,
    required this.title,
  });

  @override
  State<ProductCategoryCardWidget> createState() =>
      _ProductCategoryCardWidgetState();
}

class _ProductCategoryCardWidgetState extends State<ProductCategoryCardWidget> {
  List<ProductCategoryInfoItemCardWidget> serviceTypeInfoItemList = [];

  @override
  void initState() {
    super.initState();
    _fillData();
  }

  @override
  void dispose() {
    serviceTypeInfoItemList.clear();
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
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3.2,
                  context: context,
                  importedList: serviceTypeInfoItemList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 6,
                  importedList: serviceTypeInfoItemList),
              desktop: widgetsGridview(
                  context: context,
                  importedList: serviceTypeInfoItemList,
                  childAspectRatio: size.width < 1400 ? 3.5 : 4,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  void _fillData() {
    for (var i in widget.productCategoryList) {
      setState(() {
        serviceTypeInfoItemList.add(ProductCategoryInfoItemCardWidget(
          item: ProductCategory(
              categoryName: i.categoryName,
              priceInDollar: i.priceInDollar,
              pannelId: i.pannelId,
              expireDay: i.expireDay,
              id: i.id,
              volume: i.volume,
              price: i.price,
              rechargable: i.rechargable,
              showPannelLink: i.showPannelLink,
              isActive: i.isActive,
              showSubscriptionLink: i.showSubscriptionLink),
        ));
      });
    }
  }
}
