import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/story_content.dart';
import '../data/models/story_state.dart';
import '../../../core/network/elevenlabs_service.dart';

part 'story_view_model.g.dart';

@riverpod
ElevenLabsService elevenLabsService(Ref ref) {
  return ElevenLabsService();
}

@riverpod
AudioPlayer audioPlayer(Ref ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
}

@Riverpod(keepAlive: true)
class StoryViewModel extends _$StoryViewModel {
  StreamSubscription<PlayerState>? _audioPlayerSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  Duration? _totalDuration;

  @override
  StoryState build() {
    //initializing content
    ref.watch(audioPlayerProvider);

    Future.microtask(() => loadStoryContent());

    ref.onDispose(() {
      _cancelSubscriptions();
    });

    return StoryState(
      audioState: AudioState.idle,
      quizAnswerStatus: QuizAnswerStatus.idle,
      buddyState: BuddyState.idle,
      showQuiz: false,
      activeWordIndex: -1,
    );
  }

  void _cancelSubscriptions() {
    _audioPlayerSubscription?.cancel();
    _audioPlayerSubscription = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _durationSubscription?.cancel();
    _durationSubscription = null;
    _totalDuration = null;
  }

  //function to fetch story (mimics fetching from db)
  Future<void> loadStoryContent() async {
    try {
      final json = await rootBundle.loadString(
        'assets/data/story.json',
      ); //i am just mimicing the fetching function from db
      final Map<String, dynamic> decodedJson = jsonDecode(json);
      final content = StoryContent.fromJson(decodedJson);

      state = state.copyWith(storyContent: content);
    } catch (e) {
      state = state.copyWith(
        audioState: AudioState.error,
        errorMessage: "Couldn't fetch story content",
      );
    }
  }

  //funtion to read story
  Future<void> readStory() async {
    final story = state.storyContent?.storyText;
    if (story == null || state.audioState == AudioState.playing) {
      return;
    }

    state = state.copyWith(
      audioState: AudioState.loading,
      buddyState: BuddyState.thinking,
      errorMessage: null,
      activeWordIndex: -1,
    );

    try {
      final ttsService = ref.read(elevenLabsServiceProvider);
      final player = ref.read(audioPlayerProvider);

      final audioFile = await ttsService.fetchTTS(story);
      state = state.copyWith(cachedAudioFile: audioFile);

      state = state.copyWith(
        audioState: AudioState.playing,
        buddyState: BuddyState.talking,
      );

      _cancelSubscriptions();

      final words = story.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      final totalWords = words.length;

      _audioPlayerSubscription = player.onPlayerStateChanged.listen((playerState) {
        if (playerState == PlayerState.completed) {
          onAudioFinished();
        }
      });

      _durationSubscription = player.onDurationChanged.listen((duration) {
        _totalDuration = duration;
      });

      _positionSubscription = player.onPositionChanged.listen((position) {
        final totalDur = _totalDuration;
        if (totalDur != null && totalDur.inMilliseconds > 0 && totalWords > 0) {
          final progress = position.inMilliseconds / totalDur.inMilliseconds;
          final activeIndex = (totalWords * progress).floor().clamp(0, totalWords - 1);
          state = state.copyWith(activeWordIndex: activeIndex);
        }
      });

      await player.play(DeviceFileSource(audioFile.path));
    } catch (e) {
      _cancelSubscriptions();
      state = state.copyWith(
        audioState: AudioState.error,
        buddyState: BuddyState.idle,
        errorMessage: "Couldn't fetch voice",
        activeWordIndex: -1,
      );
    }
  }

  //just a helper for clean code
  void onAudioFinished() {
    _cancelSubscriptions();
    state = state.copyWith(
      audioState: AudioState.completed,
      buddyState: BuddyState.idle,
      showQuiz: true,
      activeWordIndex: -1,
    );
  }

  //verifying quiz answer
  void submitAnswer(String selectedOption) {
    final currQuestion = state.currentQuestion;
    if (currQuestion == null) {
      return;
    }

    if (selectedOption == currQuestion.answer) {
      //correct answer
      state = state.copyWith(
        quizAnswerStatus: QuizAnswerStatus.correct,
        buddyState: BuddyState.happy,
      );
      HapticFeedback.heavyImpact();

      Future.delayed(Duration(seconds: 2), () {
        //small delay (might be replaced by animation later)
        final totalQuestions = state.storyContent?.quizQuestions.length ?? 0;

        if (state.currentQuestionIndex + 1 < totalQuestions) {
          state = state.copyWith(
            currentQuestionIndex: state.currentQuestionIndex + 1,
            quizAnswerStatus: QuizAnswerStatus.idle,
            buddyState: BuddyState.idle,
          );
        } else {
          //all questions are over
          state = state.copyWith(buddyState: BuddyState.happy);
        }
      });
    } else {
      //wrong answer
      state = state.copyWith(
        quizAnswerStatus: QuizAnswerStatus.wrong,
        buddyState: BuddyState.thinking,
      );
      HapticFeedback.vibrate();

      Future.delayed(const Duration(milliseconds: 600), () {
        state = state.copyWith(quizAnswerStatus: QuizAnswerStatus.idle);
      });
    }
  }

  void reset() {
    ref.read(audioPlayerProvider).stop();
    _cancelSubscriptions();
    state = StoryState(
      audioState: AudioState.idle,
      quizAnswerStatus: QuizAnswerStatus.idle,
      buddyState: BuddyState.idle,
      currentQuestionIndex: 0,
      storyContent: state.storyContent,
      showQuiz: false,
      activeWordIndex: -1,
    );
  }
}
