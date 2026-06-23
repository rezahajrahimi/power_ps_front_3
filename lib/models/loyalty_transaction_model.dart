class LoyaltyTransactionModel {
  final int id;
  final int userId;
  final String type;
  final String? event;
  final int points;
  final String? description;
  final String createdAt;
  final String? userName;
  final int? accountId;

  LoyaltyTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    this.event,
    required this.points,
    this.description,
    required this.createdAt,
    this.userName,
    this.accountId,
  });

  factory LoyaltyTransactionModel.fromMap(Map<String, dynamic> map) {
    final user = map['user'];
    return LoyaltyTransactionModel(
      id: map['id'] ?? 0,
      userId: map['user_id'] ?? 0,
      type: map['type']?.toString() ?? '',
      event: map['event']?.toString(),
      points: int.tryParse(map['points']?.toString() ?? '') ?? 0,
      description: map['description']?.toString(),
      createdAt: map['created_at']?.toString() ?? '',
      userName: user is Map
          ? (user['name']?.toString() ?? user['username']?.toString())
          : null,
      accountId: user is Map
          ? int.tryParse(user['account_id']?.toString() ?? '')
          : null,
    );
  }

  String get eventLabel {
    switch (event) {
      case 'purchase':
        return 'خرید';
      case 'renewal':
        return 'تمدید';
      case 'deposit':
        return 'واریز';
      case 'referral_signup':
        return 'معرفی';
      case 'checkout':
        return 'استفاده در خرید';
      case 'admin':
        return 'تغییر مدیر';
      default:
        return event ?? 'امتیاز';
    }
  }

  bool get isEarn => points > 0;
}
