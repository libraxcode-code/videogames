import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_search_bar.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/game_card_widget.dart';

class GameListPage extends StatefulWidget {
  const GameListPage({super.key});

  @override
  State<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(const FetchGamesEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Cyberpunk subtle mesh background gradient bubbles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withOpacity(isDark ? 0.18 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C4DFF).withOpacity(isDark ? 0.16 : 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header with Glass Container
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: GlassContainer(
                    borderRadius: 20,
                    blur: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                            ),
                          ),
                          child: const Icon(
                            Icons.gamepad_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GAME LIBRARY',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                'Discover & explore featured games',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.5)
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
                                  const FetchGamesEvent(forceRefresh: true),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar Widget with Glassmorphism
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: GlassSearchBar(
                    controller: _searchController,
                    hintText: 'Cari judul game atau genre...',
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                    onClear: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                ),

                const SizedBox(height: 6),

                // Body List Content
                Expanded(
                  child: BlocBuilder<GameBloc, GameState>(
                    builder: (context, state) {
                      if (state is GameLoadingState) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                          ),
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
                                            const FetchGamesEvent(forceRefresh: true),
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
                        final filteredGames = _searchQuery.isEmpty
                            ? state.games
                            : state.games.where((game) {
                                final titleMatch = game.title.toLowerCase().contains(_searchQuery);
                                final genreMatch = game.genre.toLowerCase().contains(_searchQuery);
                                return titleMatch || genreMatch;
                              }).toList();

                        if (filteredGames.isEmpty) {
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
                                      _searchQuery.isEmpty
                                          ? 'Belum ada koleksi game.'
                                          : 'Tidak ditemukan game dengan kata kunci "$_searchQuery"',
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

                        return RefreshIndicator(
                          color: const Color(0xFF00E5FF),
                          onRefresh: () async {
                            context.read<GameBloc>().add(
                                  const FetchGamesEvent(forceRefresh: true),
                                );
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(top: 4, bottom: 20),
                            itemCount: filteredGames.length,
                            itemBuilder: (context, index) {
                              final game = filteredGames[index];
                              return GameCardWidget(
                                key: ValueKey(game.id),
                                game: game,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Selected: ${game.title}'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 1),
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
