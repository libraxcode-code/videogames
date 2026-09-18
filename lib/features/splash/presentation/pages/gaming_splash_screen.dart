import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../features/games/presentation/pages/game_list_page.dart';

class GamingSplashScreen extends StatefulWidget {
  const GamingSplashScreen({super.key});

  @override
  State<GamingSplashScreen> createState() => _GamingSplashScreenState();
}

class _GamingSplashScreenState extends State<GamingSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotationController;
  late final AnimationController _fadeController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 120 FPS high-refresh physics controllers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubicEmphasized),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    // Auto navigate to main page after 3.2 seconds
    Future<void>.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const GameListPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Cyberpunk subtle mesh background gradient
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: [
                  Color(0xFF161F36),
                  Color(0xFF090D16),
                  Colors.black,
                ],
              ),
            ),
          ),

          // Animated particle aura behind the logo
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                painter: _NeonRingsPainter(
                  rotation: _rotationController.value * 2 * math.pi,
                  glowIntensity: _glowAnimation.value,
                ),
              );
            },
          ),

          // Center branding content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated controller image with pulsing glow
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withOpacity(
                                  0.45 * _glowAnimation.value,
                                ),
                                blurRadius: 42,
                                spreadRadius: 6,
                              ),
                              BoxShadow(
                                color: const Color(0xFF7C4DFF).withOpacity(
                                  0.35 * _glowAnimation.value,
                                ),
                                blurRadius: 65,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(36),
                            child: Image.asset(
                              'assets/images/app_icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 38),

                  // Title with glowing gradient text
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF00E5FF),
                        Color(0xFF80D8FF),
                        Color(0xFFB388FF),
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'VIDEOGAMES',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Cyberpunk subtitle
                  Text(
                    'ULTIMATE GAME LIBRARY',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom glowing linear progress bar
          Positioned(
            left: 48,
            right: 48,
            bottom: 60,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 3,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.lerp(
                              const Color(0xFF00E5FF),
                              const Color(0xFFB388FF),
                              _glowAnimation.value,
                            )!,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'INITIALIZING ENGINE...',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: const Color(0xFF00E5FF).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonRingsPainter extends CustomPainter {
  final double rotation;
  final double glowIntensity;

  _NeonRingsPainter({required this.rotation, required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 35);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Outer rotating dashed cyber ring
    paint.color = const Color(0xFF00E5FF).withOpacity(0.3 * glowIntensity);
    paint.strokeWidth = 2.0;

    const outerRadius = 115.0;
    const segments = 4;
    const sweepAngle = math.pi / 3;

    for (int i = 0; i < segments; i++) {
      final startAngle = rotation + (i * (2 * math.pi / segments));
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Inner counter-rotating ring
    paint.color = const Color(0xFFB388FF).withOpacity(0.35 * glowIntensity);
    paint.strokeWidth = 1.8;

    const innerRadius = 96.0;
    const innerSegments = 3;
    const innerSweep = math.pi / 2;

    for (int i = 0; i < innerSegments; i++) {
      final startAngle = -rotation * 1.5 + (i * (2 * math.pi / innerSegments));
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        innerSweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NeonRingsPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
