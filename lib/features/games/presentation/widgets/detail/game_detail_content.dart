import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/glass_container.dart';
import '../../../domain/entities/game_entity.dart';
import 'game_trailer_player.dart';

/// Game detail content sections: Genres, Official Trailer, Description, and Credits/Publishers.
class GameDetailContent extends StatelessWidget {
  final GameEntity game;

  const GameDetailContent({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Genres
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
          children: game.genre.split(' • ').map((genre) {
            return GlassContainer(
              borderRadius: 10,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                genre,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00E5FF),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),

        // 2. Official Trailer Player (Opsi 1) with seamless YouTube Fallback (Opsi 3)
        GameTrailerPlayer(
          gameTitle: game.title,
          trailerUrl: game.trailerUrl,
          trailerPreview: game.trailerPreview,
          fallbackImageUrl: game.imageUrl,
        ),
        const SizedBox(height: 22),

        // 2. Description
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
            game.description,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ),
        const SizedBox(height: 22),

        // 3. Extra Details: Developers, Publishers, Platforms
        if (game.developers.isNotEmpty || game.publishers.isNotEmpty) ...[
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
                if (game.developers.isNotEmpty) ...[
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
                    game.developers.join(', '),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                ],
                if (game.publishers.isNotEmpty) ...[
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
                    game.publishers.join(', '),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
