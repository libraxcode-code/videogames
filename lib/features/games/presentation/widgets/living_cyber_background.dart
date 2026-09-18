import 'package:flutter/material.dart';

/// Dynamic animated living cyberpunk background for detail and list screens.
class LivingCyberBackground extends StatelessWidget {
  final AnimationController motionController;
  final Animation<double> pulseAnimation;
  final Animation<double> driftAnimation;

  const LivingCyberBackground({
    super.key,
    required this.motionController,
    required this.pulseAnimation,
    required this.driftAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Living Cyberpunk Dynamic Wallpaper with Pan & Zoom
        Positioned.fill(
          child: AnimatedBuilder(
            animation: motionController,
            builder: (context, child) {
              final zoom = 1.08 + (0.10 * pulseAnimation.value);
              final panX = driftAnimation.value * 1.2;
              final panY = driftAnimation.value * 0.7;

              return Transform.translate(
                offset: Offset(panX, panY),
                child: Transform.scale(
                  scale: zoom,
                  child: Image.asset(
                    'assets/images/cyberpunk_bg.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        // 2. High-contrast Dark Cyberpunk Gradient Overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.30),
                  const Color(0xFF060910).withOpacity(0.65),
                  const Color(0xFF060910).withOpacity(0.92),
                ],
                stops: const [0.0, 0.40, 1.0],
              ),
            ),
          ),
        ),

        // 3. Living Floating Neon Orbs
        AnimatedBuilder(
          animation: motionController,
          builder: (context, child) {
            final drift = driftAnimation.value;
            final pulse = pulseAnimation.value;

            return Stack(
              children: [
                Positioned(
                  top: -40 + drift,
                  right: -40 - drift,
                  child: Transform.scale(
                    scale: pulse,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF00E5FF).withOpacity(0.28),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.65],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120 - drift,
                  left: -80 + drift,
                  child: Transform.scale(
                    scale: 1.8 - pulse,
                    child: Container(
                      width: 340,
                      height: 340,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF7C4DFF).withOpacity(0.25),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.65],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // 4. Moving Cyber Grid
        Positioned.fill(
          child: AnimatedBuilder(
            animation: motionController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.22,
                child: CustomPaint(
                  painter: _CyberGridPainter(
                    offsetX: driftAnimation.value * 0.8,
                    offsetY: driftAnimation.value * 0.5,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  final double offsetX;
  final double offsetY;

  const _CyberGridPainter({this.offsetX = 0.0, this.offsetY = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.12)
      ..strokeWidth = 0.6;

    const step = 44.0;
    final startX = (offsetX % step) - step;
    final startY = (offsetY % step) - step;

    for (double x = startX; x < size.width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = startY; y < size.height + step; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) =>
      oldDelegate.offsetX != offsetX || oldDelegate.offsetY != offsetY;
}
