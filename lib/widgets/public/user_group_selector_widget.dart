import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/user_group_model.dart';
import 'package:powerps/repositories/user_group_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class UserGroupSelectorWidget extends StatefulWidget {
  const UserGroupSelectorWidget({
    super.key,
    required this.userId,
    required this.roleType,
    this.currentGroupId,
    this.onChanged,
  });

  final int userId;
  final String roleType;
  final int? currentGroupId;
  final VoidCallback? onChanged;

  @override
  State<UserGroupSelectorWidget> createState() =>
      _UserGroupSelectorWidgetState();
}

class _UserGroupSelectorWidgetState extends State<UserGroupSelectorWidget> {
  List<UserGroup> _groups = [];
  int? _selectedGroupId;
  bool _loaded = false;

  @override
  void initState() {
    _selectedGroupId = widget.currentGroupId;
    _loadGroups();
    super.initState();
  }

  Future<void> _loadGroups() async {
    final data = await getUserGroups(roleType: widget.roleType);
    if (!mounted) return;
    if (data != null) {
      setState(() {
        _groups = (data['groups'] as List<UserGroup>)
            .where((g) => widget.roleType != 'user' || !g.isDefault)
            .toList();
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'گروه کاربری',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding / 2),
          DropdownButtonFormField<int?>(
            initialValue:
                widget.roleType == 'user' ? _selectedGroupId : _selectedGroupId,
            decoration: InputDecoration(
              labelText: 'انتخاب گروه',
              border: const OutlineInputBorder(),
              helperText: widget.roleType == 'user'
                  ? 'بدون گروه = پرداخت بر اساس وضعیت تایید'
                  : null,
            ),
            items: [
              if (widget.roleType == 'user')
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('بدون گروه (بر اساس وضعیت تایید)'),
                ),
              ..._groups.map(
                (g) => DropdownMenuItem<int?>(
                  value: g.id,
                  child: Text(g.name),
                ),
              ),
            ],
            onChanged: (val) async {
              EasyLoading.show();
              final user = await assignUserToGroup(
                userId: widget.userId,
                userGroupId: val,
              );
              EasyLoading.dismiss();
              if (!context.mounted) return;
              if (user != null) {
                setState(() => _selectedGroupId = val);
                showMsg(msg: 'گروه کاربر ذخیره شد', context: context);
                widget.onChanged?.call();
              } else {
                showMsg(msg: 'خطا', context: context, type: 'error');
              }
            },
          ),
        ],
      ),
    );
  }
}
