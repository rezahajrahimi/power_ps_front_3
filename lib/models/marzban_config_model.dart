class MarzbanConfig {
  DateTime expire;
  String? dataLimitResetStrategy,
      note,
      subUpdatedAt,
      subLastUserAgent,
      onlineAt,
      onHoldExpireDuration,
      onHoldTimeout,
      username,
      status;
  int dataLimit, usedTraffic, lifetimeUsedTraffic;

  MarzbanConfig({
    required this.expire,
    this.dataLimitResetStrategy,
    this.note,
    this.subUpdatedAt,
    this.subLastUserAgent,
    this.onlineAt,
    this.onHoldExpireDuration,
    this.onHoldTimeout,
    this.username,
    this.status,
    required this.dataLimit,
    required this.usedTraffic,
    required this.lifetimeUsedTraffic,
  });

  factory MarzbanConfig.fromJson(Map<String, dynamic> json) {
    final expireRaw = json['expire'];
    DateTime expireDate;
    if (expireRaw == null) {
      expireDate = DateTime.fromMillisecondsSinceEpoch(0);
    } else {
      final expireNum = (expireRaw as num).toInt();
      expireDate = expireNum > 9999999999
          ? DateTime.fromMillisecondsSinceEpoch(expireNum)
          : DateTime.fromMillisecondsSinceEpoch(expireNum * 1000);
    }

    return MarzbanConfig(
      expire: expireDate,
      dataLimitResetStrategy: json['data_limit_reset_strategy'],
      note: json['note'],
      subUpdatedAt: json['sub_updated_at'],
      subLastUserAgent: json['sub_last_user_agent'],
      onlineAt: json['online_at'],
      onHoldExpireDuration: json['on_hold_expire_duration'],
      onHoldTimeout: json['on_hold_timeout'],
      username: json['username'],
      status: json['status'],
      dataLimit: json['data_limit'],
      usedTraffic: json['used_traffic'],
      lifetimeUsedTraffic: json['lifetime_used_traffic'],
    );
  }
}
