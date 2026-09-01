class Faq {
  String id;
  String question;
  String answer;
  Faq({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'].toString(),
      question: json['question'].toString(),
      answer: json['answer'].toString(),
    );
  }
}
