import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/servicetype_details_info.dart';
import 'package:powerps/models/service_type_model.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/service_type/servicetype_info_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:flutter/material.dart';

class ServiceTypesCardWidget extends StatefulWidget {
  final List<ServiceType> serviceTypeList;
  final String title;

  const ServiceTypesCardWidget({
    super.key,
    required this.serviceTypeList,
    required this.title,
  });

  @override
  State<ServiceTypesCardWidget> createState() => _ServiceTypesCardWidgetState();
}

class _ServiceTypesCardWidgetState extends State<ServiceTypesCardWidget> {
  List<ServiceTypeInfoItemCardWidget> serviceTypeInfoItemList = [];

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
    for (var i in widget.serviceTypeList) {
      setState(() {
        serviceTypeInfoItemList.add(ServiceTypeInfoItemCardWidget(
          item: ServiceTypeDetailsInfoItem(
            itemName: i.serviceName,
            itemID: i.id,
          ),
        ));
      });
    }
  }
}
