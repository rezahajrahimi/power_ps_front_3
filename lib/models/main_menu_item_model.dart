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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alias_name': aliasName,
      'is_active': isActive ? 1 : 0,
      'position': position,
    };
  }
  MainMenuItem copyWith({
    String? id,
    String? name,
    String? aliasName,
    bool? isActive,
    int? position,
  }) {
    return MainMenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      aliasName: aliasName ?? this.aliasName,
      isActive: isActive ?? this.isActive,
      position: position ?? this.position,
    );
  }
  // convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'alias_name': aliasName,
      'is_active': isActive ? 1 : 0,
      'position': position,
    };
  }
}
