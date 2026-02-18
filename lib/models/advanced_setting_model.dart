class AdvancedSettingModel {
  final String name;
  final String value;
  final String? description;

  AdvancedSettingModel({
    required this.name,
    required this.value,
    this.description,
  });

  factory AdvancedSettingModel.fromJson(Map<String, dynamic> json) {
    return AdvancedSettingModel(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'description': description,
    };
  }

  AdvancedSettingModel copyWith({
    String? name,
    String? value,
    String? description,
  }) {
    return AdvancedSettingModel(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
    );
  }

  factory AdvancedSettingModel.fromMap(Map<String, dynamic> map) {
    return AdvancedSettingModel(
      name: map['name'] ?? '',
      value: map['value'] ?? '',
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'description': description,
    };
  }
}
