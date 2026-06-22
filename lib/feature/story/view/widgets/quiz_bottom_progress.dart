import 'package:flutter/material.dart';

class QuizBottomProgress extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;

  const QuizBottomProgress({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalQuestions > 0
        ? (currentQuestionIndex + 1) / totalQuestions
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
            const SizedBox(width: 4),
            Text(
              "${currentQuestionIndex + 1}/$totalQuestions",
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
}
