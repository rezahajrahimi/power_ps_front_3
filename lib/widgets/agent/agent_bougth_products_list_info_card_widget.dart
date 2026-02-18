import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/bought_product_details_model.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/agent/agent_bought_product_info_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class AgentBougthProductsListInfoCardWidget extends StatefulWidget {
  const AgentBougthProductsListInfoCardWidget(
      {super.key,
      required this.products,
      required this.title,
      this.lggedUSerRole = "user"});
  final List<BoughtProductDetailsModel> products;
  final String title;
  final String lggedUSerRole;

  @override
  State<AgentBougthProductsListInfoCardWidget> createState() =>
      _AgentBougthProductsListInfoCardWidgetState();
}

class _AgentBougthProductsListInfoCardWidgetState
    extends State<AgentBougthProductsListInfoCardWidget> {
  final List<AgentBoughtProductInfoWidget> _productsItemList = [];
  bool _showData = false;
  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _productsItemList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final Size size = MediaQuery.of(context).size;

    return _showData == true
        ? Container(
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            decoration: BoxDecoration(
              color: AppStyle.secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                        onPressed: () async {
                          if (widget.lggedUSerRole == "user") {
                            await getUserSelledProductsByPagination()
                                .then((value) {
                              if (value.isNotEmpty) {
                                _refresh();
                              }
                            }).onError((error, stackTrace) {
                              setState(() {
                                showMsg(
                                    msg: "خطا",
                                    context: context,
                                    type: "error");
                              });
                              debugPrint(error.toString());
                            });
                          } else if (widget.lggedUSerRole == "agent") {
                            await getAgentSelledProductsByPagination()
                                .then((value) {
                              if (value.isNotEmpty) {
                                _refresh();
                              }
                            }).onError((error, stackTrace) {
                              setState(() {
                                showMsg(
                                    msg: "خطا",
                                    context: context,
                                    type: "error");
                              });
                              debugPrint(error.toString());
                            });
                          }
                        },
                        icon: const Icon(Icons.refresh))
                  ],
                ),
                SizedBox(height: AppStyle.defaultPadding),
                SizedBox(
                  width: double.infinity,
                  child: Responsive(
                    mobile: widgetsGridview(
                        childAspectRatio: 2.9,
                        context: context,
                        importedList: _productsItemList),
                    tablet: widgetsGridview(
                        context: context,
                        childAspectRatio: 3.2,
                        crossAxisCount: 2,
                        importedList: _productsItemList),
                    desktop: widgetsGridview(
                        context: context,
                        importedList: _productsItemList,
                        childAspectRatio: 4.5,
                        crossAxisCount: 2),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  void _fillData() {
    if (mounted) {
      setState(() {
        _productsItemList.clear();
        for (var i in widget.products) {
          _productsItemList.add(AgentBoughtProductInfoWidget(
            boughtProductDetailsModel: i,
            userRole: widget.lggedUSerRole,
          ));
        }
        _showData = true;
      });
    }
  }

  void _refresh() {
    if (mounted) {
      setState(() {
        _showData = false;

        _productsItemList.clear();
        for (var i in boughtProducts) {
          _productsItemList.add(AgentBoughtProductInfoWidget(
            boughtProductDetailsModel: i,
          ));
        }
        _showData = true;
      });
    }
  }
}
