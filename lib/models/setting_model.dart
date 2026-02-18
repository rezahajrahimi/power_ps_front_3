class Setting {
  String id;
  String botName;
  String adminId;
  String botToken;
  String panelAddress;
  Setting({
    required this.id,
    required this.botName,
    required this.adminId,
    required this.botToken,
    required this.panelAddress,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['id'].toString(),
      botName: json['bot_name'].toString(),
      adminId: json['admin_id'].toString(),
      botToken: json['bot_token'].toString(),
      panelAddress: json['panel_address'].toString(),
    );
  }
}
