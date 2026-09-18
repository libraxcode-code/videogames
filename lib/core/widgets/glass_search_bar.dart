import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'glass_container.dart';

/// Reusable Glassmorphism Search Text Field for games with clear button, prefix icon, and glowing border.
class GlassSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final FocusNode? focusNode;

  const GlassSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onClear,
    this.hintText = 'Search favorite games...',
    this.focusNode,
  });

  @override
  State<GlassSearchBar> createState() => _GlassSearchBarState();
}

class _GlassSearchBarState extends State<GlassSearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      borderRadius: 16,
      opacity: isDark ? 0.08 : 0.6,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      border: Border.all(
        color: isDark
            ? AppColors.primary.withOpacity(0.3)
            : AppColors.primary.withOpacity(0.2),
        width: 1.2,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isDark ? const Color(0xFF00E5FF) : AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: widget.focusNode,
              onChanged: widget.onChanged,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? Colors.white.withOpacity(0.4)
                      : AppColors.textSecondaryLight.withOpacity(0.7),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_hasText)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
                widget.onClear?.call();
              },
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
            ),
        ],
      ),
    );
  }
}
