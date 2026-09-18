import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'glass_container.dart';

/// Real-time FPS overlay widget that calculates actual frame refresh rate
/// and displays it in a subtle cyberpunk floating glass badge in Debug Mode.
class FpsOverlay extends StatefulWidget {
  final Widget child;

  const FpsOverlay({super.key, required this.child});

  @override
  State<FpsOverlay> createState() => _FpsOverlayState();
}

class _FpsOverlayState extends State<FpsOverlay> {
  int _fps = 0;
  int _frameCount = 0;
  DateTime _lastTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      SchedulerBinding.instance.addPostFrameCallback(_onFrame);
    }
  }

  void _onFrame(Duration timeStamp) {
    if (!mounted) return;

    _frameCount++;
    final now = DateTime.now();
    final elapsedMs = now.difference(_lastTime).inMilliseconds;

    // Calculate every 500ms for smooth readable FPS reading
    if (elapsedMs >= 500) {
      final currentFps = ((_frameCount * 1000) / elapsedMs).round();
      setState(() {
        _fps = currentFps;
        _frameCount = 0;
        _lastTime = now;
      });
    }

    // Schedule next frame measurement
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  @override
  Widget build(BuildContext context) {
    // Only show overlay in debug mode
    if (!kDebugMode) {
      return widget.child;
    }

    Color badgeColor;
    if (_fps >= 100) {
      badgeColor = const Color(0xFF00E5FF); // Neon Cyan for 120 FPS
    } else if (_fps >= 55) {
      badgeColor = const Color(0xFF10B981); // Emerald Green for 60 FPS
    } else {
      badgeColor = const Color(0xFFEF4444); // Red
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 6,
          right: 16,
          child: IgnorePointer(
            child: GlassContainer(
              borderRadius: 10,
              blur: 10,
              opacity: 0.25,
              color: Colors.black.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              border: Border.all(
                color: badgeColor.withOpacity(0.6),
                width: 1.0,
              ),
              shadows: [
                BoxShadow(
                  color: badgeColor.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$_fps FPS',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: badgeColor,
                      letterSpacing: 0.5,
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
