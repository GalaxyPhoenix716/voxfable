import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:voxfable/feature/story/view/screens/victory_screen.dart';
import 'package:voxfable/feature/story/view/widgets/option_card.dart';
import 'package:voxfable/feature/story/view/widgets/quiz_bottom_progress.dart';
import 'package:voxfable/feature/story/view/widgets/quiz_mascot_header.dart';
import '../../data/models/story_state.dart';
import '../../view_model/story_view_model.dart';
import 'peblo_mascot.dart';

class QuizView extends ConsumerStatefulWidget {
  const QuizView({super.key});

  @override
  ConsumerState<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends ConsumerState<QuizView>
    with SingleTickerProviderStateMixin {
  String? _selectedOption;
  late final CardSwiperController _swiperController;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  TextStyle _getPoppinsStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  void initState() {
    super.initState();
    _swiperController = CardSwiperController();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 12.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 12.0, end: -12.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 12.0, end: -12.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -12.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storyViewModelProvider);
    final notifier = ref.read(storyViewModelProvider.notifier);

    // Sync swiper card swipe on next question
    ref.listen<StoryState>(storyViewModelProvider, (previous, next) {
      if (next.currentQuestionIndex > (previous?.currentQuestionIndex ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _swiperController.swipe(CardSwiperDirection.left);
        });
      }
      if (next.quizAnswerStatus == QuizAnswerStatus.wrong &&
          previous?.quizAnswerStatus != QuizAnswerStatus.wrong) {
        _shakeController.forward(from: 0.0);
      }
      if (next.currentQuestionIndex != previous?.currentQuestionIndex ||
          (next.quizAnswerStatus == QuizAnswerStatus.idle &&
              previous?.quizAnswerStatus != QuizAnswerStatus.idle)) {
        setState(() {
          _selectedOption = null;
        });
      }
    });

    final totalQuestions = state.storyContent?.quizQuestions.length ?? 0;
    final currentIdx = state.currentQuestionIndex;
    final question = state.currentQuestion;

    final isVictory =
        question != null &&
        currentIdx == totalQuestions - 1 &&
        state.buddyState == BuddyState.happy &&
        state.quizAnswerStatus == QuizAnswerStatus.idle &&
        _selectedOption == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => notifier.reset(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF36165E),
                    size: 20,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${state.score}",
                      style: _getPoppinsStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF36165E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Expanded(
            child: isVictory
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: VictoryScreen(notifier: notifier),
                  )
                : _buildSwiperContent(state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildSwiperContent(StoryState state, StoryViewModel notifier) {
    final questions = state.storyContent?.quizQuestions ?? [];
    if (questions.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        QuizMascotHeader(buddyState: state.buddyState),

        const Spacer(),

        SizedBox(
          height: 480,
          child: CardSwiper(
            key: ValueKey(state.showQuiz),
            controller: _swiperController,
            cardsCount: questions.length,
            isDisabled: true,
            numberOfCardsDisplayed: questions.length > 2 ? 3 : questions.length,
            padding: const EdgeInsets.only(bottom: 28, left: 4, right: 4),
            backCardOffset: const Offset(0, 18),
            scale: 0.92,
            cardBuilder: (context, index, percentX, percentY) {
              final question = questions[index];
              return _buildQuestionCard(
                question,
                state,
                notifier,
                index,
                questions.length,
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        QuizBottomProgress(
          currentQuestionIndex: state.currentQuestionIndex,
          totalQuestions: questions.length,
        ),
      ],
    );
  }

  Widget _buildQuestionCard(
    dynamic question,
    StoryState state,
    StoryViewModel notifier,
    int index,
    int totalQuestions,
  ) {
    final isActive = index == state.currentQuestionIndex;

    final cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isActive
              ? const Color(0xFF6F2BC2).withValues(alpha: 0.15)
              : const Color(0xFFE0B0FF),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isActive ? 0.08 : 0.04),
            blurRadius: isActive ? 12 : 6,
            offset: Offset(0, isActive ? 6 : 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFEDE7F6)
                  : const Color(0xFFD1C4E9).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Question ${index + 1} of $totalQuestions",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? const Color(0xFF6F2BC2)
                    : const Color(0xFF6F2BC2).withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            question.question,
            textAlign: TextAlign.center,
            style: _getPoppinsStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? const Color(0xFF36165E)
                  : const Color(0xFF36165E).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),

          if (isActive)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(question.options.length, (optIdx) {
                  final optionText = question.options[optIdx];
                  return OptionCard(
                    index: optIdx,
                    optionText: optionText,
                    isSelected: _selectedOption == optionText,
                    isCorrectAnswer: optionText == question.answer,
                    quizAnswerStatus: state.quizAnswerStatus,
                    hasSelectedAny: _selectedOption != null,
                    totalOptions: question.options.length,
                    onTap: () {
                      if (_selectedOption == null) {
                        setState(() {
                          _selectedOption = optionText;
                        });
                        notifier.submitAnswer(optionText);
                      }
                    },
                  );
                }),
              ),
            )
          else
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(question.options.length, (optIdx) {
                  final totalOpts = question.options.length;
                  final double verticalPadding = totalOpts <= 2
                      ? 22.0
                      : (totalOpts == 3 ? 16.0 : 10.0);
                  final double badgeSize = totalOpts <= 2
                      ? 44.0
                      : (totalOpts == 3 ? 36.0 : 30.0);

                  return Container(
                    height: badgeSize + (verticalPadding * 2),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFEDE7F6).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );

    if (isActive) {
      return AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: cardContent,
      );
    }

    return cardContent;
  }
}
