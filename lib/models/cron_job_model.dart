import 'dart:convert';

class CronJobModel {
  int id;
  String name;
  String frequency;
  String description;
  bool isActive;

  CronJobModel({
    required this.id,
    required this.name,
    required this.frequency,
    required this.description,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'frequency': frequency,
      'description': description,
      'isActive': isActive,
    };
  }

  factory CronJobModel.fromMap(Map<String, dynamic> map) {
    return CronJobModel(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      frequency: map['frequency'] ?? '',
      description: map['description'] ?? '',
      isActive:
          map['is_active'] == 1 || map['is_active'] == true ? true : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory CronJobModel.fromJson(String source) =>
      CronJobModel.fromMap(json.decode(source));
}
