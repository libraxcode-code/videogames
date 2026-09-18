import 'package:flutter/material.dart';

/// Top header banner for the trailer player displaying icon, title, and streaming badge.
class TrailerHeaderWidget extends StatelessWidget {
  final bool hasOfficialMovie;
  final Color badgeColor;

  const TrailerHeaderWidget({
    super.key,
    required this.hasOfficialMovie,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          hasOfficialMovie ? Icons.movie_creation_outlined : Icons.smart_display_rounded,
          size: 16,
          color: badgeColor,
        ),
        const SizedBox(width: 8),
        Text(
          hasOfficialMovie ? 'OFFICIAL TRAILER' : 'GAME TRAILER',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: badgeColor.withOpacity(0.4),
              width: 0.8,
            ),
          ),
          child: Text(
            hasOfficialMovie ? 'HD IN-APP STREAM' : 'YOUTUBE PREVIEW',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: badgeColor,
            ),
          ),
        ),
      ],
    );
  }
}
