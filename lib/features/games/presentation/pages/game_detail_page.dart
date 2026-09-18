import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/usecases/get_game_detail_usecase.dart';

class GameDetailPage extends StatefulWidget {
  final GameEntity initialGame;
  final GetGameDetailUseCase getGameDetailUseCase;

  const GameDetailPage({
    super.key,
    required this.initialGame,
    required this.getGameDetailUseCase,
  });

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage>
    with SingleTickerProviderStateMixin {
  late GameEntity _game;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _motionController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _driftAnimation;

  @override
  void initState() {
    super.initState();
    _game = widget.initialGame;
    _fetchDetail();

    // 120 FPS motion controller for living atmospheric background in detail page
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.75, end: 1.25).animate(
      CurvedAnimation(parent: _motionController, curve: Curves.easeInOutQuad),
    );

    _driftAnimation = Tween<double>(begin: -30.0, end: 30.0).animate(
      CurvedAnimation(parent: _motionController, curve: Curves.easeInOutQuad),
    );
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  String _formatReleaseDate(String dateStr) {
    if (dateStr.isEmpty || dateStr.toLowerCase() == 'tba') {
      return 'TBA';
    }
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = int.tryParse(parts[1]) ?? 1;
        final day = int.tryParse(parts[2]) ?? 1;
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final monthName = (month >= 1 && month <= 12) ? months[month - 1] : parts[1];
        return '$day $monthName $year';
      }
    } catch (_) {}
    return dateStr;
  }

  Future<void> _fetchDetail() async {
    final result = await widget.getGameDetailUseCase(_game.id);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _isLoading = false;
        _errorMessage = failure.message;
      }),
      (detailedGame) => setState(() {
        _isLoading = false;
        _game = detailedGame;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color metacriticColor;
    if (_game.metacritic >= 75) {
      metacriticColor = const Color(0xFF10B981);
    } else if (_game.metacritic >= 50) {
      metacriticColor = const Color(0xFFF59E0B);
    } else {
      metacriticColor = const Color(0xFFEF4444);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF060910),
      body: Stack(
        children: [
          // 1. Living Cyberpunk Dynamic Background with Pan & Zoom
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _motionController,
              builder: (context, child) {
                final zoom = 1.08 + (0.10 * _pulseAnimation.value);
                final panX = _driftAnimation.value * 1.2;
                final panY = _driftAnimation.value * 0.7;

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

          // 2. High-contrast Dark Cyberpunk Overlay
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
            animation: _motionController,
            builder: (context, child) {
              final drift = _driftAnimation.value;
              final pulse = _pulseAnimation.value;

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
              animation: _motionController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.22,
                  child: CustomPaint(
                    painter: _DetailCyberGridPainter(
                      offsetX: _driftAnimation.value * 0.8,
                      offsetY: _driftAnimation.value * 0.5,
                    ),
                  ),
                );
              },
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Cyberpunk Glass Sliver App Bar with Background Image
              SliverAppBar(
                expandedHeight: 330.0,
                pinned: true,
                stretch: true,
                backgroundColor: const Color(0xFF060910),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withOpacity(0.4),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _game.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF161F36),
                          child: const Icon(
                            Icons.videogame_asset_rounded,
                            size: 64,
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                      ),
                      // Top & Bottom Gradient Shadows for readability
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                              isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // Title Overlay at the bottom of the header
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF003791).withOpacity(0.85),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF29B6F6)),
                              ),
                              child: const Text(
                                'PLAYSTATION 5 EXCLUSIVE & COMPATIBLE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _game.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Body Details in Glassmorphism Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats Row (Metacritic, Rating, Release Date)
                      Row(
                        children: [
                          if (_game.metacritic > 0)
                            Expanded(
                              child: GlassContainer(
                                borderRadius: 16,
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                border: Border.all(
                                  color: metacriticColor.withOpacity(0.4),
                                  width: 1.2,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${_game.metacritic}',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: metacriticColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'METASCORE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_game.metacritic > 0) const SizedBox(width: 10),
                          Expanded(
                            child: GlassContainer(
                              borderRadius: 16,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 22),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_game.rating}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'RAWG RATING',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GlassContainer(
                              borderRadius: 16,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.calendar_month_rounded,
                                    size: 20,
                                    color: Color(0xFF00E5FF),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatReleaseDate(_game.releaseDate),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'RELEASE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Genres
                      const Text(
                        'GENRES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _game.genre.split(' • ').map((genre) {
                          return GlassContainer(
                            borderRadius: 10,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              genre,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF00E5FF) : AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 22),

                      // Description
                      const Text(
                        'ABOUT THIS GAME',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GlassContainer(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _game.description,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.6,
                            color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Extra Details: Developers, Publishers, Platforms
                      if (_game.developers.isNotEmpty || _game.publishers.isNotEmpty) ...[
                        const Text(
                          'GAME CREDITS & PUBLISHERS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GlassContainer(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_game.developers.isNotEmpty) ...[
                                const Text(
                                  'DEVELOPER',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _game.developers.join(', '),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                              ],
                              if (_game.publishers.isNotEmpty) ...[
                                const Text(
                                  'PUBLISHER',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _game.publishers.join(', '),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCyberGridPainter extends CustomPainter {
  final double offsetX;
  final double offsetY;

  const _DetailCyberGridPainter({this.offsetX = 0.0, this.offsetY = 0.0});

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
  bool shouldRepaint(covariant _DetailCyberGridPainter oldDelegate) =>
      oldDelegate.offsetX != offsetX || oldDelegate.offsetY != offsetY;
}
