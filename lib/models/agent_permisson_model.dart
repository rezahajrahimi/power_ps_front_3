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
      minusBallance: map['minus_ballance'].toString() == "0" ? false : true,
      createProducts: map['create_products'].toString() == "0" ? false : true,
      deleteProducts: map['delete_products'].toString() == "0" ? false : true,
      trafficLimitationTB: map['traffic_limitation_tb']?.toDouble() ?? 0.0,
      productLimitation: map['product_limitation']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory AgentPermisson.fromJson(String source) =>
      AgentPermisson.fromMap(json.decode(source));
}
