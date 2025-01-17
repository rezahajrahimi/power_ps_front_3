class Inbound {
  String id;
  String proxyId;
  String name;
  String data;
  bool isActive;
  Inbound({
    required this.id,
    required this.proxyId,
    required this.name,
    required this.data,
    required this.isActive,
  });

  factory Inbound.fromJson(Map<String, dynamic> json) {
    return Inbound(
      id: json['id'].toString(),
      proxyId: json['proxy_id'].toString(),
      name: json['name'].toString(),
      data: json['data'].toString(),
      isActive: json['is_active'].toString() == "1" ||
              json['is_active'].toString() == "true"
          ? true
          : false,
    );
  }
}
