class Pannel {
  String id;
  String type;
  String? username;
  String? password;
  String? token;
  String? location;
  String? urlPort;
  String? subPort;
  String? adminUrl;
  String? userLink;
  String? secretCode;
  String? domin;
  int? capacity;
  String? apiVersion;
  Pannel(
      {required this.id,
      required this.type,
      this.username,
      this.password,
      this.location,
      this.token,
      this.urlPort,
      this.subPort,
      this.adminUrl,
      this.userLink,
      this.secretCode,
      this.domin,
      this.capacity,
      this.apiVersion});

  factory Pannel.fromJson(Map<String, dynamic> json) {
    return Pannel(
        id: json['id'].toString(),
        type: json['type'].toString(),
        username: json['username'] ?? json['username'].toString(),
        password: json['password'] ?? json['password'].toString(),
        token: json['token'] ?? json['token'].toString(),
        location: json['location'] ?? json['location'].toString(),
        urlPort: json['url_port'] ?? json['url_port'].toString(),
        subPort: json['sub_port']?.toString(),
        adminUrl: json['admin_url'] ?? json['admin_url'].toString(),
        userLink: json['user_link'] ?? json['user_link'].toString(),
        secretCode: json['secret_code'] ?? json['secret_code'].toString(),
        domin: json['domin'] ?? json['domin'].toString(),
        capacity:
            json['capacity'] ?? int.tryParse(json['capacity'].toString()),
        apiVersion: json['api_version']?.toString());
  }
}
