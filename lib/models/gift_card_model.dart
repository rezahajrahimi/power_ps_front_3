class GiftCard {
  String id;
  String code;
  DateTime? startDate;
  DateTime? endDate;
  int discount;
  int countOfUse;
  int countOfUsePerUser;
  GiftCard({
    required this.id,
    required this.code,
    this.startDate,
    this.endDate,
    required this.discount,
    required this.countOfUse,
    required this.countOfUsePerUser,
  });

  factory GiftCard.fromJson(Map<String, dynamic> json) {
    return GiftCard(
      id: json['id'].toString(),
      code: json['code'].toString(),
      startDate: DateTime.tryParse(json['start_date']),
      endDate: DateTime.tryParse(json['end_date']),
      discount: int.parse(json['discount'].toString()),
      countOfUse: int.parse(json['count_of_use'].toString()),
      countOfUsePerUser: int.parse(json['count_of_use_per_user'].toString()),
    );
  }
}
