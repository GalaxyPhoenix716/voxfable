import 'package:flutter/material.dart';
import 'package:voxfable/core/theme/colors.dart';
import 'package:voxfable/core/theme/paddings.dart';
import 'package:voxfable/feature/story/data/repos/story_state.dart';

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
      VoxfableColors.badgeOrange, // Light Orange
      VoxfableColors.badgeBrown, // Light Brown
      VoxfableColors.badgeGreen, // Light Green
      VoxfableColors.badgePink, // Light Pink
    ];
    final badgeBgColor = badgeColors[widget.index % badgeColors.length];

    final totalOpts = widget.totalOptions;
    final double verticalPadding;
    final double badgeSize;
    final double emojiSize;
    final double fontSize;

    if (totalOpts <= 2) {
      verticalPadding = VoxfablePaddings.optionVerticalMax;
      badgeSize = 44.0;
      emojiSize = 22.0;
      fontSize = 18.0;
    } else if (totalOpts == 3) {
      verticalPadding = VoxfablePaddings.optionVerticalMid;
      badgeSize = 36.0;
      emojiSize = 18.0;
      fontSize = 16.0;
    } else {
      verticalPadding = VoxfablePaddings.optionVerticalMin;
      badgeSize = 30.0;
      emojiSize = 16.0;
      fontSize = 14.0;
    }

    Color bgColor = Colors.white;
    Color borderColor = VoxfableColors.lightLavenderBg;
    Color textColor = VoxfableColors.deepViolet;
    Widget? rightIcon;
    double opacity = 1.0;

    final hasFeedback = widget.quizAnswerStatus != QuizAnswerStatus.idle;

    if (hasFeedback) {
      if (widget.quizAnswerStatus == QuizAnswerStatus.correct &&
          widget.isCorrectAnswer) {
        bgColor = VoxfableColors.deepPurple;
        borderColor = VoxfableColors.deepPurple;
        textColor = Colors.white;
        rightIcon = Container(
          width: badgeSize - 6,
          height: badgeSize - 6,
          decoration: const BoxDecoration(
            color: VoxfableColors.correctGreen,
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
        bgColor = VoxfableColors.wrongRedBg;
        borderColor = VoxfableColors.wrongRedBorder;
        textColor = VoxfableColors.wrongRedText;
        rightIcon = Container(
          width: badgeSize - 6,
          height: badgeSize - 6,
          decoration: const BoxDecoration(
            color: VoxfableColors.wrongRedBorder,
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
              horizontal: VoxfablePaddings.optionHorizontal,
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
