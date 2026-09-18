import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Progress bar and duration timestamp display for video playback.
class TrailerProgressBar extends StatelessWidget {
  final VideoPlayerController controller;
  final Color playedColor;

  const TrailerProgressBar({
    super.key,
    required this.controller,
    required this.playedColor,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          _formatDuration(controller.value.position),
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: playedColor,
              bufferedColor: Colors.white24,
              backgroundColor: Colors.white12,
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatDuration(controller.value.duration),
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
