import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(const FetchGamesEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.gamepad_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Featured Games',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Force Refresh Data',
            onPressed: () {
              context.read<GameBloc>().add(
                    const FetchGamesEvent(forceRefresh: true),
                  );
            },
          ),
        ],
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state is GameLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is GameErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
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
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<GameBloc>().add(
                              const FetchGamesEvent(forceRefresh: true),
                            );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is GameLoadedState) {
            if (state.games.isEmpty) {
              return const Center(
                child: Text('Belum ada data game.'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<GameBloc>().add(
                      const FetchGamesEvent(forceRefresh: true),
                    );
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                itemExtent: 116,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.games.length,
                itemBuilder: (context, index) {
                  final game = state.games[index];
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
    );
  }
}
