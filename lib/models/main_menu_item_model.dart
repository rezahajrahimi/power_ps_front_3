class MainMenuItem {
  String id;
  String name;
  String aliasName;
  bool isActive;
  int position;
  String? buttonStyle;
  String? iconCustomEmojiId;
  bool soloRow;
  MainMenuItem({
    required this.id,
    required this.name,
    required this.aliasName,
    required this.isActive,
    required this.position,
    this.buttonStyle,
    this.iconCustomEmojiId,
    this.soloRow = false,
  });

  factory MainMenuItem.fromJson(Map<String, dynamic> json) {
    return MainMenuItem(
      id: json['id'].toString(),
      name: json['name'].toString(),
      aliasName: json['alias_name'].toString(),
      isActive: json['is_active'].toString() == "0" ? false : true,
      position: int.parse(json['position'].toString()),
      buttonStyle: json['button_style']?.toString(),
      iconCustomEmojiId: json['icon_custom_emoji_id']?.toString(),
      soloRow: json['solo_row'] == true ||
          json['solo_row']?.toString() == '1' ||
          json['solo_row']?.toString() == 'true',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alias_name': aliasName,
      'is_active': isActive ? 1 : 0,
      'position': position,
      'button_style': buttonStyle,
      'icon_custom_emoji_id': iconCustomEmojiId,
      'solo_row': soloRow,
    };
  }
  MainMenuItem copyWith({
    String? id,
    String? name,
    String? aliasName,
    bool? isActive,
    int? position,
    String? buttonStyle,
    String? iconCustomEmojiId,
    bool? soloRow,
  }) {
    return MainMenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      aliasName: aliasName ?? this.aliasName,
      isActive: isActive ?? this.isActive,
      position: position ?? this.position,
      buttonStyle: buttonStyle ?? this.buttonStyle,
      iconCustomEmojiId: iconCustomEmojiId ?? this.iconCustomEmojiId,
      soloRow: soloRow ?? this.soloRow,
    );
  }
  // convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'alias_name': aliasName,
      'is_active': isActive ? 1 : 0,
      'position': position,
    };
  }
}
