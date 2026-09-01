import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/repositories/user_group_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class UserVerificationToggleWidget extends StatefulWidget {
  const UserVerificationToggleWidget({
    super.key,
    required this.userId,
    required this.isVerified,
    this.onChanged,
  });

  final int userId;
  final bool isVerified;
  final VoidCallback? onChanged;

  @override
  State<UserVerificationToggleWidget> createState() =>
      _UserVerificationToggleWidgetState();
}

class _UserVerificationToggleWidgetState extends State<UserVerificationToggleWidget> {
  late bool _isVerified;

  @override
  void initState() {
    _isVerified = widget.isVerified;
    super.initState();
  }

  @override
  void didUpdateWidget(UserVerificationToggleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isVerified != widget.isVerified) {
      _isVerified = widget.isVerified;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: [
          Icon(
            _isVerified ? Icons.verified_user : Icons.person_off_outlined,
            color: _isVerified ? Colors.greenAccent : Colors.orangeAccent,
          ),
          SizedBox(width: AppStyle.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وضعیت تایید کاربر',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  _isVerified ? 'تایید شده' : 'تایید نشده',
                  style: TextStyle(
                    color: _isVerified ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isVerified,
            onChanged: (val) async {
              EasyLoading.show();
              final user = await updateUserVerificationStatus(
                userId: widget.userId,
                isVerified: val,
              );
              EasyLoading.dismiss();
              if (!context.mounted) return;
              if (user != null) {
                setState(() => _isVerified = val);
                showMsg(
                  msg: val ? 'کاربر تایید شد' : 'تایید کاربر لغو شد',
                  context: context,
                );
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
