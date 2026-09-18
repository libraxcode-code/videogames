import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/constants/app_colors.dart';
import 'trailer/trailer_header_widget.dart';
import 'trailer/trailer_player_controls.dart';
import 'trailer/trailer_poster_widget.dart';
import 'trailer/trailer_progress_bar.dart';
import 'trailer/trailer_youtube_fallback.dart';

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
    final badgeColor = hasOfficialMovie ? cyberCyan : youtubeRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Section Header
        TrailerHeaderWidget(
          hasOfficialMovie: hasOfficialMovie,
          badgeColor: badgeColor,
        ),
        const SizedBox(height: 10),

        // 2. Video Screen Container
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
                // Background: Active Video Player or Poster Thumbnail
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
                  TrailerPosterWidget(
                    posterUrl: widget.trailerPreview ?? widget.fallbackImageUrl,
                    accentColor: cyberCyan,
                  ),

                // Ambient Shadow Overlay for Controls Contrast
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

                // Interactive Controls (Play/Pause/Spinner or YouTube Fallback)
                if (hasOfficialMovie)
                  TrailerPlayerControls(
                    isLoading: _isLoading,
                    hasError: _hasError,
                    isInitialized: _isInitialized,
                    showControls: _showControls,
                    isPlaying: _controller?.value.isPlaying ?? false,
                    onPlay: _startPlaying,
                    onTogglePlayPause: _togglePlayPause,
                    accentColor: cyberCyan,
                    primaryColor: AppColors.primary,
                  )
                else
                  TrailerYoutubeFallback(
                    onLaunchYouTube: _launchYouTubeTrailer,
                    youtubeRed: youtubeRed,
                  ),

                // Bottom Progress Bar & Scrubbing
                if (hasOfficialMovie && _isInitialized && _controller != null && _showControls)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 8,
                    child: TrailerProgressBar(
                      controller: _controller!,
                      playedColor: cyberCyan,
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
