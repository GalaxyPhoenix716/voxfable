import 'package:flutter/material.dart';
import 'package:voxfable/core/theme/colors.dart';
import 'package:voxfable/core/theme/paddings.dart';
import 'package:voxfable/feature/story/data/repos/story_state.dart';
import 'package:voxfable/feature/story/view/widgets/peblo_mascot.dart';
import 'package:voxfable/feature/story/view_model/story_view_model.dart';

class VictoryScreen extends StatelessWidget {
  final StoryViewModel notifier;

  const VictoryScreen({super.key, required this.notifier});

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        // Big Glowing Trophy/Star Container
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: VoxfableColors.deepViolet,
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
          padding: VoxfablePaddings.victoryCardPadding,
          decoration: BoxDecoration(
            color: VoxfableColors.primaryBackground,
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
                  color: VoxfableColors.deepViolet,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "You read the story and answered every single question correctly! Keep up the amazing work!",
                textAlign: TextAlign.center,
                style: _getPoppinsStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: VoxfableColors.deepViolet.withValues(alpha: 0.8),
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
                  VoxfableColors.victoryGoldStart, // Bright Amber
                  VoxfableColors.victoryGoldEnd, // Dark Amber
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: VoxfableColors.deepViolet.withValues(alpha: 0.3),
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
                  color: VoxfableColors.deepViolet,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
