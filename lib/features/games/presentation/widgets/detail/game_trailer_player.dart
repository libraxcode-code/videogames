import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/constants/app_colors.dart';

/// Cyberpunk-styled On-Demand Game Trailer Player.
///
/// CRITICAL REQUIREMENT:
/// Does NOT download or buffer the video stream automatically on view load.
/// Only initializes [VideoPlayerController] and requests video data when the user explicitly taps the play button.
class GameTrailerPlayer extends StatefulWidget {
  final String trailerUrl;
  final String? trailerPreview;

  const GameTrailerPlayer({
    super.key,
    required this.trailerUrl,
    this.trailerPreview,
  });

  @override
  State<GameTrailerPlayer> createState() => _GameTrailerPlayerState();
}

class _GameTrailerPlayerState extends State<GameTrailerPlayer> {
  static const Color cyberCyan = Color(0xFF00E5FF);

  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasError = false;
  bool _showControls = true;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startPlaying() async {
    if (_isInitialized && _controller != null) {
      setState(() {
        _controller!.play();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.trailerUrl),
      );
      _controller = controller;

      await controller.initialize();
      controller.addListener(() {
        if (mounted) setState(() {});
      });

      await controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _showControls = true;
      } else {
        _controller!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.movie_creation_outlined,
              size: 16,
              color: cyberCyan,
            ),
            const SizedBox(width: 8),
            const Text(
              'OFFICIAL TRAILER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            if (_isInitialized)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cyberCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: cyberCyan.withOpacity(0.4),
                    width: 0.8,
                  ),
                ),
                child: const Text(
                  'HD STREAM',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: cyberCyan,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            height: 210,
            decoration: BoxDecoration(
              color: const Color(0xFF0D0F18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Video Player or Preview Poster (Standard Network Image, zero external package requirement)
                if (_isInitialized && _controller != null && _controller!.value.isInitialized)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showControls = !_showControls;
                      });
                    },
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  )
                else if (widget.trailerPreview != null && widget.trailerPreview!.isNotEmpty)
                  Image.network(
                    widget.trailerPreview!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFF141724),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(cyberCyan),
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
                  )
                else
                  Container(
                    color: const Color(0xFF141724),
                    child: const Center(
                      child: Icon(Icons.movie_outlined, color: Colors.white24, size: 48),
                    ),
                  ),

                // Dark subtle gradient overlay for controls readability
                if (!_isInitialized || _showControls)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 2. Center Action Button (Play or Spinner or Error Retry)
                if (_isLoading)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(cyberCyan),
                    ),
                  )
                else if (_hasError)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
                      const SizedBox(height: 6),
                      const Text(
                        'Failed to load trailer',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _startPlaying,
                        icon: const Icon(Icons.refresh, size: 14),
                        label: const Text('Try Again', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cyberCyan.withOpacity(0.2),
                          foregroundColor: cyberCyan,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                    ],
                  )
                else if (!_isInitialized)
                  // On-demand play trigger button
                  GestureDetector(
                    onTap: _startPlaying,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            cyberCyan.withOpacity(0.9),
                            AppColors.primary.withOpacity(0.9),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cyberCyan.withOpacity(0.5),
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
                  )
                else if (_showControls)
                  GestureDetector(
                    onTap: _togglePlayPause,
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
                        _controller!.value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),

                // 3. Bottom Progress Bar & Time
                if (_isInitialized && _controller != null && _showControls)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 8,
                    child: Row(
                      children: [
                        Text(
                          _formatDuration(_controller!.value.position),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: VideoProgressIndicator(
                            _controller!,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: cyberCyan,
                              bufferedColor: Colors.white24,
                              backgroundColor: Colors.white12,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(_controller!.value.duration),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
