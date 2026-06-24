import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voxfable/core/theme/colors.dart';
import 'package:voxfable/core/theme/paddings.dart';
import 'package:voxfable/feature/story/view_model/story_view_model.dart';

class ReadStoryButton extends StatelessWidget {
  const ReadStoryButton({super.key, required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      margin: VoxfablePaddings.buttonMargin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [
            VoxfableColors.accentPurple,
            VoxfableColors.deepPurple,
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
      child: ElevatedButton.icon(
        onPressed: () => ref.read(storyViewModelProvider.notifier).readStory(),
        icon: const Icon(
          Icons.volume_up_rounded,
          size: 28,
          color: Colors.white,
        ),
        label: const Text(
          "Read Story",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
    );
  }
}
