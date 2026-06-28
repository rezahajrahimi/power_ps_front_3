class AgentLimitUsage {
  final int productLimit;
  final double trafficLimitTb;
  final int usedProductCount;
  final double usedTrafficTb;
  final int remainingProductCount;
  final double remainingTrafficTb;
  final int totalProductCount;
  final double totalTrafficTb;
  final int productCountBaseline;
  final double trafficTbBaseline;
  final double productUsagePercent;
  final double trafficUsagePercent;
  final double? minusBallanceLimit;
  final double? currentBalance;
  final double currentDebt;
  final double? remainingDebtLimit;
  final double debtUsagePercent;

  AgentLimitUsage({
    required this.productLimit,
    required this.trafficLimitTb,
    required this.usedProductCount,
    required this.usedTrafficTb,
    required this.remainingProductCount,
    required this.remainingTrafficTb,
    required this.totalProductCount,
    required this.totalTrafficTb,
    required this.productCountBaseline,
    required this.trafficTbBaseline,
    required this.productUsagePercent,
    required this.trafficUsagePercent,
    this.minusBallanceLimit,
    this.currentBalance,
    this.currentDebt = 0,
    this.remainingDebtLimit,
    this.debtUsagePercent = 0,
  });

  bool get hasDebtUsage =>
      minusBallanceLimit != null || currentDebt > 0 || currentBalance != null;

  factory AgentLimitUsage.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return AgentLimitUsage.empty();
    }

    return AgentLimitUsage(
      productLimit: map['product_limit']?.toInt() ?? 0,
      trafficLimitTb:
          double.tryParse(map['traffic_limit_tb']?.toString() ?? '0') ?? 0,
      usedProductCount: map['used_product_count']?.toInt() ?? 0,
      usedTrafficTb:
          double.tryParse(map['used_traffic_tb']?.toString() ?? '0') ?? 0,
      remainingProductCount: map['remaining_product_count']?.toInt() ?? 0,
      remainingTrafficTb:
          double.tryParse(map['remaining_traffic_tb']?.toString() ?? '0') ?? 0,
      totalProductCount: map['total_product_count']?.toInt() ?? 0,
      totalTrafficTb:
          double.tryParse(map['total_traffic_tb']?.toString() ?? '0') ?? 0,
      productCountBaseline: map['product_count_baseline']?.toInt() ?? 0,
      trafficTbBaseline:
          double.tryParse(map['traffic_tb_baseline']?.toString() ?? '0') ?? 0,
      productUsagePercent:
          double.tryParse(map['product_usage_percent']?.toString() ?? '0') ??
              0,
      trafficUsagePercent:
          double.tryParse(map['traffic_usage_percent']?.toString() ?? '0') ?? 0,
      minusBallanceLimit: map['minus_ballance_limit'] == null
          ? null
          : double.tryParse(map['minus_ballance_limit'].toString()),
      currentBalance: map['current_balance'] == null
          ? null
          : double.tryParse(map['current_balance'].toString()),
      currentDebt:
          double.tryParse(map['current_debt']?.toString() ?? '0') ?? 0,
      remainingDebtLimit: map['remaining_debt_limit'] == null
          ? null
          : double.tryParse(map['remaining_debt_limit'].toString()),
      debtUsagePercent:
          double.tryParse(map['debt_usage_percent']?.toString() ?? '0') ?? 0,
    );
  }

  factory AgentLimitUsage.empty() {
    return AgentLimitUsage(
      productLimit: 0,
      trafficLimitTb: 0,
      usedProductCount: 0,
      usedTrafficTb: 0,
      remainingProductCount: 0,
      remainingTrafficTb: 0,
      totalProductCount: 0,
      totalTrafficTb: 0,
      productCountBaseline: 0,
      trafficTbBaseline: 0,
      productUsagePercent: 0,
      trafficUsagePercent: 0,
      currentDebt: 0,
      debtUsagePercent: 0,
    );
  }
}
