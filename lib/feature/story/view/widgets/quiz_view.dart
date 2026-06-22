import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Widget build(BuildContext context) {
    final state = ref.watch(storyViewModelProvider);
    final notifier = ref.read(storyViewModelProvider.notifier);

    // Listen for state changes to reset selected option
    ref.listen<StoryState>(storyViewModelProvider, (previous, next) {
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

    // Detect victory: on the last question, after answering correctly and returning to idle status
    final isVictory = question != null &&
        currentIdx == totalQuestions - 1 &&
        state.buddyState == BuddyState.happy &&
        state.quizAnswerStatus == QuizAnswerStatus.idle &&
        _selectedOption == null;

    final progress = totalQuestions > 0 ? (currentIdx + 1) / totalQuestions : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Circular Back Arrow
              GestureDetector(
                onTap: () => notifier.reset(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF36165E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              // Question Indicator
              if (!isVictory)
                Text(
                  "Question ${currentIdx + 1} of $totalQuestions",
                  style: _getPoppinsStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              // Score Tracker
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6F2BC2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFB39DDB), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "${state.quizAnswerStatus == QuizAnswerStatus.correct ? currentIdx + 1 : currentIdx}",
                      style: _getPoppinsStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          if (!isVictory) ...[
            Container(
              width: double.infinity,
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
            const SizedBox(height: 24),
          ],

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: isVictory
                  ? _buildVictoryScreen(notifier)
                  : _buildQuizContent(question, state, notifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(
    dynamic question,
    StoryState state,
    StoryViewModel notifier,
  ) {
    if (question == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Question Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5), // Solid light lavender card
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF673AB7), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Text(
            question.question,
            textAlign: TextAlign.center,
            style: _getPoppinsStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF36165E), // Deep Violet
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Animated Mascot
        PebloMascot(state: state.buddyState),
        const SizedBox(height: 24),

        // Options List
        Column(
          children: List.generate(question.options.length, (index) {
            final optionText = question.options[index];
            final optionLetter = String.fromCharCode(65 + index); // A, B, C, D

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: OptionCard(
                optionLetter: optionLetter,
                optionText: optionText,
                isSelected: _selectedOption == optionText,
                isCorrectAnswer: optionText == question.answer,
                quizAnswerStatus: state.quizAnswerStatus,
                hasSelectedAny: _selectedOption != null,
                onTap: () {
                  setState(() {
                    _selectedOption = optionText;
                  });
                  notifier.submitAnswer(optionText);
                },
              ),
            );
          }),
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
              )
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.stars_rounded,
              color: Colors.amber,
              size: 100,
            ),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
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
  final String optionLetter;
  final String optionText;
  final bool isSelected;
  final bool isCorrectAnswer;
  final QuizAnswerStatus quizAnswerStatus;
  final bool hasSelectedAny;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.optionLetter,
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
    // Determine card state coloring
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFB39DDB);
    Color textColor = const Color(0xFF36165E);
    Widget icon = Text(
      widget.optionLetter,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 16,
      ),
    );
    Color badgeColor = const Color(0xFF36165E);
    double opacity = 1.0;

    final hasFeedback = widget.quizAnswerStatus != QuizAnswerStatus.idle;

    if (hasFeedback) {
      if (widget.isCorrectAnswer) {
        // Highlight correct answer in green
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF4CAF50);
        textColor = const Color(0xFF1B5E20);
        badgeColor = const Color(0xFF4CAF50);
        icon = const Icon(Icons.check_rounded, color: Colors.white, size: 18);
      } else if (widget.isSelected) {
        // Highlight selected wrong answer in red
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFF44336);
        textColor = const Color(0xFFB71C1C);
        badgeColor = const Color(0xFFF44336);
        icon = const Icon(Icons.close_rounded, color: Colors.white, size: 18);
      } else {
        // Fade out other cards
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
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                // Badge circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: icon),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
