import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/repositories/hiddify_repository.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class AddNewSanaeiPanelScreen extends StatefulWidget {
  const AddNewSanaeiPanelScreen({super.key});

  @override
  State<AddNewSanaeiPanelScreen> createState() => _AddNewSanaeiPanelScreenState();
}

class _AddNewSanaeiPanelScreenState extends State<AddNewSanaeiPanelScreen> {
  bool _showData = false;


  final List<String> _pannelTypes = [
    "Sanaei",
  ];
  // final List<String> _pannelTypes = [
  //   "MarzBan",
  //   "Hiddify",
  //   "دیگر",
  // ];
  String _selectedPannelType = "Sanaei";
  final _sanaeiTokenEditTxt = TextEditingController();
  final List<Widget> _selectPannelTypesWidgetList = [];
  final List<Widget> _otherWidgetList = [];
  final List<Widget> _sanaeiWidgetList = [];
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(context: context, title: "سنایی افزودن پنل"),
        body: SafeArea(
          child: SingleChildScrollView(
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
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : const Opacity(opacity: 1),
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
        icon: const Icon(Icons.add),
        label: const Text("سنایی افزودن پنل"),
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
          value: _selectedPannelType,
          alignment: Alignment.centerLeft,
          onChanged: (newValue) {
            setState(() {
              _selectedPannelType = newValue.toString();
              _showData = true;
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
      _sanaeiWidgetList.add(CustomTextFromFieldWidget(
        controller: _sanaeiTokenEditTxt,
        textHint: "توکن سنایی",
        validationError: "توکن سنایی را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      _showData = true;
    });
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


  _submitData(BuildContext context) async {
    switch (_selectedPannelType) {
      case "دیگر":
        if (context.mounted) {
          await _submitOtherSection(context);
        }
        break;
      case "Sanaei":
        if (context.mounted) {
          // await _submitSanaeiSection(context);
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
