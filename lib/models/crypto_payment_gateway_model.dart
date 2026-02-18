import 'dart:convert';

class CryptoPaymentGateway {
  int id;
  String name;
  String apiKey;
  String email;
  String password;
  bool isActive;
  bool isFeePaidByUser;
  CryptoPaymentGateway({
    required this.id,
    required this.name,
    required this.apiKey,
    required this.email,
    required this.password,
    required this.isActive,
    required this.isFeePaidByUser,
  });

  CryptoPaymentGateway copyWith({
    int? id,
    String? name,
    String? apiKey,
    String? email,
    String? password,
    bool? isActive,
    bool? isFeePaidByUser,
  }) {
    return CryptoPaymentGateway(
      id: id ?? this.id,
      name: name ?? this.name,
      apiKey: apiKey ?? this.apiKey,
      email: email ?? this.email,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      isFeePaidByUser: isFeePaidByUser ?? this.isFeePaidByUser,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'apiKey': apiKey,
      'email': email,
      'password': password,
      'isActive': isActive,
      'isFeePaidByUser': isFeePaidByUser,
    };
  }

  factory CryptoPaymentGateway.fromMap(Map<String, dynamic> map) {
    return CryptoPaymentGateway(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      apiKey: map['api_key'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      isActive: map['is_active'] == 1 ? true : false,
      isFeePaidByUser: map['is_fee_paid_by_user'] == 1 ? true : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory CryptoPaymentGateway.fromJson(String source) =>
      CryptoPaymentGateway.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CryptoPaymentGateway(id: $id, name: $name, apiKey: $apiKey, email: $email, password: $password, isActive: $isActive, isFeePaidByUser: $isFeePaidByUser)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CryptoPaymentGateway &&
        other.id == id &&
        other.name == name &&
        other.apiKey == apiKey &&
        other.email == email &&
        other.password == password &&
        other.isActive == isActive &&
        other.isFeePaidByUser == isFeePaidByUser;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        apiKey.hashCode ^
        email.hashCode ^
        password.hashCode ^
        isActive.hashCode ^
        isFeePaidByUser.hashCode;
  }
}
