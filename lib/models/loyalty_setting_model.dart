import 'dart:convert';

class LoyaltySettingModel {
  int id;
  String description;
  bool isActive;
  bool earnOnPurchase;
  bool earnOnRenewal;
  bool earnOnDeposit;
  bool earnOnReferral;
  bool redeemEnabled;
  int purchasePointsPer1000Toman;
  int renewalPoints;
  int depositPointsPer1000Toman;
  int referralSignupPoints;
  int tomanPerPoint;
  int minRedeemPoints;
  int maxRedeemPercent;

  LoyaltySettingModel({
    required this.id,
    required this.description,
    required this.isActive,
    required this.earnOnPurchase,
    required this.earnOnRenewal,
    required this.earnOnDeposit,
    required this.earnOnReferral,
    required this.redeemEnabled,
    required this.purchasePointsPer1000Toman,
    required this.renewalPoints,
    required this.depositPointsPer1000Toman,
    required this.referralSignupPoints,
    required this.tomanPerPoint,
    required this.minRedeemPoints,
    required this.maxRedeemPercent,
  });

  factory LoyaltySettingModel.fromMap(Map<String, dynamic> map) {
    return LoyaltySettingModel(
      id: map['id'] ?? 0,
      description: map['description']?.toString() ?? '',
      isActive: map['is_active'] == true || map['is_active'] == 1,
      earnOnPurchase:
          map['earn_on_purchase'] != false && map['earn_on_purchase'] != 0,
      earnOnRenewal:
          map['earn_on_renewal'] != false && map['earn_on_renewal'] != 0,
      earnOnDeposit:
          map['earn_on_deposit'] != false && map['earn_on_deposit'] != 0,
      earnOnReferral:
          map['earn_on_referral'] != false && map['earn_on_referral'] != 0,
      redeemEnabled:
          map['redeem_enabled'] != false && map['redeem_enabled'] != 0,
      purchasePointsPer1000Toman:
          int.tryParse(map['purchase_points_per_1000_toman']?.toString() ?? '') ??
              10,
      renewalPoints:
          int.tryParse(map['renewal_points']?.toString() ?? '') ?? 50,
      depositPointsPer1000Toman:
          int.tryParse(map['deposit_points_per_1000_toman']?.toString() ?? '') ??
              5,
      referralSignupPoints:
          int.tryParse(map['referral_signup_points']?.toString() ?? '') ?? 100,
      tomanPerPoint:
          int.tryParse(map['toman_per_point']?.toString() ?? '') ?? 10,
      minRedeemPoints:
          int.tryParse(map['min_redeem_points']?.toString() ?? '') ?? 100,
      maxRedeemPercent:
          int.tryParse(map['max_redeem_percent']?.toString() ?? '') ?? 50,
    );
  }

  Map<String, dynamic> toApiMap() {
    return {
      'description': description,
      'is_active': isActive,
      'earn_on_purchase': earnOnPurchase,
      'earn_on_renewal': earnOnRenewal,
      'earn_on_deposit': earnOnDeposit,
      'earn_on_referral': earnOnReferral,
      'redeem_enabled': redeemEnabled,
      'purchase_points_per_1000_toman': purchasePointsPer1000Toman,
      'renewal_points': renewalPoints,
      'deposit_points_per_1000_toman': depositPointsPer1000Toman,
      'referral_signup_points': referralSignupPoints,
      'toman_per_point': tomanPerPoint,
      'min_redeem_points': minRedeemPoints,
      'max_redeem_percent': maxRedeemPercent,
    };
  }

  String toJson() => json.encode(toApiMap());
}
