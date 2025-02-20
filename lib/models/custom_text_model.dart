// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CustomTextModel {
  BigInt id;
  String defaultText;
  String key;
  String customText;

  CustomTextModel({
    required this.id,
    required this.defaultText,
    required this.key,
    required this.customText,
  });

  factory CustomTextModel.fromJson(Map<String, dynamic> json) {
    return CustomTextModel(
      id: BigInt.parse(json['id'].toString()),
      defaultText: json['default_text'],
      key: json['key'],
      customText: json['custom_text'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id.toString(),
      'default_text': defaultText,
      'key': key,
      'custom_text': customText,
    };
  }

  factory CustomTextModel.fromMap(Map<String, dynamic> map) {
    return CustomTextModel(
      id: BigInt.parse(map['id'].toString()),
      defaultText: map['default_text'] as String,
      key: map['key'] as String,
      customText: map['custom_text'] as String,
    );
  }

  String toJson() => json.encode(toMap());
}
