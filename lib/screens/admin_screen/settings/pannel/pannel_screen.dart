import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/screens/admin_screen/settings/pannel/add_new_panel_screen.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/screens/admin_screen/settings/pannel/obtain_exist_panel_users_to_agents_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/pannel_card_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class PannelScreen extends StatefulWidget {
  const PannelScreen({super.key});

  @override
  State<PannelScreen> createState() => _PannelScreenState();
}

class _PannelScreenState extends State<PannelScreen> {
  bool _showData = false;
  List<Pannel> _pannelList = [];
  final List<Widget> _pannelItemWidgetList = [];

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
        appBar: appBarWithBackButton(context: context, title: "پنل ها"),
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
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : const Opacity(opacity: 1),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddNewPanelScreen(),
                    )).then((value) => {});
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
                      "افزودن پنل",
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

  void _fillData() async {
    if (context.mounted) {
      var res = await getPannels();
      if (res != null && res != false) {
        setState(() {
          _showData = false;
          _pannelList = res;
          _pannelItemWidgetList.clear();
          for (var i in _pannelList) {
            _pannelItemWidgetList.add(PannelItemInfoWidget(
              pannel: Pannel(
                  id: i.id,
                  type: i.type,
                  adminUrl: i.adminUrl,
                  capacity: i.capacity,
                  location: i.location,
                  password: i.password,
                  token: i.token,
                  urlPort: i.urlPort,
                  username: i.username,
                  userLink: i.userLink,
                  secretCode: i.secretCode),
              callback: (val) {
                _retryPannelData();
              },
            ));
          }
          _showData = true;
        });
      }
    }
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
                    _pannelListCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
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
                    _operationInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  _pannelListCard(BuildContext context) {
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
            "پنل ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder(
                valueListenable: pannelNotifier,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  if (value == "pannelChanged") {
                    _retryPannelData();
                  }
                  return Responsive(
                    mobile: widgetsGridview(
                        childAspectRatio: 2.9,
                        context: context,
                        importedList: _pannelItemWidgetList),
                    tablet: widgetsGridview(
                        context: context,
                        childAspectRatio: 4.5,
                        importedList: _pannelItemWidgetList),
                    desktop: widgetsGridview(
                        importedList: _pannelItemWidgetList,
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

  void _retryPannelData() {
    pannelChangedToken = "aaa";

    _fillData();
    pannelNotifier.changedPannelData();
  }

  _operationInfoCard(BuildContext context) {
    List<Widget> actionsWidgetList = [];

    setState(() {
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNewPanelScreen(),
              )).then((value) => {_fillData()});
        },
        icon: const Icon(Icons.add),
        label: const Text("افزودن پنل"),
      ));
      if (_pannelList.isNotEmpty) {
        actionsWidgetList.add(ElevatedButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyle.defaultPadding * 1.5,
              vertical: AppStyle.defaultPadding /
                  (Responsive.isMobile(context) ? 2 : 1),
            ),
          ),
          onPressed: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ObtainExistPanelUsersToAgentsScreen(),
                )).then((value) => {_fillData()});
          },
          icon: const Icon(FontAwesomeIcons.indent),
          label: const Text("ورود کانفیگهای موجود به اپلیکیشن"),
        ));
      }
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
            "عملیات ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 5,
                  context: context,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              desktop: widgetsGridview(
                  importedList: actionsWidgetList,
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }
}
