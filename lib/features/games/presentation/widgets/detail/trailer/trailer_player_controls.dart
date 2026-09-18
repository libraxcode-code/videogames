import 'package:flutter/material.dart';

/// Overlay action buttons for in-app video playback (Play, Pause, Loading spinner, Retry).
class TrailerPlayerControls extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final bool isInitialized;
  final bool showControls;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onTogglePlayPause;
  final Color accentColor;
  final Color primaryColor;

  const TrailerPlayerControls({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.isInitialized,
    required this.showControls,
    required this.isPlaying,
    required this.onPlay,
    required this.onTogglePlayPause,
    required this.accentColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.6),
        ),
        padding: const EdgeInsets.all(16),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
        ),
      );
    }

    if (hasError) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
          const SizedBox(height: 6),
          const Text(
            'Failed to load trailer stream',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onPlay,
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Try Again', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor.withOpacity(0.2),
              foregroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      );
    }

    if (!isInitialized) {
      return GestureDetector(
        onTap: onPlay,
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                accentColor.withOpacity(0.9),
                primaryColor.withOpacity(0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.black,
              size: 42,
            ),
          ),
        ),
      );
    }

    if (showControls) {
      return GestureDetector(
        onTap: onTogglePlayPause,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.55),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
