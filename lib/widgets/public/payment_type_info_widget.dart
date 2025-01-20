import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/payment_type_model.dart';
import 'package:powerps/provider/paymeny_provider.dart';
import 'package:powerps/repositories/payment_type_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:provider/provider.dart';

class PaymentTypeItemInfoWidget extends StatefulWidget {
  const PaymentTypeItemInfoWidget({
    super.key,
    required this.paymentType,
  });

  final PaymentType paymentType;
  @override
  State<PaymentTypeItemInfoWidget> createState() =>
      _PaymentTypeItemInfoWidgetState();
}

class _PaymentTypeItemInfoWidgetState extends State<PaymentTypeItemInfoWidget> {
  final _valueAliasnNameEditText = TextEditingController();
  final _nameAliasnNameEditText = TextEditingController();
  bool _newState = false;
  @override
  void initState() {
    _newState = widget.paymentType.isActive;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(
            width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyle.defaultPadding),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            height: 20,
            width: 20,
            child: Icon(Icons.payment),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    widget.paymentType.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.paymentType.merchantId,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    height: 20,
                    width: 20,
                    child: Switch(
                        value: _newState,
                        onChanged: (bool newValue) async {
                          EasyLoading.show();
                          if (newValue == true) {
                            bool res = await reActivePaymentType(
                                name: widget.paymentType.name);
                            if (res == true) {
                              if (context.mounted) {
                                showMsg(msg: "فعال شد.", context: context);
                              }
                            }
                          } else {
                            bool res = await deActivePaymentType(
                                name: widget.paymentType.name);
                            if (res == true) {
                              if (context.mounted) {
                                showMsg(msg: "غیر فعال شد.", context: context);
                              }
                            }
                          }
                          setState(() {
                            _newState = newValue;
                          });
                          EasyLoading.dismiss();
                        })),
                IconButton(
                  onPressed: () async {
                    await _openAddNewAdditionDialog(context: context);
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () async {
                    await _openDeleteDialog(context: context);
                  },
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _openAddNewAdditionDialog({required BuildContext context}) {
    _nameAliasnNameEditText.text = widget.paymentType.name;
    _valueAliasnNameEditText.text = widget.paymentType.merchantId;
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: Text("ویرایش ${widget.paymentType.name}"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 200,
                  child: Column(
                    spacing: 8.0,
                    children: [
                      const Text("نام جدید را وارد کنید"),
                      TextFormField(
                        controller: _nameAliasnNameEditText,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        maxLines: null,
                        decoration:
                            const InputDecoration(labelText: "متن جدید"),
                      ),
                      const Text("عبارت جدید را وارد کنید"),
                      TextFormField(
                        controller: _valueAliasnNameEditText,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        maxLines: null,
                        decoration:
                            const InputDecoration(labelText: "متن جدید"),
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
                          if (_valueAliasnNameEditText.text.isNotEmpty &&
                              _nameAliasnNameEditText.text.isNotEmpty) {
                            bool res = false;
                            res = await updateOfflinePaymentType(
                                id: int.parse(widget.paymentType.id),
                                merchantId: _valueAliasnNameEditText.text,
                                name: _nameAliasnNameEditText.text);

                            if (res) {
                              setState(() {
                                _valueAliasnNameEditText.text = "";
                                _nameAliasnNameEditText.text = "";
                                paymentTypeChangedToken = "paymentTypeChanged";
                              });

                              if (context.mounted) {
                                showMsg(msg: "ویرایش شد.", context: context);
                                if (!context.mounted) return;
                                context
                                    .read<PaymentProvider>()
                                    .setChanged(true);

                                Navigator.pop(context);
                              }
                              // call payment provider and set it changed
                            }
                          } else {
                            // showToast(
                            //     msg: "خطا.", fToast: _fToast, type: "error");
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }

                            // paymentTypeotifier.changedPaymentTypeData();
                          }
                          EasyLoading.dismiss();
                        },
                        child: const Text(
                          "ویرایش",
                        )),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("لغو")),
                  ],
                ),
              ],
            )));
  }

  _openDeleteDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: Text("حذف ${widget.paymentType.name}"),
              content: const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 80,
                  child: Column(
                    children: [
                      Text("آیا از حذف این گزینه مطمئن هستید؟"),
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
                          var res = await removePaymentType(
                              name: widget.paymentType.name);

                          if (res == true) {
                            setState(() {
                              paymentTypeChangedToken = "paymentTypeChanged";
                            });
                            if (context.mounted) {
                              showMsg(msg: "حذف شد.", context: context);

                              Navigator.pop(context);
                            }
                            paymentTypeotifier.changedPaymentTypeData();
                          } else if (res == false) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }

                            paymentTypeotifier.changedPaymentTypeData();
                          } else {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "$res", context: context, type: "error");
                            }

                            paymentTypeotifier.changedPaymentTypeData();
                          }
                          paymentTypeotifier.changedPaymentTypeData();

                          EasyLoading.dismiss();
                        },
                        child: const Text(
                          "حذف",
                          style: TextStyle(color: Colors.red),
                        )),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("لغو")),
                  ],
                ),
              ],
            )));
  }
}
