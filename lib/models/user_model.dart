import 'dart:convert';

class User {
  int id;
  String name;
  int accountId;
  String role;
  User(
      {required this.id,
      required this.name,
      required this.accountId,
      required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        accountId: json['account_id'],
        role: json['role']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'accountId': accountId,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      accountId: map['accountId']?.toInt() ?? 0,
      role: map['role'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
}
