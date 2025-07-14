import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/hiffify_config_model.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/provider/panel_controller.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/repositories/hiddify_repository.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/product_details/hiddify_config_details_with_check_box_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:searchable_listview/searchable_listview.dart';

class GroupOperationsScreen extends StatefulWidget {
  const GroupOperationsScreen({super.key});

  @override
  State<GroupOperationsScreen> createState() => _GroupOperationsScreenState();
}

class _GroupOperationsScreenState extends State<GroupOperationsScreen> {
  bool _showData = false;
  bool _showPannelData = false;
  final List<Widget> _productCatWidgetLIst = [];
  final List<ProductCategory> _productCategoryList = [];
  final List<String> _pannelNameList = [];
  String _selectedPannelName = "";
  List<HiddifyConfig> _usersList = [];
  List<HiddifyConfig> selecedUsersList = [];

  @override
  void dispose() {
    selecedUsersList.clear();
    _usersList.clear();
    _productCategoryList.clear();
    _productCatWidgetLIst.clear();
    _pannelNameList.clear();
    _selectedPannelName = "";
    _showData = false;
    _showPannelData = false;
    super.dispose();
  }

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
        appBar: appBarWithBackButton(context: context, title: "عملیات گروهی"),
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            child: Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: Column(
                children: [
                  _showData == false
                      ? const SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: CircularProgressIndicator()))
                      : _content(context),
                ],
              ),
            ),
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
                  _pannelListInfoTabCard(context),
                  SizedBox(width: AppStyle.defaultPadding),
                  if (_showPannelData) _usersListInfoTabCard(context),
                  if (Responsive.isMobile(context))
                    Column(
                      children: [
                        _operationInfoCard(context),
                        SizedBox(width: AppStyle.defaultPadding),
                        _existConfigsListInfoCard(context)
                      ],
                    ),
                ],
              ),
            ),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            // On Mobile means if the screen is less than 850 we dont want to show it
            if (!Responsive.isMobile(context)) // side windows
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _operationInfoCard(context),
                    SizedBox(width: AppStyle.defaultPadding),
                    _existConfigsListInfoCard(context)
                  ],
                ),
              ),
          ],
        )
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
          await _submitIncOprDialog(context, opr: "inc");
        },
        icon: const Icon(Icons.add),
        label: const Text("افزایش روز/حجم"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          await _submitIncOprDialog(context, opr: "dec");
        },
        icon: const Icon(Icons.remove),
        label: const Text("کاهش روز/حجم"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          await _submitIncOprDialog(context, opr: "dec");
        },
        icon: const Icon(Icons.start),
        label: const Text("فعالسازی/غیرفعال‌سازی"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          await _submitIncOprDialog(context, opr: "dec");
        },
        icon: const Icon(Icons.delete_forever),
        label: const Text("حذف"),
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
                  crossAxisCount: 2,
                  importedList: actionsWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 2,
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

  _existConfigsListInfoCard(BuildContext context) {
    final configs = context.watch<PannelChangeController>().obtinedConfigList;

    List<Widget> myWidgetList = [];
    for (var i in configs) {
      setState(() {
        myWidgetList.add(HiddifyConfigDetailsWithCheckBoxWidget(
          item: i,
        ));
      });
    }

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
            "کانفیگ های انتخاب شده (${myWidgetList.length})",
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
                  importedList: myWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4,
                  crossAxisCount: 1,
                  importedList: myWidgetList),
              desktop: widgetsGridview(
                  importedList: myWidgetList,
                  context: context,
                  childAspectRatio: 4,
                  crossAxisCount: 1),
            ),
          ),
        ],
      ),
    );
  }

  void _fillData() async {
    if (context.mounted) {
      await getPannels().then((onValue) {
        if (onValue.isNotEmpty) {
          setState(() {
            _pannelNameList.clear();
            for (var i in onValue) {
              _pannelNameList.add(
                  "${i.id}: ${getPannelName(name: i.type)} - ${i.location}");
            }
            _selectedPannelName =
                "${onValue[0].id}: ${getPannelName(name: onValue[0].type)} - ${onValue[0].location}";
            _showData = true;
          });
        }
      }).onError((e, s) {
        if (!mounted) return;

        showMsg(msg: "خطا", context: context, type: "error");
        Navigator.of(context).pop();
      });
    }
  }

  _pannelListInfoTabCard(BuildContext context) {
    List<Widget> myList = [];
    setState(() {
      myList.add(const Text("یک پنل را انتخاب کنید"));
      myList.add(DropdownButtonFormField(
        isExpanded: true,
        hint: const Text('پنل'),
        value: _selectedPannelName,
        alignment: Alignment.centerRight,
        onChanged: (newValue) {
          setState(() {
            _selectedPannelName = newValue.toString();
          });
        },
        items: _pannelNameList.map((clType) {
          return DropdownMenuItem(
            value: clType,
            alignment: Alignment.centerRight,
            child: Text(clType),
          );
        }).toList(),
      ));
      myList.add(ElevatedButton.icon(
          onPressed: () async {
            Provider.of<PannelChangeController>(context, listen: false)
                .clearConfigList();
            EasyLoading.show();
            _showPannelData = false;
            int pannelID = 1;
            if (_selectedPannelName != "") {
              pannelID = int.parse(_selectedPannelName.split(":")[0]);
            }
            await getHiddifyPanelUsersByPannelID(pannelID: pannelID)
                .then((res) {
              if (res != null && res != false) {
                setState(() {
                  _usersList = res;
                  _showPannelData = true;
                  EasyLoading.dismiss();
                });
              } else {
                EasyLoading.dismiss();
                if (!context.mounted) return;

                showMsg(
                    msg: "خطا در دریافت لیست کانفیگ‌ها",
                    context: context,
                    type: "error");
              }
            }).onError((e, s) {
              EasyLoading.dismiss();
              if (!context.mounted) return;

              showMsg(
                  msg: "خطا در دریافت لیست کانفیگ‌ها",
                  context: context,
                  type: "error");
            });
          },
          label: const Text("دریافت لیست کانفیگ‌ها")));
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
            "پنل",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 3.2,
                    context: context,
                    importedList: myList),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: myList),
                desktop: widgetsGridview(
                    importedList: myList,
                    context: context,
                    childAspectRatio: 4.5,
                    crossAxisCount: 3),
              )),
        ],
      ),
    );
  }

  _usersListInfoTabCard(BuildContext context) {
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
            "کانفیگ‌های موجود در پنل",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _selectionOptions(context),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 180,
              child: SearchableList<HiddifyConfig>(
                initialList: _usersList,
                shrinkWrap: false,
                textStyle: const TextStyle(fontSize: 25),
                itemBuilder: (HiddifyConfig config) =>
                    HiddifyConfigDetailsWithCheckBoxWidget(item: config),
                loadingWidget: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 20,
                    ),
                    Text('بارگذاری کانفیگ ها ...')
                  ],
                ),
                errorWidget: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('خطا')
                  ],
                ),
                filter: (q) {
                  return _usersList
                      .where((element) => element.name.toString().contains(q))
                      .toList();
                },
                textAlign: TextAlign.right,
                emptyWidget: const EmptyView(),
                onRefresh: () async {},
                sortPredicate: (a, b) => a.name.compareTo(b.name),
                displayClearIcon: true,
                inputDecoration: InputDecoration(
                  labelText: "کانفیگ را انتخاب کنید",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _selectionOptions(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.add(ElevatedButton.icon(
      onPressed: () {
        // Provider.of<PannelChangeController>(context, listen: false)
        //     .clearConfigList();
        for (HiddifyConfig config in _usersList) {
          Provider.of<PannelChangeController>(context, listen: false)
              .addNewConfig(config);
        }
      },
      icon: const Icon(Icons.check_box),
      label: const Text("انتخاب همه"),
    ));
    widgetList.add(ElevatedButton.icon(
      onPressed: () {
        // Provider.of<PannelChangeController>(context, listen: false)
        //     .clearConfigList();
        for (HiddifyConfig config in _usersList) {
          if (config.isActive == false) {
            Provider.of<PannelChangeController>(context, listen: false)
                .addNewConfig(config);
          }
        }
      },
      icon: const Icon(Icons.disabled_by_default),
      label: const Text("غیر فعالها"),
    ));
    widgetList.add(ElevatedButton.icon(
      onPressed: () {
        // Provider.of<PannelChangeController>(context, listen: false)
        // //     .clearConfigList();
        for (HiddifyConfig config in _usersList) {
          if (config.isActive == true) {
            Provider.of<PannelChangeController>(context, listen: false)
                .addNewConfig(config);
          }
        }
      },
      icon: const Icon(Icons.access_alarm),
      label: const Text("فعالها"),
    ));
    widgetList.add(ElevatedButton.icon(
      onPressed: () {
        // Provider.of<PannelChangeController>(context, listen: false)
        //     .clearConfigList();
        for (HiddifyConfig config in _usersList) {
          if (config.currentUsageGB == 0) {
            Provider.of<PannelChangeController>(context, listen: false)
                .addNewConfig(config);
          }
        }
      },
      icon: const Icon(Icons.access_alarm),
      label: const Text("استفاده نشده"),
    ));
    widgetList.add(ElevatedButton.icon(
      onPressed: () {
        Provider.of<PannelChangeController>(context, listen: false)
            .clearConfigList();
      },
      icon: const Icon(Icons.clear),
      label: const Text("پاک کردن لیست"),
    ));
    // group config by capacity
    // اضافه کردن packageDays بدون تکرار
    widgetList.add(
      ElevatedButton.icon(
      onPressed: () {
        showModalBottomSheet(
          
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
          List<Widget> advancedOptions = [];

          List<int> dayGroup = _usersList.map((e) => e.packageDays).toSet().toList()..sort();
          for (var i in dayGroup) {
          advancedOptions.add(ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text("کانفیگ های با $i روز"),
            onTap: () {
            Navigator.pop(context);
            Provider.of<PannelChangeController>(context, listen: false).clearConfigList();
            for (HiddifyConfig config in _usersList) {
              if (config.packageDays == i) {
              Provider.of<PannelChangeController>(context, listen: false).addNewConfig(config);
              }
            }
            },
          ));
          }

          List<double> capacityGroup = _usersList.map((e) => e.usageLimitGB).toSet().toList()..sort();
          for (var i in capacityGroup) {
          advancedOptions.add(ListTile(
            leading: const Icon(Icons.storage),
            title: Text("کانفیگ های با $i گیگابایت"),
            onTap: () {
            Navigator.pop(context);
            // Provider.of<PannelChangeController>(context, listen: false).clearConfigList();
            for (HiddifyConfig config in _usersList) {
              if (config.usageLimitGB == i) {
              Provider.of<PannelChangeController>(context, listen: false).addNewConfig(config);
              }
            }
            },
          ));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("انتخاب پیشرفته", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ...advancedOptions,
                ],
              ),
            ),
          );
        },
        );
      },
      icon: const Icon(Icons.tune),
      label: const Text("انتخاب پیشرفته"),
      ),
    );

    return SizedBox(
        width: double.infinity,
        child: Responsive(
          mobile: widgetsGridview(
              childAspectRatio: 3.2,
              context: context,
              crossAxisCount: 2,
              importedList: widgetList),
          tablet: widgetsGridview(
              context: context,
              childAspectRatio: 4.5,
              crossAxisCount: 4,
              importedList: widgetList),
          desktop: widgetsGridview(
              importedList: widgetList,
              context: context,
              childAspectRatio: 4.5,
              crossAxisCount: 6),
        ));
  }

  _submitIncOprDialog(BuildContext context, {required String opr}) async {
    TextEditingController input = TextEditingController();
    List<String> options = ["روز", "حجم"];
    String selectedOption = "روز";
    final formKey = GlobalKey<FormState>();
    // show dialog
    return showDialog(
      context: context,
      builder: (context) {
        return Form(
          key: formKey,
          child: AlertDialog(
            title: opr == "inc"
                ? Text("افزایش روز یا حجم کانفیگ های انتخابی")
                : Text("کاهش روز یا حجم کانفیگ های انتخابی"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: AppStyle.defaultPadding,
              children: [
                DropdownButtonFormField<String>(
                  value: options.first,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "یک گزینه را انتخاب کنید",
                    border: OutlineInputBorder(),
                  ),
                  items: options.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedOption = value!;
                  },
                ),
                CustomTextFromFieldWidget(
                  controller: input,
                  textHint: "مقدار",
                  validationError: "مقدار را وارد کنید.",
                  validatorType: "text",
                  keyboardType: TextInputType.text,
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("لغو"),
              ),
              ElevatedButton(
                onPressed: () {
                  String actionEn = "inc_days";
                  switch (opr) {
                    case "inc":
                      actionEn =
                          selectedOption == "روز" ? "inc_days" : "inc_vol";
                      break;
                    case "dec":
                      actionEn =
                          selectedOption == "روز" ? "dec_days" : "dec_vol";
                      break;
                  }
                  int pannelID = 1;
                  if (_selectedPannelName != "") {
                    pannelID = int.parse(_selectedPannelName.split(":")[0]);
                  }

                  if (formKey.currentState!.validate()) {
                    EasyLoading.show();
                    batchExistSubscriptionJobDayOpr(
                            action: actionEn,
                            day: int.tryParse(input.text) ?? 0,
                            vol: input.text,
                            panelId: pannelID,
                            hiddifyConfig: Provider.of<PannelChangeController>(
                                    context,
                                    listen: false)
                                .obtinedConfigList)
                        .then((value) {
                      EasyLoading.dismiss();
                      if (!context.mounted) return;

                      if (value == true) {
                        showMsg(msg: "با موفقیت انجام شد", context: context);
                      } else {
                        showMsg(msg: "خطا", context: context, type: "error");
                      }
                    }).onError((e, s) {
                      EasyLoading.dismiss();
                      if (!context.mounted) return;
                      debugPrint("Error: $e");

                      showMsg(msg: "خطا", context: context, type: "error");
                    });
                    // Navigator.of(context).pop();
                  } else {
                    showMsg(
                        msg: "اطلاعات درخواستی را وارد کنید.",
                        context: context);
                  }
                },
                child: const Text("اعمال"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: Colors.red,
        ),
        Text("گزینه‌ای پیدا نشد."),
      ],
    );
  }
}
