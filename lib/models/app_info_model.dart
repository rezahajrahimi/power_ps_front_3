import 'dart:convert';

class AppInfoModel {
  String name;
  String version;
  String image;
  String? primaryColor;
  String? secondaryColor;
  String? backgroundColor;
  String? panelTitle;
  String? footerText;
  bool showPowerpsCredit;

  AppInfoModel({
    required this.name,
    required this.version,
    required this.image,
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.panelTitle,
    this.footerText,
    this.showPowerpsCredit = true,
  });

  factory AppInfoModel.fromJson(Map<String, dynamic> json) {
    return AppInfoModel(
      name: json['name'] ?? '',
      version: json['version'] ?? '',
      image: json['image'] ?? '',
      primaryColor: json['primary_color']?.toString(),
      secondaryColor: json['secondary_color']?.toString(),
      backgroundColor: json['background_color']?.toString(),
      panelTitle: json['panel_title']?.toString(),
      footerText: json['footer_text']?.toString(),
      showPowerpsCredit: json['show_powerps_credit'] != false,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'version': version,
      'image': image,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'background_color': backgroundColor,
      'panel_title': panelTitle,
      'footer_text': footerText,
      'show_powerps_credit': showPowerpsCredit,
    };
  }

  factory AppInfoModel.fromMap(Map<String, dynamic> map) {
    return AppInfoModel(
      name: map['name'] as String,
      version: map['version'] as String,
      image: map['image'] as String,
      primaryColor: map['primary_color']?.toString(),
      secondaryColor: map['secondary_color']?.toString(),
      backgroundColor: map['background_color']?.toString(),
      panelTitle: map['panel_title']?.toString(),
      footerText: map['footer_text']?.toString(),
      showPowerpsCredit: map['show_powerps_credit'] != false,
    );
  }

  String toJson() => json.encode(toMap());

  static AppInfoModel fromJsonString(String source) {
    return AppInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);
  }
}
