import 'package:powerps/models/payment_type_model.dart';
import 'package:powerps/models/transaction_image_model.dart';
import 'package:powerps/models/bot_user_model.dart';

class Transaction {
  BigInt id;
  BigInt? accountId;
  BigInt? amount;
  BigInt? paymentTypeId;
  bool confirmed;
  String? recipeNumber;
  String? username;

  String? createdAt;
  String? updatedAt;

  PaymentType? paymentType;
  BotUser? botUser;
  TransactionImage? image;

  Transaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.paymentTypeId,
    required this.username,
    required this.confirmed,
    required this.recipeNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.paymentType,
    required this.botUser,
    required this.image,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: BigInt.from(json['id']),
      accountId: BigInt.from(json['account_id']),
      amount: BigInt.from(json['amount']),
      paymentTypeId: BigInt.from(json['payment_type_id']),
      confirmed: json['confirmed'].toString() == "1" ? true : false,
      recipeNumber: json['recipe_number'].toString(),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      username: json['username'].toString(),
      paymentType: json['payment_types'] != null
          ? PaymentType.fromJson(json['payment_types'])
          : null,
      botUser: json['user'] != null ? BotUser.fromJson(json['user']) : null,
      image: json['transaction_image'] != null
          ? TransactionImage.fromJson(json['transaction_image'])
          : null,
    );
  }
}
