import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class ConfigsReportTab extends StatefulWidget {
  const ConfigsReportTab({super.key});

  @override
  State<ConfigsReportTab> createState() => _ConfigsReportTabState();
}

class _ConfigsReportTabState extends State<ConfigsReportTab>
    with AutomaticKeepAliveClientMixin {
  bool _showData = false;
  final List<String> _accountStatusList = ["غیرفعال", "فعال", "همه"];
  String _accountStatus = "همه";

  final List<String> _pannelNamesList = ["همه"];
  String _pannelName = "همه";

  final List<String> _productCategoryList = [];
  String _selectedProductCategory = "";

  final List<Widget> _myWidgetListSearchAction = [];
  final List<Widget> _myWidgetListMainDetails = [];

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _myWidgetListSearchAction.clear();
    _myWidgetListMainDetails.clear();
    _showData = false;
    _accountStatus = "همه";
    _pannelName = "همه";
    _selectedProductCategory = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                    primary: false,
                    padding: EdgeInsets.all(AppStyle.defaultPadding),
                    child: _content(context))),
            // bottomNavigationBar: _buildBottomNavigationBar(),
            // bottomNavigationBar: Responsive.isMobile(context)
            //     ? _buttomNavBar(context)
            //     : const Opacity(opacity: 1),
          )),
    );
  }

  _content(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _showData == true
                        ? _searchWidgetCard(context)
                        : const Center(child: CircularProgressIndicator()),
                    SizedBox(height: AppStyle.defaultPadding),
                    // if (_showData == false) _searchResualtCard(context),
                    // SizedBox(height: AppStyle.defaultPadding),
                  ],
                )),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            // side windows
            if (!Responsive.isMobile(context))
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // if (!Responsive.isMobile(context)) _actionCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  _searchWidgetCard(BuildContext context) {
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
            "گزینه های گزارش",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3,
                  context: context,
                  importedList: _myWidgetListMainDetails),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4,
                  importedList: _myWidgetListMainDetails),
              desktop: widgetsGridview(
                  importedList: _myWidgetListMainDetails,
                  context: context,
                  childAspectRatio: 4,
                  crossAxisCount: 2),
            ),
          ),
          // SizedBox(
          //   width: double.infinity,
          //   child: Responsive(
          //     mobile: widgetsGridview(
          //         childAspectRatio: 3,
          //         context: context,
          //         importedList: _myWidgetListSecendDetails),
          //     tablet: widgetsGridview(
          //         context: context,
          //         childAspectRatio: 4,
          //         importedList: _myWidgetListSecendDetails),
          //     desktop: widgetsGridview(
          //         importedList: _myWidgetListSecendDetails,
          //         context: context,
          //         childAspectRatio: 4,
          //         crossAxisCount: 2),
          //   ),
          // ),
          // SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  context: context,
                  importedList: _myWidgetListSearchAction),
              tablet: widgetsGridview(
                  crossAxisCount: 2,
                  context: context,
                  childAspectRatio: 4,
                  importedList: _myWidgetListSearchAction),
              desktop: widgetsGridview(
                  importedList: _myWidgetListSearchAction,
                  context: context,
                  childAspectRatio: 4,
                  crossAxisCount: 4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void _fillData() async {
    await getAllProdctCategory().then((res) {
      if (res != null && res != false) {
        for (var i in res) {
          _productCategoryList.add("${i.id}: ${i.categoryName}");
        }
        _selectedProductCategory = _productCategoryList[0];
      }
    }).whenComplete(() async {
      await getPannels().then((res) {
        if (res != null && res != false) {
          _pannelNamesList.clear();
          _pannelNamesList.add("همه");
          for (var i in res) {
            _pannelNamesList
                .add("${i.id}: ${getPannelName(name: i.type)} - ${i.location}");
          }

          _pannelName = "همه";
        }
        _showData = true;
      }).then((val) {
        setStateIfMounted(() {
          _myWidgetListMainDetails.add(Container(
            margin: EdgeInsets.only(top: AppStyle.defaultPadding),
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            decoration: BoxDecoration(
              border: Border.all(
                  width: 2,
                  color: AppStyle.primaryColor..withValues(alpha: 0.15)),
              borderRadius: BorderRadius.all(
                Radius.circular(AppStyle.defaultPadding),
              ),
            ),
            child: DropdownButtonFormField(
              isExpanded: true,
              hint: const Text('پنل'),
              initialValue: _pannelName,
              alignment: Alignment.centerRight,
              onChanged: (newValue) {
                setState(() {
                  _pannelName = newValue.toString();
                });
              },
              items: _pannelNamesList.map((clType) {
                return DropdownMenuItem(
                  value: clType,
                  alignment: Alignment.centerRight,
                  child: Text(clType),
                );
              }).toList(),
            ),
          ));
          _myWidgetListMainDetails.add(Container(
            margin: EdgeInsets.only(top: AppStyle.defaultPadding),
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            decoration: BoxDecoration(
              border: Border.all(
                  width: 2,
                  color: AppStyle.primaryColor..withValues(alpha: 0.15)),
              borderRadius: BorderRadius.all(
                Radius.circular(AppStyle.defaultPadding),
              ),
            ),
            child: DropdownButtonFormField(
              isExpanded: true,
              hint: const Text('وضعیت بسته'),
              initialValue: _accountStatus,
              alignment: Alignment.centerRight,
              onChanged: (newValue) {
                setState(() {
                  _accountStatus = newValue.toString();
                });
              },
              items: _accountStatusList.map((clType) {
                return DropdownMenuItem(
                  value: clType,
                  alignment: Alignment.centerRight,
                  child: Text(clType),
                );
              }).toList(),
            ),
          ));
          _myWidgetListMainDetails.add(Container(
            margin: EdgeInsets.only(top: AppStyle.defaultPadding),
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            decoration: BoxDecoration(
              border: Border.all(
                  width: 2,
                  color: AppStyle.primaryColor..withValues(alpha: 0.15)),
              borderRadius: BorderRadius.all(
                Radius.circular(AppStyle.defaultPadding),
              ),
            ),
            child: DropdownButtonFormField(
              isExpanded: true,
              hint: const Text('بسته'),
              initialValue: _selectedProductCategory,
              alignment: Alignment.centerRight,
              onChanged: (newValue) {
                setState(() {
                  _selectedProductCategory = newValue.toString();
                });
              },
              items: _productCategoryList.map((clType) {
                return DropdownMenuItem(
                  value: clType,
                  alignment: Alignment.centerRight,
                  child: Text(clType),
                );
              }).toList(),
            ),
          ));
        });
      });
    });
  }
}
