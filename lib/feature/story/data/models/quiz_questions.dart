class QuizQuestions {
  final String question;
  final List<String> options;
  final String answers;

  QuizQuestions({
    required this.question,
    required this.options,
    required this.answers,
  });

  factory QuizQuestions.fromJson(Map<String, dynamic> json) {
    return QuizQuestions(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answers: json['answers'] as String,
    );
  }
}
