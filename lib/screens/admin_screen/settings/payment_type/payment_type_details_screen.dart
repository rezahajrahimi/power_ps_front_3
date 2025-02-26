import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/crypto_payment_gateway_model.dart';
import 'package:powerps/models/payment_type_model.dart';
import 'package:powerps/models/sub_menu_item_model.dart';
import 'package:powerps/provider/paymeny_provider.dart';
import 'package:powerps/repositories/payment_type_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/payment_type_info_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:provider/provider.dart';

class PaymentTypeScreen extends StatefulWidget {
  const PaymentTypeScreen({super.key});

  @override
  State<PaymentTypeScreen> createState() => _PaymentTypeScreenState();
}

class _PaymentTypeScreenState extends State<PaymentTypeScreen> {
  bool _showData = false;
  bool _hasDollarePayment = false;
  // bool _showOfflinePayment = false;
  List<PaymentType> _paymentTypeList = [];
  List<SubMenuItem> subList = [];
  PaymentType? _zarinPal;
  CryptoPaymentGateway? _nowPayment;
  final _zarinpalMerchantIdTxtEdit = TextEditingController();
  final _newPaymentMerchantIdTxtEdit = TextEditingController();
  final _newPaymentNameTxtEdit = TextEditingController();
  bool _isZarinPalActive = true;
  final List<Widget> _paymentItemWidgetList = [];

  // nowPayment
  final _nowPaymentApiKeyTxtEdit = TextEditingController();
  final _nowPaymentEmaikTxtEdit = TextEditingController();
  final _nowPaymentPasswordTxtEdit = TextEditingController();
  bool _nowPaymentIsActive = true;
  bool _nowPaymentIsFeePaidByUser = true;

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
        appBar: appBarWithBackButton(context: context, title: "درگاه و پرداخت"),
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

  _rebuildOfflinePayment() async {
    await getAllOfflinePayments().then((res) {
      if (res != null && res != false) {
        setState(() {
          _paymentTypeList = res;

          _paymentItemWidgetList.clear();
          for (var i in _paymentTypeList) {
            _paymentItemWidgetList.add(PaymentTypeItemInfoWidget(
              paymentType: PaymentType(
                  id: i.id,
                  name: i.name,
                  merchantId: i.merchantId,
                  isActive: i.isActive,
                  type: i.type),
            ));
          }
        });
      }
    }).onError((e, s) {
      debugPrint(e.toString());
    });
  }

  void _fillData() async {
    if (context.mounted) {
      var res = await getAllOfflinePayments();
      var resZarinpal = await getZarinpalPaymentDetails();
      var resNowPayment = await getNovPaymentDetails();
      await getDollorTransactionSetting().then((val) {
        if (mounted) {
          setState(() {
            _hasDollarePayment = val;
          });
        }
      });
      if (res != null &&
          res != false &&
          resZarinpal != null &&
          resZarinpal != false &&
          resNowPayment != null &&
          resNowPayment != false) {
        setState(() {
          _showData = false;
          _paymentTypeList = res;
          _paymentItemWidgetList.clear();
          for (var i in _paymentTypeList) {
            _paymentItemWidgetList.add(PaymentTypeItemInfoWidget(
              paymentType: PaymentType(
                  id: i.id,
                  name: i.name,
                  merchantId: i.merchantId,
                  isActive: i.isActive,
                  type: i.type),
            ));
          }

          _zarinPal = resZarinpal;
          _zarinpalMerchantIdTxtEdit.text = _zarinPal!.merchantId;
          _isZarinPalActive = _zarinPal!.isActive;

          // nowPayment
          _nowPayment = resNowPayment;
          _nowPaymentApiKeyTxtEdit.text = _nowPayment!.apiKey;
          _nowPaymentEmaikTxtEdit.text = _nowPayment!.email;
          _nowPaymentPasswordTxtEdit.text = _nowPayment!.password;
          _nowPaymentIsActive = _nowPayment!.isActive;
          _nowPaymentIsFeePaidByUser = _nowPayment!.isFeePaidByUser;
          // _showOfflinePayment = true;
          _showData = true;
        });
      }
    }
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
                await await _newPaymentDialog(context);
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
                      "افزودن پرداخت آفلاین",
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
                    _offlinePaymentTypeCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    _zarinpalGatewayTypeCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    _dollarpaymentsTypeCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    _nowPaymentTypeCard(context),
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

  _offlinePaymentTypeCard(BuildContext context) {
    return Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
      if (paymentProvider.changed) {
        Future.microtask(() => _rebuildOfflinePayment());
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
              "پرداخت های آفلاین",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppStyle.defaultPadding),
            SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 1.75,
                    context: context,
                    importedList: _paymentItemWidgetList),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: _paymentItemWidgetList),
                desktop: widgetsGridview(
                    importedList: _paymentItemWidgetList,
                    context: context,
                    childAspectRatio: 3,
                    crossAxisCount: 2),
              ),
            )
          ],
        ),
      );
    });
  }



  _dollarpaymentsTypeCard(BuildContext context) {
    List<Widget> dollarPaymentWidgetList = [];
    setState(() {
      dollarPaymentWidgetList.add(Column(
        children: [
          Row(
            children: [
              const Text("نمایش قیمت و پرداخت دلاری"),
              Switch(
                  value: _hasDollarePayment,
                  onChanged: (bool newValue) async {
                    EasyLoading.show();
                    await setDollorTransactionSetting(
                            dollarTransaction: newValue)
                        .then((val) {
                      if (!context.mounted) return;

                      if (val) {
                        showMsg(msg: "فعال شد.", context: context);
                      } else {
                        showMsg(msg: "غیر فعال شد.", context: context);
                      }
                    });
                    setState(() {
                      _hasDollarePayment = newValue;
                    });
                    EasyLoading.dismiss();
                  })
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "در صورت فعال بودن، قیمت ها در ربات تلگرام به دلار نیز نمایش داده خواهد شد و همچنین درگاه ها و روش های پرداخت ارزی نیز فعال خواهند بود.",
              style: TextStyle(color: AppStyle.deactiveStatus),
            ),
          ),
        ],
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
            "پرداخت دلاری",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2,
                  context: context,
                  importedList: dollarPaymentWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 3,
                  importedList: dollarPaymentWidgetList),
              desktop: widgetsGridview(
                  importedList: dollarPaymentWidgetList,
                  context: context,
                  childAspectRatio: 3,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _zarinpalGatewayTypeCard(BuildContext context) {
    List<Widget> zarinpalWidgetList = [];
    List<Widget> actionWidgetList = [];
    setState(() {
      zarinpalWidgetList.add(Column(
        children: [
          CustomTextFromFieldWidget(
            controller: _zarinpalMerchantIdTxtEdit,
            textDirection: TextDirection.ltr,
            textHint: "کد درگاه پرداخت",
            validationError: "کد درگاه پرداخت را وارد کنید.",
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "کد درگاه پرداخت را وارد کنید را از قسمت تنظیمات درگاه، پنل زرین پال خود کپی و در ایت قسمت وارد کنید.",
              style: TextStyle(color: AppStyle.deactiveStatus),
            ),
          ),
        ],
      ));
      zarinpalWidgetList.add(Column(
        children: [
          Row(
            children: [
              const Text("امکان پرداخت از این درگاه"),
              Switch(
                  value: _isZarinPalActive,
                  onChanged: (bool newValue) async {
                    EasyLoading.show();
                    if (newValue == true) {
                      bool res = await reActivePaymentType(name: "زرین پال");
                      if (res == true) {
                        if (context.mounted) {
                          showMsg(msg: "فعال شد.", context: context);
                        }
                      }
                    } else {
                      bool res = await deActivePaymentType(name: "زرین پال");
                      if (res == true) {
                        if (context.mounted) {
                          showMsg(msg: "غیر فعال شد.", context: context);
                        }
                      }
                    }
                    setState(() {
                      _isZarinPalActive = newValue;
                    });
                    EasyLoading.dismiss();
                  })
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "برای فعال سازی این گزینه می بایست درگاه فعال در سایت زرین پال داشته باشید.",
              style: TextStyle(color: AppStyle.deactiveStatus),
            ),
          ),
        ],
      ));
      actionWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          if (_zarinpalMerchantIdTxtEdit.text.isNotEmpty) {
            EasyLoading.show();
            if (_zarinpalMerchantIdTxtEdit.text.isNotEmpty) {
              bool res = false;
              res = await chanegeMerChantIdByPaymentTypeName(
                  merchantId: _zarinpalMerchantIdTxtEdit.text,
                  name: "زرین پال");

              if (res) {
                if (context.mounted) {
                  showMsg(msg: "ویرایش شد.", context: context);
                }
              }
            } else {
              if (context.mounted) {
                showMsg(msg: "خطا.", context: context, type: "error");
              }
            }
            EasyLoading.dismiss();
          }
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
            "درگاره پرداخت آنلاین زرین پال",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2,
                  context: context,
                  importedList: zarinpalWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 3,
                  importedList: zarinpalWidgetList),
              desktop: widgetsGridview(
                  importedList: zarinpalWidgetList,
                  context: context,
                  childAspectRatio: 3,
                  crossAxisCount: 2),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 5,
                  context: context,
                  importedList: actionWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 5,
                  crossAxisCount: 2,
                  importedList: actionWidgetList),
              desktop: widgetsGridview(
                  importedList: actionWidgetList,
                  context: context,
                  childAspectRatio: 5.5,
                  crossAxisCount: 4),
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
          await _newPaymentDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("افزودن پرداخت آفلاین"),
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

  _newPaymentDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: const Text("افزودن گزینه پرداخت"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      const Text("نام روش پرداخت"),
                      TextFormField(
                        controller: _newPaymentNameTxtEdit,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        maxLines: null,
                        decoration:
                            const InputDecoration(labelText: "نام روش پرداخت"),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text("شماره حساب یا آدرس واریزی را وارد کنید."),
                      TextFormField(
                        controller: _newPaymentMerchantIdTxtEdit,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        maxLines: null,
                        decoration:
                            const InputDecoration(labelText: "شماره حساب"),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () async {
                          EasyLoading.show();
                          if (_newPaymentNameTxtEdit.text.isNotEmpty &&
                              _newPaymentMerchantIdTxtEdit.text.isNotEmpty) {
                            bool res = false;
                            res = await addNewOfflinePaymentType(
                                merchantId: _newPaymentMerchantIdTxtEdit.text,
                                name: _newPaymentNameTxtEdit.text);
                            if (res) {
                              setState(() {
                                _newPaymentMerchantIdTxtEdit.text = "";
                                _newPaymentNameTxtEdit.text = "";
                                paymentTypeChangedToken = "paymentTypeChanged";
                              });

                              if (context.mounted) {
                                showMsg(msg: "اضافه گردید", context: context);

                                Navigator.pop(context);
                              }
                              paymentTypeotifier.changedPaymentTypeData();
                            }
                          } else {
                            // showToast(
                            //     msg: "خطا.", fToast: _fToast, type: "error");
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }

                            paymentTypeotifier.changedPaymentTypeData();
                          }
                          EasyLoading.dismiss();
                        },
                        child: const Text(
                          "افزودن",
                        )),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("لغو")),
                  ],
                ),
              ],
            )));
  }

  _nowPaymentTypeCard(BuildContext context) {
    List<Widget> zarinpalWidgetList = [];
    List<Widget> actionWidgetList = [];
    setState(() {
      zarinpalWidgetList.add(Column(
        children: [
          CustomTextFromFieldWidget(
            controller: _nowPaymentApiKeyTxtEdit,
            textDirection: TextDirection.ltr,
            textHint: "API KEY",
            validationError: "API KEY را وارد کنید.",
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              "از قسمت setting درگاه، منوی Payments , کد Key را کپی کنید و در این قسمت وارد کنید.",
              style: TextStyle(color: AppStyle.deactiveStatus),
            ),
          ),
        ],
      ));
      zarinpalWidgetList.add(Column(
        children: [
          Row(
            children: [
              const Text("امکان پرداخت از این درگاه"),
              Switch(
                  value: _nowPaymentIsActive,
                  onChanged: (bool newValue) async {
                    setState(() {
                      _nowPaymentIsActive = newValue;
                    });
                  })
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "قابلیت پرداخت از درگاه NOWPAYMENTS",
              style: TextStyle(color: AppStyle.deactiveStatus),
            ),
          ),
        ],
      ));
      zarinpalWidgetList.add(Column(
        children: [
          Row(
            children: [
              const Text("پرداخت کارمزد تراکنش توسط کاربر"),
              Switch(
                  value: _nowPaymentIsFeePaidByUser,
                  onChanged: (bool newValue) async {
                    setState(() {
                      _nowPaymentIsFeePaidByUser = newValue;
                    });
                  })
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "در صورن فعال بودن کارمزد تراکنش از کاربر دریافت می شود و در صورت غیر فعال بودن از مبلغ پرداخت شده کم خواهد شد.",
              style: TextStyle(color: AppStyle.deactiveStatus),
            ),
          ),
        ],
      ));
      actionWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          if (_nowPaymentApiKeyTxtEdit.text.isNotEmpty) {
            EasyLoading.show();
            await updateNowPaymentDetails(
                    cryptoPaymentGateway: CryptoPaymentGateway(
                        id: 0,
                        name: "nowpayments",
                        apiKey: _nowPaymentApiKeyTxtEdit.text,
                        email: "john@gmail.com",
                        password: "123456789",
                        isActive: _nowPaymentIsActive,
                        isFeePaidByUser: _nowPaymentIsFeePaidByUser))
                .then((value) {
              if (value != null) {
                setState(() {
                  _nowPayment = value;
                });
              }
            }).whenComplete(() {
              if (!context.mounted) return;

              EasyLoading.dismiss();
              showMsg(
                msg: "ذخیره شد.",
                context: context,
              );
            });
          } else {
            if (context.mounted) {
              showMsg(
                  msg: "API KEY نمی تواند خالی باشد.",
                  context: context,
                  type: "ERROR");
            }
          }
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
            "درگاره پرداخت  NOWPAYMENTS",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.5,
                  context: context,
                  importedList: zarinpalWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 3,
                  importedList: zarinpalWidgetList),
              desktop: widgetsGridview(
                  importedList: zarinpalWidgetList,
                  context: context,
                  childAspectRatio: 3,
                  crossAxisCount: 2),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 5,
                  context: context,
                  importedList: actionWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 5,
                  crossAxisCount: 2,
                  importedList: actionWidgetList),
              desktop: widgetsGridview(
                  importedList: actionWidgetList,
                  context: context,
                  childAspectRatio: 5.5,
                  crossAxisCount: 4),
            ),
          ),
        ],
      ),
    );
  }
}
