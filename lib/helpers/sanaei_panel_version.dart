import 'package:flutter/material.dart';
import 'package:powerps/styles/app_theme.dart';

/// 3x-ui v3+ uses `/panel/api`, older sanaei/x-ui uses `/xui/API`.
class SanaeiApiVersion {
  static const String v3 = 'v3';
  static const String v2 = 'v2';

  static String normalize(String? value) {
    final v = (value ?? v3).toLowerCase().trim();
    if (v == '2' || v == 'v2' || v == '1' || v == 'v1') return v2;
    return v3;
  }

  static String label(String value) {
    return normalize(value) == v3
        ? 'نسخه 3 و بالاتر (3x-ui جدید)'
        : 'نسخه 2 و پایین‌تر (sanaei / x-ui قدیمی)';
  }
}

class SanaeiApiVersionDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const SanaeiApiVersionDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding / 2),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: AppStyle.primaryColor.withValues(alpha: 0.15),
        ),
        borderRadius:
            BorderRadius.all(Radius.circular(AppStyle.defaultPadding)),
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: SanaeiApiVersion.normalize(value),
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: 'نسخه API پنل سنایی',
        ),
        alignment: Alignment.centerLeft,
        onChanged: onChanged,
        items: const [
          DropdownMenuItem(
            value: SanaeiApiVersion.v3,
            alignment: Alignment.centerRight,
            child: Text('نسخه 3 و بالاتر (3x-ui جدید)'),
          ),
          DropdownMenuItem(
            value: SanaeiApiVersion.v2,
            alignment: Alignment.centerRight,
            child: Text('نسخه 2 و پایین‌تر (sanaei / x-ui قدیمی)'),
          ),
        ],
      ),
    );
  }
}
