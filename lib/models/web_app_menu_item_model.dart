import 'dart:convert';

class WebAPPMenuItemModel {
  int id;
  String key;
  String title;
  String subtitle;
  bool isActive;
  int position;
  WebAPPMenuItemModel(
      {required this.id,
      required this.key,
      required this.title,
      required this.subtitle,
      required this.isActive,
      required this.position});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'title': title,
      'subtitle': subtitle,
      'is_active': isActive,
      'position': position,
    };
  }

  factory WebAPPMenuItemModel.fromMap(Map<String, dynamic> map) {
    return WebAPPMenuItemModel(
      id: map['id'] ?? 0,
      key: map['key'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      isActive:
          map['is_active'] == 1 || map['is_active'] == true ? true : false,
      position: map['position'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory WebAPPMenuItemModel.fromJson(String source) =>
      WebAPPMenuItemModel.fromMap(json.decode(source));
}
