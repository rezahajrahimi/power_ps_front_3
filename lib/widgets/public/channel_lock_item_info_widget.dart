// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/channel_lock_model.dart';
import 'package:powerps/repositories/channel_lock_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class ChannelLockItemInfoWidget extends StatefulWidget {
  const ChannelLockItemInfoWidget({super.key, required this.channelLock});
  final ChannelLock channelLock;
  @override
  State<ChannelLockItemInfoWidget> createState() =>
      _ChannelLockItemInfoWidgetState();
}

class _ChannelLockItemInfoWidgetState extends State<ChannelLockItemInfoWidget> {
  final _newChannelIDEditTxt = TextEditingController();
  bool _newState = false;
  @override
  void initState() {
    _newState = widget.channelLock.isActive;
    _newChannelIDEditTxt.text = widget.channelLock.channelId;
    super.initState();
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
            child: Icon(Icons.lock),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.channelLock.channelId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppStyle.defaultPadding),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          height: 20,
                          width: 20,
                          child: Switch(
                              value: _newState,
                              onChanged: (bool newValue) async {
                                EasyLoading.show();
                                if (newValue == true) {
                                  bool res = await reActiveChannelLockByID(
                                      id: int.parse(widget.channelLock.id));
                                  if (res == true) {
                                    if (context.mounted) {
                                      showMsg(
                                          msg: "فعال شد.", context: context);
                                    }
                                  }
                                } else {
                                  bool res = await deActiveChannelLockByID(
                                      id: int.parse(widget.channelLock.id));
                                  if (res == true) {
                                    if (context.mounted) {
                                      showMsg(
                                          msg: "غیر فعال شد.",
                                          context: context);
                                    }
                                  }
                                }
                                setState(() {
                                  _newState = newValue;
                                });
                                EasyLoading.dismiss();
                              })),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await _openEditingChannelIdDialog(context: context);
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
            ),
          ),
        ],
      ),
    );
  }

  _openEditingChannelIdDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: Text("ویرایش ${widget.channelLock.channelId}"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      const Text("ID کانال را وارد کنید"),
                      TextFormField(
                        controller: _newChannelIDEditTxt,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        textDirection: TextDirection.ltr,
                        maxLines: null,
                        decoration:
                            const InputDecoration(labelText: "ID کانال"),
                      ),
                      const SizedBox(
                        height: 8,
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
                          if (_newChannelIDEditTxt.text.isNotEmpty) {
                            bool res = false;
                            res = await editChannelLock(
                                channelLock: ChannelLock(
                                    id: widget.channelLock.id,
                                    channelId: _newChannelIDEditTxt.text,
                                    isActive: _newState));

                            if (res) {
                              setState(() {
                                _newChannelIDEditTxt.text = "";
                                channelLockChangedToken = "channelLockChanged";
                              });

                              if (context.mounted) {
                                showMsg(msg: "ویرایش شد.", context: context);

                                Navigator.pop(context);
                              }
                              channelLockNotifier.changedChannelLockData();
                            }
                          } else {
                            // showToast(
                            //     msg: "خطا.", fToast: _fToast, type: "error");
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }

                            channelLockNotifier.changedChannelLockData();
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
            )));
  }

  _openDeleteDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: Text("حذف ${widget.channelLock.channelId}"),
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
                          var res = await deleteChannelLockByID(
                              id: int.parse(widget.channelLock.id));
                          if (res == true) {
                            setState(() {
                              channelLockChangedToken = "channelLockChanged";
                            });
                            if (context.mounted) {
                              showMsg(msg: "حذف شد.", context: context);

                              Navigator.pop(context);
                            }
                            channelLockNotifier.changedChannelLockData();
                          } else if (res == false) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }

                            channelLockNotifier.changedChannelLockData();
                          } else {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "$res", context: context, type: "error");
                            }

                            channelLockNotifier.changedChannelLockData();
                          }
                          channelLockNotifier.changedChannelLockData();

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
