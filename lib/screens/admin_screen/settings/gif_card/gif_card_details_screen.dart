import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persian_datetimepickers/persian_datetimepickers.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/gift_card_model.dart';
import 'package:powerps/models/sub_menu_item_model.dart';
import 'package:powerps/repositories/gift_card_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/gift_card_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class GifCardScreen extends StatefulWidget {
  const GifCardScreen({super.key});

  @override
  State<GifCardScreen> createState() => _GifCardScreenState();
}

class _GifCardScreenState extends State<GifCardScreen> {
  bool _showData = false;
  List<SubMenuItem> subList = [];
  List<GiftCard> _giftCardList = [];
  final List<Widget> _giftItemWidgetList = [];

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
        appBar: appBarWithBackButton(
            context: context, title: "گیف کارت و کدهای تخفیف"),
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
    if (context.mounted) {
      var res = await getGiftCardList();
      if (res != null && res != false) {
        setState(() {
          _showData = false;
          _giftCardList = res;
          _giftItemWidgetList.clear();
          for (var i in _giftCardList) {
            _giftItemWidgetList.add(GiftCarfItemInfoWidget(
              giftCard: GiftCard(
                  id: i.id,
                  code: i.code,
                  countOfUse: i.countOfUse,
                  countOfUsePerUser: i.countOfUsePerUser,
                  discount: i.discount,
                  endDate: i.endDate,
                  startDate: i.startDate),
            ));
          }
          _showData = true;
        });
      }
    }
  }

  void _retryGiftCardData() {
    gifCardChangedToken = "aaa";

    _fillData();
    giftCardotifier.changedGiftCaradData();
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
                    _giftCardLIstCard(context),
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


  _giftCardLIstCard(BuildContext context) {
    var size = MediaQuery.of(context).size.width;

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
            "گیف کارت ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder(
                valueListenable: giftCardotifier,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  if (value == "giftCardChanged") {
                    _retryGiftCardData();
                  }
                  return Responsive(
                    mobile: widgetsGridview(
                        childAspectRatio: 2.9,
                        context: context,
                        importedList: _giftItemWidgetList),
                    tablet: widgetsGridview(
                        context: context,
                        childAspectRatio: 4.5,
                        importedList: _giftItemWidgetList),
                    desktop: widgetsGridview(
                        importedList: _giftItemWidgetList,
                        context: context,
                        childAspectRatio: size > 1550 ? 4.5 : 3,
                        crossAxisCount: 2),
                  );
                }),
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
          await _openAddNewAdditionDialog(context: context);
        },
        icon: const Icon(Icons.add),
        label: const Text("افزودن گیفت کارد"),
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
                  childAspectRatio: 5,
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

  _openAddNewAdditionDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                title: const Text("افزودن گیفت کارت جدید"),
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
                        const Text("مبلغ گیف کارد"),
                        TextFormField(
                          controller: _newDiscountDateTxtEdit,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration:
                              const InputDecoration(labelText: "مبلغ گیف کارد"),
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
                              res = await createNewGiftCard(
                                  giftCard: GiftCard(
                                id: "0",
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
                                  showMsg(msg: "افزوده شد.", context: context);

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
                            "افزودن",
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
                await _openAddNewAdditionDialog(context: context);
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
                      "افزودن گیفت کارد",
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
}
