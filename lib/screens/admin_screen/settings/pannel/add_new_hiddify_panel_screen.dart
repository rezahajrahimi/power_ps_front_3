import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/repositories/hiddify_repository.dart';
import 'package:powerps/repositories/marzban_repository.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custom_switch_widget.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class AddNewHiddifyPanelScreen extends StatefulWidget {
  const AddNewHiddifyPanelScreen({super.key});

  @override
  State<AddNewHiddifyPanelScreen> createState() =>
      _AddNewHiddifyPanelScreenState();
}

class _AddNewHiddifyPanelScreenState extends State<AddNewHiddifyPanelScreen> {
  bool _showData = false;
  bool _showHiddifyData = true;
  bool _showMarzbanData = false;
  bool _showProxiesData = false;
  bool _showOtherData = false;

  bool _vmessProxy = true;
  bool _vmessInboundTCP = true;
  bool _vmessinboundWebSocket = true;

  bool _vlessProxy = true;
  bool _vlessInboundTcpReality = true;
  bool _vlessInboundGprcReality = true;

  bool _trojanProxy = true;
  bool _trojanInboundWebsocketTLS = true;

  bool _shadowsocksProxy = true;
  bool _shadowsocksIboundTCP = true;
  final List<String> _pannelTypes = [
    "Hiddify",
  ];
  // final List<String> _pannelTypes = [
  //   "MarzBan",
  //   "Hiddify",
  //   "دیگر",
  // ];
  String _selectedPannelType = "Hiddify";
  String _marzbanToken = "";
  final List<Widget> _selectPannelTypesWidgetList = [];
  final List<Widget> _otherWidgetList = [];
  final List<Widget> _hiddifyWidgetList = [];
  final List<Widget> _marzbanWidgetList = [];
  final _locationEditTxt = TextEditingController();
  final _capacityEditTxt = TextEditingController();
  final _userNameEditTxt = TextEditingController();
  final _userPasswordEditTxt = TextEditingController();
  final _urlPortEditTxt = TextEditingController();
  final _adminUrlEditTxt = TextEditingController();
  final _secretCodeEditTxt = TextEditingController();
  final _userLinkEditTxt = TextEditingController();

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
              context: context, title: "هیدیفای افزودن پنل"),
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
                      Icons.add,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "افزودن پنل",
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
                    // _selectPannelTypeCard(context),
                    // SizedBox(height: AppStyle.defaultPadding),
                    if (_showOtherData) _otherPannelInfoCard(context),
                    if (_showHiddifyData) _hiddifyPannelInfoCard(context),
                    if (_showMarzbanData) _marzbanPannelInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    if (_showProxiesData) _marzbanProxiesInfoCard(context),
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
        icon: const Icon(Icons.add),
        label: const Text("هیدیفای افزودن پنل"),
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

  // _selectPannelTypeCard(BuildContext context) {
  //   return Container(
  //     padding: EdgeInsets.all(AppStyle.defaultPadding),
  //     decoration: BoxDecoration(
  //       color: AppStyle.secondaryColor,
  //       borderRadius: const BorderRadius.all(Radius.circular(10)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           "انتخاب نوع پنل",
  //           style: Theme.of(context).textTheme.titleMedium,
  //         ),
  //         SizedBox(height: AppStyle.defaultPadding),
  //         SizedBox(
  //             width: double.infinity,
  //             child: Responsive(
  //               mobile: widgetsGridview(
  //                   childAspectRatio: 2.9,
  //                   context: context,
  //                   importedList: _selectPannelTypesWidgetList),
  //               tablet: widgetsGridview(
  //                   context: context,
  //                   childAspectRatio: 4.5,
  //                   importedList: _selectPannelTypesWidgetList),
  //               desktop: widgetsGridview(
  //                   importedList: _selectPannelTypesWidgetList,
  //                   context: context,
  //                   childAspectRatio: 4.5,
  //                   crossAxisCount: 2),
  //             )),
  //       ],
  //     ),
  //   );
  // }

  _otherPannelInfoCard(BuildContext context) {
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
                    importedList: _otherWidgetList),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: _otherWidgetList),
                desktop: widgetsGridview(
                    importedList: _otherWidgetList,
                    context: context,
                    childAspectRatio: 4.5,
                    crossAxisCount: 2),
              )),
        ],
      ),
    );
  }

  _hiddifyPannelInfoCard(BuildContext context) {
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
                    importedList: _hiddifyWidgetList),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: _hiddifyWidgetList),
                desktop: widgetsGridview(
                    importedList: _hiddifyWidgetList,
                    context: context,
                    childAspectRatio: 4.5,
                    crossAxisCount: 2),
              )),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppStyle.defaultPadding * 1.5,
                        vertical: AppStyle.defaultPadding /
                            (Responsive.isMobile(context) ? 2 : 1),
                      ),
                    ),
                    onPressed: () async {
                      if (_adminUrlEditTxt.text.isNotEmpty &&
                          _secretCodeEditTxt.text.isNotEmpty &&
                          _userLinkEditTxt.text.isNotEmpty) {
                        EasyLoading.show();
                        await checkIsHiddifyUrl(
                                url: _getHiddifyUrl(_adminUrlEditTxt.text),
                                secretCode: _secretCodeEditTxt.text)
                            .then((value) {
                          EasyLoading.dismiss();
                          if (!context.mounted) return;

                          if (value == true) {
                            showMsg(msg: "موفق", context: context);
                            return;
                          }
                          showMsg(
                              msg: "ناموفق، اطلاعات وارد شده را بررسی کنید.",
                              context: context,
                              type: "error");
                        });
                      }
                    },
                    icon: const Icon(Icons.checklist_rtl),
                    label: const Text("بررسی لینک "),
                  )
                ],
              )),
        ],
      ),
    );
  }

  String _getHiddifyUrl(String str) {
    try {
      var res = str.substring(0, str.indexOf('admin'));
      return res;
    } catch (e) {
      return str;
    }
  }

  _marzbanPannelInfoCard(BuildContext context) {
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
              )),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppStyle.defaultPadding * 1.5,
                        vertical: AppStyle.defaultPadding /
                            (Responsive.isMobile(context) ? 2 : 1),
                      ),
                    ),
                    onPressed: () async {
                      if (_urlPortEditTxt.text.isNotEmpty) {
                        EasyLoading.show();

                        String str = _getMarzbanUrl(_urlPortEditTxt.text);
                        var res = await checkIsMarzbanUrl(
                            url: str,
                            password: _userPasswordEditTxt.text.trim(),
                            username: _userNameEditTxt.text.trim());
                        EasyLoading.dismiss();

                        if (res != null) {
                          if (context.mounted) {
                            setState(() {
                              _marzbanToken = res;
                              debugPrint(_marzbanToken);
                            });
                            showMsg(msg: "موفق", context: context);
                          }
                        } else {
                          if (context.mounted) {
                            showMsg(
                                msg:
                                    "ناموفق، لینکی که برای اتصال به پنل استفاده می کنید را وارد کنید.",
                                context: context,
                                type: "error");
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.checklist_rtl),
                    label: const Text("بررسی لینک "),
                  )
                ],
              )),
        ],
      ),
    );
  }

  _marzbanProxiesInfoCard(BuildContext context) {
    List<Widget> vmess = [];
    List<Widget> vless = [];
    List<Widget> trojan = [];
    List<Widget> shadowsocks = [];
    setState(() {
      vmess.add(CustomSwitchWidget(
        title: "VMESS TCP (TCP)",
        val: _vmessInboundTCP,
        callback: (bool val) {
          setState(() {
            _vmessInboundTCP = val;
          });
        },
      ));
      vmess.add(CustomSwitchWidget(
        title: "VMESS WEBSOCKET (WS)",
        val: _vmessinboundWebSocket,
        callback: (bool val) {
          setState(() {
            _vmessinboundWebSocket = val;
          });
        },
      ));

      vless.add(CustomSwitchWidget(
        title: "VLESS TCP REALITY (TCP)",
        val: _vlessInboundTcpReality,
        callback: (bool val) {
          setState(() {
            _vlessInboundTcpReality = val;
          });
        },
      ));
      vless.add(CustomSwitchWidget(
        title: "VLESS GPRC REALITY (GPRC)",
        val: _vlessInboundGprcReality,
        callback: (bool val) {
          setState(() {
            _vlessInboundGprcReality = val;
          });
        },
      ));

      trojan.add(CustomSwitchWidget(
        title: "TROJAN WEBSOCKET TLS (WS)",
        val: _trojanInboundWebsocketTLS,
        callback: (bool val) {
          setState(() {
            _trojanInboundWebsocketTLS = val;
          });
        },
      ));
      shadowsocks.add(CustomSwitchWidget(
        title: "SHADOWSOCKS TCP (TCP)",
        val: _shadowsocksIboundTCP,
        callback: (bool val) {
          setState(() {
            _shadowsocksIboundTCP = val;
          });
        },
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
            "Protocols",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: CustomSwitchWidget(
                title: "VMESS",
                val: _vmessProxy,
                callback: (bool val) {
                  setState(() {
                    _vmessProxy = val;
                    if (!val) {
                      _vmessInboundTCP = false;
                      _vmessinboundWebSocket = false;
                    } else {
                      _vmessInboundTCP = true;
                      _vmessinboundWebSocket = true;
                    }
                  });
                },
              )),
          Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: const Text("VMESS Inbounds:")),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.9,
                    context: context,
                    importedList: vmess),
                tablet: widgetsGridview(
                    context: context, childAspectRatio: 6, importedList: vmess),
                desktop: widgetsGridview(
                    importedList: vmess,
                    context: context,
                    childAspectRatio: 6,
                    crossAxisCount: 2),
              )),
          SizedBox(
            height: AppStyle.defaultPadding,
          ),
          Divider(
              thickness: 5,
              color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          SizedBox(
              width: double.infinity,
              child: CustomSwitchWidget(
                title: "VLESS",
                val: _vlessProxy,
                callback: (bool val) {
                  setState(() {
                    _vlessProxy = val;
                    if (!val) {
                      _vlessInboundTcpReality = false;
                      _vlessInboundGprcReality = false;
                    } else {
                      _vlessInboundTcpReality = true;
                      _vlessInboundGprcReality = true;
                    }
                  });
                },
              )),
          Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: const Text("VLESS Inbounds:")),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.9,
                    context: context,
                    importedList: vless),
                tablet: widgetsGridview(
                    context: context, childAspectRatio: 6, importedList: vless),
                desktop: widgetsGridview(
                    importedList: vless,
                    context: context,
                    childAspectRatio: 6,
                    crossAxisCount: 2),
              )),
          SizedBox(height: AppStyle.defaultPadding),
          Divider(
              thickness: 5,
              color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          SizedBox(
              width: double.infinity,
              child: CustomSwitchWidget(
                title: "TROJAN",
                val: _trojanProxy,
                callback: (bool val) {
                  setState(() {
                    _trojanProxy = val;
                    if (!val) {
                      _trojanInboundWebsocketTLS = false;
                    } else {
                      _trojanInboundWebsocketTLS = true;
                    }
                  });
                },
              )),
          Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: const Text("TROJAN Inbounds:")),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.9,
                    context: context,
                    importedList: trojan),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 6,
                    importedList: trojan),
                desktop: widgetsGridview(
                    importedList: trojan,
                    context: context,
                    childAspectRatio: 6,
                    crossAxisCount: 2),
              )),
          SizedBox(height: AppStyle.defaultPadding),
          Divider(
              thickness: 5,
              color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          SizedBox(
              width: double.infinity,
              child: CustomSwitchWidget(
                title: "SHADOWSOCKS",
                val: _shadowsocksProxy,
                callback: (bool val) {
                  setState(() {
                    _shadowsocksProxy = val;
                    if (!val) {
                      _shadowsocksIboundTCP = false;
                    }
                  });
                },
              )),
          Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: const Text("SHADOWSOCKS Inbounds:")),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.9,
                    context: context,
                    importedList: shadowsocks),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 6,
                    importedList: shadowsocks),
                desktop: widgetsGridview(
                    importedList: shadowsocks,
                    context: context,
                    childAspectRatio: 6,
                    crossAxisCount: 2),
              )),
        ],
      ),
    );
  }

  void _fillData() {
    setState(() {
      _selectPannelTypesWidgetList.add(Container(
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
          hint: const Text('نوع پنل'),
          initialValue: _selectedPannelType,
          alignment: Alignment.centerLeft,
          onChanged: (newValue) {
            setState(() {
              _selectedPannelType = newValue.toString();
              switch (_selectedPannelType) {
                case "MarzBan":
                  _showMarzbanData = true;
                  _showHiddifyData = false;
                  _showOtherData = false;
                  _showProxiesData = true;
                  break;
                case "Hiddify":
                  _showMarzbanData = false;
                  _showHiddifyData = true;
                  _showProxiesData = false;
                  _showOtherData = false;
                  break;
                case "دیگر":
                  _showMarzbanData = false;
                  _showHiddifyData = false;
                  _showProxiesData = false;
                  _showOtherData = true;
                  break;

                default:
                  _showMarzbanData = false;
                  _showHiddifyData = false;
                  _showProxiesData = false;
                  _showOtherData = false;
              }
            });
          },
          items: _pannelTypes.map((clType) {
            return DropdownMenuItem(
              value: clType,
              alignment: Alignment.centerRight,
              child: Text(clType),
            );
          }).toList(),
        ),
      ));
      _otherWidgetList.add(CustomTextFromFieldWidget(
        controller: _locationEditTxt,
        textHint: "موقعیت جغرافیایی سرور",
        validationError: "کشوری که سرور در آن قرار گرفته است را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      _otherWidgetList.add(CustomTextFromFieldWidget(
        controller: _capacityEditTxt,
        textHint: "ظرفیت سرور",
        validationError: "مقدار کاربری که می توانند از این سرور استفاده کنند.",
        keyboardType: TextInputType.text,
      ));
      _marzbanWidgetList.add(CustomTextFromFieldWidget(
        controller: _urlPortEditTxt,
        textHint: "url و port صفحه لاگین",
        textDirection: TextDirection.ltr,
        validationError:
            "آدرس لینکی که با آن وارد صفحه داشبورد سرور می شوید را وارد کنید.",
        keyboardType: TextInputType.url,
      ));
      _marzbanWidgetList.add(CustomTextFromFieldWidget(
        controller: _userNameEditTxt,
        textHint: "User Name",
        textDirection: TextDirection.ltr,
        validationError: "نام کاربری ادمین سرور را وارد کنید",
        keyboardType: TextInputType.text,
      ));
      _marzbanWidgetList.add(CustomTextFromFieldWidget(
        controller: _userPasswordEditTxt,
        textHint: "Password",
        textDirection: TextDirection.ltr,
        validationError: "رمز عبور، ادمین سرور را وارد کنید",
        keyboardType: TextInputType.text,
      ));
      _marzbanWidgetList.add(CustomTextFromFieldWidget(
        controller: _locationEditTxt,
        textHint: "موقعیت جغرافیایی سرور",
        validationError: "کشوری که سرور در آن قرار گرفته است را وارد کنید.",
        keyboardType: TextInputType.text,
      ));

      // _marzbanWidgetList.add(CustomTextFromFieldWidget(
      //   controller: _capacityEditTxt,
      //   textHint: "ظرفیت سرور",
      //   validationError: "مقدار کاربری که می توانند از این سرور استفاده کنند.",
      //   keyboardType: TextInputType.text,
      // ));

      _hiddifyWidgetList.add(CustomTextFromFieldWidget(
        controller: _adminUrlEditTxt,
        textDirection: TextDirection.ltr,
        textHint: "لینک ادمین سرور",
        validationError:
            "آدرس لینکی که با آن وارد صفحه داشبورد سرور می شوید را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      _hiddifyWidgetList.add(CustomTextFromFieldWidget(
        controller: _userLinkEditTxt,
        textDirection: TextDirection.ltr,
        textHint: "لینک کاربران سرور",
        validationError:
            "آدرس لینکی که با آن وارد صفحه کاربران سرور می شوید را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      _hiddifyWidgetList.add(CustomTextFromFieldWidget(
        controller: _secretCodeEditTxt,
        textDirection: TextDirection.ltr,
        textHint: "secret code",
        validationError: "secret code را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      _hiddifyWidgetList.add(CustomTextFromFieldWidget(
        controller: _locationEditTxt,
        textHint: "موقعیت جغرافیایی سرور",
        validationError: "کشوری که سرور در آن قرار گرفته است را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      _hiddifyWidgetList.add(CustomTextFromFieldWidget(
        controller: _capacityEditTxt,
        textHint: "ظرفیت سرور",
        textDirection: TextDirection.ltr,
        validationError: "مقدار کاربری که می توانند از این سرور استفاده کنند.",
        keyboardType: TextInputType.number,
      ));

      _showData = true;
    });
  }

  String _getMarzbanUrl(String text) {
    final uri = Uri.parse(text);
    String str = "";

    str = "${uri.scheme}://${uri.host}:${uri.port}";
    return str;
  }

  _submitOtherSection(BuildContext context) async {
    EasyLoading.show();

    var res = await addNewPannel(
        pannel: Pannel(
            id: "1",
            type: "custome",
            location: _locationEditTxt.text,
            capacity: int.parse(_capacityEditTxt.text)));
    if (res) {
      if (context.mounted) {
        showMsg(msg: "با موفقیت ثبت شد.", context: context);
        Navigator.pop(context);
      }
    } else {
      if (context.mounted) {
        showMsg(
            msg: "خطا، اطلاعات وارد شده را بررسی کنید.",
            context: context,
            type: "error");
      }
    }
    EasyLoading.dismiss();
  }

  _submitHiddifySection(BuildContext context) async {
    EasyLoading.show();

    await addHiddifyPannel(
      pannel: Pannel(
          id: "1",
          type: "hiddify",
          location: _locationEditTxt.text,
          adminUrl: _getHiddifyUrl(_adminUrlEditTxt.text),
          secretCode: _secretCodeEditTxt.text,
          userLink: _userLinkEditTxt.text,
          capacity: int.parse(_capacityEditTxt.text)),
    ).then((res) {
      if (!context.mounted) return;

      if (res == true) {
        EasyLoading.dismiss();

        showMsg(msg: "با موفقیت ثبت شد.", context: context);
        Navigator.pop(context);
        return;
      } else if (res.runtimeType == String) {
        EasyLoading.dismiss();

        showMsg(msg: "$res", context: context, type: "error");
        Navigator.pop(context);
        return;
      }
      showMsg(
          msg: "خطا، اطلاعات وارد شده را بررسی کنید.",
          context: context,
          type: "error");

      EasyLoading.dismiss();
    }).onError((e, s) {
      EasyLoading.dismiss();

      if (!context.mounted) return;
      showMsg(msg: "خطا", context: context, type: "error");
    });
  }

  _submitMarzbanSection(BuildContext context) async {
    EasyLoading.show();

    var res = await addNewPannelMarzban(
        pannel: Pannel(
          id: "1",
          type: "marzban",
          location: _locationEditTxt.text,
          urlPort: _urlPortEditTxt.text,
          username: _userNameEditTxt.text,
          password: _userPasswordEditTxt.text,
          token: _marzbanToken,
          capacity: int.parse(_capacityEditTxt.text),
        ),
        vmess: _vmessProxy,
        vless: _vlessProxy,
        trojan: _trojanProxy,
        shadowsocks: _shadowsocksProxy,
        vmessTCP: _vmessInboundTCP,
        shadowsocksTCP: _shadowsocksIboundTCP,
        trojanWebsocketTLS: _trojanInboundWebsocketTLS,
        vlessGprcReality: _vlessInboundGprcReality,
        vlessTcpReality: _vlessInboundTcpReality,
        vmessWebSocket: _vmessinboundWebSocket);
    if (res) {
      if (context.mounted) {
        showMsg(msg: "با موفقیت ثبت شد.", context: context);
        Navigator.pop(context);
      }
    } else {
      if (context.mounted) {
        showMsg(
            msg: "خطا، اطلاعات وارد شده را بررسی کنید.",
            context: context,
            type: "error");
      }
    }
    EasyLoading.dismiss();
  }

  _submitData(BuildContext context) async {
    switch (_selectedPannelType) {
      case "دیگر":
        if (context.mounted) {
          await _submitOtherSection(context);
        }
        break;
      case "Hiddify":
        if (context.mounted) {
          await _submitHiddifySection(context);
        }
        break;
      case "MarzBan":
        if (_marzbanToken.isNotEmpty) {
          if (context.mounted) {
            await _submitMarzbanSection(context);
          }
        } else {
          if (context.mounted) {
            showMsg(
                msg: "ابتدا بر روی بررسی لینک کلیک کنید.", context: context);
          }
        }
        break;

      default:
        if (context.mounted) {
          await _submitOtherSection(context);
        }
    }
    EasyLoading.dismiss();
  }
}
