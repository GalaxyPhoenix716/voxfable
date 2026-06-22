import 'package:flutter/material.dart';
import 'package:voxfable/feature/story/data/models/story_state.dart';

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
      const Color(0xFFFFE0B2),
      const Color(0xFFD7CCC8),
      const Color(0xFFC8E6C9),
      const Color(0xFFF8BBD0),
    ];
    final badgeBgColor = badgeColors[widget.index % badgeColors.length];

    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFEDE7F6);
    Color textColor = const Color(0xFF36165E);
    Widget? rightIcon;
    double opacity = 1.0;

    final hasFeedback = widget.quizAnswerStatus != QuizAnswerStatus.idle;

    if (hasFeedback) {
      if (widget.quizAnswerStatus == QuizAnswerStatus.correct &&
          widget.isCorrectAnswer) {
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
      } else if (widget.quizAnswerStatus == QuizAnswerStatus.wrong &&
          widget.isSelected) {
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                // Option Text
                Expanded(
                  child: Text(
                    widget.optionText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                if (rightIcon != null) ...[const SizedBox(width: 8), rightIcon],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
