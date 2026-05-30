import 'package:flutter/material.dart';

class PulseWaveIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const PulseWaveIcon({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  State<PulseWaveIcon> createState() => _PulseWaveIconState();
}

class _PulseWaveIconState extends State<PulseWaveIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Wave 1
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_controller.value * 0.8),
              child: Opacity(
                opacity: (1.0 - _controller.value).clamp(0.0, 1.0),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.2),
                  ),
                ),
              ),
            );
          },
        ),
        // Wave 2
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = (_controller.value + 0.5) % 1.0;
            return Transform.scale(
              scale: 1.0 + (value * 0.8),
              child: Opacity(
                opacity: (1.0 - value).clamp(0.0, 1.0),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.15),
                  ),
                ),
              ),
            );
          },
        ),
        // Central icon container
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.1),
          ),
          child: Icon(
            widget.icon,
            size: 36,
            color: widget.color,
          ),
        ),
      ],
    );
  }
}
