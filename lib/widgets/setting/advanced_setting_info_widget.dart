import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/repositories/setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class AdvancedSettingInfoWidget extends StatefulWidget {
  const AdvancedSettingInfoWidget({
    super.key,
    required this.description,
    required this.state,
    required this.name,
  });

  final String description, name;
  final bool state;
  @override
  State<AdvancedSettingInfoWidget> createState() =>
      _AdvancedSettingInfoWidgetState();
}

class _AdvancedSettingInfoWidgetState extends State<AdvancedSettingInfoWidget> {
  bool _newState = false;
  @override
  void initState() {
    _newState = widget.state;

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
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          width: 1,
          color: AppStyle.primaryColor.withValues(alpha: 0.1),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppStyle.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings_suggest_outlined,
              color: AppStyle.primaryColor,
              size: 20,
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Switch(
            value: _newState,
            activeThumbColor: AppStyle.primaryColor,
            onChanged: (bool newValue) async {
              EasyLoading.show();
              await changeAdvancedSetting(name: widget.name, value: newValue)
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
                showMsg(msg: "خطا", context: context, type: "error");
              }).whenComplete(() => EasyLoading.dismiss());
            },
          ),
        ],
      ),
    );
  }
}
