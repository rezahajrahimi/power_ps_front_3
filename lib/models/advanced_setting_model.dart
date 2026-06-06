class AdvancedSettingModel {
  static const Map<String, String> defaultDescriptions = {
    'bot_show_configs_by_panels_category':
        'نمایش کانفیگ ها براساس موقیت جغرافیایی پنل',
    'bot_auto_set_price_by_dollar_price':
        'قیمت گذاری اتوماتیک بر اساس قیمت دلار',
    'bot_calculate_product_category_price_in_dollar_by_toman':
        'قیمت گذاری اتوماتیک بر اساس قیمت تومان',
    'bot_show_one_row_config': 'نمایش پیکربندی ها در یک ردیف',
    'bot_daily_backup': 'برای ایجاد بکاپ روزانه',
    'bot_auto_delete_expired_configs':
        'حذف کانفیگ هایی که 10 روز از انقضا آنها می گذرد',
  };

  static String displayDescription(String name, String? description) {
    if (description != null && description.isNotEmpty) {
      return description;
    }
    return defaultDescriptions[name] ?? name;
  }

  final String name;
  final String value;
  final String? description;

  AdvancedSettingModel({
    required this.name,
    required this.value,
    this.description,
  });

  factory AdvancedSettingModel.fromJson(Map<String, dynamic> json) {
    return AdvancedSettingModel(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'description': description,
    };
  }

  AdvancedSettingModel copyWith({
    String? name,
    String? value,
    String? description,
  }) {
    return AdvancedSettingModel(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
    );
  }

  factory AdvancedSettingModel.fromMap(Map<String, dynamic> map) {
    return AdvancedSettingModel(
      name: map['name'] ?? '',
      value: map['value'] ?? '',
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'description': description,
    };
  }
}
