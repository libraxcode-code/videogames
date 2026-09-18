import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/game_entity.dart';

class GameCardWidget extends StatelessWidget {
  final GameEntity game;
  final VoidCallback? onTap;

  const GameCardWidget({
    super.key,
    required this.game,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: GlassContainer(
          borderRadius: 20,
          blur: 14,
          opacity: isDark ? 0.07 : 0.65,
          onTap: onTap,
          padding: const EdgeInsets.all(12.0),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.8),
            width: 1.2,
          ),
          child: Row(
            children: [
              // Cover image with subtle glow shadow & rounded corners
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? const Color(0xFF00E5FF).withOpacity(0.12)
                          : AppColors.primary.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    game.imageUrl,
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                    cacheWidth: 164,
                    cacheHeight: 164,
                    errorBuilder: (_, __, ___) => Container(
                      width: 82,
                      height: 82,
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : AppColors.primaryLight,
                      child: const Icon(
                        Icons.videogame_asset_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Game Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title & Rating Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            game.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimaryLight,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Glass Star Rating Chip
                        GlassContainer(
                          borderRadius: 8,
                          blur: 8,
                          opacity: 0.15,
                          color: AppColors.warning.withOpacity(0.15),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.35),
                            width: 0.8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                game.rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Genre Pill Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF00E5FF).withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF00E5FF).withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.15),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        game.genre,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF00E5FF)
                              : AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Description text
                    Text(
                      game.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
