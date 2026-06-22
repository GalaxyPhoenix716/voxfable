import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voxfable/feature/story/view/widgets/read_story_button.dart';
import '../widgets/story_overlay.dart';
import '../../data/models/story_state.dart';
import '../../view_model/story_view_model.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  late final PageController _pageController;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for answer correctness changes to play confetti
    ref.listen<StoryState>(storyViewModelProvider, (previous, next) {
      if (next.quizAnswerStatus == QuizAnswerStatus.correct) {
        _confettiController.play();
      }
    });

    final state = ref.watch(storyViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final H = constraints.maxHeight;
          final W = constraints.maxWidth;

          return Stack(
            children: [
              //bg (parallax)
              AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  final double offset = _pageController.hasClients
                      ? _pageController.offset
                      : 0.0;

                  const double bushSlideThreshold = 120.0;
                  final double bushProgress = (offset / bushSlideThreshold)
                      .clamp(0.0, 1.0);

                  //scroll starts after bushes slide away
                  final double mainScrollOffset = (offset - bushSlideThreshold)
                      .clamp(0.0, double.infinity);

                  //different offsets for parallax effect
                  final starsOffset = -mainScrollOffset * 0.15;
                  final cloudsOffset = -mainScrollOffset * 0.25;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      //base bg
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: H,
                        child: Image.asset(
                          'assets/images/bg_base.webp',
                          fit: BoxFit.fill,
                        ),
                      ),

                      //stars
                      Positioned(
                        top: starsOffset,
                        left: 0,
                        right: 0,
                        height: H * 0.5,
                        child: Image.asset(
                          'assets/images/bg_stars.webp',
                          fit: BoxFit.cover,
                        ),
                      ),

                      //top left cloud
                      Positioned(
                        top: 80 + cloudsOffset,
                        left: -10,
                        width: W * 0.5,
                        child: Image.asset(
                          'assets/images/bg_cloud_topleft.webp',
                          fit: BoxFit.contain,
                        ),
                      ),

                      //bottom left cloud
                      Positioned(
                        top: 300 + cloudsOffset,
                        left: -20,
                        width: W * 0.5,
                        child: Image.asset(
                          'assets/images/bg_cloud_bottomleft.webp',
                          fit: BoxFit.contain,
                        ),
                      ),

                      //right cloud
                      Positioned(
                        top: 200 + cloudsOffset,
                        right: -25,
                        width: W * 0.50,
                        child: Image.asset(
                          'assets/images/bg_cloud_right.webp',
                          fit: BoxFit.contain,
                        ),
                      ),

                      //main hills
                      Positioned(
                        top: 0 - (mainScrollOffset * 0.8),
                        left: 0,
                        right: 0,
                        height: H,
                        child: Opacity(
                          opacity: (1.0 - (mainScrollOffset / (H * 0.4))).clamp(
                            0.0,
                            1.0,
                          ),
                          child: Image.asset(
                            'assets/images/bg_hills.webp',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),

                      //left bush
                      Positioned(
                        bottom: -50 - (bushProgress * 80),
                        left: -10 - (bushProgress * (W * 0.35)),
                        width: W * 0.30,
                        child: Image.asset(
                          'assets/images/bg_left_bush.webp',
                          fit: BoxFit.contain,
                        ),
                      ),

                      //right bush
                      Positioned(
                        bottom: 0 - (bushProgress * 80),
                        right: 0 - (bushProgress * (W * 0.35)),
                        width: W * 0.30,
                        child: Image.asset(
                          'assets/images/bg_right_bush.webp',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  );
                },
              ),

              //main content
              PageView(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                children: [
                  // Page 1: Story Screen
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          // Header: Peblo Logo & Profile
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 180,
                                child: Image.asset(
                                  'assets/logo/voxfable_logo.png',
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          const SizedBox(height: 165),

                          //book
                          SizedBox(
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
                                          text:
                                              state.storyContent?.storyText ??
                                              "Reading story...",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),

                          ReadStoryButton(ref: ref),
                        ],
                      ),
                    ),
                  ),

                  // Page 2: Quiz Screen Placeholder
                  const SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.psychology_alt_rounded,
                            size: 80,
                            color: Colors.white70,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Quiz Screen\n(Mascot & Cards Coming Soon!)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 3. Confetti Overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
