import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/game_entity.dart';

/// Quick statistics row: Metacritic metascore, RAWG rating, and release date.
class GameStatsRow extends StatelessWidget {
  final GameEntity game;

  const GameStatsRow({
    super.key,
    required this.game,
  });

  Color _getMetacriticColor(int score) {
    if (score >= 75) return const Color(0xFF10B981); // Emerald green
    if (score >= 50) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
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

  @override
  Widget build(BuildContext context) {
    final metacriticColor = _getMetacriticColor(game.metacritic);

    return Row(
      children: [
        // 1. Metascore Card
        if (game.metacritic > 0) ...[
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
                    '${game.metacritic}',
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
          const SizedBox(width: 10),
        ],

        // 2. RAWG Rating Card
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
                      '${game.rating}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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

        // 3. Release Date Card
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
                  _formatReleaseDate(game.releaseDate),
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
    );
  }
}
