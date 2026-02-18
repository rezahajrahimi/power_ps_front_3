import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/details_info.dart';
import 'package:powerps/provider/agent/agent_ballance_provider.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/details_info_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentBallanceInfoItemCardWidget extends StatefulWidget {
  const AgentBallanceInfoItemCardWidget({super.key});
  @override
  State<AgentBallanceInfoItemCardWidget> createState() =>
      _AgentBallanceInfoItemCardWidgetState();
}

class _AgentBallanceInfoItemCardWidgetState
    extends State<AgentBallanceInfoItemCardWidget> {
  List<Widget> botUserWidgetLIst = [];
  String _shetabiMerchentID = "";
  String _walletAddress = "";
  bool _zarinPal = false;
  bool _cryptoPay = false;
  @override
  void initState() {
    super.initState();
    _fillData();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AgentBallanceProvider>().ballanceInDollar;

    _fillData();
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
            "موجودی کیف شما",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.9,
                    context: context,
                    importedList: botUserWidgetLIst),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: botUserWidgetLIst),
                desktop: widgetsGridview(
                    importedList: botUserWidgetLIst,
                    context: context,
                    childAspectRatio: 4,
                    crossAxisCount: 1),
              )),
        ],
      ),
    );
  }

  void _fillData() async {
    botUserWidgetLIst.clear();
    botUserWidgetLIst.add(DetailsInfoItemWidget(
      item: DetailsInfoItem(
          icon: const Icon(Icons.money),
          itemName: "موجودی",
          itemValue:
              "${thousandSeperatorFormatter(context.read<AgentBallanceProvider>().ballanceInToman.toString())} تومان"),
    ));

    botUserWidgetLIst.add(DetailsInfoItemWidget(
      item: DetailsInfoItem(
          icon: const Icon(Icons.currency_bitcoin),
          itemName: "موجودی کریپتو",
          itemValue:
              "${thousandSeperatorFormatter(context.read<AgentBallanceProvider>().ballanceInDollar.toString())} دلار"),
    ));
    botUserWidgetLIst.add(ElevatedButton.icon(
      onPressed: () async {
        // await _showAddBallanceDialog(context);
        await getAgentPaymentWays().then((res) {
          if (!mounted) return;
          if (res != null) {
            _showAddBallanceDialog(context, res);
          } else {
            showMsg(
                context: context,
                type: "error",
                msg: 'خطا در برقراری ارتباط با سرور');
          }
        });
      },
      label: const Text("افزایش موجودی"),
      // ignore: prefer_const_constructors
      icon: Icon(Icons.done),
    ));
  }

  _showAddBallanceDialog(BuildContext context, List res) {
    for (var element in res) {
      if (element['name'] == "کارت به کارت") {
        _shetabiMerchentID = element['merchant_id'];
      }
      if (element['name'] == "تتر (usdt-trc20)") {
        _walletAddress = element['merchant_id'];
      }
      if (element['name'] == "زرین پال") {
        _zarinPal = true;
      }
      if (element['name'] == "crypto_payment_status") {
        _cryptoPay = element['status'];
      }
    }

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text("افزایش موجودی"),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_shetabiMerchentID.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () async {
                          showDialogBox(
                              context: context,
                              title:
                                  "لطفا مبلغ مورد نظر را به این شماره کارت واریز کنید و رسید را در تلگرام ارسال کنید",
                              msg: _shetabiMerchentID);
                        },
                        icon: const Icon(Icons.done),
                        label: const Text(
                            "دریافت شماره کارت برای واریز بصورت کارت به کارت"),
                      ),
                    if (_shetabiMerchentID.isNotEmpty)
                      SizedBox(
                        height: AppStyle.defaultPadding,
                      ),
                    if (_walletAddress.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialogBox(
                              context: context,
                              title:
                                  "لطفا مبلغ تتر مورد نظر را به این آدرس واریز کنید و رسید را در تلگرام ارسال کنید",
                              msg: _walletAddress);
                        },
                        icon: const Icon(Icons.done),
                        label: const Text(
                            "دریافت آدرس کیف پول برای واریز بصورت رمز ارز"),
                      ),
                    if (_walletAddress.isNotEmpty)
                      SizedBox(
                        height: AppStyle.defaultPadding,
                      ),
                    if (_zarinPal)
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddBallanceTomanDialog(context);
                        },
                        icon: const Icon(Icons.book_online),
                        label: const Text("واریز از طریق درگاه پرداخت"),
                      ),
                    if (_zarinPal)
                      SizedBox(
                        height: AppStyle.defaultPadding,
                      ),
                    if (_cryptoPay)
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddBallanceDollarDialog(context);
                        },
                        icon: const Icon(Icons.book_online),
                        label: const Text("واریز رمز ارز از طریق درگاه پرداخت"),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("لغو")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("افزودن")),
              ],
            ),
          );
        });
  }

  showDialogBox(
      {required BuildContext context,
      required String msg,
      required String title}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(msg),
            actions: [
              // TextButton(
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //     },
              //     child: const Text("لغو")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("بستن")),
            ],
          );
        });
  }
}

_showAddBallanceTomanDialog(BuildContext context) {
  int amount = 0;
  // show a dialog
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("افزایش موجودی"),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    amount = int.parse(value);
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'مبلغ (حداقل واریزی 10 هزار تومان)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("لغو")),
            TextButton(
                onPressed: () {
                  if (amount < 10) {
                    showMsg(
                        msg: "حداقل واریزی 10 هزار تومان می باشد.",
                        context: context,
                        type: "error");
                    return;
                  }
                  createNewAgentTomanBillUrl(amount: amount).then((value) {
                    if (value != null) {
                      // open browser
                      launchUrl(Uri.parse(value),
                          mode: LaunchMode.externalApplication);
                    }
                    debugPrint(value.toString());
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("افزودن")),
          ],
        );
      });
}

_showAddBallanceDollarDialog(BuildContext context) {
  int amount = 0;
  // show a dialog
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("افزایش موجودی"),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    amount = int.parse(value);
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'مبلغ (حداقل واریزی 10 دلار)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("لغو")),
            TextButton(
                onPressed: () {
                  if (amount < 10) {
                    showMsg(
                        msg: "حداقل واریزی 10 دلار می باشد.",
                        context: context,
                        type: "error");
                    return;
                  }
                  createNewAgentDollarBillUrl(amount: amount).then((value) {
                    if (value != null) {
                      // open browser
                      launchUrl(Uri.parse(value),
                          mode: LaunchMode.externalApplication);
                    }
                    debugPrint(value.toString());
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("افزودن")),
          ],
        );
      });
}
