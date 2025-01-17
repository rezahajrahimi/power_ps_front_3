import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/main_menu_item_model.dart';
import 'package:powerps/repositories/main_menu_item_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/menu_item_info_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class MainMenuItemsScreen extends StatefulWidget {
  const MainMenuItemsScreen({super.key});

  @override
  State<MainMenuItemsScreen> createState() => _MainMenuItemsScreenState();
}

class _MainMenuItemsScreenState extends State<MainMenuItemsScreen> {
  List<MainMenuItem> _mainMenuItemsList = [];
  bool _showData = false;
  final List<Widget> _menuItemWidgetList = [];

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(
            context: context, title: "ویرایش منو اصلی ربات"),
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _showData == false
                ? const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _content(context),
          ),
        ),
      ),
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
                    _menuInfoCard(context),
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
                    // _actionInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  _menuInfoCard(BuildContext context) {
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
            "منوها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder(
                valueListenable: menuItemNotifier,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  if (value == "menuItemChanged") {
                    _retryMenuData();
                  }
                  return Responsive(
                    mobile: widgetsGridview(
                        childAspectRatio: 2.5,
                        context: context,
                        importedList: _menuItemWidgetList),
                    tablet: widgetsGridview(
                        context: context,
                        childAspectRatio: 4.5,
                        importedList: _menuItemWidgetList),
                    desktop: widgetsGridview(
                        importedList: _menuItemWidgetList,
                        context: context,
                        childAspectRatio: 4.5,
                        crossAxisCount: 2),
                  );
                }),
          ),
        ],
      ),
    );
  }

  void _fillData() async {
    if (context.mounted) {
      var res = await getAllMainMenuItems();
      if (res != null && res != false) {
        setState(() {
          _showData = false;
          _mainMenuItemsList = res;
          _menuItemWidgetList.clear();
          for (var i in _mainMenuItemsList) {
            _menuItemWidgetList.add(MenuItemInfoWidget(
              aliasName: i.aliasName,
              id: i.id,
              isActive: i.isActive,
              name: i.name,
              position: i.position,
            ));
          }
          _showData = true;
        });
      }
    }
  }

  void _retryMenuData() {
    menuChangedToken = "aaa";

    _fillData();
    menuItemNotifier.changedMenuData();
  }
}
