import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helpers/sanaei_inbound_sync.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/models/proxy_model.dart';
import 'package:powerps/repositories/hiddify_repository.dart';
import 'package:powerps/repositories/marzban_repository.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/screens/admin_screen/settings/pannel/edit_marzban_panel_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custom_switch_widget.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class EditPanelScreen extends StatefulWidget {
  const EditPanelScreen({super.key, required this.selectedPannel});
  final Pannel selectedPannel;
  @override
  State<EditPanelScreen> createState() => _EditPanelScreenState();
}

class _EditPanelScreenState extends State<EditPanelScreen> {
  List<Proxy> proxies = [];

  bool _showData = false;
  bool _showHiddifyData = false;
  bool _showMarzbanData = false;
  bool _showSanaeiData = false;
  bool _showProxiesData = false;
  bool _showOtherData = true;

  bool _vmessProxy = false;
  bool _vmessInboundTCP = false;
  bool _vmessinboundWebSocket = false;

  bool _vlessProxy = false;
  bool _vlessInboundTcpReality = false;
  bool _vlessInboundGprcReality = false;

  bool _trojanProxy = false;
  bool _trojanInboundWebsocketTLS = false;

  bool _shadowsocksProxy = false;
  bool _shadowsocksIboundTCP = false;
  String _selectedPannelType = "";
  String _marzbanToken = "";
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
  final _subPortEditTxt = TextEditingController();
  final _apiTokenEditTxt = TextEditingController();
  final List<Widget> _sanaeiWidgetList = [];

  @override
  void initState() {
    super.initState();
    if (widget.selectedPannel.type == 'marzban') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EditMarzbanPanelScreen(
              selectedPannel: widget.selectedPannel,
            ),
          ),
        );
      });
      return;
    }
    _fillData();
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
          appBar: appBarWithBackButton(context: context, title: "ویرایش پنل"),
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
                    // _selectPannelTypeCard(context),
                    // SizedBox(height: AppStyle.defaultPadding),
                    if (_showOtherData) _otherPannelInfoCard(context),
                    if (_showHiddifyData) _hiddifyPannelInfoCard(context),
                    if (_showSanaeiData) _sanaeiPannelInfoCard(context),
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
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش پنل"),
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
          SanaeiPanelActionButtons(
            pannelId: int.tryParse(widget.selectedPannel.id),
            adminUrlController: _adminUrlEditTxt,
            usernameController: _userNameEditTxt,
            passwordController: _userPasswordEditTxt,
            apiTokenController: _apiTokenEditTxt,
            normalizeUrl: _getHiddifyUrl,
          ),
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

  Future<void> _fillData() async {
    switch (widget.selectedPannel.type) {
      case "hiddify":
        _selectedPannelType = "Hiddify";
        _showMarzbanData = false;
        _showHiddifyData = true;
        _showProxiesData = false;
        _showOtherData = false;

        break;
      case 'sanaei':
      case 'Sanaei':
        _selectedPannelType = "Sanaei";
        _showMarzbanData = false;
        _showHiddifyData = false;
        _showProxiesData = false;
        _showOtherData = false;
        _showSanaeiData = true;

        break;
      case "custome":
        _selectedPannelType = "دیگر";
        _showMarzbanData = false;
        _showHiddifyData = false;
        _showProxiesData = false;
        _showOtherData = true;

        break;
      case "marzban":
        _selectedPannelType = "MarzBan";
        _showMarzbanData = true;
        _showHiddifyData = false;
        _showOtherData = false;
        _showProxiesData = true;

        break;
      default:
        _selectedPannelType = "دیگر";
    }
    _marzbanToken = widget.selectedPannel.token ?? "";
    _apiTokenEditTxt.text = widget.selectedPannel.token ?? "";
    _locationEditTxt.text = widget.selectedPannel.location ?? "";
    _capacityEditTxt.text = widget.selectedPannel.capacity.toString();
    _userNameEditTxt.text = widget.selectedPannel.username ?? "";
    _userPasswordEditTxt.text = widget.selectedPannel.password ?? "";
    _urlPortEditTxt.text = widget.selectedPannel.urlPort ?? "";
    _subPortEditTxt.text = widget.selectedPannel.subPort ?? "";
    _adminUrlEditTxt.text = widget.selectedPannel.adminUrl ?? "";
    _secretCodeEditTxt.text = widget.selectedPannel.secretCode ?? "";
    _userLinkEditTxt.text = widget.selectedPannel.userLink ?? "";
    _showData = false;
    if (widget.selectedPannel.type == 'marzban') {
      await getProxiesByPannelID(pannelId: int.parse(widget.selectedPannel.id))
          .then((value) {
        if (value.isEmpty) return;
        for (final i in value) {
          if (i.type == 'vmess') {
            setState(() {
              _vmessProxy = i.isActive;
              for (final j in i.inbounds ?? []) {
                if (j.name == 'VMess TCP') {
                  _vmessInboundTCP = j.isActive;
                }
                if (j.name == 'VMess Websocket') {
                  _vmessinboundWebSocket = j.isActive;
                }
              }
            });
          } else if (i.type == 'vless') {
            setState(() {
              _vlessProxy = i.isActive;
              for (final j in i.inbounds ?? []) {
                if (j.name == 'VLESS TCP REALITY') {
                  _vlessInboundTcpReality = j.isActive;
                }
                if (j.name == 'VLESS GRPC REALITY') {
                  _vlessInboundGprcReality = j.isActive;
                }
              }
            });
          } else if (i.type == 'trojan') {
            setState(() {
              _trojanProxy = i.isActive;
              for (final j in i.inbounds ?? []) {
                if (j.name == 'Trojan Websocket TLS') {
                  _trojanInboundWebsocketTLS = j.isActive;
                }
              }
            });
          } else if (i.type == 'shadowsocks') {
            setState(() {
              _shadowsocksProxy = i.isActive;
              for (final j in i.inbounds ?? []) {
                if (j.name == 'Shadowsocks TCP') {
                  _shadowsocksIboundTCP = j.isActive;
                }
              }
            });
          }
        }
      });
    }
    setState(() {
      _otherWidgetList.add(CustomTextFromFieldWidget(
        controller: _locationEditTxt,
        textHint: "موقعیت جغرافیایی سرور",
        validationError: "کشوری که سرور در آن قرار گرفته است را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      // Sanaei specific widgets
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
      _sanaeiWidgetList.add(CustomTextFromFieldWidget(
        controller: _capacityEditTxt,
        textHint: "ظرفیت سرور",
        validationError: "مقدار کاربری که می توانند از این سرور استفاده کنند.",
        keyboardType: TextInputType.number,
      ));
      // _otherWidgetList.add(CustomTextFromFieldWidget(
      //   controller: _capacityEditTxt,
      //   textHint: "ظرفیت سرور",
      //   validationError: "مقدار کاربری که می توانند از این سرور استفاده کنند.",
      //   keyboardType: TextInputType.text,
      // ));
      _marzbanWidgetList.add(CustomTextFromFieldWidget(
        controller: _urlPortEditTxt,
        textDirection: TextDirection.ltr,
        textHint: "url و port صفحه لاگین",
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
        textHint: "لینک ادمین سرور",
        textDirection: TextDirection.ltr,
        validationError:
            "آدرس لینکی که با آن وارد صفحه داشبورد سرور می شوید را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      _hiddifyWidgetList.add(CustomTextFromFieldWidget(
        controller: _userLinkEditTxt,
        textHint: "لینک کاربران سرور",
        textDirection: TextDirection.ltr,
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
          validationError:
              "مقدار کاربری که می توانند از این سرور استفاده کنند.",
          keyboardType: TextInputType.number));

      _showData = true;
    });
  }

  String _getMarzbanUrl(String text) {
    final uri = Uri.parse(text);
    String str = "";

    str = "${uri.scheme}://${uri.host}:${uri.port}";
    return str;
  }

  _submitSanaeiSection(BuildContext context) async {
    EasyLoading.show();
    final capacity = int.tryParse(_capacityEditTxt.text) ?? 0;
    if (capacity <= 0) {
      EasyLoading.dismiss();
      showMsg(msg: "ظرفیت نامعتبر است.", context: context, type: "error");
      return;
    }
    var res = await updatePannel(
      pannel: Pannel(
        id: widget.selectedPannel.id,
        type: "sanaei",
        location: _locationEditTxt.text,
        adminUrl: _getHiddifyUrl(_adminUrlEditTxt.text),
        subPort: _subPortEditTxt.text,
        username: _userNameEditTxt.text,
        password: _userPasswordEditTxt.text,
        token: _apiTokenEditTxt.text.trim().isEmpty
            ? null
            : _apiTokenEditTxt.text.trim(),
        capacity: capacity,
      ),
    );
    EasyLoading.dismiss();
    if (!context.mounted) return;
    if (res == true) {
      showMsg(msg: "با موفقیت ثبت شد.", context: context);
      Navigator.pop(context, true);
    } else {
      showMsg(
        msg: "خطا، اطلاعات وارد شده را بررسی کنید.",
        context: context,
        type: "error",
      );
    }
  }

  _submitOtherSection(BuildContext context) async {
    EasyLoading.show();

    var res = await updatePannel(
        pannel: Pannel(
            id: widget.selectedPannel.id,
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

    var res = await updateHiddifyPannel(
      pannel: Pannel(
          id: widget.selectedPannel.id,
          type: "hiddify",
          location: _locationEditTxt.text,
          adminUrl: _getHiddifyUrl(_adminUrlEditTxt.text),
          secretCode: _secretCodeEditTxt.text,
          capacity: int.parse(_capacityEditTxt.text),
          userLink: _userLinkEditTxt.text),
    );
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

  _submitMarzbanSection(BuildContext context) async {
    EasyLoading.show();
    var res = await editMarzbanPannel(
        pannel: Pannel(
          id: widget.selectedPannel.id,
          type: "marzban",
          location: _locationEditTxt.text,
          urlPort: _urlPortEditTxt.text,
          username: _userNameEditTxt.text,
          password: _userPasswordEditTxt.text,
          token: _marzbanToken,
          capacity: int.parse(_capacityEditTxt.text),
        ),
        dynamicInbounds: []);
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
      case "Sanaei":
        if (context.mounted) {
          await _submitSanaeiSection(context);
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
