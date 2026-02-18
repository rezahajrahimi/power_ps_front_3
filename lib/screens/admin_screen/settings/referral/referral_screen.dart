import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/referral_setting_model.dart';
import 'package:powerps/repositories/referral_setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'referral_logs_screen.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  bool _showData = false;
  final _descriptionTxtEdit = TextEditingController();
  final _visitCardTxtEdit = TextEditingController();
  final _referralPercentTxtEdit = TextEditingController();
  bool _isActive = true;
  final List<Widget> _referralSecendInfoWidgetList = [];

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
          appBar: appBarWithBackButton(
              context: context, title: "بازاریابی و لینک دعوت"),
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
        ),
      ),
    );
  }

  _content(BuildContext context) {
    _referralSecendInfoWidgetList.clear();
    _referralSecendInfoWidgetList.add(Column(
      children: [
        CustomTextFromFieldWidget(
          controller: _referralPercentTxtEdit,
          keyboardType: TextInputType.text,
          textHint: "میزان درصد بازاریابی",
          textDirection: TextDirection.ltr,
          validationError: "میزان درصد بازاریابی",
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "میزان درصد بازاریابی که برای کاربر ثبت می شود.",
            style: TextStyle(color: AppStyle.deactiveStatus),
          ),
        ),
      ],
    ));
    _referralSecendInfoWidgetList.add(Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "فعال بودن بازاریابی",
            style: TextStyle(color: AppStyle.deactiveStatus),
          ),
        ),
        Switch(
            value: _isActive,
            onChanged: (bool newValue) async {
              if (newValue == true) {
                setState(() {
                  _isActive = newValue;
                });
              } else {
                setState(() {
                  _isActive = newValue;
                });
              }
            }),
      ],
    ));
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _referralInfoCard(context),
                    SizedBox(width: AppStyle.defaultPadding),
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

  void _fillData() async {
    await getReferralSetting().then((value) {
      if (value != false && value != null) {
        setState(() {
          _descriptionTxtEdit.text = value.description;
          _visitCardTxtEdit.text = value.visitCardText;
          _referralPercentTxtEdit.text = value.referralPercent.toString();
          _isActive = value.isActive;

          _showData = true;
        });
      }
    });
  }

  _referralInfoCard(BuildContext context) {
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
            "اطلاعات لینک دعوت",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "متنی که به کاربر، برای ایجاد لینک دعوت نمایش می دهید. از \\r\\n برای ایجاد خط جدید برای متن استفاده کنید.",
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppStyle.deactiveStatus,
                      ),
                    ),
                  ),
                ],
              )),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2,
                  context: context,
                  importedList: _referralSecendInfoWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 3.2,
                  importedList: _referralSecendInfoWidgetList),
              desktop: widgetsGridview(
                  importedList: _referralSecendInfoWidgetList,
                  context: context,
                  childAspectRatio: 3.2,
                  crossAxisCount: 2),
            ),
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
        onPressed: () {
          _submitData(context);
        },
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReferralLogsScreen()),
          );
        },
        icon: const Icon(Icons.list),
        label: const Text("لاگ‌ها"),
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
                  childAspectRatio: 2,
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

  void _submitData(BuildContext context) async {
    if (_descriptionTxtEdit.text.isEmpty || _visitCardTxtEdit.text.isEmpty) {
      showMsg(
          msg: "اطلاعات درخواستی را وارد کنید",
          context: context,
          type: "error");
      return;
    }
    ReferralSettingModel ref = ReferralSettingModel(
        id: 1,
        description: _descriptionTxtEdit.text,
        visitCardText: _visitCardTxtEdit.text,
        referralPercent: double.parse(_referralPercentTxtEdit.text),
        isActive: _isActive);
    EasyLoading.show();
    await updateReferralSetting(referralSettingModel: ref).then((value) {
      if (!context.mounted) return;

      if (value) {
        showMsg(msg: "ذخیره شد.", context: context);
      } else {
        showMsg(msg: "خطا", context: context, type: "error");
      }
    });
    EasyLoading.dismiss();
  }
}
