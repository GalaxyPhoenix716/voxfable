import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
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
        buddyState: BuddyState.reading,
      );

      _cancelSubscriptions();

      List<WordTimestamp> wordTimestamps = [];

      _audioPlayerSubscription = player.onPlayerStateChanged.listen((
        playerState,
      ) {
        if (playerState == PlayerState.completed) {
          onAudioFinished();
        }
      });

      _durationSubscription = player.onDurationChanged.listen((duration) {
        _totalDuration = duration;
        if (duration.inMilliseconds > 0) {
          wordTimestamps = _calculateWordTimestamps(story, duration);
        }
      });

      _positionSubscription = player.onPositionChanged.listen((position) {
        final totalDur = _totalDuration;
        if (wordTimestamps.isEmpty &&
            totalDur != null &&
            totalDur.inMilliseconds > 0) {
          wordTimestamps = _calculateWordTimestamps(story, totalDur);
        }

        if (wordTimestamps.isNotEmpty) {
          int activeIndex = -1;
          for (final wt in wordTimestamps) {
            if (position >= wt.start && position < wt.end) {
              activeIndex = wt.index;
              break;
            }
          }
          if (activeIndex != -1 && activeIndex != state.activeWordIndex) {
            state = state.copyWith(activeWordIndex: activeIndex);
          }
        }
      });

      if (Platform.isWindows) {
        final fileUri = 'file:///${audioFile.path.replaceAll('\\', '/')}';
        await player.play(UrlSource(fileUri));
      } else {
        await player.play(DeviceFileSource(audioFile.path));
      }
    } catch (e) {
      debugPrint("Error during story playback: $e");
      _cancelSubscriptions();
      state = state.copyWith(
        audioState: AudioState.error,
        buddyState: BuddyState.idle,
        errorMessage: "Couldn't fetch voice",
        activeWordIndex: -1,
      );
    }
  }

  void onAudioFinished() {
    _cancelSubscriptions();
    state = state.copyWith(
      audioState: AudioState.completed,
      buddyState: BuddyState.idle,
      activeWordIndex: -1,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (state.audioState == AudioState.completed) {
        state = state.copyWith(showQuiz: true, buddyState: BuddyState.idle);
      }
    });
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
        buddyState: BuddyState.sad,
      );
      
      // Play a custom double-vibrate pattern for incorrect answers
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 250), () {
        HapticFeedback.vibrate();
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        state = state.copyWith(
          quizAnswerStatus: QuizAnswerStatus.idle,
          buddyState: BuddyState.idle,
        );
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

  List<WordTimestamp> _calculateWordTimestamps(
    String text,
    Duration actualDuration,
  ) {
    final words = text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final List<double> relativeDurations = [];

    const double charWeight = 42; //base ms per character
    const double commaPause = 400; //pause for commas and semicolons
    const double sentencePause = 800; //pause for periods and exclamation marks
    const double wordGap = 80; //basic space between spoken words

    for (final word in words) {
      double duration = word.length * charWeight;

      if (word.endsWith(',') || word.endsWith(';') || word.endsWith(':')) {
        duration += commaPause;
      } else if (word.endsWith('.') ||
          word.endsWith('!') ||
          word.endsWith('?')) {
        duration += sentencePause;
      }
      duration += wordGap;
      relativeDurations.add(duration);
    }

    final double totalRelative = relativeDurations.fold(0, (sum, d) => sum + d);
    if (totalRelative == 0) return [];

    final double scale = actualDuration.inMilliseconds / totalRelative;
    final List<WordTimestamp> timestamps = [];
    double currentMs = 0;

    for (int i = 0; i < words.length; i++) {
      final double durationMs = relativeDurations[i] * scale;
      timestamps.add(
        WordTimestamp(
          index: i,
          start: Duration(milliseconds: currentMs.round()),
          end: Duration(milliseconds: (currentMs + durationMs).round()),
        ),
      );
      currentMs += durationMs;
    }

    return timestamps;
  }
}

class WordTimestamp {
  final int index;
  final Duration start;
  final Duration end;

  WordTimestamp({required this.index, required this.start, required this.end});
}
