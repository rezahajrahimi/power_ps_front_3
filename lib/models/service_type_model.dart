class ServiceType {
  BigInt id;
  String serviceName;
  ServiceType({
    // required this.id,
    required this.id,
    required this.serviceName,
  });

  factory ServiceType.fromJson(Map<dynamic, dynamic> json) {
    return ServiceType(
        id: BigInt.from(int.parse(json['id'].toString())),
        serviceName: json['service_name'].toString());
  }
}
