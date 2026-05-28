import 'dart:math' as math;
import 'package:flutter/material.dart';

class IslamicPatternPainter extends CustomPainter {
  final Color color;
  const IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    const spacing = 80.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawOctagram(canvas, Offset(x, y), 28, paint);
      }
    }
  }

  void _drawOctagram(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Inner rotated square
    final path2 = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 + math.pi / 4;
      final x = center.dx + r * 0.6 * math.cos(angle);
      final y = center.dy + r * 0.6 * math.sin(angle);
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(IslamicPatternPainter old) => old.color != color;
}
