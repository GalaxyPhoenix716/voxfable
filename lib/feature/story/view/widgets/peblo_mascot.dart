import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/story_state.dart';


//this is completely ai generated to act as a placeholder mascot
class PebloMascot extends StatefulWidget {
  final BuddyState state;

  const PebloMascot({super.key, required this.state});

  @override
  State<PebloMascot> createState() => _PebloMascotState();
}

class _PebloMascotState extends State<PebloMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;
  bool _isBlinking = false;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Setup periodic blink timer
    _blinkTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (widget.state == BuddyState.idle || widget.state == BuddyState.talking) {
        if (mounted) {
          setState(() => _isBlinking = true);
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) {
              setState(() => _isBlinking = false);
            }
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant PebloMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      // Adjust floating/jumping speed and amplitude based on state
      if (widget.state == BuddyState.happy) {
        _floatController.duration = const Duration(milliseconds: 400);
        _floatController.repeat(reverse: true);
      } else if (widget.state == BuddyState.thinking) {
        _floatController.duration = const Duration(seconds: 3);
        _floatController.repeat(reverse: true);
      } else {
        _floatController.duration = const Duration(seconds: 2);
        _floatController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        // Apply vertical floating displacement
        double verticalOffset = _floatAnimation.value;
        if (widget.state == BuddyState.happy) {
          // Bouncy jump effect
          verticalOffset = _floatAnimation.value * 1.5 - 12.0;
        }

        return Transform.translate(
          offset: Offset(0, verticalOffset),
          child: child,
        );
      },
      child: _buildRobotBody(),
    );
  }

  Widget _buildRobotBody() {
    // Styling values based on current state
    Color eyeColor = const Color(0xFF00E5FF); // Bright Cyan
    double eyeHeightScale = 1.0;
    double eyeWidthScale = 1.0;
    Offset eyeOffset = Offset.zero;
    Widget? customEyeShape;

    if (_isBlinking) {
      eyeHeightScale = 0.1;
    }

    switch (widget.state) {
      case BuddyState.thinking:
        eyeColor = const Color(0xFFFFD54F); // Yellow
        eyeHeightScale = 0.6;
        eyeWidthScale = 0.6;
        eyeOffset = const Offset(0, -4); // Look up
        break;
      case BuddyState.happy:
        eyeColor = const Color(0xFF66BB6A); // Green
        customEyeShape = CustomPaint(
          size: const Size(16, 10),
          painter: SmilingEyePainter(color: eyeColor),
        );
        break;
      case BuddyState.talking:
        eyeColor = const Color(0xFFE040FB); // Magenta
        break;
      case BuddyState.idle:
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // robot head
        Container(
          width: 84,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9E77F3), // Light metallic purple
                Color(0xFF673AB7), // Metallic deep purple
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFB39DDB), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF36165E).withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Center(
            // Face screen
            child: Container(
              width: 68,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1035),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF311B92), width: 1.5),
              ),
              child: Stack(
                children: [
                  // Subtle screen glow grid
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05,
                      child: GridPaper(
                        color: eyeColor,
                        divisions: 1,
                        subdivisions: 1,
                      ),
                    ),
                  ),
                  // Left and Right Eyes
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildEye(customEyeShape, eyeOffset, eyeColor, eyeWidthScale, eyeHeightScale),
                        _buildEye(customEyeShape, eyeOffset, eyeColor, eyeWidthScale, eyeHeightScale),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // neck connector
        Container(
          width: 14,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF7E57C2),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        // Neck/floating shadow
        Container(
          width: 44,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: const BorderRadius.all(Radius.elliptical(22, 3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF36165E).withValues(alpha: 0.15),
                blurRadius: 4,
                spreadRadius: 1,
              )
            ]
          ),
        ),
      ],
    );
  }

  Widget _buildEye(
    Widget? customEyeShape,
    Offset offset,
    Color color,
    double widthScale,
    double heightScale,
  ) {
    if (customEyeShape != null) {
      return customEyeShape;
    }

    return Transform.translate(
      offset: offset,
      child: Transform.scale(
        scaleX: widthScale,
        scaleY: heightScale,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SmilingEyePainter extends CustomPainter {
  final Color color;

  SmilingEyePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(2, size.height - 2)
      ..quadraticBezierTo(size.width / 2, 2, size.width - 2, size.height - 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SmilingEyePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
