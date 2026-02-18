import 'dart:convert';

class TransactionSettingModel {
  bool dollarTransaction;
  TransactionSettingModel({
    required this.dollarTransaction,
  });
  factory TransactionSettingModel.fromJson(Map<String, dynamic> json) {
    return TransactionSettingModel(
      dollarTransaction:
          json['dollar_transaction'] == 1 || json['dollar_transaction'] == true
              ? true
              : false,
    );
  }
  TransactionSettingModel copyWith({
    bool? dollarTransaction,
  }) {
    return TransactionSettingModel(
      dollarTransaction: dollarTransaction ?? this.dollarTransaction,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dollarTransaction': dollarTransaction,
    };
  }

  factory TransactionSettingModel.fromMap(Map<String, dynamic> map) {
    return TransactionSettingModel(
      dollarTransaction:
          map['dollar_transaction'] == 1 || map['dollar_transaction'] == true
              ? true
              : false,
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'TransactionSettingModel(dollarTransaction: $dollarTransaction)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionSettingModel &&
        other.dollarTransaction == dollarTransaction;
  }

  @override
  int get hashCode => dollarTransaction.hashCode;
}
