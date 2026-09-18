import 'package:flutter/material.dart';

/// Interactive fallback action button when an official RAWG trailer is not available.
/// Opens YouTube search results for the game trailer.
class TrailerYoutubeFallback extends StatelessWidget {
  final VoidCallback onLaunchYouTube;
  final Color youtubeRed;

  const TrailerYoutubeFallback({
    super.key,
    required this.onLaunchYouTube,
    this.youtubeRed = const Color(0xFFFF0033),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onLaunchYouTube,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: youtubeRed,
              boxShadow: [
                BoxShadow(
                  color: youtubeRed.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onLaunchYouTube,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: youtubeRed.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_new_rounded, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Watch Trailer on YouTube',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
