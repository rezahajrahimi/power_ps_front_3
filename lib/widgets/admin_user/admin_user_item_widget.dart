import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/provider/user_admin_provider.dart';
import 'package:powerps/repositories/panel_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:provider/provider.dart';

class AdminUserItemWidget extends StatefulWidget {
  final User userModel;
  const AdminUserItemWidget({super.key, required this.userModel});

  @override
  State<AdminUserItemWidget> createState() => _AdminUserItemWidgetState();
}

class _AdminUserItemWidgetState extends State<AdminUserItemWidget> {
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
      child: ListTile(
        leading: const Icon(Icons.person),
        enabled: widget.userModel.id == 1 ? false : true, // it's main admin
        title: Text(
          widget.userModel.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          widget.userModel.accountId.toString(),
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _showDeleteDialog(context);
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف مدیر'),
          content: const Text(
            'از حذف این مدیر اطمینان دارید؟',
            style: TextStyle(color: Colors.red),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('خیر'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('بله'),
              onPressed: () async {
                EasyLoading.show();
                await changeAgentRoleToUser(userId: widget.userModel.accountId)
                    .then((res) {
                      if (!context.mounted) return;
                  if (res) {
                    // set call USerAdmin changed to true
                    Provider.of<UserAdminProvider>(listen: false, context)
                        .setChanged(true);
                    Navigator.pop(context);
                    showMsg(msg: "موفق", context: context);
                  } else {
                    showMsg(msg: "حطا", context: context, type: "error");
                  }
                }).onError((e, s) {
                  debugPrint(e.toString());
                });
                EasyLoading.dismiss();
              },
            ),
          ],
        );
      },
    );
  }
}
