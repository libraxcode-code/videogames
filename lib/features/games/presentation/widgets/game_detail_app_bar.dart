import 'package:flutter/material.dart';
import '../../domain/entities/game_entity.dart';

/// Reusable Cyberpunk Glass SliverAppBar with hero banner and back button.
class GameDetailAppBar extends StatelessWidget {
  final GameEntity game;

  const GameDetailAppBar({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
              game.imageUrl,
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
            // Top & Bottom Gradient Shadows for contrast & readability
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.60),
                    Colors.transparent,
                    const Color(0xFF060910),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Title & PS5 Exclusive badge overlay
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
                    game.title,
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
    );
  }
}
