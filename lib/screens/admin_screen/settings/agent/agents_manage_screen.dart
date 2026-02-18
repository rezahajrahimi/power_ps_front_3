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

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
              context: context,
              title: "دستیاران فروش (اکانتهای نقره ای و طلایی)"),
          body: SingleChildScrollView(
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
          bottomNavigationBar: Responsive.isMobile(context)
              ? _buildBottomNavigationBar(context)
              : const Opacity(opacity: 1),
        ),
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
        color: AppStyle.secondaryColor,
        border: Border.all(
            width: 1, color: AppStyle.primaryColor.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyle.defaultPadding),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppStyle.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: AppStyle.primaryColor),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "شناسه: ${agent.accountId}",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAgentScreen(agent: agent),
                      ),
                    ).then((value) => _fillData());
                  },
                  icon: const Icon(Icons.edit, color: Colors.blue)),
              IconButton(
                  onPressed: () {
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
    setStateIfMounted(() {
      _showData = false;
      _agentsWidgetList.clear();
    });

    try {
      await getAgents().then((val) {
        if (val != null) {
          if (!mounted) return;

          _agents = val;
          for (var i in _agents) {
            _agentsWidgetList.add(_agentInfo(agent: i, context: context));
          }
        }
      });
    } catch (e) {
      debugPrint("Error fetching agents: $e");
    } finally {
      setStateIfMounted(() {
        _showData = true;
      });
    }
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
