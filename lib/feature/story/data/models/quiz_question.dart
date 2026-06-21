class QuizQuestion {
  final String question;
  final List<String> options;
  final String answers;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.answers,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answers: json['answers'] as String,
    );
  }
}
