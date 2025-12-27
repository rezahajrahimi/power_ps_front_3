class SanaeiConfig {
  bool enable;
  double currentUsageGB;
  double usageLimitGB;
  String? startDate;
  int packageDays;
  Map<String, dynamic>? inbound;
  Map<String, dynamic>? client;

  SanaeiConfig({
    required this.enable,
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
      currentUsageGB: double.parse(json['current_usage_GB'].toString()),
      usageLimitGB: double.parse(json['usage_limit_GB'].toString()),
      startDate: json['start_date']?.toString(),
      packageDays: json['package_days'] ?? 0,
      inbound: json['inbound'],
      client: json['client'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable': enable,
      'current_usage_GB': currentUsageGB,
      'usage_limit_GB': usageLimitGB,
      'start_date': startDate,
      'package_days': packageDays,
      'inbound': inbound,
      'client': client,
    };
  }
}
