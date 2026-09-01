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

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) {
      return fallback;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return fallback;
      }
      return int.tryParse(trimmed) ??
          double.tryParse(trimmed)?.toInt() ??
          fallback;
    }
    return fallback;
  }

  static DateTime _parseExpire(dynamic expireRaw) {
    if (expireRaw == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    if (expireRaw is String) {
      final trimmed = expireRaw.trim();
      if (trimmed.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }

      final parsedDate = DateTime.tryParse(trimmed);
      if (parsedDate != null) {
        return parsedDate;
      }

      final expireNum = _parseInt(trimmed, fallback: -1);
      if (expireNum <= 0) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }

      return expireNum > 9999999999
          ? DateTime.fromMillisecondsSinceEpoch(expireNum)
          : DateTime.fromMillisecondsSinceEpoch(expireNum * 1000);
    }

    final expireNum = _parseInt(expireRaw, fallback: -1);
    if (expireNum <= 0) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return expireNum > 9999999999
        ? DateTime.fromMillisecondsSinceEpoch(expireNum)
        : DateTime.fromMillisecondsSinceEpoch(expireNum * 1000);
  }

  factory MarzbanConfig.fromJson(Map<String, dynamic> json) {
    return MarzbanConfig(
      expire: _parseExpire(json['expire'] ?? json['expire_timestamp']),
      dataLimitResetStrategy: json['data_limit_reset_strategy']?.toString(),
      note: json['note']?.toString(),
      subUpdatedAt: json['sub_updated_at']?.toString(),
      subLastUserAgent: json['sub_last_user_agent']?.toString(),
      onlineAt: json['online_at']?.toString(),
      onHoldExpireDuration: json['on_hold_expire_duration']?.toString(),
      onHoldTimeout: json['on_hold_timeout']?.toString(),
      username: json['username']?.toString(),
      status: json['status']?.toString(),
      dataLimit: _parseInt(json['data_limit']),
      usedTraffic: _parseInt(json['used_traffic']),
      lifetimeUsedTraffic: _parseInt(json['lifetime_used_traffic']),
    );
  }
}
