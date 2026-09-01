import 'dart:convert';

class Ballance {
  BigInt id;
  BigInt accountId;
  BigInt ballance;
  double accountBallanceIndollar;
  String? createdAt;
  String? updatedAt;
  Ballance({
    required this.id,
    required this.accountId,
    required this.ballance,
    required this.accountBallanceIndollar,
    this.createdAt,
    this.updatedAt,
  });
  factory Ballance.fromJson(Map<dynamic, dynamic> json) {
    return Ballance(
      id: BigInt.from(json['id']),
      accountId: BigInt.from(json['account_id'] ?? 0),
      ballance: BigInt.from(json['ballance'] ?? 0),
      accountBallanceIndollar:
          double.parse(json['account_ballance_in_dollar'].toString()),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
    );
  }

  Ballance copyWith({
    BigInt? id,
    BigInt? accountId,
    BigInt? ballance,
    double? accountBallanceIndollar,
    String? createdAt,
    String? updatedAt,
  }) {
    return Ballance(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      ballance: ballance ?? this.ballance,
      accountBallanceIndollar:
          accountBallanceIndollar ?? this.accountBallanceIndollar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'ballance': ballance,
      'accountBallanceIndollar': accountBallanceIndollar,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Ballance.fromMap(Map<String, dynamic> map) {
    return Ballance(
      id: BigInt.parse(map['id']),
      accountId: BigInt.parse(map['accountId']),
      ballance: BigInt.parse(map['ballance']),
      accountBallanceIndollar:
          map['accountBallanceIndollar']?.toDouble() ?? 0.0,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Ballance(id: $id, accountId: $accountId, ballance: $ballance, accountBallanceIndollar: $accountBallanceIndollar, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Ballance &&
        other.id == id &&
        other.accountId == accountId &&
        other.ballance == ballance &&
        other.accountBallanceIndollar == accountBallanceIndollar &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        accountId.hashCode ^
        ballance.hashCode ^
        accountBallanceIndollar.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
