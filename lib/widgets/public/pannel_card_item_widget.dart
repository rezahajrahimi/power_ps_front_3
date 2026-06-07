import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/screens/admin_screen/settings/pannel/edit_pannel_screen.dart';
import 'package:powerps/screens/admin_screen/settings/pannel/edit_marzban_panel_screen.dart';
import 'package:powerps/screens/admin_screen/settings/pannel/edit_sanaei_panel_screen.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class PannelItemInfoWidget extends StatefulWidget {
  final Pannel pannel;
  final Function(bool)? callback;

  const PannelItemInfoWidget({super.key, required this.pannel, this.callback});

  @override
  State<PannelItemInfoWidget> createState() => _PannelItemInfoWidgetState();
}

class _PannelItemInfoWidgetState extends State<PannelItemInfoWidget> {
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
                    getPannelName(name: widget.pannel.type),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.pannel.location!,
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
                  if (widget.pannel.type == "sanaei") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditSanaeiPanelScreen(
                            selectedPannel: widget.pannel,
                          ),
                        )).then((value) => {widget.callback!(true)});
                  } else if (widget.pannel.type == "marzban") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditMarzbanPanelScreen(
                            selectedPannel: widget.pannel,
                          ),
                        )).then((value) => {widget.callback!(true)});
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPanelScreen(
                            selectedPannel: widget.pannel,
                          ),
                        )).then((value) => {widget.callback!(true)});
                  }
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
              title: const Text("حذف پنل"),
              content: const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 80,
                  child: Column(
                    children: [
                      Text(
                          "بعد از این اقدام تمامی اطلاعات این پنل همراه با اطلاعات کانفیگ ها حذف خواهد شد. آیا از حذف این گزینه مطمئن هستید؟"),
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
                          var res = await deletePannel(
                              pannelId: int.parse(widget.pannel.id));

                          if (res == true) {
                            setState(() {
                              pannelChangedToken = "pannelChanged";
                            });
                            if (context.mounted) {
                              showMsg(msg: "حذف شد.", context: context);

                              Navigator.pop(context);
                            }
                            pannelNotifier.changedPannelData();
                          } else if (res == false) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }

                            pannelNotifier.changedPannelData();
                          } else {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "$res", context: context, type: "error");
                            }

                            pannelNotifier.changedPannelData();
                          }
                          pannelNotifier.changedPannelData();

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
