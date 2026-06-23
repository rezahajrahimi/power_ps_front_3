import 'dart:convert';

import 'package:powerps/models/ballance_model.dart';
import 'package:powerps/models/blocked_user_model.dart';
import 'package:powerps/models/log_model.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/models/referral_wallet_model.dart';
import 'package:powerps/models/transaction_model.dart';
import 'package:powerps/models/user_model.dart';

class BotUser {
  BigInt id;
  BigInt accountId;
  String? username;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? adminAlias;
  String createdAt;
  String updatedAt;
  List<Log>? logs = [];
  List<ProductDetails>? products = [];
  List<Transaction>? transactions = [];
  Ballance? ballance;
  ReferralWalletModel? referralWallet;
  BlockedUserModel? blockedUser;
  User? panelUser;
  BotUser(
      {required this.id,
      required this.accountId,
      required this.username,
      required this.firstName,
      required this.lastName,
      this.phoneNumber,
      this.adminAlias,
      required this.createdAt,
      required this.updatedAt,
      this.logs,
      this.ballance,
      this.referralWallet,
      this.transactions,
      this.products,
      this.blockedUser,
      this.panelUser});
  // List<Log> itemsList = List<Log>.from(json['logs'].map<Log>((dynamic i) => Log.fromJson(i)));

  factory BotUser.fromJson(Map<dynamic, dynamic> json) {
    final accountId = json['account_id'] ?? json['id'] ?? 0;

    return BotUser(
      id: BigInt.from(json['id'] ?? accountId),
      accountId: BigInt.from(accountId),
      username: json['username'] != null ? json['username'].toString() : "",
      firstName:
          json['first_name'] != null ? json['first_name'].toString() : "",
      lastName: json['last_name'] != null ? json['last_name'].toString() : "",
      phoneNumber: json['phone_number']?.toString().trim().isEmpty == true
          ? null
          : json['phone_number']?.toString(),
      adminAlias: json['admin_alias']?.toString().trim().isEmpty == true
          ? null
          : json['admin_alias']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      ballance:
          json['ballance'] != null ? Ballance.fromJson(json['ballance']) : null,
      referralWallet:
          json['user'] != null && json['user']['referral_wallet'] != null
              ? ReferralWalletModel.fromJson(json['user']['referral_wallet'])
              : null,
      logs: json['logs'] != null
          ? List<Log>.from(
              json['logs'].map<Log>((dynamic i) => Log.fromJson(i)))
          : null, // try use map
      products: json['products'] != null
          ? List<ProductDetails>.from(json['products']
              .map<ProductDetails>((dynamic i) => ProductDetails.fromJson(i)))
          : null,
      transactions: json['transaction'] != null
          ? List<Transaction>.from(json['transaction']
              .map<Transaction>((dynamic i) => Transaction.fromJson(i)))
          : null,
      blockedUser: json['blocked_user'] != null
          ? BlockedUserModel.fromJson(json['blocked_user'])
          : null,
      panelUser: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'adminAlias': adminAlias,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'ballance': ballance?.toMap(),
      'referralWallet': referralWallet?.toMap(),
      'blockedUser': blockedUser?.toMap(),
    };
  }

  factory BotUser.fromMap(Map<String, dynamic> map) {
    return BotUser(
      id: BigInt.from(map['id']),
      accountId: BigInt.from(map['accountId']),
      username: map['username'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      adminAlias: map['adminAlias'],
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      ballance: map['ballance'] != null
          ? Ballance.fromMap(map['ballance'])
          : null,
      referralWallet: map['referralWallet'] != null
          ? ReferralWalletModel.fromMap(map['referralWallet'])
          : null,
      blockedUser: map['blockedUser'] != null
          ? BlockedUserModel.fromJson(map['blocked_user'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());
}

typedef MyCallback = void Function(String text);
