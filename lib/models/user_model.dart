
import 'package:powerps/models/agent_limit_usage_model.dart';

class User {
  final int id;
  final int accountId;
  final String name;
  final String role;
  final int? userGroupId;
  final String? userGroupName;
  final bool isVerified;
  final int? agentProductsCount;
  final int? salesCount;
  final num? balanceToman;
  final double? balanceDollar;
  final int? botUserId;
  final String? adminAlias;
  final AgentLimitUsage? agentLimitUsage;

  User({
    required this.id,
    required this.accountId,
    required this.name,
    required this.role,
    this.userGroupId,
    this.userGroupName,
    this.isVerified = false,
    this.agentProductsCount,
    this.salesCount,
    this.balanceToman,
    this.balanceDollar,
    this.botUserId,
    this.adminAlias,
    this.agentLimitUsage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      accountId: _parseInt(json['account_id']),
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      userGroupId: json['user_group_id'] != null
          ? _parseInt(json['user_group_id'])
          : null,
      userGroupName: json['user_group']?['name']?.toString(),
      isVerified: json['is_verified'] == true ||
          json['is_verified'] == 1 ||
          json['is_verified'] == '1',
      agentProductsCount: json['agent_products_count'] != null
          ? _parseInt(json['agent_products_count'])
          : null,
      salesCount:
          json['sales_count'] != null ? _parseInt(json['sales_count']) : null,
      balanceToman: json['balance_toman'] != null
          ? num.tryParse(json['balance_toman'].toString())
          : null,
      balanceDollar: json['balance_dollar'] != null
          ? double.tryParse(json['balance_dollar'].toString())
          : null,
      botUserId: json['bot_user_id'] != null
          ? _parseInt(json['bot_user_id'])
          : null,
      adminAlias: json['admin_alias']?.toString().trim().isEmpty == true
          ? null
          : json['admin_alias']?.toString(),
      agentLimitUsage: json['agent_limit_usage'] != null
          ? AgentLimitUsage.fromMap(
              Map<String, dynamic>.from(json['agent_limit_usage']))
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '0') ?? 0;
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
    return User.fromJson(map);
  }

}
