import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/glass_container.dart';

/// Cyberpunk-styled On-Demand Game Trailer Player with Opsi 3 YouTube Fallback.
///
/// CRITICAL REQUIREMENT:
/// 1. Does NOT download or buffer the video stream automatically on view load.
/// 2. Only initializes [VideoPlayerController] when the user explicitly taps the play button.
/// 3. If no official RAWG movie is found (trailerUrl is null or empty), it seamlessly
///    provides Option 3: "Watch Trailer on YouTube" deep-link / launch.
class GameTrailerPlayer extends StatefulWidget {
  final String? trailerUrl;
  final String? trailerPreview;
  final String gameTitle;
  final String? fallbackImageUrl;

  const GameTrailerPlayer({
    super.key,
    required this.gameTitle,
    this.trailerUrl,
    this.trailerPreview,
    this.fallbackImageUrl,
  });

  @override
  State<GameTrailerPlayer> createState() => _GameTrailerPlayerState();
}

class _GameTrailerPlayerState extends State<GameTrailerPlayer> {
  static const Color cyberCyan = Color(0xFF00E5FF);
  static const Color youtubeRed = Color(0xFFFF0033);

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
    if (widget.trailerUrl == null || widget.trailerUrl!.isEmpty) return;

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
        Uri.parse(widget.trailerUrl!),
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

  Future<void> _launchYouTubeTrailer() async {
    final query = Uri.encodeComponent('${widget.gameTitle} PS5 official trailer');
    final youtubeUri = Uri.parse('https://www.youtube.com/results?search_query=$query');

    try {
      final launched = await launchUrl(
        youtubeUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(youtubeUri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      // Graceful fallback to default browser
      await launchUrl(youtubeUri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasOfficialMovie = widget.trailerUrl != null && widget.trailerUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              hasOfficialMovie ? Icons.movie_creation_outlined : Icons.smart_display_rounded,
              size: 16,
              color: hasOfficialMovie ? cyberCyan : youtubeRed,
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
                color: (hasOfficialMovie ? cyberCyan : youtubeRed).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: (hasOfficialMovie ? cyberCyan : youtubeRed).withOpacity(0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                hasOfficialMovie ? 'HD IN-APP STREAM' : 'YOUTUBE PREVIEW',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: hasOfficialMovie ? cyberCyan : youtubeRed,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Container Card
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            height: 200,
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
                // 1. Video Player or Poster Image
                if (hasOfficialMovie && _isInitialized && _controller != null && _controller!.value.isInitialized)
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
                else
                  _buildPosterImage(),

                // Dark gradient overlay for visual depth & control readability
                if (!_isInitialized || _showControls)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.65),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 2. Action Buttons & UI Overlays
                if (hasOfficialMovie)
                  _buildOfficialMovieAction()
                else
                  _buildYouTubeFallbackAction(),

                // 3. Bottom Progress Bar (for official in-app stream)
                if (hasOfficialMovie && _isInitialized && _controller != null && _showControls)
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

  Widget _buildPosterImage() {
    final posterUrl = widget.trailerPreview ?? widget.fallbackImageUrl;
    if (posterUrl != null && posterUrl.isNotEmpty) {
      return Image.network(
        posterUrl,
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
      );
    }

    return Container(
      color: const Color(0xFF141724),
      child: const Center(
        child: Icon(Icons.movie_outlined, color: Colors.white24, size: 48),
      ),
    );
  }

  Widget _buildOfficialMovieAction() {
    if (_isLoading) {
      return Container(
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
      );
    }

    if (_hasError) {
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
      );
    }

    if (!_isInitialized) {
      return GestureDetector(
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
      );
    }

    if (_showControls) {
      return GestureDetector(
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
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildYouTubeFallbackAction() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _launchYouTubeTrailer,
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
          onTap: _launchYouTubeTrailer,
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
