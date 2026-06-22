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
  final int totalOptions;

  const OptionCard({
    super.key,
    required this.index,
    required this.optionText,
    required this.isSelected,
    required this.isCorrectAnswer,
    required this.quizAnswerStatus,
    required this.hasSelectedAny,
    required this.onTap,
    required this.totalOptions,
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

    final totalOpts = widget.totalOptions;
    final double verticalPadding;
    final double badgeSize;
    final double emojiSize;
    final double fontSize;

    if (totalOpts <= 2) {
      verticalPadding = 22.0;
      badgeSize = 44.0;
      emojiSize = 22.0;
      fontSize = 18.0;
    } else if (totalOpts == 3) {
      verticalPadding = 16.0;
      badgeSize = 36.0;
      emojiSize = 18.0;
      fontSize = 16.0;
    } else {
      verticalPadding = 10.0;
      badgeSize = 30.0;
      emojiSize = 16.0;
      fontSize = 14.0;
    }

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
          width: badgeSize - 6,
          height: badgeSize - 6,
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: badgeSize - 14,
          ),
        );
      } else if (widget.quizAnswerStatus == QuizAnswerStatus.wrong &&
          widget.isSelected) {
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFF44336);
        textColor = const Color(0xFFB71C1C);
        rightIcon = Container(
          width: badgeSize - 6,
          height: badgeSize - 6,
          decoration: const BoxDecoration(
            color: Color(0xFFF44336),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: badgeSize - 14,
          ),
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
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: verticalPadding,
            ),
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
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(emoji, style: TextStyle(fontSize: emojiSize)),
                  ),
                ),
                const SizedBox(width: 12),
                // Option Text
                Expanded(
                  child: Text(
                    widget.optionText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: fontSize,
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
