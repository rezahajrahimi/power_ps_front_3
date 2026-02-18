import 'package:powerps/models/servicetype_details_info.dart';
import 'package:powerps/screens/admin_screen/product/product_category_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

class ServiceTypeInfoItemCardWidget extends StatefulWidget {
  const ServiceTypeInfoItemCardWidget({
    super.key,
    required this.item,
  });

  final ServiceTypeDetailsInfoItem item;
  @override
  State<ServiceTypeInfoItemCardWidget> createState() =>
      _ServiceTypeInfoItemCardWidgetState();
}

class _ServiceTypeInfoItemCardWidgetState
    extends State<ServiceTypeInfoItemCardWidget> {
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
              builder: (context) => const ProductCategoryScreen(),
            )).then((value) {});
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
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                widget.item.itemName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.item.itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
