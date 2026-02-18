class PaymentSettingModel {
   String key;
   String value;
   String description;
   bool status;
  PaymentSettingModel({
    required this.key,
    required this.value,
    required this.description,
    required this.status,
  });

  factory PaymentSettingModel.fromJson(Map<String, dynamic> json) {
    return PaymentSettingModel(
      key: json['key'],
      value: json['value'],
      description: json['description'],
      status: json['status'] == "true" || json['status'] == 1 ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'description': description,
      'status': status,
    };
  }

  static List<PaymentSettingModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PaymentSettingModel.fromJson(json)).toList();
  }
  // from map
  static PaymentSettingModel fromMap(Map<String, dynamic> map) {
    return PaymentSettingModel(
      key: map['key'],
      value: map['value'],
      description: map['description'],
      status: map['status'] == "true" || map['status'] == 1 ? true : false,
    );
  }
  // to map 
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      'description': description,
      'status': status,
    };
  }
}