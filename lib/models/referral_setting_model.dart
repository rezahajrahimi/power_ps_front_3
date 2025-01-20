import 'dart:convert';

class ReferralSettingModel {
  int id;
  String description;
  String visitCardText;
  double referralPercent;
  bool isActive;

  ReferralSettingModel({
    required this.id,
    required this.description,
    required this.visitCardText,
    required this.referralPercent,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'visitCardText': visitCardText,
      'referralPercent': referralPercent,
      'isActive': isActive,
    };
  }

  factory ReferralSettingModel.fromMap(Map<String, dynamic> map) {
    return ReferralSettingModel(
      id: map['id'],
      description: map['description'] ?? '',
      visitCardText: map['visit_card_text'] ?? '',
      referralPercent: double.parse(map['referral_percent'].toString()),
      isActive:
          map['is_active'] == true || map['is_active'] == 1 ? true : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReferralSettingModel.fromJson(String source) =>
      ReferralSettingModel.fromMap(json.decode(source));
}
