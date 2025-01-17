import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/support_model.dart';
import 'package:powerps/repositories/support_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class SupportCardInfoItemWidget extends StatefulWidget {
  const SupportCardInfoItemWidget({super.key, required this.support});
  final Support support;
  @override
  State<SupportCardInfoItemWidget> createState() =>
      _SupportCardInfoItemWidgetState();
}

class _SupportCardInfoItemWidgetState extends State<SupportCardInfoItemWidget> {
  final _newQuestionTxtEdit = TextEditingController();
  final _newAnswerTxtEdit = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _newAnswerTxtEdit.clear();
    _newQuestionTxtEdit.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(
            width: 2, color: AppStyle.primaryColor.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyle.defaultPadding),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            height: 20,
            width: 20,
            child: Icon(Icons.support_agent),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.support.question.length < 25
                        ? widget.support.question
                        : "${widget.support.question.substring(0, 25)}...",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.support.answer.length < 25
                        ? widget.support.answer
                        : "${widget.support.answer.substring(0, 25)}...",
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
                    _newQuestionTxtEdit.text = widget.support.question;
                    _newAnswerTxtEdit.text = widget.support.answer;
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
                title: Text("ویرایش ${widget.support.answer}"),
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
                              res = await updateSupportById(
                                  support: Support(
                                      id: widget.support.id,
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
                                  showMsg(msg: "ویرایش شد.", context: context);

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
              title: Text("حذف ${widget.support.question}"),
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
                          var res = await deleteSupportById(
                              id: int.parse(widget.support.id));

                          if (res == true) {
                            setState(() {
                              supportChangedToken = "supportChanged";
                            });
                            if (context.mounted) {
                              showMsg(msg: "حذف شد.", context: context);

                              Navigator.pop(context);
                            }
                            supportNotifier.changedSupportData();
                          } else if (res == false) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }

                            supportNotifier.changedSupportData();
                          } else {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "$res", context: context, type: "error");
                            }

                            supportNotifier.changedSupportData();
                          }
                          supportNotifier.changedSupportData();

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
