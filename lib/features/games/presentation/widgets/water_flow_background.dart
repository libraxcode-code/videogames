import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Interactive Fluid Liquid / Water Ripple Background with touch & scroll motion.
/// Calm, elegant, and reactive without causing dizziness or nausea.
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
  late AnimationController _waveController;
  final List<_WaterRipple> _ripples = [];
  double _scrollVelocityOffset = 0.0;

  @override
  void initState() {
    super.initState();
    // Gentle continuous water wave animation (120 FPS high-refresh compatible)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  /// Trigger a gentle water ripple on touch or click
  void addTouchRipple(Offset position) {
    if (!mounted) return;
    setState(() {
      _ripples.add(_WaterRipple(
        center: position,
        startTime: DateTime.now(),
      ));
      // Keep at most 6 active ripples for optimal performance
      if (_ripples.length > 6) {
        _ripples.removeAt(0);
      }
    });
  }

  /// Trigger fluid displacement on scroll
  void onScrollOffsetUpdate(double scrollOffset) {
    if (!mounted) return;
    setState(() {
      _scrollVelocityOffset = scrollOffset * 0.15;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        addTouchRipple(event.localPosition);
      },
      onPointerMove: (event) {
        // Add ripple occasionally during drags
        if (DateTime.now().millisecond % 160 < 25) {
          addTouchRipple(event.localPosition);
        }
      },
      child: Stack(
        children: [
          // 1. Deep Ocean Cyberpunk Fluid Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF030712), // Deep midnight abyss
                    Color(0xFF071529), // Subtle oceanic blue
                    Color(0xFF0A1020), // Dark liquid navy
                    Color(0xFF050811), // Bottom dark void
                  ],
                  stops: [0.0, 0.40, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // 2. Animated Ambient Liquid Caustic Glows (Tenang & Tidak Pusing)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                final t = _waveController.value * 2 * math.pi;
                // Calming sinusoidal liquid drift
                final driftX1 = math.sin(t) * 35.0;
                final driftY1 = math.cos(t * 0.8) * 40.0;

                final driftX2 = math.cos(t * 1.2) * 45.0;
                final driftY2 = math.sin(t * 0.9) * 35.0;

                return Stack(
                  children: [
                    // Deep Azure Liquid Pool (Top Right)
                    Positioned(
                      top: -60 + driftY1 + (_scrollVelocityOffset * 0.2),
                      right: -60 + driftX1,
                      child: Container(
                        width: 380,
                        height: 380,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF00B4D8).withOpacity(0.18),
                              const Color(0xFF0077B6).withOpacity(0.08),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.50, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Bioluminescent Aqua Pool (Bottom Left)
                    Positioned(
                      bottom: 80 + driftY2 - (_scrollVelocityOffset * 0.2),
                      left: -80 + driftX2,
                      child: Container(
                        width: 420,
                        height: 420,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF00E5FF).withOpacity(0.14),
                              const Color(0xFF03045E).withOpacity(0.06),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Center Floating Soft Pearl Glow
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.45 + (driftY1 * 0.6),
                      right: MediaQuery.of(context).size.width * 0.2 + (driftX2 * 0.5),
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF48CAE4).withOpacity(0.09),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.70],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 3. Calm Harmonic Water Waves & Interactive Touch Ripples Canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                // Clean up expired ripples older than 1.4 seconds
                final now = DateTime.now();
                _ripples.removeWhere(
                  (r) => now.difference(r.startTime).inMilliseconds > 1400,
                );

                return CustomPaint(
                  painter: _WaterFlowPainter(
                    waveProgress: _waveController.value,
                    ripples: List.from(_ripples),
                    scrollOffset: _scrollVelocityOffset,
                  ),
                );
              },
            ),
          ),

          // 4. Foreground Content Slot (if any)
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _WaterRipple {
  final Offset center;
  final DateTime startTime;

  _WaterRipple({required this.center, required this.startTime});
}

class _WaterFlowPainter extends CustomPainter {
  final double waveProgress;
  final List<_WaterRipple> ripples;
  final double scrollOffset;

  _WaterFlowPainter({
    required this.waveProgress,
    required this.ripples,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = waveProgress * 2 * math.pi;

    // Draw 3 layers of harmonic soft water surface sine waves
    _drawWave(
      canvas,
      size,
      amplitude: 14.0,
      wavelength: size.width * 0.9,
      phase: t,
      baseY: size.height * 0.28 + (scrollOffset * 0.15),
      color: const Color(0xFF00E5FF).withOpacity(0.04),
      strokeWidth: 1.5,
    );

    _drawWave(
      canvas,
      size,
      amplitude: 18.0,
      wavelength: size.width * 1.2,
      phase: t * 0.8 + 1.2,
      baseY: size.height * 0.58 + (scrollOffset * 0.25),
      color: const Color(0xFF0096C7).withOpacity(0.05),
      strokeWidth: 1.8,
    );

    _drawWave(
      canvas,
      size,
      amplitude: 12.0,
      wavelength: size.width * 0.75,
      phase: t * 1.3 + 2.5,
      baseY: size.height * 0.82 + (scrollOffset * 0.35),
      color: const Color(0xFF48CAE4).withOpacity(0.035),
      strokeWidth: 1.2,
    );

    // Draw interactive touch/scroll water ripples expanding outward
    final now = DateTime.now();
    for (final ripple in ripples) {
      final elapsedMs = now.difference(ripple.startTime).inMilliseconds;
      if (elapsedMs < 1400) {
        final progress = elapsedMs / 1400.0; // 0.0 -> 1.0
        final radius = progress * 160.0; // Expand up to 160px
        final opacity = (1.0 - progress) * 0.45; // Fade out

        // Outer ripple ring
        final ripplePaint = Paint()
          ..color = const Color(0xFF00E5FF).withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 * (1.0 - progress * 0.6);

        canvas.drawCircle(ripple.center, radius, ripplePaint);

        // Secondary inner echo ring
        if (progress > 0.2) {
          final innerRadius = (progress - 0.2) / 0.8 * 120.0;
          final innerOpacity = (1.0 - progress) * 0.30;
          final innerPaint = Paint()
            ..color = const Color(0xFF48CAE4).withOpacity(innerOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2;
          canvas.drawCircle(ripple.center, innerRadius, innerPaint);
        }
      }
    }
  }

  void _drawWave(
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
      ..strokeWidth = strokeWidth;

    final path = Path();
    path.moveTo(0, baseY + amplitude * math.sin(phase));

    for (double x = 0; x <= size.width; x += 10.0) {
      final y = baseY + amplitude * math.sin((x / wavelength * 2 * math.pi) + phase);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaterFlowPainter oldDelegate) => true;
}
