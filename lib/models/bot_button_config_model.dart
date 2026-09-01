class BotButtonStyleRule {
  final String match;
  final String matchType;
  final String? style;
  final String? iconCustomEmojiId;

  BotButtonStyleRule({
    required this.match,
    required this.matchType,
    this.style,
    this.iconCustomEmojiId,
  });

  factory BotButtonStyleRule.fromJson(Map<String, dynamic> json) {
    return BotButtonStyleRule(
      match: json['match']?.toString() ?? '',
      matchType: json['match_type']?.toString() ?? 'action_prefix',
      style: json['style']?.toString(),
      iconCustomEmojiId: json['icon_custom_emoji_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'match': match,
      'match_type': matchType,
      if (style != null && style!.isNotEmpty) 'style': style,
      if (iconCustomEmojiId != null && iconCustomEmojiId!.isNotEmpty)
        'icon_custom_emoji_id': iconCustomEmojiId,
    };
  }
}

class BotButtonConfig {
  final int replyButtonsPerRow;
  final int inlineButtonsPerRow;
  final int packageButtonsPerRow;
  final bool replyKeyboardPersistent;
  final bool mainMenuFirstItemAlone;
  final List<BotButtonStyleRule> styleRules;
  final List<String> availableStyles;

  BotButtonConfig({
    required this.replyButtonsPerRow,
    required this.inlineButtonsPerRow,
    required this.packageButtonsPerRow,
    required this.replyKeyboardPersistent,
    required this.mainMenuFirstItemAlone,
    required this.styleRules,
    required this.availableStyles,
  });

  factory BotButtonConfig.fromJson(Map<String, dynamic> json) {
    final rules = (json['style_rules'] as List<dynamic>? ?? [])
        .map((e) => BotButtonStyleRule.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();

    return BotButtonConfig(
      replyButtonsPerRow:
          int.tryParse(json['reply_buttons_per_row']?.toString() ?? '') ?? 2,
      inlineButtonsPerRow:
          int.tryParse(json['inline_buttons_per_row']?.toString() ?? '') ?? 1,
      packageButtonsPerRow:
          int.tryParse(json['package_buttons_per_row']?.toString() ?? '') ?? 1,
      replyKeyboardPersistent:
          json['reply_keyboard_persistent'] == true ||
              json['reply_keyboard_persistent']?.toString() == 'true',
      mainMenuFirstItemAlone:
          json['main_menu_first_item_alone'] != false &&
              json['main_menu_first_item_alone']?.toString() != 'false',
      styleRules: rules,
      availableStyles: (json['available_styles'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> layoutPayload() {
    return {
      'reply_buttons_per_row': replyButtonsPerRow,
      'inline_buttons_per_row': inlineButtonsPerRow,
      'package_buttons_per_row': packageButtonsPerRow,
      'reply_keyboard_persistent': replyKeyboardPersistent,
      'main_menu_first_item_alone': mainMenuFirstItemAlone,
    };
  }
}
