class Log {
  BigInt id;
  BigInt accountId;
  String? username;

  String? type;
  String? message;
  String? event;
  String? createdAt;
  String? updatedAt;
  Log({
    required this.id,
    required this.accountId,
    this.type,
    this.username,
    this.message,
    this.event,
    this.createdAt,
    this.updatedAt,
  });
  factory Log.fromJson(Map<dynamic, dynamic> json) {
    return Log(
      id: BigInt.from(json['id']),
      accountId: BigInt.from(json['account_id'] ?? 0),
      username: json['username'].toString(),
      type: json['type'].toString(),
      message: json['message'].toString(),
      event: json['event'].toString(),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
    );
  }
}
