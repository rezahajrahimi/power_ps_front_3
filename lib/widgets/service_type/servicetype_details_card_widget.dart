import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/service_type_model.dart';
import 'package:powerps/models/servicetype_details_info.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/service_type/servicetype_info_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:flutter/material.dart';

class ServiceTypeDetailsInfoCardWidget extends StatefulWidget {
  final ServiceType selectedServiceType;
  const ServiceTypeDetailsInfoCardWidget(
      {super.key, required this.selectedServiceType});

  @override
  State<ServiceTypeDetailsInfoCardWidget> createState() =>
      _ServiceTypeDetailsInfoCardWidgetState();
}

class _ServiceTypeDetailsInfoCardWidgetState
    extends State<ServiceTypeDetailsInfoCardWidget> {
  List<Widget> servicetypeInfoItemwidgetList = [];

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    servicetypeInfoItemwidgetList.clear();
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
            "لیست سرویس های موجود",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 4,
                  context: context,
                  importedList: servicetypeInfoItemwidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 6,
                  importedList: servicetypeInfoItemwidgetList),
              desktop: widgetsGridview(
                  importedList: servicetypeInfoItemwidgetList,
                  context: context,
                  childAspectRatio: 5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  void _fillData() {
    setState(() {
      servicetypeInfoItemwidgetList.clear();
      servicetypeInfoItemwidgetList.add(ServiceTypeInfoItemCardWidget(
        item: ServiceTypeDetailsInfoItem(
          itemName: widget.selectedServiceType.serviceName,
          itemID: widget.selectedServiceType.id,
        ),
      ));
    });
  }
}
