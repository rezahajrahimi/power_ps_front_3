import 'package:powerps/helper/public.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/repositories/product_details_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

class ConfigDetailsInfoItemWidget extends StatefulWidget {
  const ConfigDetailsInfoItemWidget(
      {super.key, required this.item, required this.isActive});

  final ProductDetails item;
  final bool isActive;
  @override
  State<ConfigDetailsInfoItemWidget> createState() =>
      _ConfigDetailsInfoItemWidgetState();
}

class _ConfigDetailsInfoItemWidgetState
    extends State<ConfigDetailsInfoItemWidget> {
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
    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(
            width: 2, color: AppStyle.primaryColor.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyle.defaultPadding),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: Icon(Icons.code, color: AppStyle.primaryColor),
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
                    widget.item.configs.length > 25
                        ? widget.item.configs.substring(0, 25)
                        : widget.item.configs,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 50,
            width: 50,
            child: IconButton(
              onPressed: () async {
                await _showDeleteDialog(context: context);
                // var res = await deleteProductDetails(
                //   id: widget.item.id.toInt(),
                // );
                // if (res == true) {
                //   productChangedToken = "productCardChanged";

                //   setState(() {
                //     productChangedToken = "productCardChanged";
                //   });
                //   productChangedToken = "productCardChanged";

                //   if (context.mounted) {
                //     showMsg(
                //       context: context,
                //       msg: "حذف شد.",
                //     );
                //     productNotifier.changedProductData();
                //   }
                // }
              },
              icon: const Icon(Icons.delete_forever, color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  _showDeleteDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                  title: const Text("حذف"),
                  content: const Text("آیا مطمئن هستید؟"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("لغو"),
                    ),
                    TextButton(
                      onPressed: () async {
                        var res = await deleteProductDetails(
                          id: widget.item.id.toInt(),
                        );

                        if (res == true) {
                          setState(() {
                            productChangedToken = "productCardChanged";
                          });
                          productNotifier.changedProductData();

                          if (context.mounted) {
                            showMsg(
                              context: context,
                              msg: "حذف شد.",
                            );
                            productNotifier.changedProductData();
                            Navigator.pop(context);
                          }
                        }
                        productNotifier.changedProductData();
                      },
                      child: const Text("حذف",
                          style: TextStyle(color: Colors.red)),
                    )
                  ]);
            }),
          );
        });
  }
}
