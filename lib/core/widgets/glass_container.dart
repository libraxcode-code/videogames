import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable Glassmorphism Container with customizable blur, opacity, border, and gradient.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final Gradient? gradient;
  final Color? color;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.12,
    this.borderRadius = 20.0,
    this.padding,
    this.margin,
    this.border,
    this.gradient,
    this.color,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBorder = border ??
        Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.65),
          width: 1.2,
        );

    final defaultGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(opacity * 1.5),
                  Colors.white.withOpacity(opacity * 0.4),
                ]
              : [
                  Colors.white.withOpacity(0.85),
                  Colors.white.withOpacity(0.45),
                ],
        );

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.35)
                    : const Color(0xFF6366F1).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              gradient: color == null ? defaultGradient : null,
              borderRadius: BorderRadius.circular(borderRadius),
              border: defaultBorder,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
