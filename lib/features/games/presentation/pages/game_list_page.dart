import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_search_bar.dart';
import '../../../../core/widgets/glass_skeleton_loading.dart';
import '../../domain/usecases/get_game_detail_usecase.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/game_card_widget.dart';
import 'game_detail_page.dart';

class GameListPage extends StatefulWidget {
  const GameListPage({super.key});

  @override
  State<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  late final AnimationController _motionController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _driftAnimation;

  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(const FetchGamesEvent());
    _scrollController.addListener(_onScroll);

    // 120 FPS high-refresh atmospheric motion controller
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _motionController, curve: Curves.easeInOutSine),
    );

    _driftAnimation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(parent: _motionController, curve: Curves.easeInOutCubic),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger infinite scroll pagination 250px before bottom
    if (currentScroll >= (maxScroll - 250)) {
      final state = context.read<GameBloc>().state;
      if (state is GameLoadedState && !state.isLoadingMore && !state.hasReachedMax) {
        context.read<GameBloc>().add(const LoadMoreGamesEvent());
      }
    }
  }

  @override
  void dispose() {
    _motionController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF060910),
      body: Stack(
        children: [
          // 1. High-Contrast Vivid Cyberpunk Gaming Wallpaper with 120 FPS Cinematic Pan & Zoom
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _motionController,
              builder: (context, child) {
                // Smooth Ken-Burns dynamic motion
                final zoom = 1.06 + (0.06 * _pulseAnimation.value);
                final panX = _driftAnimation.value * 0.8;
                final panY = _driftAnimation.value * 0.5;

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

          // 2. Cinematic Dark Cyberpunk Overlay - jelas dan kontras tinggi
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.40),
                    const Color(0xFF060910).withOpacity(0.70),
                    const Color(0xFF060910).withOpacity(0.92),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 3. Living 120 FPS Floating Cyberpunk Plasma Orbs (Bergerak Halus)
          AnimatedBuilder(
            animation: _motionController,
            builder: (context, child) {
              final pulse = _pulseAnimation.value;
              final drift = _driftAnimation.value;

              return Stack(
                children: [
                  // Cyan Neon Pulse Orb (Kanan Atas)
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
                              const Color(0xFF00E5FF).withOpacity(0.35),
                              const Color(0xFF0070D1).withOpacity(0.18),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Electric Purple Neon Drift Orb (Kiri Tengah)
                  Positioned(
                    top: 240 - drift,
                    left: -70 + drift,
                    child: Transform.scale(
                      scale: 2.0 - pulse,
                      child: Container(
                        width: 340,
                        height: 340,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF7C4DFF).withOpacity(0.30),
                              const Color(0xFFD500F9).withOpacity(0.14),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Emerald Accent Orb (Kanan Bawah)
                  Positioned(
                    bottom: 40 + drift,
                    right: -50,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF10B981).withOpacity(0.18),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 4. Subtle Cyber Digital Grid
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: CustomPaint(
                painter: _CyberGridPainter(),
              ),
            ),
          ),

          // 5. Main Content Layer
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header with Glass Container
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: GlassContainer(
                    borderRadius: 22,
                    blur: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF003791), Color(0xFF00E5FF)],
                            ),
                          ),
                          child: const Icon(
                            Icons.sports_esports_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'PLAYSTATION 5',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'LIVE API',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Latest Released PS5 Vault • SSL Pinned',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.70)
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          tooltip: 'Refresh Data',
                          onPressed: () {
                            context.read<GameBloc>().add(
                                  FetchGamesEvent(
                                    forceRefresh: true,
                                    searchQuery: _searchController.text.trim(),
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Glass Search Bar connected to BLoC
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: GlassSearchBar(
                    controller: _searchController,
                    hintText: 'Cari game PlayStation 5...',
                    onChanged: (query) {
                      context.read<GameBloc>().add(SearchGamesEvent(query));
                    },
                    onClear: () {
                      context.read<GameBloc>().add(const SearchGamesEvent(''));
                    },
                  ),
                ),

                const SizedBox(height: 6),

                // Body List Content with Skeleton Loading
                Expanded(
                  child: BlocBuilder<GameBloc, GameState>(
                    builder: (context, state) {
                      // Skeleton Loading View
                      if (state is GameLoadingState) {
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 4, bottom: 20),
                          itemCount: 6,
                          itemBuilder: (context, index) => const GameCardSkeletonWidget(),
                        );
                      }

                      if (state is GameErrorState) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: GlassContainer(
                              padding: const EdgeInsets.all(24.0),
                              borderRadius: 24,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.error,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6366F1),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      context.read<GameBloc>().add(
                                            FetchGamesEvent(
                                              forceRefresh: true,
                                              searchQuery: state.activeQuery,
                                            ),
                                          );
                                    },
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      if (state is GameLoadedState) {
                        if (state.games.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(24),
                                borderRadius: 20,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 48,
                                      color: isDark ? Colors.white38 : Colors.black38,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      state.activeQuery.isEmpty
                                          ? 'Belum ada koleksi game PS5.'
                                          : 'Tidak ada game PS5 untuk "${state.activeQuery}"',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final itemCount = state.games.length + (state.hasReachedMax ? 0 : 1);

                        return RefreshIndicator(
                          color: const Color(0xFF00E5FF),
                          onRefresh: () async {
                            context.read<GameBloc>().add(
                                  FetchGamesEvent(
                                    forceRefresh: true,
                                    searchQuery: state.activeQuery,
                                  ),
                                );
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(top: 4, bottom: 20),
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              // If reaching bottom loader slot
                              if (index >= state.games.length) {
                                return const GameCardSkeletonWidget();
                              }

                              final game = state.games[index];
                              return GameCardWidget(
                                key: ValueKey(game.id),
                                game: game,
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder<void>(
                                      transitionDuration: const Duration(milliseconds: 400),
                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                          GameDetailPage(
                                        initialGame: game,
                                        getGameDetailUseCase:
                                            context.read<GetGameDetailUseCase>(),
                                      ),
                                      transitionsBuilder:
                                          (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
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

class _CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.08)
      ..strokeWidth = 0.5;

    const step = 42.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
