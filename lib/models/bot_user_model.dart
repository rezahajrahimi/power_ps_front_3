import 'dart:convert';

import 'package:powerps/models/ballance_model.dart';
import 'package:powerps/models/log_model.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/models/referral_wallet_model.dart';
import 'package:powerps/models/transaction_model.dart';

class BotUser {
  BigInt id;
  BigInt accountId;
  String? username;
  String? firstName;
  String? lastName;
  String createdAt;
  String updatedAt;
  List<Log>? logs = [];
  List<ProductDetails>? products = [];
  List<Transaction>? transactions = [];
  Ballance? ballance;
  ReferralWalletModel? referralWallet;
  BotUser(
      {required this.id,
      required this.accountId,
      required this.username,
      required this.firstName,
      required this.lastName,
      required this.createdAt,
      required this.updatedAt,
      this.logs,
      this.ballance,
      this.referralWallet,
      this.transactions,
      this.products});
  // List<Log> itemsList = List<Log>.from(json['logs'].map<Log>((dynamic i) => Log.fromJson(i)));

  factory BotUser.fromJson(Map<dynamic, dynamic> json) {
    return BotUser(
      id: BigInt.from(json['id']),
      accountId: BigInt.from(json['account_id'] ?? 0),
      username: json['username'] != null ? json['username'].toString() : "",
      firstName:
          json['first_name'] != null ? json['first_name'].toString() : "",
      lastName: json['last_name'] != null ? json['last_name'].toString() : "",
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory BotUser.fromMap(Map<String, dynamic> map) {
    return BotUser(
      id: BigInt.from(map['id']),
      accountId: BigInt.from(map['accountId']),
      username: map['username'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
}

typedef MyCallback = void Function(String text);
