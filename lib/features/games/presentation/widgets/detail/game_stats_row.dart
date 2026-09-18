import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/glass_container.dart';
import '../../../domain/entities/game_entity.dart';

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
        // 1. Metascore Card (if available)
        if (game.metacritic > 0) ...[
          Expanded(
            child: SizedBox(
              height: 76,
              child: GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                border: Border.all(
                  color: metacriticColor.withOpacity(0.5),
                  width: 1.2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${game.metacritic}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: metacriticColor,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'METASCORE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],

        // 2. RAWG Rating Card
        Expanded(
          child: SizedBox(
            height: 76,
            child: GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: 3),
                      Text(
                        game.rating > 0 ? game.rating.toStringAsFixed(1) : 'N/A',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      if (game.rating > 0)
                        const Padding(
                          padding: EdgeInsets.only(top: 4, left: 1),
                          child: Text(
                            '/5',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'RATING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 3. Release Date Card
        Expanded(
          child: SizedBox(
            height: 76,
            child: GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: Color(0xFF00E5FF),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _formatReleaseDate(game.releaseDate),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'RELEASE DATE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
