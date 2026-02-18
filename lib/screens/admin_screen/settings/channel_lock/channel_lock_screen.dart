import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/channel_lock_model.dart';
import 'package:powerps/repositories/channel_lock_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/channel_lock_item_info_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class ChannelLockScreen extends StatefulWidget {
  const ChannelLockScreen({super.key});

  @override
  State<ChannelLockScreen> createState() => _ChannelLockScreenState();
}

class _ChannelLockScreenState extends State<ChannelLockScreen> {
  bool _showData = false;
  // List<SubMenuItem> subList = [];
  List<ChannelLock> _channelLockList = [];
  final _newChannelIDEditTxt = TextEditingController();
  final List<Widget> _channelLockItemWidgetList = [];

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(context: context, title: "قفل ربات"),
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

  void _fillData() async {
    if (context.mounted) {
      var res = await getAllChannelLock();
      if (res != null && res != false) {
        setState(() {
          _showData = false;
          _channelLockList = res;
          _channelLockItemWidgetList.clear();
          for (var i in _channelLockList) {
            _channelLockItemWidgetList.add(ChannelLockItemInfoWidget(
              channelLock: ChannelLock(
                id: i.id,
                channelId: i.channelId,
                isActive: i.isActive,
              ),
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
                    _channelLockListCard(context),
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

  void _retryChannelLockData() {
    channelLockChangedToken = "aaa";

    _fillData();
    channelLockNotifier.changedChannelLockData();
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
                await _newChannelLockDialog(context);
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
                      "افزودن قفل",
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

  _channelLockListCard(BuildContext context) {
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
            "لیست کانال ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          Text(
            "برای این عملیات می بایست ربات به عنوان Admin در این کانال ها عضو شده باشد.",
            style: TextStyle(color: AppStyle.deactiveStatus),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder(
                valueListenable: channelLockNotifier,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  if (value == "channelLockChanged") {
                    _retryChannelLockData();
                  }
                  return Responsive(
                    mobile: widgetsGridview(
                        childAspectRatio: 2.9,
                        context: context,
                        importedList: _channelLockItemWidgetList),
                    tablet: widgetsGridview(
                        context: context,
                        childAspectRatio: 4.5,
                        importedList: _channelLockItemWidgetList),
                    desktop: widgetsGridview(
                        importedList: _channelLockItemWidgetList,
                        context: context,
                        childAspectRatio: size > 1550 ? 4.5 : 4.5,
                        crossAxisCount: 2),
                  );
                }),
          ),
        ],
      ),
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
          await _newChannelLockDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("افزودن قفل ربات"),
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
                  childAspectRatio: 2.9,
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

  _newChannelLockDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: const Text("افزودن"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      const Text("ID کانال را وارد کنید"),
                      TextFormField(
                        controller: _newChannelIDEditTxt,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        textDirection: TextDirection.ltr,
                        maxLines: null,
                        decoration:
                            const InputDecoration(labelText: "ID کانال"),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () async {
                          EasyLoading.show();
                          if (_newChannelIDEditTxt.text.isNotEmpty) {
                            bool res = false;
                            if (_newChannelIDEditTxt.text.contains('@')) {
                              _newChannelIDEditTxt.text = _newChannelIDEditTxt
                                  .text
                                  .replaceAll(RegExp(r'@'), '');
                            }
                            res = await createNewChannelLock(
                                channelLock: ChannelLock(
                                    id: "0",
                                    channelId: _newChannelIDEditTxt.text.trim(),
                                    isActive: true));

                            if (res) {
                              setState(() {
                                _newChannelIDEditTxt.text = "";
                                channelLockChangedToken = "channelLockChanged";
                              });

                              if (context.mounted) {
                                showMsg(msg: "اضافه شد.", context: context);

                                Navigator.pop(context);
                              }
                              channelLockNotifier.changedChannelLockData();
                            }
                          } else {
                            // showToast(
                            //     msg: "خطا.", fToast: _fToast, type: "error");
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }

                            channelLockNotifier.changedChannelLockData();
                          }
                          EasyLoading.dismiss();
                        },
                        child: const Text(
                          "افزودن",
                        )),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("لغو")),
                  ],
                ),
              ],
            )));
  }
}
