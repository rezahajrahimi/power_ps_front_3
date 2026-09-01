import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/repositories/bot_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';

class AdminAliasEditorWidget extends StatefulWidget {
  const AdminAliasEditorWidget({
    super.key,
    this.botUserId,
    this.accountId,
    required this.adminAlias,
    this.onChanged,
  }) : assert(botUserId != null || accountId != null,
            'botUserId or accountId is required');

  final int? botUserId;
  final int? accountId;
  final String? adminAlias;
  final VoidCallback? onChanged;

  @override
  State<AdminAliasEditorWidget> createState() => _AdminAliasEditorWidgetState();
}

class _AdminAliasEditorWidgetState extends State<AdminAliasEditorWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.adminAlias ?? '');
  }

  @override
  void didUpdateWidget(covariant AdminAliasEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adminAlias != widget.adminAlias) {
      _controller.text = widget.adminAlias ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final alias = _controller.text.trim();
    EasyLoading.show();
    final updated = await updateBotUserAdminAlias(
      botUserId: widget.botUserId,
      accountId: widget.accountId,
      adminAlias: alias.isEmpty ? null : alias,
    );
    EasyLoading.dismiss();
    if (!mounted) return;
    if (updated != null) {
      showMsg(msg: 'اسم مستعار ذخیره شد', context: context);
      widget.onChanged?.call();
    } else {
      showMsg(msg: 'خطا در ذخیره', context: context, type: 'error');
    }
  }

  Future<void> _clear() async {
    _controller.clear();
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.label_outline,
                  color: Colors.amberAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'اسم مستعار (فقط ادمین)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (widget.adminAlias != null && widget.adminAlias!.isNotEmpty)
                TextButton(
                  onPressed: _clear,
                  child: const Text('حذف'),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              'این نام فقط در پنل ادمین نمایش داده می‌شود و کاربر آن را نمی‌بیند.',
              style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 12),
            ),
          ),
          CustomTextFromFieldWidget(
            controller: _controller,
            textHint: 'مثال: مشتری VIP تهران',
            validationError: '',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('ذخیره اسم مستعار'),
            ),
          ),
        ],
      ),
    );
  }
}

class BotUserAdminAliasWidget extends StatelessWidget {
  const BotUserAdminAliasWidget({
    super.key,
    required this.botUser,
    this.onChanged,
  });

  final BotUser botUser;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return AdminAliasEditorWidget(
      botUserId: botUser.id.toInt(),
      adminAlias: botUser.adminAlias,
      onChanged: onChanged,
    );
  }
}
