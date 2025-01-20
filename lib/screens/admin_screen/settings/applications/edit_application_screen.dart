import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/application_model.dart';
import 'package:powerps/repositories/application_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class EditApplicationScreen extends StatefulWidget {
  final Application application;
  const EditApplicationScreen({super.key, required this.application});

  @override
  State<EditApplicationScreen> createState() => _EditApplicationScreenState();
}

class _EditApplicationScreenState extends State<EditApplicationScreen> {
  bool _showData = true;

  bool _isActive = true;
  final List<String> _osNameList = [
    'Android',
    'iOS',
    'MacOS',
    'Windows 64bit',
    'Windows 32bit',
    'Linux'
  ];
  String _selectedOsName = "Android";
  final _nameEditText = TextEditingController();
  final _downloadLinkEditText = TextEditingController();
//  final _fileSrcEditText = TextEditingController();
  final _howToUseEditText = TextEditingController();
  final _descriptionEditText = TextEditingController();
  final _youtubeLInkEditText = TextEditingController();
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
          context: context,
          title: "ویرایش اپلیکیشن ${widget.application.name}",
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            child: Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: Column(
                children: [
                  // const Header(title: "ویرایش بسته"),
                  SizedBox(height: AppStyle.defaultPadding),
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
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : const Opacity(opacity: 1),
      ),
    );
  }

  void _fillData() {
    setState(() {
      _isActive = widget.application.isActive;
      _selectedOsName = widget.application.os ?? "Android";
      _nameEditText.text = widget.application.name ?? "";
      _downloadLinkEditText.text = widget.application.downloadLink ?? "";
      _howToUseEditText.text = widget.application.howToUse ?? "";
      _descriptionEditText.text = widget.application.description ?? "";
      _youtubeLInkEditText.text = widget.application.youtubeLink ?? "";
      _showData = true;
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
                    _applicationInfoTabCard(context),
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

  _applicationInfoTabCard(BuildContext context) {
    final List<Widget> applicationDetailsWidgetLIst = [];
    final List<Widget> texterDetailsWidgetLIst = [];

    setState(() {
      applicationDetailsWidgetLIst.add(CustomTextFromFieldWidget(
        controller: _nameEditText,
        textHint: "نام برنامه",
        validationError: "نام برنامه را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      applicationDetailsWidgetLIst.add(Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: DropdownButtonFormField(
          isExpanded: true,
          hint: const Text('سیستم عامل'),
          value: _selectedOsName,
          alignment: Alignment.centerLeft,
          onChanged: (newValue) {
            setState(() {
              _selectedOsName = newValue.toString();
            });
          },
          items: _osNameList.map((osName) {
            return DropdownMenuItem(
              value: osName,
              alignment: Alignment.centerRight,
              child: Text(osName),
            );
          }).toList(),
        ),
      ));
      applicationDetailsWidgetLIst.add(CustomTextFromFieldWidget(
        controller: _downloadLinkEditText,
        textHint: "لینک دانلود فایل",
        validationError: "لینک دانلود فایل را وارد کنید.",
        keyboardType: TextInputType.text,
      ));

      applicationDetailsWidgetLIst.add(CustomTextFromFieldWidget(
        controller: _youtubeLInkEditText,
        textHint: "لینک آموزش برنامه در یوتیوب",
        validationError: "لینک آموزش برنامه در یوتیوب را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      applicationDetailsWidgetLIst.add(Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: SwitchListTile(
          value: _isActive,
          onChanged: (bool value) {
            setState(() {
              _isActive = value;
            });
          },
          title: const Text("نمایش به کاربر"),
        ),
      ));
      texterDetailsWidgetLIst.add(Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: TextFormField(
          controller: _howToUseEditText,
          decoration: InputDecoration(
            hintText: "آموزش استفاده",
            fillColor: AppStyle.secondaryColor,
            filled: true,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          textInputAction: TextInputAction.next,
          maxLines: 5,
          maxLength: 1000,
          scrollController: ScrollController(),
        ),
      ));
      texterDetailsWidgetLIst.add(Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: TextFormField(
          controller: _descriptionEditText,
          decoration: InputDecoration(
            hintText: "درباره برنامه",
            fillColor: AppStyle.secondaryColor,
            filled: true,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          textInputAction: TextInputAction.next,
          maxLines: 5,
          maxLength: 1000,
          scrollController: ScrollController(),
        ),
      ));

      _showData = true;
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
            "ورود اطلاعات",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.9,
                    context: context,
                    importedList: applicationDetailsWidgetLIst),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: applicationDetailsWidgetLIst),
                desktop: widgetsGridview(
                    importedList: applicationDetailsWidgetLIst,
                    context: context,
                    childAspectRatio: 4.5,
                    crossAxisCount: 2),
              )),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2,
                  context: context,
                  importedList: texterDetailsWidgetLIst),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4,
                  importedList: texterDetailsWidgetLIst),
              desktop: widgetsGridview(
                  importedList: texterDetailsWidgetLIst,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 1),
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

  void _submitData(BuildContext context) async {
    EasyLoading.show();

    if (_nameEditText.text.isNotEmpty &&
        _downloadLinkEditText.text.isNotEmpty) {
      await updateApplication(
              application: Application(
                  id: widget.application.id,
                  name: _nameEditText.text,
                  downloadLink: _downloadLinkEditText.text,
                  fileSrc: "",
                  os: _selectedOsName,
                  howToUse: _howToUseEditText.text,
                  youtubeLink: _youtubeLInkEditText.text,
                  description: _descriptionEditText.text,
                  isActive: _isActive))
          .then((value) {
        if (!context.mounted) return;

        if (value) {
          showMsg(msg: "ذخیره شد.", context: context);
          Navigator.pop(context);
        } else {
          showMsg(msg: "خطا", context: context, type: "error");
        }
      });
    } else {
      showMsg(msg: "اطلاعات درخواست شده را وارد کنید.", context: context);
    }
    EasyLoading.dismiss();
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
            ),
          ),
        ],
      ),
    );
  }
}
