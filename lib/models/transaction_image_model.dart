class TransactionImage {
  String imgSrc;
  String? userText;
  TransactionImage({
    required this.imgSrc,
    this.userText,
  });

  factory TransactionImage.fromJson(Map<String, dynamic> json) {
    return TransactionImage(
      imgSrc: json['img_src'].toString(),
      userText: json['user_text'].toString(),
    );
  }
}
