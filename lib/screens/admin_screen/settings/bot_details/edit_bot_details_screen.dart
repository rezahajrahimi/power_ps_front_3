import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/setting_model.dart';
import 'package:powerps/repositories/setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class EditBotDetailsScreen extends StatefulWidget {
  const EditBotDetailsScreen({super.key});

  @override
  State<EditBotDetailsScreen> createState() => _EditBotDetailsScreenState();
}

class _EditBotDetailsScreenState extends State<EditBotDetailsScreen> {
  late Setting _setting;
  bool _showData = false;
  final _botNameTxtEdit = TextEditingController();
  final _botTokenTxtEdit = TextEditingController();
  final _adminIdTxtEdit = TextEditingController();
  final _panelAddressTxtEdit = TextEditingController();
  final List<Widget> _botInfoWidgetList = [];
  final List<Widget> _botTokenWidgetList = [];
  final List<Widget> _botDescriptionWidgetList = [];
  final List<Widget> _botActionWidgetList = [];

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _showData == true
          ? Scaffold(
              appBar: appBarWithBackButton(
                  context: context, title: "ویرایش اطلاعات ربات"),
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
    await getBotSetting().then((value) {
      if (null != value) {
        setState(() {
          _setting = value;
          _botNameTxtEdit.text = _setting.botName;
          _adminIdTxtEdit.text = _setting.adminId;
          _botTokenTxtEdit.text = _setting.botToken;
          _panelAddressTxtEdit.text = _setting.panelAddress;
        });
      } else {
        setState(() {
          _setting = Setting(
              adminId: "تعریف نشده",
              botName: "تعریف نشده",
              botToken: "تعریف نشده",
              id: "تعریف نشده",
              panelAddress: "تعریف نشده"
              );
        });
      }
      setState(() {
        _botInfoWidgetList.add(Column(
          children: [
            CustomTextFromFieldWidget(
              controller: _botNameTxtEdit,
              textDirection: TextDirection.ltr,
              textHint: "نام ربات",
              validationError: "نام ربات را وارد کنید.",
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "نام ربات را همراه با @ وارد کنید ماننده @botSeller",
                style: TextStyle(color: AppStyle.deactiveStatus),
              ),
            ),
          ],
        ));
        _botInfoWidgetList.add(Column(
          children: [
            CustomTextFromFieldWidget(
              controller: _adminIdTxtEdit,
              textDirection: TextDirection.ltr,
              textHint: "ID ادمین",
              validationError: "ID ادمین را وارد کنید.",
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "برای پیدا کردن id ادمین در تلگرام به بات @ShowChatIdBot پیام بدهید.",
                style: TextStyle(color: AppStyle.deactiveStatus),
              ),
            ),
          ],
        ));
        _botInfoWidgetList.add(Column(
          children: [
            CustomTextFromFieldWidget(
              controller: _panelAddressTxtEdit,
              textDirection: TextDirection.ltr,
              textHint: "آدرس هسته ربات را وارد کنید.",
              keyboardType: TextInputType.url,
              validationError: " را وارد کنید را وارد کنید.",
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "تغییر ندهید.",
                style: TextStyle(color: AppStyle.deactiveStatus),
              ),
            ),
          ],
        ));

        _botActionWidgetList.add(ElevatedButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyle.defaultPadding * 1.5,
              vertical: AppStyle.defaultPadding /
                  (Responsive.isMobile(context) ? 2 : 1),
            ),
          ),
          onPressed: () async {
            if (_botNameTxtEdit.text.isNotEmpty &&
                _botTokenTxtEdit.text.isNotEmpty &&
                _adminIdTxtEdit.text.isNotEmpty &&
                _panelAddressTxtEdit.text.isNotEmpty) {
              _submitData(context);
            }
          },
          icon: const Icon(Icons.edit),
          label: const Text("ویرایش"),
        ));
        _botTokenWidgetList.add(Column(
          children: [
            CustomTextFromFieldWidget(
              controller: _botTokenTxtEdit,
              keyboardType: TextInputType.text,
              textHint: "توکن بات را وارد کنید.",
              textDirection: TextDirection.ltr,
              validationError: "توکن بات را وارد کنید را وارد کنید.",
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "توکن ربات خود را همراه با عبارت bot وارد کنید.",
                style: TextStyle(color: AppStyle.deactiveStatus),
              ),
            ),
          ],
        ));


        _showData = true;
      });
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
                    _botInfoCard(context),
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

  _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        child: ElevatedButton(
          onPressed: () {
            if (_botNameTxtEdit.text.isNotEmpty &&
                _botTokenTxtEdit.text.isNotEmpty &&
                _adminIdTxtEdit.text.isNotEmpty &&
                _panelAddressTxtEdit.text.isNotEmpty) {
              _submitData(context);
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: AppStyle.secondaryColor),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.done,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 4.0,
                ),
                Text(
                  "ثبت تغییرات",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ));
  }

  _botInfoCard(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

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
            "اطلاعات ربات",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2,
                  context: context,
                  importedList: _botInfoWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 3.2,
                  importedList: _botInfoWidgetList),
              desktop: widgetsGridview(
                  importedList: _botInfoWidgetList,
                  context: context,
                  childAspectRatio: 3.2,
                  crossAxisCount: 2),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2,
                  context: context,
                  importedList: _botTokenWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: size.width < 1400 ? 4 : 5.5,
                  importedList: _botTokenWidgetList),
              desktop: widgetsGridview(
                  importedList: _botTokenWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 4 : 5.5,
                  crossAxisCount: 1),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2,
                  context: context,
                  importedList: _botDescriptionWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: size.width < 1400 ? 4 : 5.5,
                  importedList: _botDescriptionWidgetList),
              desktop: widgetsGridview(
                  importedList: _botDescriptionWidgetList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 4 : 5.5,
                  crossAxisCount: 1),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          !Responsive.isMobile(context)
              ? SizedBox(
                  width: double.infinity,
                  child: Responsive(
                    mobile: widgetsGridview(
                        childAspectRatio: 5.5,
                        context: context,
                        importedList: _botActionWidgetList),
                    tablet: widgetsGridview(
                        context: context,
                        childAspectRatio: size.width < 1400 ? 4 : 5.5,
                        crossAxisCount: 2,
                        importedList: _botActionWidgetList),
                    desktop: widgetsGridview(
                        importedList: _botActionWidgetList,
                        context: context,
                        childAspectRatio: size.width < 1400 ? 4 : 5.5,
                        crossAxisCount: 4),
                  ),
                )
              : const Opacity(opacity: 1)
        ],
      ),
    );
  }

  void _submitData(BuildContext context) async {
    bool res = false;
    try {
      EasyLoading.show(status: '...در حال ثبت اطلاعات');

      Setting set = Setting(
          id: _setting.id,
          botName: _botNameTxtEdit.text,
          adminId: _adminIdTxtEdit.text,
          botToken: _botTokenTxtEdit.text,
          panelAddress: _panelAddressTxtEdit.text);

      res = await updateBotSetting(setting: set);

      if (res == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "دخیره شد",
              textDirection: TextDirection.rtl,
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ));
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "خطا",
              textDirection: TextDirection.rtl,
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ));
        }
      }
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();

      debugPrint(e.toString());
    }
  }
}
