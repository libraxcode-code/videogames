import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Interactive Neon Liquid Background.
///
/// Features:
/// - Distinct & Bold Neon Liquid Glows (Cyan, Magenta/Pink, Violet, Mint Green)
/// - Interactive Ripple/Splash on Touch and Drag via Global Listener wrapping child content
/// - Scroll-reactive fluid flow & wave displacement
/// - Dynamic liquid mesh with glowing neon waves
class WaterFlowBackground extends StatefulWidget {
  final Widget? child;

  const WaterFlowBackground({
    super.key,
    this.child,
  });

  @override
  State<WaterFlowBackground> createState() => WaterFlowBackgroundState();
}

class WaterFlowBackgroundState extends State<WaterFlowBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _fluidController;
  final List<_NeonLiquidRipple> _touchRipples = [];
  double _scrollDisplacement = 0.0;
  Offset _lastTouchPos = Offset.zero;

  @override
  void initState() {
    super.initState();
    // 12-second smooth fluid loop
    _fluidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _fluidController.dispose();
    super.dispose();
  }

  /// Trigger interactive neon liquid ripple on touch or pointer move
  void addTouchRipple(Offset position) {
    if (!mounted) return;
    _lastTouchPos = position;
    setState(() {
      _touchRipples.add(_NeonLiquidRipple(
        center: position,
        startTime: DateTime.now(),
        colorIndex: _touchRipples.length,
      ));
      if (_touchRipples.length > 10) {
        _touchRipples.removeAt(0);
      }
    });
  }

  /// Update fluid flow displacement when page scrolls with bounded harmonic cycle
  void onScrollOffsetUpdate(double scrollOffset) {
    if (!mounted) return;
    setState(() {
      // Loop displacement within -45.0 to +45.0 px so background fluid stays on screen indefinitely
      _scrollDisplacement = (scrollOffset % 360.0) / 360.0 * 90.0 - 45.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        addTouchRipple(event.position);
      },
      onPointerMove: (event) {
        // Continuous fluid dragging trail when user drags or scrolls
        if ((event.position - _lastTouchPos).distance > 30) {
          addTouchRipple(event.position);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Deep Midnight Cyber Space Base
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF030712), // Deepest obsidian
                  Color(0xFF070B1E), // Midnight indigo
                  Color(0xFF0B112C), // Dark cyber blue
                  Color(0xFF04060E), // Base black
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
            ),
          ),

          // 2. Bold Glowing Neon Liquid Blobs (Organic, Floating, Morphing)
          AnimatedBuilder(
            animation: _fluidController,
            builder: (context, child) {
              final t = _fluidController.value * 2 * math.pi;

              // Pronounced fluid coordinates reacting strongly to scroll
              final scrollFactor = (_scrollDisplacement * 0.45);

              final blob1X = math.sin(t) * 60.0;
              final blob1Y = math.cos(t * 0.8) * 80.0 - scrollFactor;

              final blob2X = math.cos(t * 0.9) * 70.0;
              final blob2Y = math.sin(t * 1.1) * 90.0 + (scrollFactor * 0.8);

              final blob3X = math.sin(t * 1.3) * 65.0;
              final blob3Y = math.cos(t * 0.6) * 75.0 - (scrollFactor * 0.5);

              final blob4X = math.cos(t * 0.7) * 55.0;
              final blob4Y = math.sin(t * 0.5) * 80.0 + (scrollFactor * 0.6);

              return Stack(
                children: [
                  // --- Blob 1: Vibrant Electric Neon Cyan (#00F0FF) ---
                  Positioned(
                    top: screenSize.height * 0.08 + blob1Y,
                    left: screenSize.width * 0.02 + blob1X,
                    child: _buildLiquidGlowBlob(
                      diameter: 360,
                      primaryColor: const Color(0xFF00F0FF).withOpacity(0.38),
                      secondaryColor: const Color(0xFF0077B6).withOpacity(0.18),
                    ),
                  ),

                  // --- Blob 2: Hot Neon Pink / Magenta (#FF007F) ---
                  Positioned(
                    top: screenSize.height * 0.35 + blob2Y,
                    right: -50 + blob2X,
                    child: _buildLiquidGlowBlob(
                      diameter: 380,
                      primaryColor: const Color(0xFFFF007F).withOpacity(0.35),
                      secondaryColor: const Color(0xFF7B2CBF).withOpacity(0.16),
                    ),
                  ),

                  // --- Blob 3: Royal Purple Neon Fluid (#8B5CF6) ---
                  Positioned(
                    bottom: screenSize.height * 0.05 + blob3Y,
                    left: -60 + blob3X,
                    child: _buildLiquidGlowBlob(
                      diameter: 420,
                      primaryColor: const Color(0xFF8B5CF6).withOpacity(0.36),
                      secondaryColor: const Color(0xFF4C1D95).withOpacity(0.18),
                    ),
                  ),

                  // --- Blob 4: Emerald Mint Neon Liquid (#00FFA3) ---
                  Positioned(
                    bottom: screenSize.height * 0.28 + blob4Y,
                    right: screenSize.width * 0.05 + blob4X,
                    child: _buildLiquidGlowBlob(
                      diameter: 330,
                      primaryColor: const Color(0xFF00FFA3).withOpacity(0.30),
                      secondaryColor: const Color(0xFF028090).withOpacity(0.14),
                    ),
                  ),
                ],
              );
            },
          ),

          // 3. Flowing Liquid Waves Canvas & Strong Interactive Touch Ripples
          AnimatedBuilder(
            animation: _fluidController,
            builder: (context, child) {
              final now = DateTime.now();
              _touchRipples.removeWhere(
                (r) => now.difference(r.startTime).inMilliseconds > 1800,
              );

              return CustomPaint(
                painter: _NeonLiquidPainter(
                  fluidTime: _fluidController.value,
                  ripples: List.from(_touchRipples),
                  scrollDisplacement: _scrollDisplacement,
                ),
              );
            },
          ),

          // 4. Foreground Content Slot (Passes touches cleanly through Listener)
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }

  Widget _buildLiquidGlowBlob({
    required double diameter,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              primaryColor,
              secondaryColor,
              Colors.transparent,
            ],
            stops: const [0.0, 0.48, 1.0],
          ),
        ),
      ),
    );
  }
}

class _NeonLiquidRipple {
  final Offset center;
  final DateTime startTime;
  final int colorIndex;

  _NeonLiquidRipple({
    required this.center,
    required this.startTime,
    required this.colorIndex,
  });
}

class _NeonLiquidPainter extends CustomPainter {
  final double fluidTime;
  final List<_NeonLiquidRipple> ripples;
  final double scrollDisplacement;

  static const List<Color> _neonPalette = [
    Color(0xFF00F0FF), // Neon Cyan
    Color(0xFFFF007F), // Neon Pink / Magenta
    Color(0xFF8B5CF6), // Neon Violet
    Color(0xFF00FFA3), // Neon Mint
  ];

  _NeonLiquidPainter({
    required this.fluidTime,
    required this.ripples,
    required this.scrollDisplacement,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = fluidTime * 2 * math.pi;

    // 1. Organic Fluid Sine Waves (Bold neon liquid contour lines)
    _drawLiquidWave(
      canvas,
      size,
      amplitude: 24.0,
      wavelength: size.width * 0.75,
      phase: t,
      baseY: size.height * 0.24 + (scrollDisplacement * 0.18),
      color: const Color(0xFF00F0FF).withOpacity(0.18),
      strokeWidth: 2.8,
    );

    _drawLiquidWave(
      canvas,
      size,
      amplitude: 30.0,
      wavelength: size.width * 1.1,
      phase: t * 0.85 + 1.6,
      baseY: size.height * 0.50 + (scrollDisplacement * 0.32),
      color: const Color(0xFFFF007F).withOpacity(0.16),
      strokeWidth: 3.0,
    );

    _drawLiquidWave(
      canvas,
      size,
      amplitude: 26.0,
      wavelength: size.width * 0.88,
      phase: t * 1.2 + 2.8,
      baseY: size.height * 0.76 + (scrollDisplacement * 0.42),
      color: const Color(0xFF00FFA3).withOpacity(0.15),
      strokeWidth: 2.6,
    );

    // 2. Interactive Neon Liquid Splashes & Ripples on Touch & Drag
    final now = DateTime.now();
    for (final ripple in ripples) {
      final elapsed = now.difference(ripple.startTime).inMilliseconds;
      if (elapsed < 1800) {
        final progress = elapsed / 1800.0; // 0.0 -> 1.0
        final radius = progress * 240.0; // Expands visibly up to 240px
        final opacity = (1.0 - progress);

        final neonColor = _neonPalette[ripple.colorIndex % _neonPalette.length];

        // Outer expanding neon liquid shockwave ring
        final outerPaint = Paint()
          ..color = neonColor.withOpacity(opacity * 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.8 * (1.0 - progress * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 6);

        canvas.drawCircle(ripple.center, radius, outerPaint);

        // Core glowing neon splash droplet
        if (progress < 0.65) {
          final splashOpacity = (1.0 - (progress / 0.65)) * 0.65;
          final splashPaint = Paint()
            ..color = neonColor.withOpacity(splashOpacity)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

          canvas.drawCircle(ripple.center, (1.0 - progress) * 38.0, splashPaint);
        }

        // Secondary harmonic echo ring
        if (progress > 0.15) {
          final innerProgress = (progress - 0.15) / 0.85;
          final innerRadius = innerProgress * 170.0;
          final innerOpacity = (1.0 - innerProgress) * 0.55;
          final nextNeonColor = _neonPalette[(ripple.colorIndex + 1) % _neonPalette.length];

          final echoPaint = Paint()
            ..color = nextNeonColor.withOpacity(innerOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4;

          canvas.drawCircle(ripple.center, innerRadius, echoPaint);
        }
      }
    }
  }

  void _drawLiquidWave(
    Canvas canvas,
    Size size, {
    required double amplitude,
    required double wavelength,
    required double phase,
    required double baseY,
    required Color color,
    required double strokeWidth,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    final path = Path();
    path.moveTo(0, baseY + amplitude * math.sin(phase));

    for (double x = 0; x <= size.width; x += 10.0) {
      final y = baseY + amplitude * math.sin((x / wavelength * 2 * math.pi) + phase);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NeonLiquidPainter oldDelegate) => true;
}
