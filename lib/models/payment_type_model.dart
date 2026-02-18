class PaymentType {
  String id;
  String name;
  String merchantId;
  bool isActive;
  String type;
  PaymentType({
    required this.id,
    required this.name,
    required this.merchantId,
    required this.isActive,
    required this.type,
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: json['id'].toString(),
      name: json['name'].toString(),
      merchantId: json['merchant_id'].toString(),
      isActive: json['is_active'].toString() == "0" ? false : true,
      type: json['type'].toString(),
    );
  }
}
