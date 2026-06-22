import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../data/models/story_state.dart';
import '../../view_model/story_view_model.dart';
import 'peblo_mascot.dart';

class QuizView extends ConsumerStatefulWidget {
  const QuizView({super.key});

  @override
  ConsumerState<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends ConsumerState<QuizView> {
  String? _selectedOption;
  late final CardSwiperController _swiperController;

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
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storyViewModelProvider);
    final notifier = ref.read(storyViewModelProvider.notifier);

    // Sync swiper card swipe on next question
    ref.listen<StoryState>(storyViewModelProvider, (previous, next) {
      if (next.currentQuestionIndex > (previous?.currentQuestionIndex ?? 0)) {
        _swiperController.swipe(CardSwiperDirection.left);
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

    final isVictory = question != null &&
        currentIdx == totalQuestions - 1 &&
        state.buddyState == BuddyState.happy &&
        state.quizAnswerStatus == QuizAnswerStatus.idle &&
        _selectedOption == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Circular Back Arrow (White circle, dark icon)
              GestureDetector(
                onTap: () => notifier.reset(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
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
              // Score Indicator Pill (White background, star icon, score)
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
          const SizedBox(height: 16),

          Expanded(
            child: isVictory
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _buildVictoryScreen(notifier),
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
        // Mascot & Speech Bubble
        _buildMascotHeader(state),
        const SizedBox(height: 20),

        // Stacked Card Swiper
        Expanded(
          child: CardSwiper(
            key: ValueKey(state.storyContent.hashCode ^ (state.currentQuestionIndex == 0 ? 1 : 0)),
            controller: _swiperController,
            cardsCount: questions.length,
            isDisabled: true, // Disable user gestures
            numberOfCardsDisplayed: questions.length > 2 ? 3 : questions.length,
            backCardOffset: const Offset(0, 20),
            scale: 0.93,
            cardBuilder: (context, index, percentX, percentY) {
              final question = questions[index];
              return _buildQuestionCard(question, state, notifier, index, questions.length);
            },
          ),
        ),
        const SizedBox(height: 20),

        // Bottom Progress Indicator (Star ratio + progress bar, no buttons)
        _buildBottomProgress(state),
      ],
    );
  }

  Widget _buildMascotHeader(StoryState state) {
    return Column(
      children: [
        PebloMascot(state: state.buddyState),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: const [
              Expanded(
                child: Text(
                  "Now let's see how much you remember!",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF36165E),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.volume_up_rounded,
                color: Color(0xFF6f2bc2),
                size: 20,
              ),
            ],
          ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // "Question X of Y" Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Question ${index + 1} of $totalQuestions",
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F2BC2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Question Text
          Text(
            question.question,
            textAlign: TextAlign.center,
            style: _getPoppinsStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF36165E),
            ),
          ),
          const SizedBox(height: 20),

          // Options List
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: List.generate(question.options.length, (optIdx) {
                  final optionText = question.options[optIdx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: OptionCard(
                      index: optIdx,
                      optionText: optionText,
                      isSelected: isActive && _selectedOption == optionText,
                      isCorrectAnswer: optionText == question.answer,
                      quizAnswerStatus: isActive ? state.quizAnswerStatus : QuizAnswerStatus.idle,
                      hasSelectedAny: isActive && _selectedOption != null,
                      onTap: () {
                        if (isActive && _selectedOption == null) {
                          setState(() {
                            _selectedOption = optionText;
                          });
                          notifier.submitAnswer(optionText);
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomProgress(StoryState state) {
    final totalQuestions = state.storyContent?.quizQuestions.length ?? 0;
    final currentIdx = state.currentQuestionIndex;
    final progress = totalQuestions > 0 ? (currentIdx + 1) / totalQuestions : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 22,
            ),
            const SizedBox(width: 4),
            Text(
              "${currentIdx + 1}/$totalQuestions",
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1035),
            borderRadius: BorderRadius.circular(5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF9E47FF), // Bright purple
                    Color(0xFF00E5FF), // Cyan glow
                  ],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVictoryScreen(StoryViewModel notifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        // Big Glowing Trophy/Star Container
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF36165E),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.stars_rounded, color: Colors.amber, size: 100),
          ),
        ),
        const SizedBox(height: 32),
        // Mascot in happy state
        PebloMascot(state: BuddyState.happy),
        const SizedBox(height: 32),
        // Congratulatory Text Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "Super Reader!",
                style: _getPoppinsStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF36165E),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "You read the story and answered every single question correctly! Keep up the amazing work!",
                textAlign: TextAlign.center,
                style: _getPoppinsStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF36165E).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // Play Again Button
        GestureDetector(
          onTap: () => notifier.reset(),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFD54F), // Bright Amber
                  Color(0xFFFFB300), // Dark Amber
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF36165E).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "Play Again",
                style: _getPoppinsStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF36165E),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OptionCard extends StatefulWidget {
  final int index;
  final String optionText;
  final bool isSelected;
  final bool isCorrectAnswer;
  final QuizAnswerStatus quizAnswerStatus;
  final bool hasSelectedAny;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.index,
    required this.optionText,
    required this.isSelected,
    required this.isCorrectAnswer,
    required this.quizAnswerStatus,
    required this.hasSelectedAny,
    required this.onTap,
  });

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final emojis = ['🦊', '🐻', '🐢', '🐹'];
    final emoji = emojis[widget.index % emojis.length];

    final badgeColors = [
      const Color(0xFFFFE0B2), // Light Orange
      const Color(0xFFD7CCC8), // Light Brown
      const Color(0xFFC8E6C9), // Light Green
      const Color(0xFFF8BBD0), // Light Pink
    ];
    final badgeBgColor = badgeColors[widget.index % badgeColors.length];

    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFEDE7F6);
    Color textColor = const Color(0xFF36165E);
    Widget? rightIcon;
    double opacity = 1.0;

    final hasFeedback = widget.quizAnswerStatus != QuizAnswerStatus.idle;

    if (hasFeedback) {
      if (widget.isCorrectAnswer) {
        bgColor = const Color(0xFF6F2BC2);
        borderColor = const Color(0xFF6F2BC2);
        textColor = Colors.white;
        rightIcon = Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        );
      } else if (widget.isSelected) {
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFF44336);
        textColor = const Color(0xFFB71C1C);
        rightIcon = Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFF44336),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
        );
      } else {
        opacity = 0.45;
      }
    }

    final isClickable = !widget.hasSelectedAny;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTapDown: (_) {
          if (isClickable) {
            setState(() => _isPressed = true);
          }
        },
        onTapUp: (_) {
          if (isClickable) {
            setState(() => _isPressed = false);
            widget.onTap();
          }
        },
        onTapCancel: () {
          if (isClickable) {
            setState(() => _isPressed = false);
          }
        },
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 100),
          tween: Tween<double>(begin: 1.0, end: _isPressed ? 0.96 : 1.0),
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Badge circle with emoji
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Option Text
                Expanded(
                  child: Text(
                    widget.optionText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                if (rightIcon != null) ...[
                  const SizedBox(width: 10),
                  rightIcon,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
