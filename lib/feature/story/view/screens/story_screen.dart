import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voxfable/feature/story/view/widgets/parallax_background.dart';
import 'package:voxfable/feature/story/view/widgets/read_story_button.dart';
import 'package:voxfable/feature/story/view/widgets/story_book_widget.dart';
import 'quiz_screen.dart';
import '../widgets/peblo_mascot.dart';
import '../../data/repos/story_state.dart';
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
      duration: const Duration(seconds: 1),
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
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOutCubic,
          );
        }
      }

      if (!next.showQuiz && (previous?.showQuiz ?? false)) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            0,
            duration: const Duration(seconds: 2),
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
              ParallaxBackground(pageController: _pageController, H: H, W: W),

              //main content
              PageView(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics:
                    const NeverScrollableScrollPhysics(), //user cannot scroll by his own
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
                          //header
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

                          //mascot
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

                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const SafeArea(child: QuizView()),
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
