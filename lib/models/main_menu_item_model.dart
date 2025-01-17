class MainMenuItem {
  String id;
  String name;
  String aliasName;
  bool isActive;
  int position;
  MainMenuItem({
    required this.id,
    required this.name,
    required this.aliasName,
    required this.isActive,
    required this.position,
  });

  factory MainMenuItem.fromJson(Map<String, dynamic> json) {
    return MainMenuItem(
      id: json['id'].toString(),
      name: json['name'].toString(),
      aliasName: json['alias_name'].toString(),
      isActive: json['is_active'].toString() == "0" ? false : true,
      position: int.parse(json['position'].toString()),
    );
  }
}
