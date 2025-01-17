import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/faq_model.dart';
import 'package:powerps/repositories/faq_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class FaqCardInfoItemWidget extends StatefulWidget {
  const FaqCardInfoItemWidget({super.key, required this.faq});
  final Faq faq;
  @override
  State<FaqCardInfoItemWidget> createState() => _FaqCardInfoItemWidgetState();
}

class _FaqCardInfoItemWidgetState extends State<FaqCardInfoItemWidget> {
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
            child: Icon(Icons.question_answer),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.faq.question.length < 25
                        ? widget.faq.question
                        : "${widget.faq.question.substring(0, 25)}...",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.faq.answer.length < 25
                        ? widget.faq.answer
                        : "${widget.faq.answer.substring(0, 25)}...",
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
                    _newQuestionTxtEdit.text = widget.faq.question;
                    _newAnswerTxtEdit.text = widget.faq.answer;
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
                title: Text("ویرایش ${widget.faq.answer}"),
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
                              res = await updateFac(
                                  faq: Faq(
                                      id: widget.faq.id,
                                      question: _newQuestionTxtEdit.text,
                                      answer: _newAnswerTxtEdit.text));

                              if (res) {
                                setState(() {
                                  _newAnswerTxtEdit.text = "";
                                  _newQuestionTxtEdit.text = "";
                                  faqChangedToken = "faqChanged";
                                });

                                if (context.mounted) {
                                  showMsg(msg: "ویرایش شد.", context: context);

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
              title: Text("حذف ${widget.faq.question}"),
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
                          var res =
                              await deleteFacById(id: int.parse(widget.faq.id));

                          if (res == true) {
                            setState(() {
                              faqChangedToken = "faqChanged";
                            });
                            if (context.mounted) {
                              showMsg(msg: "حذف شد.", context: context);

                              Navigator.pop(context);
                            }
                            faqNotifier.changedfaqData();
                          } else if (res == false) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }

                            faqNotifier.changedfaqData();
                          } else {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "$res", context: context, type: "error");
                            }

                            faqNotifier.changedfaqData();
                          }
                          faqNotifier.changedfaqData();

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
