class BlockedUserModel {
  final String accountId;
  final String reason;  

  BlockedUserModel({
    required this.accountId,
    required this.reason,
  });

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) {
    return BlockedUserModel(
      accountId: json['account_id'],
      reason: json['reason'],
    );
  }
  fromMap(Map<String, dynamic> map) {
    return BlockedUserModel(
      accountId: map['account_id'],
      reason: map['reason'],
    );
  }
  toMap() {
    return {
      'accountId': accountId,
      'reason': reason,
    };
  } 

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'reason': reason,
    };
  }

  @override
  String toString() {
    return 'BlockedUserModel(accountId: $accountId, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is BlockedUserModel &&
        other.accountId == accountId &&
        other.reason == reason;
  }

  @override
  int get hashCode => accountId.hashCode ^ reason.hashCode;

}