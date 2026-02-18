import 'user_model.dart';

class UsedTestAccount {
  String id;
  String testAccountId;
  String accountId;
  String? createdAt;
  User? user;

  UsedTestAccount({
    required this.id,
    required this.testAccountId,
    required this.accountId,
    this.createdAt,
    this.user,
  });

  factory UsedTestAccount.fromJson(Map<String, dynamic> json) {
    return UsedTestAccount(
      id: json['id'].toString(),
      testAccountId: json['test_account_id'].toString(),
      accountId: json['account_id'].toString(),
      createdAt: json['created_at']?.toString(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
