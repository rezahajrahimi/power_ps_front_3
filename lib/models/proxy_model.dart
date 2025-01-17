import 'package:powerps/models/inbound_model.dart';

class Proxy {
  String id;
  String pannelId;
  String type;
  bool isActive;
  List<Inbound>? inbounds = [];
  Proxy({
    required this.id,
    required this.pannelId,
    required this.type,
    required this.isActive,
    required this.inbounds,
  });

  factory Proxy.fromJson(Map<String, dynamic> json) {
    return Proxy(
      id: json['id'].toString(),
      pannelId: json['pannel_id'].toString(),
      type: json['type'].toString(),
      isActive: json['is_active'].toString() == "1" ||
              json['is_active'].toString() == "true"
          ? true
          : false,
      inbounds: json['inbounds'] != null
          ? List<Inbound>.from(
              json['inbounds'].map<Inbound>((dynamic i) => Inbound.fromJson(i)))
          : null, // try use map
    );
  }
}
