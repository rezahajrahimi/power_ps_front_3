class ReferralWalletModel {
  int id;
  int referralUserId;
  int amount;

  ReferralWalletModel({
    required this.id,
    required this.referralUserId,
    required this.amount,
  });

  factory ReferralWalletModel.fromJson(Map<String, dynamic> json) {
    return ReferralWalletModel(
      id: json['id'],
      referralUserId: json['referral_user_id'],
      amount: json['amount'],
    );
  }
  factory ReferralWalletModel.fromMap(Map<String, dynamic> map) {
    return ReferralWalletModel(
      id: map['id'],
      referralUserId: map['referral_user_id'] ?? 0,
      amount: map['amount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'referral_user_id': referralUserId,
      'amount': amount,
    };
  }

  @override
  String toString() {
    return 'ReferralWalletModel{id: $id, referralUserId: $referralUserId, amount: $amount}';
  }

  ReferralWalletModel copyWith({
    int? id,
    int? referralUserId,
    int? amount,
  }) {
    return ReferralWalletModel(
      id: id ?? this.id,
      referralUserId: referralUserId ?? this.referralUserId,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referral_user_id': referralUserId,
      'amount': amount,
    };
  }
}
