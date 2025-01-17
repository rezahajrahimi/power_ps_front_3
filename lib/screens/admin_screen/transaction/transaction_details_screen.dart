import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/details_info.dart';

import 'package:powerps/models/transaction_model.dart';
import 'package:powerps/repositories/payment_type_repository.dart';
import 'package:powerps/repositories/transaction_image_repository.dart';
import 'package:powerps/repositories/transaction_repositopry.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/details_info_item_widget.dart';
import 'package:powerps/widgets/public/image_view_tab_v4_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({
    super.key,
    required this.item,
  });
  final Transaction item;

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  bool _showData = false;
  String _imageSrc = "";
  bool _showImage = false;
  final TextEditingController _amountTxtController = TextEditingController();
  final TextEditingController _recipeNUmberTxtController =
      TextEditingController();
  String _selectedTransactionStatus = "تایید نشده";
  final List<String> _transactionStatusList = ["تایید نشده", "تایید شده"];
  late String _selectedPaymentType;

  final List<String> _paymentTypeList = [];
  final List<Widget> _mainInfoWidgetList = [];
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
            title:
                "تراکنش  ${widget.item.accountId} - ${widget.item.botUser!.username!}"),
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

  void _fillData() async {
    if (mounted) {
      await getAllActiveOfflinePaymentTypes().then((value) {
        setState(() {
          _paymentTypeList.clear();
          for (var i in paymentTypesList) {
            _paymentTypeList.add("${i.id}: ${i.name}");
          }

          _selectedPaymentType =
              "${widget.item.paymentType!.id}: ${widget.item.paymentType!.name}";
          widget.item.confirmed == true
              ? _selectedTransactionStatus = "تایید شده"
              : _selectedTransactionStatus = "تایید نشده";
        });
      });
      setState(() {
        _mainInfoWidgetList.clear();
        if (widget.item.amount != null) {
          _amountTxtController.text = widget.item.amount.toString();
        }
        if (widget.item.recipeNumber != null) {
          _recipeNUmberTxtController.text = widget.item.recipeNumber.toString();
        }
        // _selectedTransactionStatus =
        //     widget.item.confirmed ? "تایید شده" : "تایید نشده";
        _mainInfoWidgetList.add(DetailsInfoItemWidget(
            item: DetailsInfoItem(
                icon: const Icon(Icons.info),
                itemName: "Account Id",
                itemValue: widget.item.accountId.toString())));
        _mainInfoWidgetList.add(DetailsInfoItemWidget(
            item: DetailsInfoItem(
                icon: const Icon(Icons.info),
                itemName: "نام کاربر",
                itemValue: widget.item.botUser!.username!)));
        _mainInfoWidgetList.add(DetailsInfoItemWidget(
            item: DetailsInfoItem(
                icon: const Icon(Icons.info),
                itemName: "زمان ایجاد",
                itemValue: widget.item.createdAt!)));

        _mainInfoWidgetList.add(Container(
          margin: EdgeInsets.only(top: AppStyle.defaultPadding),
          padding: EdgeInsets.all(AppStyle.defaultPadding),
          decoration: BoxDecoration(
            border: Border.all(
                width: 2, color: AppStyle.primaryColor.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.all(
              Radius.circular(AppStyle.defaultPadding),
            ),
          ),
          child: DropdownButtonFormField(
            isExpanded: true,
            hint: const Text('وضعیت تراکنش'),
            decoration: const InputDecoration(
              label: Text('وضعیت تراکنش'),
              alignLabelWithHint: true,
              floatingLabelAlignment: FloatingLabelAlignment.start,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            value: _selectedTransactionStatus,
            alignment: Alignment.centerLeft,
            onChanged: (newValue) {
              setState(() {
                _selectedTransactionStatus = newValue.toString();
              });
            },
            items: _transactionStatusList.map((clType) {
              return DropdownMenuItem(
                value: clType,
                alignment: Alignment.centerRight,
                child: Text(clType),
              );
            }).toList(),
          ),
        ));
        widget.item.paymentType!.type == "online"
            ? _mainInfoWidgetList.add(DetailsInfoItemWidget(
                item: DetailsInfoItem(
                    icon: const Icon(Icons.info),
                    itemName: "درگاه پرداخت",
                    itemValue: widget.item.paymentType!.name)))
            : _mainInfoWidgetList.add(Container(
                margin: EdgeInsets.only(top: AppStyle.defaultPadding),
                padding: EdgeInsets.all(AppStyle.defaultPadding),
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 2,
                      color: AppStyle.primaryColor.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppStyle.defaultPadding),
                  ),
                ),
                child: DropdownButtonFormField(
                  isExpanded: true,
                  hint: const Text('درگاه پرداخت'),
                  decoration: const InputDecoration(
                    label: Text('درگاه پرداخت'),
                    alignLabelWithHint: true,
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  value: _selectedPaymentType,
                  alignment: Alignment.centerLeft,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPaymentType = newValue.toString();
                    });
                  },
                  items: _paymentTypeList.map((clType) {
                    return DropdownMenuItem(
                      value: clType,
                      alignment: Alignment.centerRight,
                      child: Text(clType),
                    );
                  }).toList(),
                ),
              ));
        widget.item.paymentType!.type == "online"
            ? _mainInfoWidgetList.add(DetailsInfoItemWidget(
                item: DetailsInfoItem(
                    icon: const Icon(Icons.currency_exchange),
                    itemName: "مقدار واریزی (تومان)",
                    itemValue: thousandSeperatorFormatter(
                        widget.item.amount.toString()))))
            : _mainInfoWidgetList.add(CustomTextFromFieldWidget(
                controller: _amountTxtController,
                keyboardType: TextInputType.number,
                labelText: "مقدار واریزی (تومان)",
                textHint: "مقدار واریزی را وارد کنید",
                validationError: "مقدار واریزی را وارد کنید"));
        widget.item.paymentType!.type == "online"
            ? _mainInfoWidgetList.add(DetailsInfoItemWidget(
                item: DetailsInfoItem(
                    icon: const Icon(Icons.offline_pin),
                    itemName: "کد پیگیری رسید واریزی",
                    itemValue: widget.item.recipeNumber
                        .toString()
                        .replaceAll(RegExp(r'^0+(?=\d)'), ''))))
            : _mainInfoWidgetList.add(CustomTextFromFieldWidget(
                controller: _recipeNUmberTxtController,
                labelText: "کد پیگیری رسید",
                textHint: "کد پیگیری رسید واریزی را وارد کنید",
                validationError: "کد پیگیری رسید واریزی را وارد کنید"));
        _showData = true;
      });
      if (widget.item.image != null) {
        await getImageSrcFromTelegram(botfile: widget.item.image!.imgSrc)
            .then((value) {
          if (value != null && value.toString().isNotEmpty) {
            setState(() {
              _imageSrc = value;
              _showImage = true;
            });
          }
        });
      }
    }
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
                    if (Responsive.isMobile(context)) // side bar mobile
                      _imageCard(context),
                    _mainInfoItemCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    // _channelLockListCard(context),
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
                    if (_showImage) _imageCard(context)
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
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: ElevatedButton(
              onPressed: () async {
                await _editTransaction(context);
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
                      "ثبت تغییرات",
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
          await _editTransaction(context);
        },
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش تراکنش"),
      ));
      if (!widget.item.confirmed) {
        actionsWidgetList.add(ElevatedButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyle.defaultPadding * 1.5,
              vertical: AppStyle.defaultPadding /
                  (Responsive.isMobile(context) ? 2 : 1),
            ),
          ),
          onPressed: () async {
            await removeUnconfirmedTransaction(
                    transactionId: widget.item.id.toInt())
                .then((value) async {
              if (value) {
                if (!context.mounted) return;
                showMsg(msg: "تراکنش حذف گردید.", context: context);
                Navigator.pop(context);
              } else {
                if (!context.mounted) return;

                showMsg(msg: "خطا", context: context, type: "error");
              }
            });
          },
          icon: const Icon(
            Icons.delete_forever,
            color: Colors.red,
          ),
          label: const Text("حذف تراکنش"),
        ));
      }
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

  _mainInfoItemCard(BuildContext context) {
    // remove zero number in recipe number until first number

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
            "جزییات تراکنش",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: _mainInfoWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: _mainInfoWidgetList),
              desktop: widgetsGridview(
                  importedList: _mainInfoWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _imageCard(BuildContext context) {
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
            "تصویر تراکنش",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          CustomImageView(
            imageSrc: _imageSrc,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          widget.item.image!.userText != null
              ? Text.rich(TextSpan(children: [
                  TextSpan(
                    text: "پیام کاربر:\n\r${widget.item.image!.userText}",
                  )
                ]))
              : const SizedBox(),
        ],
      ),
    );
  }

  _editTransaction(BuildContext context) async {
    EasyLoading.show();
    int pannelID = 1;
    if (_selectedPaymentType != "") {
      pannelID = int.parse(_selectedPaymentType.split(":")[0]);
    }
    if (_amountTxtController.text.isNotEmpty &&
        _recipeNUmberTxtController.text.isNotEmpty) {
      var res = await editUserTranaction(
          amount: int.parse(_amountTxtController.text),
          confirmed: _selectedTransactionStatus == "تایید شده" ? true : false,
          id: widget.item.id.toInt(),
          paymentTypeId: pannelID,
          recipeNUmber: _recipeNUmberTxtController.text);
      if (res) {
        if (context.mounted) {
          showMsg(msg: "ویرایش شد.", context: context);
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          showMsg(msg: "خطا", context: context, type: "error");
        }
      }
    } else {
      showMsg(msg: "اطلاعات درخواست شده را وارد کنید.", context: context);
    }
    EasyLoading.dismiss();
  }
}
