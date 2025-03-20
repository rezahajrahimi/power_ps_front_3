import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/screens/admin_screen/settings/agent/add_new_agent_screen.dart';
import 'package:powerps/repositories/panel_user_repository.dart';
import 'package:powerps/screens/admin_screen/settings/agent/edit_agent_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class AgentsManageScreen extends StatefulWidget {
  const AgentsManageScreen({super.key});

  @override
  State<AgentsManageScreen> createState() => _AgentsManageScreenState();
}

class _AgentsManageScreenState extends State<AgentsManageScreen> {
  List<User> _agents = [];
  bool _showData = false;
  final List<Widget> _agentsWidgetList = [];
  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _agentsWidgetList.clear();
    _agents.clear();
    _showData = false;
    _agentsWidgetList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _fillData();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(context: context, title: "دستیاران فروش (اکانتهای نقره ای و طلایی)"),
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

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  _agentInfo({required BuildContext context, required User agent}) {
    return Container(
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
          const SizedBox(
            height: 20,
            width: 20,
            child: Icon(Icons.verified_user),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        agent.accountId.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        agent.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // IconButton(
                      //     onPressed: () {
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (context) => BotUserDetailsScreen(
                      //             id: BigInt.from(agent.accountId),
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //     icon: const Icon(Icons.info)),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditAgentScreen(agent: agent),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit)),
                      IconButton(
                          onPressed: () {
                            //کاربر را باید تبدیل به کاربر معمولی کنی
                            // اگه کاربری ایجاد کرده ، تکلیف اون چی میشه
                            // می خوای کلا دسترسی این ادمین را بگیری یا کلا حذفش کنی
                            // اگه این کار را بکنی تکلیف موجودی حسابش چی می شه
                            _showDeleteDialog(context, agent);
                          },
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, User agent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف دستیار فروش'),
          content: const Text(
              'با حذف دستیار فروش تمام اکانتهای این کاربر به مدیر ربات منتقل می شود و کاربر به عنوان کاربر عادی تغییر خواهد کرد. از حذف این کاربر اطمینان دارید؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('لغو'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حذف'),
              onPressed: () async {
                EasyLoading.show();
                await removeAgent(userID: agent.accountId).then((val) {
                        if (!context.mounted) return;

                  if (val != null && val == true) {
                    showMsg(msg: "با موفقیت حذف شد", context: context);
                    EasyLoading.dismiss();

                    Navigator.of(context).pop();
                    _fillData();
                  } else {
                    showMsg(msg: "خطا", context: context, type: "error");
                    EasyLoading.dismiss();
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _fillData() async {
    _agentsWidgetList.clear();
    await getAgents().then((value) {
      if (value != null) {
        setStateIfMounted(() {
          _agents = value;
          for (var i in _agents) {
            _agentsWidgetList.add(_agentInfo(agent: i, context: context));
          }
          _showData = true;
        });
      }
    }).onError((e, s) {
      debugPrint(e.toString());
    });
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
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const AddNewAgentScreen();
                })).then((val) {
                  _fillData();
                });
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
                      "افزودن دستیار فروش جدید",
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
                    _agentListCard(context),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const AddNewAgentScreen();
          })).then((val) {
            _fillData();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text("افزودن دستیار فروش"),
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

  _agentListCard(BuildContext context) {
    var size = MediaQuery.of(context).size.width;

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
            "لیست دستیاران فروش",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.8,
                    context: context,
                    importedList: _agentsWidgetList),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: _agentsWidgetList),
                desktop: widgetsGridview(
                    importedList: _agentsWidgetList,
                    context: context,
                    childAspectRatio: size > 1550 ? 4.5 : 4.5,
                    crossAxisCount: 2),
              )),
        ],
      ),
    );
  }
}
