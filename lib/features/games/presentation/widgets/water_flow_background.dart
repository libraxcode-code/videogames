import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Modern Neon Fluid / Liquid Lava Lamp Background.
///
/// Features:
/// - Floating, morphing organic liquid blobs with modern neon cyber gradients:
///   (Electric Cyan #00F0FF, Hot Magenta/Pink #FF007F, Royal Purple #7B2CBF, Emerald Mint #00FFA3)
/// - Interactive touch physics: tapping or dragging spawns liquid splash droplets & multi-color neon rings
/// - Scroll-reactive fluid motion: scrolling drives fluid vertical flow and morphing
/// - Calm, smooth 120 FPS frame rate with no dizziness or harsh panning
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
    // Continuous smooth organic liquid morphing
    _fluidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _fluidController.dispose();
    super.dispose();
  }

  /// Trigger interactive neon liquid ripple & splash on touch/tap
  void addTouchRipple(Offset position) {
    if (!mounted) return;
    _lastTouchPos = position;
    setState(() {
      _touchRipples.add(_NeonLiquidRipple(
        center: position,
        startTime: DateTime.now(),
        colorIndex: _touchRipples.length % 4,
      ));
      if (_touchRipples.length > 8) {
        _touchRipples.removeAt(0);
      }
    });
  }

  /// Update fluid flow displacement when page scrolls
  void onScrollOffsetUpdate(double scrollOffset) {
    if (!mounted) return;
    setState(() {
      _scrollDisplacement = scrollOffset * 0.25;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => addTouchRipple(event.localPosition),
      onPointerMove: (event) {
        // Continuous fluid dragging trail
        if ((event.localPosition - _lastTouchPos).distance > 45) {
          addTouchRipple(event.localPosition);
        }
      },
      child: Stack(
        children: [
          // 1. Deep Midnight Cyber Void Base
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF030712), // Deepest obsidian
                    Color(0xFF070B19), // Midnight violet
                    Color(0xFF0A0F24), // Dark indigo
                    Color(0xFF04060E), // Base black
                  ],
                  stops: [0.0, 0.35, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 2. Glowing Neon Liquid Blobs (Organic, Floating, Morphing)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fluidController,
              builder: (context, child) {
                final t = _fluidController.value * 2 * math.pi;

                // Smooth organic harmonic oscillation coordinates
                final blob1X = math.sin(t) * 45.0 + math.cos(t * 0.7) * 20.0;
                final blob1Y = math.cos(t * 0.8) * 60.0 - (_scrollDisplacement * 0.3);

                final blob2X = math.cos(t * 0.9) * 55.0;
                final blob2Y = math.sin(t * 1.1) * 70.0 + (_scrollDisplacement * 0.2);

                final blob3X = math.sin(t * 1.3) * 50.0;
                final blob3Y = math.cos(t * 0.6) * 45.0 - (_scrollDisplacement * 0.15);

                final blob4X = math.cos(t * 0.7) * 40.0;
                final blob4Y = math.sin(t * 0.5) * 50.0 + (_scrollDisplacement * 0.25);

                return Stack(
                  children: [
                    // --- Blob 1: Neon Cyan Electric Fluid (Top Left / Center) ---
                    Positioned(
                      top: screenSize.height * 0.10 + blob1Y,
                      left: screenSize.width * 0.05 + blob1X,
                      child: _buildLiquidGlowBlob(
                        diameter: 320,
                        primaryColor: const Color(0xFF00F0FF).withOpacity(0.24), // Vibrant Neon Cyan
                        secondaryColor: const Color(0xFF0077B6).withOpacity(0.12),
                      ),
                    ),

                    // --- Blob 2: Hot Neon Pink / Magenta Liquid (Right Center) ---
                    Positioned(
                      top: screenSize.height * 0.38 + blob2Y,
                      right: -40 + blob2X,
                      child: _buildLiquidGlowBlob(
                        diameter: 340,
                        primaryColor: const Color(0xFFFF007F).withOpacity(0.22), // Hot Neon Pink
                        secondaryColor: const Color(0xFF7B2CBF).withOpacity(0.10),
                      ),
                    ),

                    // --- Blob 3: Royal Purple / Violet Neon Fluid (Bottom Left) ---
                    Positioned(
                      bottom: screenSize.height * 0.08 + blob3Y,
                      left: -50 + blob3X,
                      child: _buildLiquidGlowBlob(
                        diameter: 380,
                        primaryColor: const Color(0xFF8B5CF6).withOpacity(0.25), // Neon Purple
                        secondaryColor: const Color(0xFF4C1D95).withOpacity(0.12),
                      ),
                    ),

                    // --- Blob 4: Emerald Mint Neon Liquid (Bottom Right) ---
                    Positioned(
                      bottom: screenSize.height * 0.25 + blob4Y,
                      right: screenSize.width * 0.08 + blob4X,
                      child: _buildLiquidGlowBlob(
                        diameter: 290,
                        primaryColor: const Color(0xFF00FFA3).withOpacity(0.18), // Electric Mint Green
                        secondaryColor: const Color(0xFF028090).withOpacity(0.08),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 3. Flowing Liquid Waves & Interactive Touch Splashes Canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fluidController,
              builder: (context, child) {
                final now = DateTime.now();
                _touchRipples.removeWhere(
                  (r) => now.difference(r.startTime).inMilliseconds > 1600,
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
          ),

          // 4. Foreground Page Content
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
            stops: const [0.0, 0.45, 1.0],
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
    Color(0xFFFF007F), // Neon Pink
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

    // 1. Organic Fluid Sine Waves (Liquid Surface Lines with Neon Glow)
    // Cyan Wave
    _drawLiquidWave(
      canvas,
      size,
      amplitude: 16.0,
      wavelength: size.width * 0.85,
      phase: t,
      baseY: size.height * 0.26 + (scrollDisplacement * 0.1),
      color: const Color(0xFF00F0FF).withOpacity(0.08),
      strokeWidth: 2.0,
    );

    // Magenta Wave
    _drawLiquidWave(
      canvas,
      size,
      amplitude: 22.0,
      wavelength: size.width * 1.15,
      phase: t * 0.85 + 1.6,
      baseY: size.height * 0.52 + (scrollDisplacement * 0.2),
      color: const Color(0xFFFF007F).withOpacity(0.07),
      strokeWidth: 2.2,
    );

    // Mint Green Wave
    _drawLiquidWave(
      canvas,
      size,
      amplitude: 18.0,
      wavelength: size.width * 0.95,
      phase: t * 1.2 + 2.8,
      baseY: size.height * 0.78 + (scrollDisplacement * 0.3),
      color: const Color(0xFF00FFA3).withOpacity(0.06),
      strokeWidth: 1.8,
    );

    // 2. Interactive Neon Liquid Splashes & Ripples on Touch
    final now = DateTime.now();
    for (final ripple in ripples) {
      final elapsed = now.difference(ripple.startTime).inMilliseconds;
      if (elapsed < 1600) {
        final progress = elapsed / 1600.0; // 0.0 -> 1.0
        final radius = progress * 180.0;
        final opacity = (1.0 - progress);

        final neonColor = _neonPalette[ripple.colorIndex % _neonPalette.length];

        // Outer expanding neon liquid ring
        final outerPaint = Paint()
          ..color = neonColor.withOpacity(opacity * 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * (1.0 - progress * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

        canvas.drawCircle(ripple.center, radius, outerPaint);

        // Inner glowing liquid droplet
        if (progress < 0.6) {
          final splashOpacity = (1.0 - (progress / 0.6)) * 0.4;
          final splashPaint = Paint()
            ..color = neonColor.withOpacity(splashOpacity)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

          canvas.drawCircle(ripple.center, (1.0 - progress) * 28.0, splashPaint);
        }

        // Secondary echo ring
        if (progress > 0.18) {
          final innerProgress = (progress - 0.18) / 0.82;
          final innerRadius = innerProgress * 130.0;
          final innerOpacity = (1.0 - innerProgress) * 0.35;
          final nextNeonColor = _neonPalette[(ripple.colorIndex + 1) % _neonPalette.length];

          final echoPaint = Paint()
            ..color = nextNeonColor.withOpacity(innerOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6;

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
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    final path = Path();
    path.moveTo(0, baseY + amplitude * math.sin(phase));

    for (double x = 0; x <= size.width; x += 12.0) {
      final y = baseY + amplitude * math.sin((x / wavelength * 2 * math.pi) + phase);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NeonLiquidPainter oldDelegate) => true;
}
