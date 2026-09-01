class ChannelLock {
  String id;
  String channelId;
  bool isActive;
  ChannelLock({
    required this.id,
    required this.channelId,
    required this.isActive,
  });

  factory ChannelLock.fromJson(Map<String, dynamic> json) {
    return ChannelLock(
      id: json['id'].toString(),
      channelId: json['channel_id'].toString(),
      isActive: json['is_active'].toString() == "0" ? false : true,
    );
  }
}
