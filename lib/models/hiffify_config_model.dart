import 'dart:convert';

class HiddifyConfig {
  String uuid;
  String? addedByUuid;
  String? comment;
  double currentUsageGB;
  String? lastOnline;
  String? mode;
  String name;
  int packageDays;
  String? startDate;
  double usageLimitGB;
  bool isActive;

  HiddifyConfig({
    required this.uuid,
    this.addedByUuid,
    this.comment,
    required this.currentUsageGB,
    this.lastOnline,
    this.mode,
    required this.name,
    required this.packageDays,
    this.startDate,
    required this.usageLimitGB,
    required this.isActive,
  });

  factory HiddifyConfig.fromJson(Map<String, dynamic> json) {
    return HiddifyConfig(
      uuid: json['uuid'].toString(),
      addedByUuid: json['added_by_uuid'].toString(),
      comment: json['comment'].toString(),
      currentUsageGB: double.parse(json['current_usage_GB'].toString()),
      lastOnline: json['last_online'].toString(),
      mode: json['mode'].toString(),
      name: json['name'].toString(),
      packageDays: json['package_days'],
      startDate: json['start_date'].toString(),
      usageLimitGB: double.parse(json['usage_limit_GB'].toString()),
      isActive: json['is_active'].toString() == "1" ||
              json['is_active'].toString() == "true"
          ? true
          : false,
    );
  }

  HiddifyConfig copyWith({
    String? uuid,
    String? addedByUuid,
    String? comment,
    double? currentUsageGB,
    String? lastOnline,
    String? mode,
    String? name,
    int? packageDays,
    String? startDate,
    double? usageLimitGB,
    bool? isActive,
  }) {
    return HiddifyConfig(
      uuid: uuid ?? this.uuid,
      addedByUuid: addedByUuid ?? this.addedByUuid,
      comment: comment ?? this.comment,
      currentUsageGB: currentUsageGB ?? this.currentUsageGB,
      lastOnline: lastOnline ?? this.lastOnline,
      mode: mode ?? this.mode,
      name: name ?? this.name,
      packageDays: packageDays ?? this.packageDays,
      startDate: startDate ?? this.startDate,
      usageLimitGB: usageLimitGB ?? this.usageLimitGB,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'addedByUuid': addedByUuid,
      'comment': comment,
      'currentUsageGB': currentUsageGB,
      'lastOnline': lastOnline,
      'mode': mode,
      'name': name,
      'packageDays': packageDays,
      'startDate': startDate,
      'usageLimitGB': usageLimitGB,
      'isActive': isActive,
    };
  }

  factory HiddifyConfig.fromMap(Map<String, dynamic> map) {
    return HiddifyConfig(
      uuid: map['uuid'] ?? '',
      addedByUuid: map['addedByUuid'],
      comment: map['comment'],
      currentUsageGB: map['currentUsageGB']?.toDouble() ?? 0.0,
      lastOnline: map['lastOnline'],
      mode: map['mode'],
      name: map['name'] ?? '',
      packageDays: map['packageDays']?.toInt() ?? 0,
      startDate: map['startDate'],
      usageLimitGB: map['usageLimitGB']?.toDouble() ?? 0.0,
      isActive: map['isActive'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  // factory HiddifyConfig.fromJson(String source) => HiddifyConfig.fromMap(json.decode(source));

  @override
  String toString() {
    return 'HiddifyConfig(uuid: $uuid, addedByUuid: $addedByUuid, comment: $comment, currentUsageGB: $currentUsageGB, lastOnline: $lastOnline, mode: $mode, name: $name, packageDays: $packageDays, startDate: $startDate, usageLimitGB: $usageLimitGB, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HiddifyConfig &&
        other.uuid == uuid &&
        other.addedByUuid == addedByUuid &&
        other.comment == comment &&
        other.currentUsageGB == currentUsageGB &&
        other.lastOnline == lastOnline &&
        other.mode == mode &&
        other.name == name &&
        other.packageDays == packageDays &&
        other.startDate == startDate &&
        other.usageLimitGB == usageLimitGB &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        addedByUuid.hashCode ^
        comment.hashCode ^
        currentUsageGB.hashCode ^
        lastOnline.hashCode ^
        mode.hashCode ^
        name.hashCode ^
        packageDays.hashCode ^
        startDate.hashCode ^
        usageLimitGB.hashCode ^
        isActive.hashCode;
  }
}
