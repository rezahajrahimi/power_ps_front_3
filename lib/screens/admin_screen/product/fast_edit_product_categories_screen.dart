import 'package:flutter/material.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/widgets/product_category/fast_editable_product_category_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class FastEditProductCategoriesScreen extends StatefulWidget {
  const FastEditProductCategoriesScreen(
      {super.key, required this.productCategoryList});
  final List<ProductCategory> productCategoryList;

  @override
  State<FastEditProductCategoriesScreen> createState() =>
      _FastEditProductCategoriesScreenState();
}

class _FastEditProductCategoriesScreenState
    extends State<FastEditProductCategoriesScreen> {
  final List<Widget> _widgetList = [];
  final ScrollController horizontalScroll = ScrollController();
  final ScrollController verticalScroll = ScrollController();

  @override
  void initState() {
    for (var i in widget.productCategoryList) {
      _widgetList.add(FastEditableProductCategoryWidget(
        productCategory: i,
      ));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //row data
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(
          context: context,
          title: "ویرایش سریع بسته‌ها",
        ),
        body: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height,
                width: 1500,
                child: ListView.builder(
                    itemCount: _widgetList.length,
                    itemBuilder: (context, index) {
                      return _widgetList[index];
                    }))
          ],
        ),
      ),
    );
    // return Directionality(
    //   textDirection: TextDirection.rtl,
    //   child: Scaffold(
    //     appBar: appBarWithBackButton(
    //       context: context,
    //       title: "ویرایش سریع بسته‌ها",
    //     ),
    //     body: SingleChildScrollView(
    //       physics: const BouncingScrollPhysics(),
    //       child: Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: Container(
    //               padding: EdgeInsets.all(AppStyle.defaultPadding),
    //               decoration: BoxDecoration(
    //                 color: AppStyle.secondaryColor,
    //                 borderRadius: const BorderRadius.all(Radius.circular(10)),
    //               ),
    //               child: ListView.builder(
    //                   shrinkWrap: true,
    //                   itemCount: _widgetList.length,
    //                   scrollDirection: Axis.horizontal,
    //                   itemBuilder: (context, index) {
    //                     return _widgetList[index];
    //                   }))),
    //     ),
    //   ),
    // );
  }
}
