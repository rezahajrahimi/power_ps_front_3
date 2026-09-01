import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/provider/user_admin_provider.dart';
import 'package:powerps/repositories/panel_user_repository.dart';
// import 'package:powerps/repositories/panel_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/admin_user/admin_user_item_widget.dart';
import 'package:powerps/widgets/dialogs/admin/add_new_admin_dialog.dart';
// import 'package:powerps/widgets/admin_user/admin_user_item_widget.dart';
// import 'package:powerps/widgets/dialogs/admin/add_new_admin_dialog.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:provider/provider.dart';

class ManageAdminsScreen extends StatefulWidget {
  const ManageAdminsScreen({super.key});

  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  bool _showAdmins = false;
  final List<Widget> _adminItemWidgetList = [];

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
        appBar: appBarWithBackButton(context: context, title: "مدیران"),
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _showAdmins == false
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
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : const Opacity(opacity: 1),
      ),
    );
  }

  _content(BuildContext context) {
    bool changed = context.watch<UserAdminProvider>().changed;
    if (changed) {
      _fillData();
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _adminsInfoCard(context),
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
                    _actionInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  _adminsInfoCard(BuildContext context) {
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
            "مدیران",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.5,
                  context: context,
                  importedList: _adminItemWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: _adminItemWidgetList),
              desktop: widgetsGridview(
                  importedList: _adminItemWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          )
        ],
      ),
    );
  }

  void _fillData() async {
    setState(() {
      _showAdmins = false;
      _adminItemWidgetList.clear();
    });
    await getAdmins().then((value) {
      if (value != null) {
        for (var element in value) {
          _adminItemWidgetList.add(AdminUserItemWidget(
            userModel: element,
          ));
        }
      }
    }).whenComplete(() {
      setState(() {
        _showAdmins = true;
      });
      if (!mounted) return;

      Provider.of<UserAdminProvider>(listen: false, context).setChanged(false);
    }).onError((e, s) {
      if (!mounted) return;

      showMsg(msg: "$e خطا", context: context, type: "error");
      Navigator.of(context).pop();
    });
  }

  _actionInfoCard(BuildContext context) {
    List<Widget> myList = [];
    final Size size = MediaQuery.of(context).size;
    setState(() {
      myList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          await _showAdminListDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("افزودن مدیر"),
      ));
    });
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
            "عملیات‌ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    context: context,
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    importedList: myList),
                tablet: widgetsGridview(
                    context: context,
                    crossAxisCount: 1,
                    childAspectRatio: size.width < 1400 ? 3 : 4.5,
                    importedList: myList),
                desktop: widgetsGridview(
                    importedList: myList,
                    context: context,
                    childAspectRatio: size.width < 1400 ? 3 : 4.5,
                    crossAxisCount: 2),
              )),
        ],
      ),
    );
  }

  _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: ElevatedButton(
              onPressed: () async {
                await _showAdminListDialog(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.secondaryColor),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "افزودن مدیر",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showAdminListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text("افزودن مدیر جدید"),
              content: AddNewAdminDialog(),
            ),
          ),
        );
      },
    );
  }
}
