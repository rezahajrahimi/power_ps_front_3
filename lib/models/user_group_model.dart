bool _parseBool(dynamic value) {
  return value == true || value == 1 || value == '1';
}

class GlobalVerificationPaymentMethod {
  final bool isVerified;
  final String paymentKey;
  final bool isEnabled;

  GlobalVerificationPaymentMethod({
    required this.isVerified,
    required this.paymentKey,
    required this.isEnabled,
  });

  factory GlobalVerificationPaymentMethod.fromJson(Map<String, dynamic> json) {
    return GlobalVerificationPaymentMethod(
      isVerified: _parseBool(json['is_verified']),
      paymentKey: json['payment_key']?.toString() ?? '',
      isEnabled: _parseBool(json['is_enabled']),
    );
  }
}

class UserGroupVerificationPaymentMethod {
  final int id;
  final int userGroupId;
  final bool isVerified;
  final String paymentKey;
  final bool isEnabled;

  UserGroupVerificationPaymentMethod({
    required this.id,
    required this.userGroupId,
    required this.isVerified,
    required this.paymentKey,
    required this.isEnabled,
  });

  factory UserGroupVerificationPaymentMethod.fromJson(Map<String, dynamic> json) {
    return UserGroupVerificationPaymentMethod(
      id: json['id'] ?? 0,
      userGroupId: json['user_group_id'] ?? 0,
      isVerified: _parseBool(json['is_verified']),
      paymentKey: json['payment_key']?.toString() ?? '',
      isEnabled: _parseBool(json['is_enabled']),
    );
  }
}

class UserGroupPaymentMethod {
  final int id;
  final int userGroupId;
  final String paymentKey;
  final bool isEnabled;

  UserGroupPaymentMethod({
    required this.id,
    required this.userGroupId,
    required this.paymentKey,
    required this.isEnabled,
  });

  factory UserGroupPaymentMethod.fromJson(Map<String, dynamic> json) {
    return UserGroupPaymentMethod(
      id: json['id'] ?? 0,
      userGroupId: json['user_group_id'] ?? 0,
      paymentKey: json['payment_key']?.toString() ?? '',
      isEnabled: _parseBool(json['is_enabled']),
    );
  }
}

class UserGroup {
  final int id;
  final String name;
  final String roleType;
  final bool isDefault;
  final int usersCount;
  final int verifiedUsersCount;
  final int unverifiedUsersCount;
  final List<UserGroupPaymentMethod> paymentMethods;
  final List<UserGroupVerificationPaymentMethod> verificationPaymentMethods;

  UserGroup({
    required this.id,
    required this.name,
    required this.roleType,
    required this.isDefault,
    this.usersCount = 0,
    this.verifiedUsersCount = 0,
    this.unverifiedUsersCount = 0,
    this.paymentMethods = const [],
    this.verificationPaymentMethods = const [],
  });

  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      roleType: json['role_type']?.toString() ?? '',
      isDefault: _parseBool(json['is_default']),
      usersCount: json['users_count'] ?? 0,
      verifiedUsersCount: json['verified_users_count'] ?? 0,
      unverifiedUsersCount: json['unverified_users_count'] ?? 0,
      paymentMethods: json['payment_methods'] != null
          ? (json['payment_methods'] as List)
              .map((e) => UserGroupPaymentMethod.fromJson(e))
              .toList()
          : [],
      verificationPaymentMethods: json['verification_payment_methods'] != null
          ? (json['verification_payment_methods'] as List)
              .map((e) => UserGroupVerificationPaymentMethod.fromJson(e))
              .toList()
          : [],
    );
  }

  bool hasCustomVerificationPayments(bool isVerified) {
    return verificationPaymentMethods.any((m) => m.isVerified == isVerified);
  }

  bool isVerificationPaymentEnabled(
    bool isVerified,
    String paymentKey,
    bool fallback,
  ) {
    final custom = verificationPaymentMethods.where(
      (m) => m.isVerified == isVerified && m.paymentKey == paymentKey,
    );
    if (custom.isEmpty) return fallback;
    return custom.first.isEnabled;
  }
}
