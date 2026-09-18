import 'package:flutter/material.dart';
import '../../../../../core/widgets/glass_skeleton_loading.dart';
import '../../../domain/entities/game_entity.dart';
import 'game_card_widget.dart';

/// Scrollable game list content supporting pull-to-refresh, infinite scroll pagination,
/// and smooth page navigation transitions.
class GameListView extends StatelessWidget {
  final List<GameEntity> games;
  final bool hasReachedMax;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final ValueChanged<GameEntity> onGameTap;

  const GameListView({
    super.key,
    required this.games,
    required this.hasReachedMax,
    required this.scrollController,
    required this.onRefresh,
    required this.onGameTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = games.length + (hasReachedMax ? 0 : 1);

    return RefreshIndicator(
      color: const Color(0xFF00E5FF),
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 20),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Bottom loading slot during pagination
          if (index >= games.length) {
            return const GameCardSkeletonWidget();
          }

          final game = games[index];
          return GameCardWidget(
            key: ValueKey(game.id),
            game: game,
            onTap: () => onGameTap(game),
          );
        },
      ),
    );
  }
}
