import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/category_type_model.dart';
import 'package:powerps/provider/category_type_provider.dart';
import 'package:powerps/repositories/category_type_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:provider/provider.dart';

class CategoryItemWidgetInfo extends StatefulWidget {
  final CategoryTypeModel categoryType;
  final Function(bool)? callback;

  const CategoryItemWidgetInfo(
      {super.key, required this.categoryType, this.callback});

  @override
  State<CategoryItemWidgetInfo> createState() => CategoryItemWidgetInfoState();
}

class CategoryItemWidgetInfoState extends State<CategoryItemWidgetInfo> {
  @override
  void initState() {
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
            child: Icon(Icons.input),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.categoryType.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.categoryType.isActive ? "فعال" : "غیرفعال",
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
                  await _showEditDialog(context);
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

  _showEditDialog(BuildContext context) async {
    final nameCntrl = TextEditingController();
    nameCntrl.text = widget.categoryType.name;
    bool isActive = widget.categoryType.isActive;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text("ویرایش نوع کاتگوری"),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "نام",
                        hintText: "نام نوع کاتگوری را وارد کنید",
                        border: OutlineInputBorder(),
                      ),
                      controller: nameCntrl,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("وضعیت: "),
                        const Spacer(),
                        const Text("فعال"),
                        Switch(
                          activeThumbColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () async {
                          EasyLoading.show();
                          var res = await updateCategoryType(
                              categoryTypeId: widget.categoryType.id,
                              name: nameCntrl.text,
                              isActive: isActive);

                          if (res == true) {
                            if (context.mounted) {
                              context.read<CategoryTypeProvider>().reFillData();
                              showMsg(msg: "ویرایش شد.", context: context);
                              // widget.callback!;

                              Navigator.pop(context);
                            }
                          } else if (res == false) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }
                          } else {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "$res", context: context, type: "error");
                            }
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
          );
        },
      ),
    );
  }

  _openDeleteDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: const Text("حذف نوع کاتگوری"),
              content: const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 80,
                  child: Column(
                    children: [
                      Text(
                          "بعد از این اقدام تمامی اطلاعات این نوع کاتگوری همراه با اطلاعات کاتگوری ها حذف خواهد شد. آیا از حذف این گزینه مطمئن هستید؟"),
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
                              await deleteCategoryType(widget.categoryType.id);

                          if (res == true) {
                            if (context.mounted) {
                              context.read<CategoryTypeProvider>().reFillData();

                              showMsg(msg: "حذف شد.", context: context);
                              // execute callback
                              // widget.callback!;

                              Navigator.pop(context);
                            }
                          } else if (res == false) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }
                          } else {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "$res", context: context, type: "error");
                            }
                          }

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
