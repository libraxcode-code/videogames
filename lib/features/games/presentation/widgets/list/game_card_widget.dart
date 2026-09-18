import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/glass_container.dart';
import '../../../domain/entities/game_entity.dart';

class GameCardWidget extends StatelessWidget {
  final GameEntity game;
  final VoidCallback? onTap;
  final Animation<double>? animation;

  const GameCardWidget({
    super.key,
    required this.game,
    this.onTap,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Metacritic badge color helper (Green >= 75, Yellow >= 50, Red < 50)
    Color metacriticColor;
    if (game.metacritic >= 75) {
      metacriticColor = const Color(0xFF10B981); // Emerald Green
    } else if (game.metacritic >= 50) {
      metacriticColor = const Color(0xFFF59E0B); // Amber
    } else {
      metacriticColor = const Color(0xFFEF4444); // Red
    }

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: GlassContainer(
          borderRadius: 22,
          blur: 16,
          opacity: isDark ? 0.08 : 0.70,
          onTap: onTap,
          padding: const EdgeInsets.all(12.0),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.12)
                : Colors.white.withOpacity(0.85),
            width: 1.2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Precise Square 100x100 Container with Center Crop Fill
              SizedBox(
                width: 100,
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF00E5FF).withOpacity(0.28)
                          : AppColors.primary.withOpacity(0.2),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(isDark ? 0.16 : 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      game.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: isDark ? const Color(0xFF161F36) : const Color(0xFFE2E8F0),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark ? const Color(0xFF1E293B) : AppColors.primaryLight,
                        child: const Icon(
                          Icons.videogame_asset_rounded,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // 2. Game Info (Title, Metacritic, Release Date, Genre)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title & Metacritic Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Expanded(
                          child: Text(
                            game.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              letterSpacing: 0.2,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Metacritic Score Badge (Requirement 2.4)
                        if (game.metacritic > 0)
                          GlassContainer(
                            borderRadius: 8,
                            blur: 6,
                            color: metacriticColor.withOpacity(0.18),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            border: Border.all(
                              color: metacriticColor.withOpacity(0.55),
                              width: 1.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.speed_rounded,
                                  size: 12,
                                  color: metacriticColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${game.metacritic}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    color: metacriticColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Release Date (Requirement 2.2) & PS5 Tag
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF003791), Color(0xFF0070D1)],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'PS5',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          game.releaseDate,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Genre Tag with Cyber Glass Look
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF00E5FF).withOpacity(0.12)
                            : AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF00E5FF).withOpacity(0.28)
                              : AppColors.primary.withOpacity(0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        game.genre,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF00E5FF)
                              : AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
