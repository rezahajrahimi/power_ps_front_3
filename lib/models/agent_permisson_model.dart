import 'dart:convert';

class AgentPermisson {
  int userId;
  bool minusBallance;
  bool createProducts;
  bool deleteProducts;
  double trafficLimitationTB;
  int productLimitation;
  AgentPermisson(
      {required this.userId,
      required this.createProducts,
      required this.deleteProducts,
      required this.minusBallance,
      required this.trafficLimitationTB,
      required this.productLimitation});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'minusBallance': minusBallance,
      'createProducts': createProducts,
      'deleteProducts': deleteProducts,
      'trafficLimitationTB': trafficLimitationTB,
      'productLimitation': productLimitation
    };
  }

  factory AgentPermisson.fromMap(Map<String, dynamic> map) {
    return AgentPermisson(
      userId: map['user_id']?.toInt() ?? 0,
      minusBallance: _parseBool(map['minus_ballance']),
      createProducts: _parseBool(map['create_products']),
      deleteProducts: _parseBool(map['delete_products']),
      trafficLimitationTB:
          double.tryParse(map['traffic_limitation_tb']?.toString() ?? '0') ??
              0.0,
      productLimitation: map['product_limitation']?.toInt() ?? 0,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    return value.toString() != '0' && value.toString().toLowerCase() != 'false';
  }

  String toJson() => json.encode(toMap());

  factory AgentPermisson.fromJson(String source) =>
      AgentPermisson.fromMap(json.decode(source));
}
