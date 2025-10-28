// lib/core/widgets/animated_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;
  final bool isActive;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.isActive = false,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> {
  bool _isPressed = false;

  void _handleTap() {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
    widget.onPressed();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: widget.tooltip,
      icon: Icon(
        widget.icon,
        color: widget.isActive 
            ? (widget.color ?? Theme.of(context).colorScheme.primary)
            : null,
      ),
      onPressed: _handleTap,
    )
        .animate(target: _isPressed ? 1 : 0)
        .scale(begin: const Offset(1, 1), end: const Offset(0.85, 0.85));
  }
}

class PulseButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool enabled;

  const PulseButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      child: child,
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 2000.ms, delay: 1000.ms);
  }
}
