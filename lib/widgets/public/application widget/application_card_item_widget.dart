import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/application_model.dart';
import 'package:powerps/screens/admin_screen/settings/applications/edit_application_screen.dart';
import 'package:powerps/repositories/application_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class ApplicationCardInfoItemWidget extends StatefulWidget {
  final Application application;
  const ApplicationCardInfoItemWidget(this.application, {super.key});

  @override
  State<ApplicationCardInfoItemWidget> createState() =>
      _ApplicationCardInfoItemWidgetState();
}

class _ApplicationCardInfoItemWidgetState
    extends State<ApplicationCardInfoItemWidget> {
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
          SizedBox(
            height: 20,
            width: 20,
            child: widget.application.isActive == true
                ? const Icon(Icons.app_settings_alt_sharp)
                : const Icon(Icons.app_blocking),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.application.name!.length < 25
                        ? widget.application.name!
                        : "${widget.application.name!.substring(0, 25)}...",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.application.os!.length < 25
                        ? widget.application.os!
                        : "${widget.application.os!.substring(0, 25)}...",
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditApplicationScreen(
                          application: widget.application,
                        ),
                      )).then((value) => {
                        // _fillData()
                      });
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

  _openDeleteDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: Text("حذف ${widget.application.name}"),
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
                          var res = await deleteApplication(
                              id: widget.application.id);

                          if (res == true) {
                            setState(() {
                              applicationChangedToken = "applicationChanged";
                            });
                            if (context.mounted) {
                              showMsg(msg: "حذف شد.", context: context);

                              Navigator.pop(context);
                            }
                            applicationNotifier.changedApplicationtData();
                          } else if (res == false) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }

                            applicationNotifier.changedApplicationtData();
                          } else {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "$res", context: context, type: "error");
                            }

                            applicationNotifier.changedApplicationtData();
                          }
                          applicationNotifier.changedApplicationtData();

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
