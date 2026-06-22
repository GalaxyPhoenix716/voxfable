import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voxfable/feature/story/view/widgets/read_story_button.dart';
import 'package:voxfable/feature/story/view/widgets/story_book_widget.dart';
import '../widgets/story_overlay.dart';
import '../widgets/quiz_view.dart';
import '../widgets/peblo_mascot.dart';
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
    ref.listen<StoryState>(storyViewModelProvider, (previous, next) {
      if (next.quizAnswerStatus == QuizAnswerStatus.correct) {
        _confettiController.play();
      }

      if (next.showQuiz && !(previous?.showQuiz ?? false)) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      }

      if (!next.showQuiz && (previous?.showQuiz ?? false)) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
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
                physics:
                    const NeverScrollableScrollPhysics(), //user canno scroll by his own
                children: [
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

                          // Mascot and Speech Bubble Row
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                width: MediaQuery.of(context).size.width * 0.6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFF673AB7),
                                    width: 2.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _getSpeechBubbleText(state),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF36165E),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              PebloMascot(state: state.buddyState),
                            ],
                          ),

                          const Spacer(),

                          //book
                          StoryBookWidget(W: W, H: H, state: state),
                          const Spacer(),

                          ReadStoryButton(ref: ref),
                        ],
                      ),
                    ),
                  ),

                  // Page 2: Quiz Screen
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1E0E4F),
                          Color(0xFF3F1B85),
                          Color(0xFF673AB7),
                          Color(0xFFD1C4E9),
                          Colors.white,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const SafeArea(top: false, child: QuizView()),
                  ),
                ],
              ),

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

  String _getSpeechBubbleText(StoryState state) {
    if (state.audioState == AudioState.idle) {
      return "Hey there! Would you like to hear a story?";
    }
    if (state.audioState == AudioState.loading) {
      return "Let me open the book";
    }
    if (state.audioState == AudioState.playing) {
      return "Listen closely to the story!";
    }
    if (state.audioState == AudioState.completed) {
      if (state.buddyState == BuddyState.happy) {
        return "Wow, what a great story! Let's do a quiz!";
      }
      return "Ready for the quiz? Swipe down!";
    }
    if (state.audioState == AudioState.error) {
      return "Oh no, I lost my voice! Let's try again";
    }
    return "Hello, reader!";
  }
}
