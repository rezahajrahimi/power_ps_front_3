class Setting {
  String id;
  String botName;
  String adminId;
  String botToken;
  String panelAddress;
  String configNamePrefix;
  String configNameFormat;
  bool useAdminAliasInConfigName;
  Setting({
    required this.id,
    required this.botName,
    required this.adminId,
    required this.botToken,
    required this.panelAddress,
    this.configNamePrefix = 'bot',
    this.configNameFormat = '{prefix}{account_label}',
    this.useAdminAliasInConfigName = true,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    final aliasFlag = json['use_admin_alias_in_config_name'];
    return Setting(
      id: json['id'].toString(),
      botName: json['bot_name'].toString(),
      adminId: json['admin_id'].toString(),
      botToken: json['bot_token'].toString(),
      panelAddress: json['panel_address'].toString(),
      configNamePrefix: json['config_name_prefix']?.toString().trim().isNotEmpty == true
          ? json['config_name_prefix'].toString()
          : 'bot',
      configNameFormat: json['config_name_format']?.toString().trim().isNotEmpty == true
          ? json['config_name_format'].toString()
          : '{prefix}{account_label}',
      useAdminAliasInConfigName: aliasFlag == true ||
          aliasFlag == 1 ||
          aliasFlag == '1' ||
          aliasFlag == null,
    );
  }

  String configNamePreview({bool? useAdminAlias}) {
    final useAlias = useAdminAlias ?? useAdminAliasInConfigName;
    final prefix = configNamePrefix.trim().isEmpty ? 'bot' : configNamePrefix.trim();
    final format = configNameFormat.trim().isEmpty
        ? '{prefix}{account_label}'
        : configNameFormat.trim();
    final accountLabel = useAlias ? 'ali-42' : '123456789-42';

    return format
        .replaceAll('{prefix}', prefix)
        .replaceAll('{account_id}', '123456789')
        .replaceAll('{account_label}', accountLabel)
        .replaceAll('{chat_id}', '123456789')
        .replaceAll('{product_id}', '42')
        .replaceAll('{random}', 'abcd');
  }
}
