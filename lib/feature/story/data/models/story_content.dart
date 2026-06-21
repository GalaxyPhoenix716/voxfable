import 'package:voxfable/feature/story/data/models/quiz_question.dart';

class StoryContent {
  final String storyText;
  final List<QuizQuestion> quizQuestions;

  StoryContent({required this.storyText, required this.quizQuestions});

  factory StoryContent.fromJson(Map<String, dynamic> json) {
    final questionsList = json['quiz_questions'] as List;
    return StoryContent(
      storyText: json['story_text'] as String,
      quizQuestions: questionsList
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}
