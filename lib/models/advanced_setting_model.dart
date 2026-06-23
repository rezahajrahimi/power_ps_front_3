class AdvancedSettingModel {
  static const String packageButtonLayoutKey = 'bot_package_button_layout';

  static const Map<String, String> defaultDescriptions = {
    'bot_show_configs_by_panels_category':
        'نمایش کانفیگ ها براساس موقیت جغرافیایی پنل',
    'bot_auto_set_price_by_dollar_price':
        'قیمت گذاری اتوماتیک بر اساس قیمت دلار',
    'bot_calculate_product_category_price_in_dollar_by_toman':
        'قیمت گذاری اتوماتیک بر اساس قیمت تومان',
    'bot_show_one_row_config': 'نمایش پیکربندی ها در یک ردیف (قدیمی)',
    packageButtonLayoutKey: 'نحوه نمایش لیست بسته‌ها در ربات',
    'bot_require_mobile_verification':
        'الزام تایید موبایل قبل از خرید (ارسال شماره تماس در تلگرام)',
    'bot_mobile_verification_iran_only':
        'تایید موبایل فقط برای شماره‌های ایران (+98)',
    'bot_daily_backup': 'برای ایجاد بکاپ روزانه',
    'bot_auto_delete_expired_configs':
        'حذف کانفیگ هایی که 10 روز از انقضا آنها می گذرد',
  };

  static const Map<String, String> packageButtonLayoutOptions = {
    'full_button': 'دکمه کامل (نام + قیمت در یک دکمه)',
    'multi_column': 'جدولی (ستون جدا برای قیمت و نام)',
    'list_in_message': 'لیست در پیام + دکمه کوتاه (پیشنهادی)',
    'compact_button': 'دکمه فشرده (نام کوتاه + قیمت)',
  };

  static const Set<String> botButtonCustomizationKeys = {
    'bot_reply_buttons_per_row',
    'bot_inline_buttons_per_row',
    'bot_package_buttons_per_row',
    'bot_reply_keyboard_persistent',
    'bot_main_menu_first_item_alone',
    'bot_button_style_rules',
    packageButtonLayoutKey,
  };

  static bool isHiddenFromAdvancedSettings(String name) {
    return name == 'bot_show_one_row_config' ||
        botButtonCustomizationKeys.contains(name);
  }

  static bool isChoiceSetting(String name) {
    return name == packageButtonLayoutKey;
  }

  static String packageButtonLayoutLabel(String value) {
    return packageButtonLayoutOptions[value] ?? value;
  }

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
