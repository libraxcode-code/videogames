import 'package:flutter/material.dart';

/// Poster thumbnail widget displayed before the video is initialized or as background.
class TrailerPosterWidget extends StatelessWidget {
  final String? posterUrl;
  final Color accentColor;

  const TrailerPosterWidget({
    super.key,
    this.posterUrl,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (posterUrl != null && posterUrl!.isNotEmpty) {
      return Image.network(
        posterUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFF141724),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF141724),
          child: const Center(
            child: Icon(Icons.videocam_off, color: Colors.white24, size: 40),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF141724),
      child: const Center(
        child: Icon(Icons.movie_outlined, color: Colors.white24, size: 48),
      ),
    );
  }
}
