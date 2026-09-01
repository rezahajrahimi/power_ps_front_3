import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/advanced_setting_model.dart';
import 'package:powerps/repositories/setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/license_gate_dialog.dart';
import 'package:powerps/widgets/public/license_tier_badge.dart';

class AdvancedSettingInfoWidget extends StatefulWidget {
  const AdvancedSettingInfoWidget({
    super.key,
    required this.description,
    required this.state,
    required this.name,
    this.locked = false,
    this.requiredTier = 'نقره‌ای',
  });

  final String description;
  final String name;
  final bool state;
  final bool locked;
  final String requiredTier;

  @override
  State<AdvancedSettingInfoWidget> createState() =>
      _AdvancedSettingInfoWidgetState();
}

class _AdvancedSettingInfoWidgetState extends State<AdvancedSettingInfoWidget> {
  late bool _newState;

  @override
  void initState() {
    _newState = widget.state;
    super.initState();
  }

  @override
  void didUpdateWidget(AdvancedSettingInfoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _newState = widget.state;
    }
  }

  void _showLicenseGate() {
    showLicenseGateDialog(
      context: context,
      title: 'تنظیمات پیشرفته',
      message:
          'این گزینه در لایسنس ${widget.requiredTier} و بالاتر فعال می‌شود.',
      requiredTier: widget.requiredTier,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tier = AdvancedSettingModel.tierBadgeType(widget.name);

    return Opacity(
      opacity: widget.locked ? 0.65 : 1,
      child: Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            width: 1,
            color: AppStyle.primaryColor.withValues(alpha: 0.1),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (tier != null) ...[
                          const SizedBox(width: 8),
                          LicenseTierBadge.fromAdvancedTier(tier, compact: true),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Switch(
              value: _newState,
              activeThumbColor: AppStyle.primaryColor,
              onChanged: widget.locked
                  ? (_) => _showLicenseGate()
                  : (bool newValue) async {
                      EasyLoading.show();
                      final saved = await changeAdvancedSetting(
                        name: widget.name,
                        value: newValue,
                      );
                      EasyLoading.dismiss();
                      if (!context.mounted) return;
                      if (saved) {
                        setState(() => _newState = newValue);
                        showMsg(msg: 'ذخیره شد', context: context);
                      } else {
                        showMsg(
                          msg: 'خطا در ذخیره سازی',
                          context: context,
                          type: 'error',
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
