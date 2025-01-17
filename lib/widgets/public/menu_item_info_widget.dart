import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/repositories/main_menu_item_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class MenuItemInfoWidget extends StatefulWidget {
  const MenuItemInfoWidget({
    super.key,
    required this.name,
    required this.aliasName,
    required this.id,
    required this.position,
    required this.isActive,
  });

  final String name, aliasName, id;
  final int position;
  final bool isActive;
  @override
  State<MenuItemInfoWidget> createState() => _MenuItemInfoWidgetState();
}

class _MenuItemInfoWidgetState extends State<MenuItemInfoWidget> {
  final _newAliasnNameEditText = TextEditingController();
  bool _newState = false;
  @override
  void initState() {
    _newState = widget.isActive;

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
                    widget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.aliasName,
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
                        if (newValue == true) {
                          bool res =
                              await reActiveMainMenuItem(name: widget.name);
                          if (res == true) {
                            if (context.mounted) {
                              showMsg(msg: "فعال شد.", context: context);
                            }
                          }
                        } else {
                          bool res =
                              await deActiveMainMenuItem(name: widget.name);
                          if (res == true) {
                            if (context.mounted) {
                              showMsg(msg: "غیر فعال شد.", context: context);
                            }
                          }
                        }
                        setState(() {
                          _newState = newValue;
                        });
                        EasyLoading.dismiss();
                      })),
              GestureDetector(
                onTap: () async {
                  await _openAddNewAdditionDialog(context: context);
                },
                child: const SizedBox(
                  height: 20,
                  width: 20,
                  child: Icon(Icons.edit),
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
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: Text("ویرایش متن ${widget.name}"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      const Text("متن جدید را وارد کنید"),
                      TextFormField(
                        controller: _newAliasnNameEditText,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        maxLines: null,
                        decoration:
                            const InputDecoration(labelText: "متن جدید"),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      // const Text("واحد ردیف جدید را وارد کنید."),
                      // TextFormField(
                      //   controller: _newAdditionUnitEditText,
                      //   keyboardType: TextInputType.text,
                      //   textInputAction: TextInputAction.next,
                      //   maxLines: null,
                      //   decoration:
                      //       const InputDecoration(labelText: "واحد ردیف جدید"),
                      // ),
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
                          if (_newAliasnNameEditText.text.isNotEmpty) {
                            bool res = false;
                            res = await changeMainMenuAliasName(
                                newName: _newAliasnNameEditText.text,
                                oldName: widget.name);

                            if (res) {
                              setState(() {
                                _newAliasnNameEditText.text = "";
                                menuChangedToken = "menuItemChanged";
                              });

                              if (context.mounted) {
                                showMsg(msg: "ویرایش شد.", context: context);

                                Navigator.pop(context);
                              }
                              menuItemNotifier.changedMenuData();
                            }
                          } else {
                            // showToast(
                            //     msg: "خطا.", fToast: _fToast, type: "error");
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMsg(
                                  msg: "خطا.", context: context, type: "error");
                            }

                            menuItemNotifier.changedMenuData();
                          }
                          EasyLoading.dismiss();
                        },
                        child: const Text(
                          "ویرایش",
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
