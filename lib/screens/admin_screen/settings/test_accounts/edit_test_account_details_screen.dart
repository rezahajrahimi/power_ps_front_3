import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/repositories/test_account_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class EditTestAccountDetailsScreen extends StatefulWidget {
  const EditTestAccountDetailsScreen({super.key});

  @override
  State<EditTestAccountDetailsScreen> createState() =>
      _EditTestAccountDetailsScreenState();
}

class _EditTestAccountDetailsScreenState
    extends State<EditTestAccountDetailsScreen> {
  bool _showData = false;
  final _volTxtEdit = TextEditingController();
  final _expireDayTxtEdit = TextEditingController();
  String _selectedPannelName = "";
  final List<Widget> _infoWidgetList = [];
  final List<String> _pannelNameList = [];

  @override
  void initState() {
    super.initState();
    _fillData();
  }

  @override
  void dispose() {
    super.dispose();
    _infoWidgetList.clear();
    _pannelNameList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _showData == true
          ? Scaffold(
              appBar: appBarWithBackButton(
                  context: context, title: "جزییات اکانت آزمایشی"),
              bottomNavigationBar: Responsive.isMobile(context)
                  ? _buildBottomNavigationBar(context)
                  : const Opacity(opacity: 1),
              body: SafeArea(
                child: SingleChildScrollView(
                  primary: false,
                  padding: EdgeInsets.all(AppStyle.defaultPadding),
                  child: _showData == false
                      ? const SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: CircularProgressIndicator()))
                      : _content(context),
                ),
              ),
            )
          : const CircularProgressIndicator(),
    );
  }

  void _fillData() async {
    List<Pannel> resPannel = await getPannels();
    await getTestAccountDetails().then((res) async {
      if (res != null) {
        _infoWidgetList.clear();
        _volTxtEdit.text = res.volume;
        _expireDayTxtEdit.text = res.expireDay;

        setState(() {
          _infoWidgetList.add(CustomTextFromFieldWidget(
            controller: _volTxtEdit,
            textDirection: TextDirection.ltr,
            textHint: "حجم اکانت",
            validationError: "حجم اکانت را وارد کنید.",
          ));
          _infoWidgetList.add(CustomTextFromFieldWidget(
            controller: _expireDayTxtEdit,
            textDirection: TextDirection.ltr,
            textHint: "تعداد روز",
            validationError: "تعداد روز را وارد کنید.",
          ));
          if (resPannel.isNotEmpty) {
            setState(() {
              _pannelNameList.clear();
              for (var i in resPannel) {
                if (i.type != "custom") {
                  _pannelNameList.add(
                      "${i.id}: ${getPannelName(name: i.type)} - ${i.location}");
                }

                if (i.id == res.pannelId) {
                  _selectedPannelName =
                      "${i.id}: ${getPannelName(name: i.type)} - ${i.location}";
                }
              }

              _infoWidgetList.add(DropdownButtonFormField(
                isExpanded: true,
                hint: const Text('نوع پنل'),
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
            });
          }
          _showData = true;
        });
      }
    });
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
                    _accountInfoCard(context),
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

  _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        child: ElevatedButton(
          onPressed: () {
            _submitData(context);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: AppStyle.secondaryColor),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 4.0,
                ),
                Text(
                  "ویرایش",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ));
  }

  _accountInfoCard(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          color: AppStyle.secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "اطلاعات اکانت",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: _infoWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: _infoWidgetList),
              desktop: widgetsGridview(
                  importedList: _infoWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          )
        ]));
  }

  _submitData(BuildContext context) async {
    EasyLoading.show();
    int pannelID = 1;
    if (_selectedPannelName != "") {
      pannelID = int.parse(_selectedPannelName.split(":")[0]);
    }
    if (_expireDayTxtEdit.text.isNotEmpty && _volTxtEdit.text.isNotEmpty) {
      await updateTestAccountDetails(
              pannelID: pannelID,
              expireDays: int.parse(_expireDayTxtEdit.text),
              volume: double.parse(_volTxtEdit.text))
          .then((value) {
        if (!context.mounted) return;

        if (value != null) {
          showMsg(msg: "ویرایش شد.", context: context);
          _fillData();
        } else {
          showMsg(msg: "خطا", context: context, type: "error");
        }
      });
    } else {
      showMsg(msg: "اطلاعات درخواست شده را وارد کنید.", context: context);
    }
    EasyLoading.dismiss();
  }

  _actionInfoCard(BuildContext context) {
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
          _submitData(context);
        },
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش"),
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
}
