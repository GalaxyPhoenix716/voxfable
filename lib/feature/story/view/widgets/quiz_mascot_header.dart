import 'package:flutter/material.dart';
import 'package:voxfable/feature/story/data/repos/story_state.dart';
import 'package:voxfable/feature/story/view/widgets/peblo_mascot.dart';

class QuizMascotHeader extends StatelessWidget {
  final BuddyState buddyState;
  const QuizMascotHeader({super.key, required this.buddyState});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: FittedBox(
            fit: BoxFit.contain,
            child: PebloMascot(state: buddyState),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF36165E),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.volume_up_rounded,
                  color: Color(0xFF6F2BC2),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
