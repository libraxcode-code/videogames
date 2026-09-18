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

class _GameDetailPageState extends State<GameDetailPage> {
  late GameEntity _game;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _game = widget.initialGame;
    _fetchDetail();
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
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Cyberpunk Background Ambient Mesh Glows
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withOpacity(isDark ? 0.22 : 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C4DFF).withOpacity(isDark ? 0.20 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
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
                backgroundColor: isDark ? const Color(0xFF090D16) : Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GlassContainer(
                    borderRadius: 14,
                    blur: 14,
                    opacity: 0.2,
                    padding: EdgeInsets.zero,
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: isDark ? Colors.white : Colors.black87,
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
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 20,
                                    color: isDark ? const Color(0xFF00E5FF) : AppColors.primary,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _game.releaseDate,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
