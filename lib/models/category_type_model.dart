import 'dart:convert';

class CategoryTypeModel {
  int id;
  String name;
  bool isActive;
  CategoryTypeModel({
    required this.id,
    required this.name,
    required this.isActive,
  });
  CategoryTypeModel copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return CategoryTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }

  factory CategoryTypeModel.fromJson(String source) =>
      CategoryTypeModel.fromMap(json.decode(source));
  factory CategoryTypeModel.fromMap(Map<String, dynamic> map) {
    return CategoryTypeModel(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      isActive: map['is_active'] == 1 ? true : false,
    );
  }
}
