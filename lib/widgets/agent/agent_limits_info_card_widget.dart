import 'package:flutter/material.dart';
import 'package:powerps/models/agent_permisson_model.dart';
import 'package:powerps/styles/app_theme.dart';

class AgentLimitsInfoCardWidget extends StatelessWidget {
  const AgentLimitsInfoCardWidget({super.key, required this.permission});

  final AgentPermisson permission;

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
          Text(
            "محدودیت‌های فروش",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _limitRow(
            context,
            icon: Icons.inventory_2_outlined,
            label: "حداکثر کانفیگ",
            value: permission.productLimitation.toString(),
          ),
          const SizedBox(height: 8),
          _limitRow(
            context,
            icon: Icons.data_usage,
            label: "حداکثر ترافیک",
            value: "${permission.trafficLimitationTB} ترابایت",
          ),
          const SizedBox(height: 8),
          _limitRow(
            context,
            icon: Icons.account_balance_wallet_outlined,
            label: "موجودی منفی",
            value: permission.minusBallance ? "مجاز" : "غیرمجاز",
          ),
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
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
