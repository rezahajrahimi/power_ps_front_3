import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helpers/marzban_proxy_settings.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/repositories/marzban_repository.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class EditMarzbanPanelScreen extends StatefulWidget {
  final Pannel selectedPannel;
  const EditMarzbanPanelScreen({super.key, required this.selectedPannel});

  @override
  State<EditMarzbanPanelScreen> createState() => _EditMarzbanPanelScreenState();
}

class _EditMarzbanPanelScreenState extends State<EditMarzbanPanelScreen> {
  bool _showData = false;
  String _marzbanToken = "";

  final List<Widget> _marzbanWidgetList = [];
  final _locationEditTxt = TextEditingController();
  final _capacityEditTxt = TextEditingController();
  final _urlPortEditTxt = TextEditingController();
  final _userNameEditTxt = TextEditingController();
  final _userPasswordEditTxt = TextEditingController();
  final _proxySettings = MarzbanProxySettings();

  @override
  void initState() {
    _marzbanToken = widget.selectedPannel.token ?? "";
    _locationEditTxt.text = widget.selectedPannel.location ?? "";
    _capacityEditTxt.text = widget.selectedPannel.capacity?.toString() ?? "";
    _urlPortEditTxt.text = widget.selectedPannel.urlPort ?? "";
    _userNameEditTxt.text = widget.selectedPannel.username ?? "";
    _userPasswordEditTxt.text = widget.selectedPannel.password ?? "";
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    _locationEditTxt.dispose();
    _capacityEditTxt.dispose();
    _urlPortEditTxt.dispose();
    _userNameEditTxt.dispose();
    _userPasswordEditTxt.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    await _loadInboundsFromPanel();
    final proxies =
        await getProxiesByPannelID(pannelId: int.parse(widget.selectedPannel.id));
    if (_proxySettings.isLoaded && proxies.isNotEmpty) {
      _proxySettings.applyFromSavedProxies(proxies);
    }
    _fillFields();
    if (mounted) setState(() {});
  }

  Future<void> _loadInboundsFromPanel() async {
    if (_marzbanToken.isEmpty ||
        _urlPortEditTxt.text.isEmpty ||
        _userNameEditTxt.text.isEmpty ||
        _userPasswordEditTxt.text.isEmpty) {
      return;
    }

    final url = _getMarzbanUrl(_urlPortEditTxt.text);
    var token = _marzbanToken;
    if (!token.toLowerCase().startsWith('bearer ')) {
      final fresh = await checkIsMarzbanUrl(
        url: url,
        password: _userPasswordEditTxt.text.trim(),
        username: _userNameEditTxt.text.trim(),
      );
      if (fresh != null) token = fresh;
    }

    final inbounds = await fetchMarzbanPanelInbounds(url: url, token: token);
    if (inbounds != null && inbounds.isNotEmpty) {
      _proxySettings.loadFromPanel(inbounds);
      _marzbanToken = token;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
              context: context, title: "ویرایش پنل مرزبان"),
          body: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _showData
                ? _content(context)
                : const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  ),
          ),
          bottomNavigationBar: Responsive.isMobile(context)
              ? _buildBottomNavigationBar(context)
              : const Opacity(opacity: 1),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () => _submitData(context),
        style: ElevatedButton.styleFrom(backgroundColor: AppStyle.secondaryColor),
        child: const Text("ویرایش پنل", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _marzbanInfoCard(context),
                  SizedBox(height: AppStyle.defaultPadding),
                  MarzbanProxiesCard(
                    settings: _proxySettings,
                    onChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
            if (!Responsive.isMobile(context)) ...[
              SizedBox(width: AppStyle.defaultPadding),
              Expanded(
                flex: 2,
                child: _operationInfoCard(context),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _operationInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("عملیات ها", style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppStyle.defaultPadding),
          ElevatedButton.icon(
            onPressed: () => _submitData(context),
            icon: const Icon(Icons.edit),
            label: const Text("ذخیره تغییرات"),
          ),
        ],
      ),
    );
  }

  Widget _marzbanInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("اطلاعات پنل", style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: _marzbanWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: _marzbanWidgetList),
              desktop: widgetsGridview(
                  importedList: _marzbanWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          ElevatedButton.icon(
            onPressed: () async {
              if (_urlPortEditTxt.text.isEmpty) return;
              EasyLoading.show();
              final url = _getMarzbanUrl(_urlPortEditTxt.text);
              final token = await checkIsMarzbanUrl(
                url: url,
                password: _userPasswordEditTxt.text.trim(),
                username: _userNameEditTxt.text.trim(),
              );
              if (token == null) {
                EasyLoading.dismiss();
                if (!context.mounted) return;
                showMsg(
                    msg: "اتصال ناموفق.",
                    context: context,
                    type: "error");
                return;
              }

              final inbounds = await fetchMarzbanPanelInbounds(
                url: url,
                token: token,
              );
              EasyLoading.dismiss();
              if (!context.mounted) return;

              if (inbounds == null || inbounds.isEmpty) {
                showMsg(
                    msg: "inbound فعالی در پنل مرزبان یافت نشد.",
                    context: context,
                    type: "error");
                return;
              }

              final saved = await getProxiesByPannelID(
                  pannelId: int.parse(widget.selectedPannel.id));

              setState(() {
                _marzbanToken = token;
                _proxySettings.loadFromPanel(inbounds);
                if (saved.isNotEmpty) {
                  _proxySettings.applyFromSavedProxies(saved);
                }
              });
              if (context.mounted) {
                showMsg(msg: "اتصال موفق", context: context);
              }
            },
            icon: const Icon(Icons.checklist_rtl),
            label: const Text("بررسی اتصال"),
          ),
        ],
      ),
    );
  }

  String _getMarzbanUrl(String str) {
    var url = str.trim();
    url = url.replaceAll('/dashboard/', '');
    url = url.replaceAll('/dashboard', '');
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  void _fillFields() {
    _marzbanWidgetList.addAll([
      CustomTextFromFieldWidget(
        controller: _urlPortEditTxt,
        textHint: "url و port صفحه لاگین",
        textDirection: TextDirection.ltr,
        validationError: "آدرس داشبورد مرزبان را وارد کنید.",
        keyboardType: TextInputType.url,
      ),
      CustomTextFromFieldWidget(
        controller: _userNameEditTxt,
        textHint: "User Name",
        textDirection: TextDirection.ltr,
        validationError: "نام کاربری ادمین را وارد کنید",
        keyboardType: TextInputType.text,
      ),
      CustomTextFromFieldWidget(
        controller: _userPasswordEditTxt,
        textHint: "Password",
        textDirection: TextDirection.ltr,
        validationError: "رمز عبور ادمین را وارد کنید",
        keyboardType: TextInputType.text,
      ),
      CustomTextFromFieldWidget(
        controller: _locationEditTxt,
        textHint: "موقعیت جغرافیایی سرور",
        validationError: "موقعیت سرور را وارد کنید.",
        keyboardType: TextInputType.text,
      ),
      CustomTextFromFieldWidget(
        controller: _capacityEditTxt,
        textHint: "ظرفیت سرور",
        validationError: "ظرفیت سرور را وارد کنید.",
        keyboardType: TextInputType.number,
      ),
    ]);
    setState(() => _showData = true);
  }

  Future<void> _submitData(BuildContext context) async {
    if (_marzbanToken.isEmpty) {
      showMsg(
          msg: "توکن API موجود نیست. «بررسی اتصال» را بزنید.",
          context: context,
          type: "error");
      return;
    }

    if (!_proxySettings.isLoaded) {
      showMsg(
          msg: "inboundهای پنل بارگذاری نشده. «بررسی اتصال» را بزنید.",
          context: context,
          type: "error");
      return;
    }

    final capacity = int.tryParse(_capacityEditTxt.text) ?? 0;
    if (capacity <= 0) {
      showMsg(msg: "ظرفیت نامعتبر است.", context: context, type: "error");
      return;
    }

    EasyLoading.show();
    try {
      final res = await editMarzbanPannel(
        pannel: Pannel(
          id: widget.selectedPannel.id,
          type: "marzban",
          location: _locationEditTxt.text,
          urlPort: _urlPortEditTxt.text,
          username: _userNameEditTxt.text,
          password: _userPasswordEditTxt.text,
          token: _marzbanToken,
          capacity: capacity,
        ),
        dynamicInbounds: _proxySettings.toApiPayload(),
      );

      EasyLoading.dismiss();
      if (!context.mounted) return;

      if (res) {
        showMsg(msg: "با موفقیت ویرایش شد.", context: context);
        Navigator.pop(context, true);
      } else {
        showMsg(
            msg: "خطا، اطلاعات وارد شده را بررسی کنید.",
            context: context,
            type: "error");
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (context.mounted) {
        showMsg(msg: "خطا", context: context, type: "error");
      }
    }
  }
}
