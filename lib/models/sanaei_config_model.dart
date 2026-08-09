class SanaeiConfig {
  bool enable;
  bool isActive;
  double currentUsageGB;
  double usageLimitGB;
  String? startDate;
  int packageDays;
  Map<String, dynamic>? inbound;
  Map<String, dynamic>? client;

  SanaeiConfig({
    required this.enable,
    required this.isActive,
    required this.currentUsageGB,
    required this.usageLimitGB,
    this.startDate,
    required this.packageDays,
    this.inbound,
    this.client,
  });

  factory SanaeiConfig.fromJson(Map<String, dynamic> json) {
    return SanaeiConfig(
      enable: json['enable'] == true ||
          json['enable'].toString() == "1" ||
          json['enable'].toString() == "true",
      isActive: json['is_active'] == true ||
          json['is_active'].toString() == "1" ||
          json['is_active'].toString() == "true",
      currentUsageGB: double.parse(json['current_usage_GB'].toString()),
      usageLimitGB: double.parse(json['usage_limit_GB'].toString()),
      startDate: json['start_date']?.toString(),
      packageDays: _toIntDays(json['package_days']),
      inbound: json['inbound'],
      client: json['client'],
    );
  }

  static int _toIntDays(dynamic raw) {
    if (raw == null) return 0;
    if (raw is int) return raw < 0 ? 0 : raw;
    if (raw is num) return raw <= 0 ? 0 : raw.round();
    return int.tryParse(raw.toString()) ??
        (double.tryParse(raw.toString())?.round() ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'enable': enable,
      'is_active': isActive,
      'current_usage_GB': currentUsageGB,
      'usage_limit_GB': usageLimitGB,
      'start_date': startDate,
      'package_days': packageDays,
      'inbound': inbound,
      'client': client,
    };
  }
}
