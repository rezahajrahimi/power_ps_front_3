class Application {
  int id;
  String? name, downloadLink, fileSrc, os, howToUse, youtubeLink, description;

  bool isActive;

  Application({
    required this.id,
    required this.name,
    required this.downloadLink,
    required this.fileSrc,
    required this.os,
    required this.howToUse,
    required this.youtubeLink,
    required this.description,
    required this.isActive,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: int.parse(json['id'].toString()),
      description: json['description'],
      name: json['name'],
      downloadLink: json['download_link'],
      fileSrc: json['file_src'],
      os: json['os'],
      howToUse: json['how_to_use'],
      youtubeLink: json['youtube_link'],
      isActive: json['is_active'].toString() == "0" ? false : true,
    );
  }
}
