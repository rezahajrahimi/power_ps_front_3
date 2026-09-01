import 'package:flutter/material.dart';
import 'package:powerps/helper/license_helper.dart';

enum LicenseTierBadgeType { silver, gold }

class LicenseTierBadge extends StatelessWidget {
  const LicenseTierBadge({
    super.key,
    required this.tier,
    this.compact = false,
  });

  final LicenseTierBadgeType tier;
  final bool compact;

  factory LicenseTierBadge.fromAdvancedTier(
    AdvancedSettingLicenseTier tier, {
    bool compact = false,
  }) {
    return LicenseTierBadge(
      tier: tier == AdvancedSettingLicenseTier.gold
          ? LicenseTierBadgeType.gold
          : LicenseTierBadgeType.silver,
      compact: compact,
    );
  }

  String get _label => tier == LicenseTierBadgeType.gold ? 'طلایی' : 'نقره‌ای';

  Color get _color =>
      tier == LicenseTierBadgeType.gold ? Colors.amber : Colors.blueGrey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.45)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: tier == LicenseTierBadgeType.gold
              ? Colors.amber.shade300
              : Colors.blueGrey.shade300,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
