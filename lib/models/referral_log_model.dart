import 'dart:convert';

import 'package:powerps/models/user_model.dart';

class ReferralLogModel {
  int id;
  int amount;
  String createdAt;
  String updatedAt;
  User? referralUser;
  User? referralToUser;

  ReferralLogModel({
    required this.id,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    this.referralUser,
    this.referralToUser,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'referral_user_id': referralUser?.toMap(),
      'referral_to_id': referralToUser?.toMap(),
    };
  }

  factory ReferralLogModel.fromMap(Map<String, dynamic> map) {
    return ReferralLogModel(
      id: map['id']?.toInt() ?? 0,
      amount: map['amount']?.toInt() ?? 0,
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      referralUser: map['referral_user'] != null
          ? User.fromMap(map['referral_user'])
          : null,
      referralToUser:
          map['referral_to'] != null ? User.fromMap(map['referral_to']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReferralLogModel.fromJson(String source) =>
      ReferralLogModel.fromMap(json.decode(source));
}
