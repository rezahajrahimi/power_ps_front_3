import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/gift_card_model.dart';
import 'package:powerps/repositories/gift_card_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:persian_datetimepickers/persian_datetimepickers.dart';

class GiftCarfItemInfoWidget extends StatefulWidget {
  const GiftCarfItemInfoWidget({
    super.key,
    required this.giftCard,
  });

  final GiftCard giftCard;
  @override
  State<GiftCarfItemInfoWidget> createState() => _GiftCarfItemInfoWidgetState();
}

class _GiftCarfItemInfoWidgetState extends State<GiftCarfItemInfoWidget> {
  final _newGiftCodeTxtEdit = TextEditingController();
  final _newStartDateTxtEdit = TextEditingController();
  final _newEndDateTxtEdit = TextEditingController();
  final _newDiscountDateTxtEdit = TextEditingController();
  final _newCountOfUSeDateTxtEdit = TextEditingController();
  final _newCountOfUSePerUserDateTxtEdit = TextEditingController();
  DateTime? _pickedStartedDate;
  DateTime? _pickedEndedtedDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _newGiftCodeTxtEdit.clear();
    _newStartDateTxtEdit.clear();
    _newEndDateTxtEdit.clear();
    _newDiscountDateTxtEdit.clear();
    _newCountOfUSeDateTxtEdit.clear();
    _newCountOfUSePerUserDateTxtEdit.clear();
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
            child: Icon(Icons.discount),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.giftCard.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "تخفیف ${widget.giftCard.discount} تومان",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  setState(() {
                    if (widget.giftCard.startDate != null) {
                      _pickedStartedDate = widget.giftCard.startDate;
                      _newStartDateTxtEdit.text =
                          _pickedStartedDate!.toPersianDate();
                    }
                    if (widget.giftCard.endDate != null) {
                      _pickedEndedtedDate = widget.giftCard.endDate;
                      _newEndDateTxtEdit.text =
                          _pickedEndedtedDate!.toPersianDate();
                    }

                    _newGiftCodeTxtEdit.text = widget.giftCard.code;
                    _newDiscountDateTxtEdit.text =
                        widget.giftCard.discount.toString();
                    _newCountOfUSeDateTxtEdit.text =
                        widget.giftCard.countOfUse.toString();
                    _newCountOfUSePerUserDateTxtEdit.text =
                        widget.giftCard.countOfUsePerUser.toString();
                  });
                  await _openAddNewAdditionDialog(context: context);
                },
                child: const SizedBox(
                  height: 20,
                  width: 20,
                  child: Icon(Icons.edit),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  await _openDeleteDialog(context: context);
                },
                child: const SizedBox(
                  height: 20,
                  width: 20,
                  child: Icon(Icons.delete_forever, color: Colors.red),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _openAddNewAdditionDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                title: Text("ویرایش ${widget.giftCard.code}"),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    // height: 200,
                    child: Column(
                      children: [
                        const Text(
                            "کد گیفت کارد را وارد کنید، کد حتما باید با عبارت \"giftcard-\" شروع بشود."),
                        TextFormField(
                          controller: _newGiftCodeTxtEdit,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration:
                              const InputDecoration(labelText: "کد جدید"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text("toPersianDate"),
                        TextFormField(
                          controller: _newDiscountDateTxtEdit,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration:
                              const InputDecoration(labelText: "toPersianDate"),
                        ),
                        const Text("محدودیت استفاده(عدد)"),
                        TextFormField(
                          controller: _newCountOfUSeDateTxtEdit,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "محدودیت استفاده(عدد)"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text("محدودیت استفاده برای هر کاربر(عدد)"),
                        TextFormField(
                          controller: _newCountOfUSePerUserDateTxtEdit,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "محدودیت استفاده برای هر کاربر(عدد)"),
                        ),
                        const Text("زمان شروع"),
                        TextField(
                          enableInteractiveSelection: false,
                          textInputAction: TextInputAction.next,
                          textDirection: TextDirection.rtl,
                          onTap: () async {
                            // Date picker
                            final DateTime? date = await showPersianDatePicker(
                              context: context,
                            );
                            if (date != null) {
                              setState(() {
                                _pickedStartedDate = date;
                              });
                              if (context.mounted) {
                                setState(() {
                                  _pickedStartedDate = DateTime(
                                    _pickedStartedDate!.year,
                                    _pickedStartedDate!.month,
                                    _pickedStartedDate!.day,
                                  );
                                  _newStartDateTxtEdit.text =
                                      _pickedStartedDate!.toPersianDate();
                                });
                              }
                            }
                          },
                          controller: _newStartDateTxtEdit,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text("زمان انقضا"),
                        TextField(
                          enableInteractiveSelection: false,
                          textInputAction: TextInputAction.next,
                          textDirection: TextDirection.rtl,
                          onTap: () async {
                            // Date picker
                            final DateTime? date = await showPersianDatePicker(
                              context: context,
                            );
                            if (date != null) {
                              setState(() {
                                _pickedEndedtedDate = date;
                              });
                              if (context.mounted) {
                                setState(() {
                                  _pickedEndedtedDate = DateTime(
                                    _pickedEndedtedDate!.year,
                                    _pickedEndedtedDate!.month,
                                    _pickedEndedtedDate!.day,
                                  );
                                  _newEndDateTxtEdit.text =
                                      _pickedEndedtedDate!.toPersianDate();
                                });
                              }
                            }
                          },
                          controller: _newEndDateTxtEdit,
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
                            if (!checkIsGiftCardString(
                                str: _newGiftCodeTxtEdit.text)) {
                              if (context.mounted) {
                                EasyLoading.dismiss();

                                showMsg(
                                    msg:
                                        "کد می بایست با عبارت giftcard- شروع بشود.",
                                    type: "error",
                                    context: context);
                              }
                              return;
                            }
                            if (_newGiftCodeTxtEdit.text.isNotEmpty &&
                                _newCountOfUSeDateTxtEdit.text.isNotEmpty &&
                                _newCountOfUSePerUserDateTxtEdit
                                    .text.isNotEmpty &&
                                _newDiscountDateTxtEdit.text.isNotEmpty) {
                              bool res = false;
                              res = await updateGiftCard(
                                  giftCard: GiftCard(
                                id: widget.giftCard.id,
                                code: _newGiftCodeTxtEdit.text,
                                discount:
                                    int.parse(_newDiscountDateTxtEdit.text),
                                countOfUse:
                                    int.parse(_newCountOfUSeDateTxtEdit.text),
                                countOfUsePerUser: int.parse(
                                    _newCountOfUSePerUserDateTxtEdit.text),
                                endDate: _pickedEndedtedDate,
                                startDate: _pickedStartedDate,
                              ));

                              if (res) {
                                setState(() {
                                  _newGiftCodeTxtEdit.text = "";
                                  gifCardChangedToken = "giftCardChanged";
                                });

                                if (context.mounted) {
                                  showMsg(msg: "ویرایش شد.", context: context);

                                  Navigator.pop(context);
                                }
                                gifCardChangedToken = "giftCardChanged";

                                giftCardotifier.changedGiftCaradData();
                              }
                            } else {
                              // showToast(
                              //     msg: "خطا.", fToast: _fToast, type: "error");
                              if (context.mounted) {
                                Navigator.pop(context);
                                showMsg(
                                    msg: "خطا.",
                                    context: context,
                                    type: "error");
                              }

                              giftCardotifier.changedGiftCaradData();
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
              ),
            )));
  }

  _openDeleteDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: Text("حذف ${widget.giftCard.code}"),
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
                          var res = await deleteGiftCardByCode(
                              code: widget.giftCard.code);

                          if (res == true) {
                            setState(() {
                              gifCardChangedToken = "giftCardChanged";
                            });
                            if (context.mounted) {
                              showMsg(msg: "حذف شد.", context: context);

                              Navigator.pop(context);
                            }
                            giftCardotifier.changedGiftCaradData();
                          } else if (res == false) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }

                            giftCardotifier.changedGiftCaradData();
                          } else {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "$res", context: context, type: "error");
                            }

                            giftCardotifier.changedGiftCaradData();
                          }
                          giftCardotifier.changedGiftCaradData();

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
