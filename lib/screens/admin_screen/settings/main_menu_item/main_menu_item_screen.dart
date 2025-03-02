import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/main_menu_item_model.dart';
import 'package:powerps/repositories/main_menu_item_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/menu_item_info_widget.dart';

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
                  return ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _menuItemWidgetList.length,
                    itemBuilder: (context, index) => _menuItemWidgetList[index],
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        // جابجایی در هر دو لیست
                        final menuItem = _mainMenuItemsList.removeAt(oldIndex);
                        _mainMenuItemsList.insert(newIndex, menuItem);
                        
                        final widgetItem = _menuItemWidgetList.removeAt(oldIndex);
                        _menuItemWidgetList.insert(newIndex, widgetItem);
                        
                        // بروزرسانی position‌ها
                        for (int i = 0; i < _mainMenuItemsList.length; i++) {
                          _mainMenuItemsList[i].position = i + 1;
                        }
                        // اینجا باید تغییرات به سرور ارسال شود
                        _updatePositionsOnServer(context);
                      });
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }

   _fillData() async {
    if(!mounted) return;
    
    _showData = false;
      
    var res = await getAllMainMenuItems();
    if (res != null && res != false) {
      if(!mounted) return;
      
      setState(() {
        _mainMenuItemsList = res;
        _menuItemWidgetList.clear();
        // مرتب‌سازی بر اساس position
        _mainMenuItemsList.sort((a, b) => a.position.compareTo(b.position));
        
        for (var i in _mainMenuItemsList) {
          _menuItemWidgetList.add(MenuItemInfoWidget(
            key: ValueKey(i.id),
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

   _retryMenuData() async {
    menuChangedToken = "aaa";
    await _fillData();
    menuItemNotifier.changedMenuData();
  }

  // اضافه کردن متد جدید برای ارسال تغییرات به سرور
   _updatePositionsOnServer(BuildContext context) async {
    await updateMainMenuItems(_mainMenuItemsList).then((value) {
      if(value == true){
        if(context.mounted){
          showMsg(msg: "منوها با موفقیت به روز شدند", context: context);
        }
      }
    });
  }
}
