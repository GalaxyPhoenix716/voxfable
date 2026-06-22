import 'package:flutter/material.dart';

class ParallaxBackground extends StatelessWidget {
  const ParallaxBackground({
    super.key,
    required this.pageController,
    required this.H,
    required this.W,
  });

  final PageController pageController;
  final double H;
  final double W;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        final double offset = pageController.hasClients
            ? pageController.offset
            : 0.0;

        const double bushSlideThreshold = 120.0;
        final double bushProgress = (offset / bushSlideThreshold).clamp(
          0.0,
          1.0,
        );

        //scroll starts after bushes slide away
        final double mainScrollOffset = (offset - bushSlideThreshold).clamp(
          0.0,
          double.infinity,
        );

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
                opacity: (1.0 - (mainScrollOffset / (H * 0.4))).clamp(0.0, 1.0),
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
    );
  }
}
