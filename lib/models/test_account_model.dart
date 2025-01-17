class TestAccount {
  String id;
  String pannelId;
  String volume;
  String expireDay;
  TestAccount({
    required this.id,
    required this.pannelId,
    required this.volume,
    required this.expireDay,
  });

  factory TestAccount.fromJson(Map<String, dynamic> json) {
    return TestAccount(
      id: json['id'].toString(),
      pannelId: json['pannel_id'].toString(),
      volume: json['volume'].toString(),
      expireDay: json['expire_day'].toString(),
    );
  }
}
