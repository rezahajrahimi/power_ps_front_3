import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/cron_job_model.dart';
import 'package:powerps/repositories/cron_job_repostory.dart';
import 'package:powerps/styles/app_theme.dart';

class CronjobInfoItemWidget extends StatefulWidget {
  const CronjobInfoItemWidget({
    super.key,
    required this.cronJobModel,
  });

  final CronJobModel cronJobModel;
  @override
  State<CronjobInfoItemWidget> createState() => _CronjobInfoItemWidgetState();
}

class _CronjobInfoItemWidgetState extends State<CronjobInfoItemWidget> {
  bool _newState = false;
  @override
  void initState() {
    _newState = widget.cronJobModel.isActive;

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
            child: Icon(Icons.menu),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cronJobModel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.cronJobModel.description,
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
              SizedBox(
                  // height: 10,
                  // width: 10,
                  child: Switch(
                      value: _newState,
                      onChanged: (bool newValue) async {
                        EasyLoading.show();
                        await changeCronJobActiveStatusById(
                                id: widget.cronJobModel.id)
                            .then((value) {
                          if (!context.mounted) return;
                          if (value == true) {
                            setState(() {
                              _newState = newValue;
                            });
                            showMsg(msg: "ذخیره شد", context: context);
                          } else {
                            showMsg(
                                msg: "خطا در ذخیره سازی",
                                context: context,
                                type: "error");
                          }
                        }).onError((e, s) {
                          if (!context.mounted) return;
                          showMsg(
                              msg: "خطا در ذخیره سازی",
                              context: context,
                              type: "error");
                        });

                        EasyLoading.dismiss();
                      })),
            ],
          )
        ],
      ),
    );
  }
}
