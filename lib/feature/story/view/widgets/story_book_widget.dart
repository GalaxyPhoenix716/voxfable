import 'package:flutter/material.dart';
import 'package:voxfable/feature/story/data/repos/story_state.dart';
import 'package:voxfable/feature/story/view/widgets/story_overlay.dart';

class StoryBookWidget extends StatelessWidget {
  const StoryBookWidget({
    super.key,
    required this.W,
    required this.H,
    required this.state,
  });

  final double W;
  final double H;
  final StoryState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: W,
      height: H * 0.48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: W,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/book.webp',
                    fit: BoxFit.fill,
                  ),
                ),

                //text overlay
                Positioned(
                  top: (H * 0.4) * 0.07,
                  bottom: (H * 0.48) * 0.2,
                  left: W * 0.23,
                  width: W * 0.67,
                  child: StoryOverlay(
                    text: state.storyContent?.storyText ?? "Reading story...",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
