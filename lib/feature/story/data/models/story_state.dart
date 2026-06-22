// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:voxfable/feature/story/data/models/quiz_question.dart';
import 'package:voxfable/feature/story/data/models/story_content.dart';

enum AudioState { idle, loading, playing, completed, error }

enum QuizAnswerStatus { idle, wrong, correct }

enum BuddyState { idle, talking, thinking, happy, reading, sad }

class StoryState {
  final AudioState audioState;
  final QuizAnswerStatus quizAnswerStatus;
  final BuddyState buddyState;
  final StoryContent? storyContent;
  final int currentQuestionIndex;
  final File? cachedAudioFile;
  final String? errorMessage;
  final bool showQuiz;
  final int activeWordIndex;
  final int score;

  StoryState({
    required this.audioState,
    required this.quizAnswerStatus,
    required this.buddyState,
    this.storyContent,
    this.currentQuestionIndex = 0,
    this.cachedAudioFile,
    this.errorMessage,
    required this.showQuiz,
    this.activeWordIndex = -1,
    this.score = 100,
  });

  QuizQuestion? get currentQuestion {
    final list = storyContent?.quizQuestions;
    if (list == null || currentQuestionIndex > list.length) {
      return null;
    }

    return list[currentQuestionIndex];
  }

  StoryState copyWith({
    AudioState? audioState,
    QuizAnswerStatus? quizAnswerStatus,
    BuddyState? buddyState,
    StoryContent? storyContent,
    int? currentQuestionIndex,
    File? cachedAudioFile,
    String? errorMessage,
    bool? showQuiz,
    int? activeWordIndex,
    int? score,
  }) {
    return StoryState(
      audioState: audioState ?? this.audioState,
      quizAnswerStatus: quizAnswerStatus ?? this.quizAnswerStatus,
      buddyState: buddyState ?? this.buddyState,
      storyContent: storyContent ?? this.storyContent,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      cachedAudioFile: cachedAudioFile ?? this.cachedAudioFile,
      errorMessage: errorMessage ?? this.errorMessage,
      showQuiz: showQuiz ?? this.showQuiz,
      activeWordIndex: activeWordIndex ?? this.activeWordIndex,
      score: score ?? this.score,
    );
  }
}
