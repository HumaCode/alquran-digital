import 'dart:math' as math;
import 'package:flutter/material.dart';

class CrescentStarPainter extends CustomPainter {
  final Color color;
  const CrescentStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    // Bulan sabit
    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    final cutPath = Path();
    cutPath.addOval(
      Rect.fromCircle(
        center: Offset(cx + r * 0.5, cy - r * 0.05),
        radius: r * 0.82,
      ),
    );
    final crescent = Path.combine(PathOperation.difference, path, cutPath);
    canvas.drawPath(crescent, paint);

    // Bintang segi enam
    _drawStar(canvas, Offset(cx + r * 0.9, cy - r * 0.5), r * 0.28, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    final path2 = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 60) * math.pi / 180;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    path2.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CrescentStarPainter old) => old.color != color;
}
