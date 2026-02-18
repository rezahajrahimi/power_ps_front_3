class SubMenuItem {
  String id;
  String name;
  String aliasName;
  int level;
  SubMenuItem({
    required this.id,
    required this.name,
    required this.aliasName,
    required this.level,
  });

  factory SubMenuItem.fromJson(Map<String, dynamic> json) {
    return SubMenuItem(
      id: json['id'].toString(),
      name: json['name'].toString(),
      aliasName: json['alias_name'].toString(),
      level: int.parse(json['level'].toString()),
    );
  }
}
