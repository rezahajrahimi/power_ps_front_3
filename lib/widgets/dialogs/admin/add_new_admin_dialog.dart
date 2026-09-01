import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/provider/user_admin_provider.dart';
import 'package:powerps/repositories/panel_user_repository.dart';
import 'package:powerps/screens/admin_screen/settings/pannel/obtain_exist_panel_users_to_agents_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:searchable_listview/searchable_listview.dart';

class AddNewAdminDialog extends StatefulWidget {
  const AddNewAdminDialog({super.key});

  @override
  State<AddNewAdminDialog> createState() => _AddNewAdminDialogState();
}

class _AddNewAdminDialogState extends State<AddNewAdminDialog> {
  bool _showData = false;
  bool _showActionBtn = false;
  final List<User> _userList = [];
  String _selectedUserName = "";

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _showData
        ? SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height - 20,
            child: Column(
              children: [
                Text(
                  "لیست کاربران عادی",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: AppStyle.defaultPadding),
                SizedBox(
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height - 250,
                    child: SearchableList<User>(
                      initialList: _userList,
                      shrinkWrap: false,
                      textStyle: const TextStyle(fontSize: 25),
                      itemBuilder: (User user) => ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          user.accountId.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedUserName =
                                "${user.accountId}: ${user.name}";
                            _showActionBtn = true;
                          });
                        },
                      ),
                      loadingWidget: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 20,
                          ),
                          Text('بارگذاری کاربران ...')
                        ],
                      ),
                      errorWidget: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text('خطا')
                        ],
                      ),
                      filter: (q) {
                        return _userList
                            .where((element) =>
                                element.accountId.toString().contains(q) ||
                                element.name.toString().contains(q))
                            .toList();
                      },
                      textAlign: TextAlign.right,
                      emptyWidget: const EmptyView(),
                      onRefresh: () async {},
                      sortPredicate: (a, b) =>
                          a.accountId.compareTo(b.accountId),
                      displayClearIcon: true,
                      inputDecoration: InputDecoration(
                        labelText: "کاربر را انتخاب کنید",
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    )),
                SizedBox(height: AppStyle.defaultPadding),
                SizedBox(
                  height: AppStyle.defaultPadding,
                  child: Text("افزودن $_selectedUserName به لیست مدیران"),
                ),
                Row(
                  children: [
                    _showActionBtn
                        ? ElevatedButton(
                            onPressed: () async {
                              EasyLoading.show();
                              int id = int.parse(
                                  _selectedUserName.split(":").first.trim());
                              await changeUserRoleToAdmin(userId: id)
                                  .then((res) {
                                        if (!context.mounted) return;
                                if (res) {
                                  // set call USerAdmin changed to true
                                  Provider.of<UserAdminProvider>(
                                          listen: false, context)
                                      .setChanged(true);
                                  Navigator.pop(context, _selectedUserName);
                                  showMsg(msg: "موفق", context: context);
                                } else {
                                  showMsg(
                                      msg: "حطا",
                                      context: context,
                                      type: "error");
                                }
                              }).onError((e, s) {
                                debugPrint(e.toString());
                              });
                              EasyLoading.dismiss();
                            },
                            child: const Text("تایید"),
                          )
                        : Container(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _selectedUserName);
                      },
                      child: const Text("لغو"),
                    ),
                  ],
                )
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  void _fillData() async {
    await getNormalUsers().then((val) {
      if (val != null && val.isNotEmpty) {
        setState(() {
          for (var i in val) {
            _userList.add(i);
          }
          _selectedUserName = "${val[0].accountId}: ${val[0].name}";
        });
      }

      setState(() {
        _showData = true;
      });
    });
  }
}
