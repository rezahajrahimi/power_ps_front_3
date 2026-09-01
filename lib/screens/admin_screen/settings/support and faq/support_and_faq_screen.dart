import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/faq_model.dart';
import 'package:powerps/models/support_model.dart';
import 'package:powerps/repositories/faq_repository.dart';
import 'package:powerps/repositories/support_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/faq_card_item_widget.dart';
import 'package:powerps/widgets/public/support_card_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class SupportFaqScreen extends StatefulWidget {
  const SupportFaqScreen({super.key});

  @override
  State<SupportFaqScreen> createState() => _SupportFaqScreenState();
}

class _SupportFaqScreenState extends State<SupportFaqScreen> {
  bool _showData = false;
  final List<Widget> _supportItemWidgetList = [];
  final List<Widget> _faqItemWidgetList = [];
  List<Support> _supportsList = [];
  List<Faq> _faqsList = [];
  final _newQuestionTxtEdit = TextEditingController();
  final _newAnswerTxtEdit = TextEditingController();
  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _supportsList.clear();
    _faqsList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
              context: context, title: "پشتیبانی و سوالات متداول"),
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

  void _retrySupportData() {
    supportChangedToken = "aaa";

    _fillData();
    supportNotifier.changedSupportData();
  }

  void _retryFaqData() {
    faqChangedToken = "aaa";

    _fillData();
    faqNotifier.changedfaqData();
  }

  void _fillData() async {
    if (context.mounted) {
      var resSupport = await getSupporstList();
      var resFaq = await getFaqList();
      if (resSupport != null &&
          resSupport != false &&
          resFaq != null &&
          resFaq != false) {
        setState(() {
          _showData = false;
          _supportsList = resSupport;
          _faqsList = resFaq;
          _supportItemWidgetList.clear();
          _faqItemWidgetList.clear();
          for (var i in resSupport) {
            _supportItemWidgetList.add(SupportCardInfoItemWidget(
              support: Support(
                  id: i.id,
                  question: i.question,
                  answer: i.answer,
                  responseType: i.responseType),
            ));
          }
          for (var i in resFaq) {
            _faqItemWidgetList.add(FaqCardInfoItemWidget(
              faq: Faq(id: i.id, question: i.question, answer: i.answer),
            ));
          }
          _showData = true;
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
                    _supportItemsCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    _faqItemsCard(context),
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
          await _openAddNewSupportDialog(context: context);
        },
        icon: const Icon(Icons.add),
        label: const Text("افزودن  پشتیبانی"),
      ));
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          await _openAddNewFaqDialog(context: context);
        },
        icon: const Icon(Icons.add),
        label: const Text("افزودن سوالات متداول"),
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

  _supportItemsCard(BuildContext context) {
    // var size = MediaQuery.of(context).size.width;

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
            "پشتیبانی",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder(
                valueListenable: supportNotifier,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  if (value == "supportChanged") {
                    _retrySupportData();
                  }
                  return Responsive(
                    mobile: widgetsGridview(
                        childAspectRatio: 2.9,
                        context: context,
                        importedList: _supportItemWidgetList),
                    tablet: widgetsGridview(
                        context: context,
                        childAspectRatio: 4.8,
                        importedList: _supportItemWidgetList),
                    desktop: widgetsGridview(
                        importedList: _supportItemWidgetList,
                        context: context,
                        childAspectRatio: 4.8,
                        crossAxisCount: 2),
                  );
                }),
          ),
        ],
      ),
    );
  }

  _faqItemsCard(BuildContext context) {
    // var size = MediaQuery.of(context).size.width;

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
            "سوالات متداول",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder(
                valueListenable: faqNotifier,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  if (value == "faqChanged") {
                    _retryFaqData();
                  }
                  return Responsive(
                    mobile: widgetsGridview(
                        childAspectRatio: 2.9,
                        context: context,
                        importedList: _faqItemWidgetList),
                    tablet: widgetsGridview(
                        context: context,
                        childAspectRatio: 4.8,
                        importedList: _faqItemWidgetList),
                    desktop: widgetsGridview(
                        importedList: _faqItemWidgetList,
                        context: context,
                        childAspectRatio: 4.8,
                        crossAxisCount: 2),
                  );
                }),
          ),
        ],
      ),
    );
  }

  _openAddNewSupportDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                title: const Text("افزودن گزینه جدید"),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    // height: 200,
                    child: Column(
                      children: [
                        const Text("متن درخواست پشتیبانی را وارد کنید"),
                        TextFormField(
                          controller: _newQuestionTxtEdit,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "متن درخواست پشتیبانی"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text("پاسخ پشتیبانی را وارد کنید."),
                        TextFormField(
                          controller: _newAnswerTxtEdit,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration:
                              const InputDecoration(labelText: "پاسخ پشتیبانی"),
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
                            if (_newAnswerTxtEdit.text.isNotEmpty &&
                                _newQuestionTxtEdit.text.isNotEmpty) {
                              bool res = false;
                              res = await createNewSupport(
                                  support: Support(
                                      id: "0",
                                      question: _newQuestionTxtEdit.text,
                                      answer: _newAnswerTxtEdit.text,
                                      responseType: "text"));

                              if (res) {
                                setState(() {
                                  _newAnswerTxtEdit.text = "";
                                  _newQuestionTxtEdit.text = "";
                                  supportChangedToken = "supportChanged";
                                });

                                if (context.mounted) {
                                  showMsg(msg: "افزوده شد.", context: context);

                                  Navigator.pop(context);
                                }
                                supportChangedToken = "supportChanged";

                                supportNotifier.changedSupportData();
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

                              supportNotifier.changedSupportData();
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

  _openAddNewFaqDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                title: const Text("افزودن گزینه جدید"),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    // height: 200,
                    child: Column(
                      children: [
                        const Text("متن سوال را وارد کنید"),
                        TextFormField(
                          controller: _newQuestionTxtEdit,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration:
                              const InputDecoration(labelText: "متن سوال"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text("پاسخ را وارد کنید."),
                        TextFormField(
                          controller: _newAnswerTxtEdit,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                          decoration: const InputDecoration(labelText: "پاسخ"),
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
                            if (_newAnswerTxtEdit.text.isNotEmpty &&
                                _newQuestionTxtEdit.text.isNotEmpty) {
                              bool res = false;
                              res = await createNewFac(
                                  faq: Faq(
                                      id: "0",
                                      question: _newQuestionTxtEdit.text,
                                      answer: _newAnswerTxtEdit.text));

                              if (res) {
                                setState(() {
                                  _newAnswerTxtEdit.text = "";
                                  _newQuestionTxtEdit.text = "";
                                  faqChangedToken = "faqChanged";
                                });

                                if (context.mounted) {
                                  showMsg(msg: "افزوده شد.", context: context);

                                  Navigator.pop(context);
                                }
                                faqChangedToken = "faqChanged";

                                faqNotifier.changedfaqData();
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

                              faqNotifier.changedfaqData();
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
            fit: FlexFit.tight,
            flex: 1,
            child: ElevatedButton(
              onPressed: () async {
                _openAddNewSupportDialog(context: context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppStyle.blueColor),
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
                      "افزودن پشتیبانی",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                await _openAddNewFaqDialog(context: context);
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
                      "افزودن سوالات متداول",
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
