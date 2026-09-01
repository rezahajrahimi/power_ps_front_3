import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/agent_limit_usage_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';
import 'package:powerps/styles/app_theme.dart';

class AgentLimitsInfoCardWidget extends StatelessWidget {
  const AgentLimitsInfoCardWidget({
    super.key,
    required this.permission,
    this.usage,
    this.showResetButton = false,
    this.onReset,
  });

  final AgentPermisson permission;
  final AgentLimitUsage? usage;
  final bool showResetButton;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "محدودیت‌های فروش",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (showResetButton && onReset != null)
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('ریست مصرف'),
                ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (usage != null) ...[
            _usageProgress(
              context,
              icon: Icons.inventory_2_outlined,
              label: 'کانفیگ',
              used: usage!.usedProductCount,
              limit: usage!.productLimit,
              remaining: usage!.remainingProductCount,
              percent: usage!.productUsagePercent,
              unit: 'عدد',
            ),
            const SizedBox(height: 14),
            _usageProgress(
              context,
              icon: Icons.data_usage,
              label: 'ترافیک',
              used: usage!.usedTrafficTb,
              limit: usage!.trafficLimitTb,
              remaining: usage!.remainingTrafficTb,
              percent: usage!.trafficUsagePercent,
              unit: 'TB',
              isDouble: true,
            ),
            const SizedBox(height: 14),
          ] else ...[
            _limitRow(
              context,
              icon: Icons.inventory_2_outlined,
              label: "حداکثر کانفیگ",
              value: thousandSeperatorFormatter(
                permission.productLimitation.toString(),
              ),
            ),
            const SizedBox(height: 8),
            _limitRow(
              context,
              icon: Icons.data_usage,
              label: "حداکثر ترافیک",
              value: "${permission.trafficLimitationTB} ترابایت",
            ),
            const SizedBox(height: 14),
          ],
          _limitRow(
            context,
            icon: Icons.account_balance_wallet_outlined,
            label: "موجودی منفی",
            value: permission.minusBallance ? "مجاز" : "غیرمجاز",
          ),
          if (permission.minusBallance) ...[
            const SizedBox(height: 14),
            if (usage != null && usage!.hasDebtUsage)
              _debtUsageSection(context)
            else ...[
              const SizedBox(height: 8),
              _limitRow(
                context,
                icon: Icons.money_off_csred_outlined,
                label: "سقف بدهی",
                value: permission.minusBallanceLimit != null &&
                        permission.minusBallanceLimit! > 0
                    ? "${thousandSeperatorFormatter(permission.minusBallanceLimit!.toStringAsFixed(0))} تومان"
                    : "بدون محدودیت",
              ),
            ],
          ],
          const SizedBox(height: 8),
          _limitRow(
            context,
            icon: Icons.delete_outline,
            label: "حذف اکانت کم‌مصرف",
            value: permission.deleteProducts ? "مجاز" : "غیرمجاز",
          ),
        ],
      ),
    );
  }

  Widget _debtUsageSection(BuildContext context) {
    final debt = usage!.currentDebt;
    final limit = usage!.minusBallanceLimit;
    final remaining = usage!.remainingDebtLimit;
    final hasLimit = limit != null && limit > 0;

    if (hasLimit) {
      return _usageProgress(
        context,
        icon: Icons.money_off_csred_outlined,
        label: 'بدهی',
        used: debt,
        limit: limit,
        remaining: remaining ?? 0,
        percent: usage!.debtUsagePercent,
        unit: 'تومان',
        isDouble: true,
        formatAsMoney: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _limitRow(
          context,
          icon: Icons.money_off_csred_outlined,
          label: "سقف بدهی",
          value: "بدون محدودیت",
        ),
        const SizedBox(height: 8),
        _limitRow(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: "بدهی فعلی",
          value: debt > 0
              ? "${thousandSeperatorFormatter(debt.toStringAsFixed(0))} تومان"
              : "بدون بدهی",
        ),
        if (usage!.currentBalance != null) ...[
          const SizedBox(height: 8),
          _limitRow(
            context,
            icon: Icons.payments_outlined,
            label: "موجودی فعلی",
            value:
                "${thousandSeperatorFormatter(usage!.currentBalance!.toStringAsFixed(0))} تومان",
          ),
        ],
      ],
    );
  }

  Widget _usageProgress(
    BuildContext context, {
    required IconData icon,
    required String label,
    required num used,
    required num limit,
    required num remaining,
    required double percent,
    required String unit,
    bool isDouble = false,
    bool formatAsMoney = false,
  }) {
    final usedText = formatAsMoney
        ? thousandSeperatorFormatter(
            isDouble ? used.toStringAsFixed(0) : used.toString())
        : isDouble
            ? used.toStringAsFixed(2)
            : used.toString();
    final limitText = formatAsMoney
        ? thousandSeperatorFormatter(
            isDouble ? limit.toStringAsFixed(0) : limit.toString())
        : isDouble
            ? limit.toStringAsFixed(2)
            : limit.toString();
    final remainingText = formatAsMoney
        ? thousandSeperatorFormatter(
            isDouble ? remaining.toStringAsFixed(0) : remaining.toString())
        : isDouble
            ? remaining.toStringAsFixed(2)
            : remaining.toString();
    final color = percent >= 100
        ? Colors.redAccent
        : percent >= 80
            ? Colors.orangeAccent
            : Colors.greenAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppStyle.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            Text(
              '$usedText / $limitText $unit',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (percent / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.white12,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'باقیمانده: $remainingText $unit (${percent.toStringAsFixed(1)}%)',
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
        ),
      ],
    );
  }

  Widget _limitRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppStyle.primaryColor),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
