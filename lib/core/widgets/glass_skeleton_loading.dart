import 'package:flutter/material.dart';
import 'glass_container.dart';

/// Reusable Glassmorphism Skeleton Loading item with smooth shimmering pulse animation.
class GlassSkeletonItem extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const GlassSkeletonItem({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  State<GlassSkeletonItem> createState() => _GlassSkeletonItemState();
}

class _GlassSkeletonItemState extends State<GlassSkeletonItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _shimmerAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        final shimmerValue = _shimmerAnimation.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.04 + (shimmerValue * 0.05)),
                      const Color(0xFF00E5FF).withOpacity(0.06 + (shimmerValue * 0.09)),
                      Colors.white.withOpacity(0.04 + (shimmerValue * 0.05)),
                    ]
                  : [
                      Colors.black.withOpacity(0.04 + (shimmerValue * 0.04)),
                      const Color(0xFF6366F1).withOpacity(0.07 + (shimmerValue * 0.08)),
                      Colors.black.withOpacity(0.04 + (shimmerValue * 0.04)),
                    ],
            ),
          ),
        );
      },
    );
  }
}

/// Card skeleton loading placeholder matching GameCardWidget dimensions.
class GameCardSkeletonWidget extends StatelessWidget {
  const GameCardSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassContainer(
        borderRadius: 22,
        blur: 16,
        opacity: isDark ? 0.06 : 0.65,
        padding: const EdgeInsets.all(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.8),
          width: 1.2,
        ),
        child: Row(
          children: [
            // Square image skeleton (100 x 100)
            const GlassSkeletonItem(
              width: 100,
              height: 100,
              borderRadius: 16,
            ),
            const SizedBox(width: 14),

            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: GlassSkeletonItem(
                          height: 16,
                          borderRadius: 6,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const GlassSkeletonItem(
                        width: 44,
                        height: 24,
                        borderRadius: 8,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const GlassSkeletonItem(
                    width: 120,
                    height: 14,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: 10),
                  const GlassSkeletonItem(
                    width: 80,
                    height: 18,
                    borderRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
