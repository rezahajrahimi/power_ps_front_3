import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/product_details/config_details_with_category_info_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class UserBougthProductsInfoCardWidget extends StatefulWidget {
  const UserBougthProductsInfoCardWidget(
      {super.key, required this.title, required this.products});
  final List<ProductDetails> products;
  final String title;

  @override
  State<UserBougthProductsInfoCardWidget> createState() =>
      _UserBougthProductsInfoCardWidgetState();
}

class _UserBougthProductsInfoCardWidgetState
    extends State<UserBougthProductsInfoCardWidget> {
  final List<Widget> _mainInfoWidgetList = [];
  @override
  void initState() {
    super.initState();
    _fillData();
  }

  @override
  void dispose() {
    _mainInfoWidgetList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: _mainInfoWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 3.2,
                  crossAxisCount: 2,
                  importedList: _mainInfoWidgetList),
              desktop: widgetsGridview(
                  context: context,
                  importedList: _mainInfoWidgetList,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  void _fillData() {
    if (mounted) {
      setState(() {
        for (var i in widget.products) {
          _mainInfoWidgetList.add(ConfigDetailsWithCatInfoItemWidget(
            item: i,
          ));
        }
      });
    }
  }
}
