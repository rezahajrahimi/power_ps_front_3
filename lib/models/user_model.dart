
class User {
  final int id;
  final int accountId;
  final String name;
  final String role;
  final int? userGroupId;
  final String? userGroupName;
  final bool isVerified;

  User({
    required this.id,
    required this.accountId,
    required this.name,
    required this.role,
    this.userGroupId,
    this.userGroupName,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      accountId: json['account_id'],
      name: json['name'],
      role: json['role'],
      userGroupId: json['user_group_id'],
      userGroupName: json['user_group']?['name']?.toString(),
      isVerified: json['is_verified'] == true || json['is_verified'] == 1 || json['is_verified'] == '1',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'name': name,
      'role': role,
      'user_group_id': userGroupId,
      'is_verified': isVerified,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'account_id': accountId,
      'role': role,
      'user_group_id': userGroupId,
      'is_verified': isVerified,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      accountId: map['account_id']?.toInt() ?? 0,
      role: map['role'] ?? '',
      userGroupId: map['user_group_id']?.toInt(),
      userGroupName: map['user_group']?['name']?.toString(),
      isVerified: map['is_verified'] == true || map['is_verified'] == 1 || map['is_verified'] == '1',
    );
  }

}
