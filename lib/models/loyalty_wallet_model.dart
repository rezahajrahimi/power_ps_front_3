class LoyaltyWalletModel {
  int id;
  int userId;
  int balance;

  LoyaltyWalletModel({
    required this.id,
    required this.userId,
    required this.balance,
  });

  factory LoyaltyWalletModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyWalletModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      balance: int.tryParse(json['balance']?.toString() ?? '') ?? 0,
    );
  }

  LoyaltyWalletModel copyWith({int? id, int? userId, int? balance}) {
    return LoyaltyWalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
    );
  }
}
