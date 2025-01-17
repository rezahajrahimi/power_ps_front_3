class Support {
  String id;
  String question;
  String answer;
  String responseType;
  Support({
    required this.id,
    required this.question,
    required this.answer,
    required this.responseType,
  });

  factory Support.fromJson(Map<String, dynamic> json) {
    return Support(
      id: json['id'].toString(),
      question: json['question'].toString(),
      answer: json['answer'].toString(),
      responseType: json['response_type'].toString(),
    );
  }
}
