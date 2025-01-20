import 'dart:convert';

class AdvancedSettingModel {
  bool botShowConfigsByPanelsCategory;
  bool botAutoSetPriceByDollarPrice;
  bool botShowWebAppLinkInTelegramForAllUsers;
  bool botCalculateProductCategoryPriceInDollarByToman;
  bool botShowOneRowConfig;
  AdvancedSettingModel({
    required this.botShowConfigsByPanelsCategory,
    required this.botAutoSetPriceByDollarPrice,
    required this.botShowWebAppLinkInTelegramForAllUsers,
    required this.botCalculateProductCategoryPriceInDollarByToman,
    required this.botShowOneRowConfig,
  });

  Map<String, dynamic> toMap() {
    return {
      'botShowConfigsByPanelsCategory': botShowConfigsByPanelsCategory,
      'botAutoSetPriceByDollarPrice': botAutoSetPriceByDollarPrice,
      'botShowWebAppLinkInTelegramForAllUsers':
          botShowWebAppLinkInTelegramForAllUsers,
      'botCalculateProductCategoryPriceInDollarByToman':
          botCalculateProductCategoryPriceInDollarByToman,
      'botShowOneRowConfig': botShowOneRowConfig
    };
  }

  factory AdvancedSettingModel.fromMap(Map<String, dynamic> map) {
    return AdvancedSettingModel(
      botShowConfigsByPanelsCategory:
          map['bot_show_configs_by_panels_category'] == true ||
                  map['bot_show_configs_by_panels_category'] == 1
              ? true
              : false,
      botAutoSetPriceByDollarPrice:
          map['bot_auto_set_price_by_dollar_price'] == true ||
                  map['bot_auto_set_price_by_dollar_price'] == 1
              ? true
              : false,
      botShowWebAppLinkInTelegramForAllUsers:
          map['bot_show_web_app_link_in_telegram_for_all_users'] == true ||
                  map['bot_show_web_app_link_in_telegram_for_all_users'] == 1
              ? true
              : false,
      botCalculateProductCategoryPriceInDollarByToman:
          map['bot_calculate_product_category_price_in_dollar_by_toman'] ==
                      true ||
                  map['bot_calculate_product_category_price_in_dollar_by_toman'] ==
                      1
              ? true
              : false,
      botShowOneRowConfig: map['bot_show_one_row_config'] == true ||
              map['bot_show_one_row_config'] == 1
          ? true
          : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AdvancedSettingModel.fromJson(String source) =>
      AdvancedSettingModel.fromMap(json.decode(source));
}
