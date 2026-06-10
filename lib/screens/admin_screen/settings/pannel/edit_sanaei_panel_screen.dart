import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helpers/sanaei_inbound_sync.dart';
import 'package:powerps/helpers/sanaei_panel_version.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/repositories/hiddify_repository.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class EditSanaeiPanelScreen extends StatefulWidget {
  final Pannel selectedPannel;
  const EditSanaeiPanelScreen({super.key, required this.selectedPannel});

  @override
  State<EditSanaeiPanelScreen> createState() => _EditSanaeiPanelScreenState();
}

class _EditSanaeiPanelScreenState extends State<EditSanaeiPanelScreen> {
  bool _showData = false;

  final List<Widget> _sanaeiWidgetList = [];
  final _locationEditTxt = TextEditingController();
  final _capacityEditTxt = TextEditingController();
  final _adminUrlEditTxt = TextEditingController();
  final _subPortEditTxt = TextEditingController();
  final _userNameEditTxt = TextEditingController();
  final _userPasswordEditTxt = TextEditingController();
  final _apiTokenEditTxt = TextEditingController();
  late String _selectedApiVersion;

  @override
  void initState() {
    _selectedApiVersion =
        SanaeiApiVersion.normalize(widget.selectedPannel.apiVersion);
    _locationEditTxt.text = widget.selectedPannel.location ?? "";
    _capacityEditTxt.text = widget.selectedPannel.capacity?.toString() ?? "";
    _adminUrlEditTxt.text = widget.selectedPannel.adminUrl ?? "";
    _subPortEditTxt.text = widget.selectedPannel.subPort ?? "";
    _userNameEditTxt.text = widget.selectedPannel.username ?? "";
    _userPasswordEditTxt.text = widget.selectedPannel.password ?? "";
    _apiTokenEditTxt.text = widget.selectedPannel.token ?? "";

    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _locationEditTxt.dispose();
    _capacityEditTxt.dispose();
    _adminUrlEditTxt.dispose();
    _subPortEditTxt.dispose();
    _userNameEditTxt.dispose();
    _userPasswordEditTxt.dispose();
    _apiTokenEditTxt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar:
              appBarWithBackButton(context: context, title: "ویرایش پنل سنایی"),
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
                await _submitData(context);
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
                      "ویرایش پنل",
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
                    _sanaeiPannelInfoCard(context),
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
          _submitData(context);
        },
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش پنل سنایی"),
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

  _sanaeiPannelInfoCard(BuildContext context) {
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
            "اطلاعات پنل",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.9,
                    context: context,
                    importedList: _sanaeiWidgetList),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: _sanaeiWidgetList),
                desktop: widgetsGridview(
                    importedList: _sanaeiWidgetList,
                    context: context,
                    childAspectRatio: 4.5,
                    crossAxisCount: 2),
              )),
          SizedBox(height: AppStyle.defaultPadding),
          SanaeiApiVersionDropdown(
            value: _selectedApiVersion,
            onChanged: (v) {
              if (v == null) return;
              setState(() => _selectedApiVersion = v);
            },
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SanaeiPanelActionButtons(
            pannelId: int.tryParse(widget.selectedPannel.id),
            adminUrlController: _adminUrlEditTxt,
            usernameController: _userNameEditTxt,
            passwordController: _userPasswordEditTxt,
            apiTokenController: _apiTokenEditTxt,
            normalizeUrl: normalizeSanaeiAdminUrl,
            apiVersion: _selectedApiVersion,
          ),
        ],
      ),
    );
  }

  void _fillData() {
    setState(() {
      _sanaeiWidgetList.add(CustomTextFromFieldWidget(
        controller: _locationEditTxt,
        textHint: "موقعیت جغرافیایی سرور",
        validationError: "کشوری که سرور در آن قرار گرفته است را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      _sanaeiWidgetList.add(CustomTextFromFieldWidget(
        controller: _capacityEditTxt,
        textHint: "ظرفیت سرور",
        validationError: "مقدار کاربری که می توانند از این سرور استفاده کنند.",
        keyboardType: TextInputType.text,
      ));
      _sanaeiWidgetList.add(CustomTextFromFieldWidget(
        controller: _adminUrlEditTxt,
        textHint: "لینک ادمین سرور",
        textDirection: TextDirection.ltr,
        validationError:
            "آدرس لینکی که با آن وارد صفحه داشبورد سرور می شوید را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      _sanaeiWidgetList.add(CustomTextFromFieldWidget(
        controller: _subPortEditTxt,
        textHint: "پورت سابسکریپشن (اختیاری)",
        textDirection: TextDirection.ltr,
        validationError: "",
        keyboardType: TextInputType.number,
      ));
      _sanaeiWidgetList.add(CustomTextFromFieldWidget(
        controller: _userNameEditTxt,
        textHint: "نام کاربری (admin)",
        validationError: "نام کاربری را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      _sanaeiWidgetList.add(CustomTextFromFieldWidget(
        controller: _userPasswordEditTxt,
        textHint: "رمز عبور (admin)",
        validationError: "رمز عبور را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      _sanaeiWidgetList.add(CustomTextFromFieldWidget(
        controller: _apiTokenEditTxt,
        textHint: "API Token (اختیاری - 3x-ui v3)",
        textDirection: TextDirection.ltr,
        validationError: "",
        keyboardType: TextInputType.text,
      ));
      _showData = true;
    });
  }

  _submitData(BuildContext context) async {
    EasyLoading.show();

    // Validate capacity safely
    int? capacity;
    try {
      capacity = int.tryParse(_capacityEditTxt.text) ?? 0;
    } catch (e) {
      capacity = 0;
    }

    if (capacity <= 0) {
      EasyLoading.dismiss();
      showMsg(msg: "ظرفیت نامعتبر است.", context: context, type: "error");
      return;
    }

    try {
      final res = await updateSanaeiPannel(
        pannel: Pannel(
            id: widget.selectedPannel.id,
            type: "sanaei",
            location: _locationEditTxt.text,
            adminUrl: normalizeSanaeiAdminUrl(_adminUrlEditTxt.text),
            subPort: _subPortEditTxt.text.trim().isEmpty
                ? null
                : _subPortEditTxt.text.trim(),
            username: _userNameEditTxt.text,
            password: _userPasswordEditTxt.text,
            token: _apiTokenEditTxt.text.trim().isEmpty
                ? null
                : _apiTokenEditTxt.text.trim(),
            apiVersion: _selectedApiVersion,
            capacity: capacity),
      );

      if (!context.mounted) return;

      EasyLoading.dismiss();
      if (res) {
        showMsg(msg: "با موفقیت ویرایش شد.", context: context);
        Navigator.pop(context, true);
        return;
      }

      showMsg(
        msg: lastPannelAddError.isNotEmpty
            ? lastPannelAddError
            : "خطا، اطلاعات وارد شده را بررسی کنید.",
        context: context,
        type: "error",
      );
    } catch (e) {
      EasyLoading.dismiss();
      if (!context.mounted) return;
      showMsg(
        msg: lastPannelAddError.isNotEmpty ? lastPannelAddError : "خطا",
        context: context,
        type: "error",
      );
    }
  }
}
