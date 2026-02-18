import 'dart:convert';

class AppInfoModel {
   String name ;
   String version;
   String image;

  AppInfoModel({
    required this.name,
    required this.version,
    required this.image,
  });
  factory AppInfoModel.fromJson(Map<String, dynamic> json) {
    return AppInfoModel(
      name: json['name'] ?? '',
      version: json['version'] ?? '',
      image: json['image'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'version': version,
      'image': image,
    };
  }
  factory AppInfoModel.fromMap(Map<String, dynamic> map) {
    return AppInfoModel(
      name: map['name'] as String,
      version: map['version'] as String,
      image: map['image'] as String,
    );
  }
  String toJson() => json.encode(toMap());
  static AppInfoModel fromJsonString(String source) {
    return AppInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);
  }
}
