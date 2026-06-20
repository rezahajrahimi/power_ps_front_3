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

  static bool parseStatus(dynamic value) {
    if (value == null) {
      return false;
    }
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  factory PaymentSettingModel.fromJson(Map<String, dynamic> json) {
    return PaymentSettingModel(
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: parseStatus(json['status']),
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
      key: map['key']?.toString() ?? '',
      value: map['value']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      status: parseStatus(map['status']),
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