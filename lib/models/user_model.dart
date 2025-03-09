
class User {
  final int id;
  final int accountId;
  final String name;
  final String role;
  
  User({
    required this.id,
    required this.accountId,
    required this.name,
    required this.role,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      accountId: json['accountId'],
      name: json['name'],
      role: json['role'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'name': name,
      'role': role,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'account_id': accountId,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      accountId: map['account_id']?.toInt() ?? 0,
      role: map['role'] ?? '',
    );
  }

}
