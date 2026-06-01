import 'dart:math' as math;
import 'package:flutter/material.dart';

class IslamicPatternPainter extends CustomPainter {
  final Color color;
  const IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Subtle Background Geometric Grid
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.015)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    const spacing = 80.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawOctagram(canvas, Offset(x, y), 24, gridPaint);
      }
    }

    // 2. Center Mandala (Behind Logo)
    final mandalaPaint = Paint()
      ..color = color.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    _drawMandala(canvas, Offset(size.width / 2, size.height * 0.38), mandalaPaint);

    // 3. Corner Ornaments (Top and Bottom)
    final cornerPaint = Paint()
      ..color = color.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    
    // Top Left
    _drawCorner(canvas, Offset.zero, 1, 1, cornerPaint);
    // Top Right
    _drawCorner(canvas, Offset(size.width, 0), -1, 1, cornerPaint);
    // Bottom Left
    _drawCorner(canvas, Offset(0, size.height), 1, -1, cornerPaint);
    // Bottom Right
    _drawCorner(canvas, Offset(size.width, size.height), -1, -1, cornerPaint);

    // 4. Hanging Lanterns on Left and Right sides
    final lanternPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    
    _drawHangingLantern(canvas, Offset(size.width * 0.15, size.height * 0.22), lanternPaint);
    _drawHangingLantern(canvas, Offset(size.width * 0.85, size.height * 0.22), lanternPaint);
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

  void _drawCorner(Canvas canvas, Offset origin, double scaleX, double scaleY, Paint paint) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scaleX, scaleY);

    // Concentric arcs
    for (double r in [30.0, 50.0, 75.0]) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: r),
        0,
        math.pi / 2,
        false,
        paint,
      );
    }

    // Radial lines
    for (int i = 1; i < 6; i++) {
      final angle = (i * 15) * math.pi / 180;
      canvas.drawLine(
        Offset(20 * math.cos(angle), 20 * math.sin(angle)),
        Offset(75 * math.cos(angle), 75 * math.sin(angle)),
        paint,
      );
    }

    // Little solid decorations
    final fillPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    _drawMiniDiamond(canvas, Offset(85 * math.cos(math.pi / 4), 85 * math.sin(math.pi / 4)), 4, fillPaint);
    _drawMiniDiamond(canvas, Offset(85 * math.cos(math.pi / 6), 85 * math.sin(math.pi / 6)), 3, fillPaint);
    _drawMiniDiamond(canvas, Offset(85 * math.cos(math.pi / 3), 85 * math.sin(math.pi / 3)), 3, fillPaint);

    canvas.restore();
  }

  void _drawMiniDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size, center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHangingLantern(Canvas canvas, Offset position, Paint paint) {
    // Draw hanging chain
    canvas.drawLine(Offset(position.dx, 0), Offset(position.dx, position.dy - 35), paint);

    // Lantern top cap
    final capPath = Path();
    capPath.moveTo(position.dx - 12, position.dy - 35);
    capPath.lineTo(position.dx + 12, position.dy - 35);
    capPath.lineTo(position.dx, position.dy - 46);
    capPath.close();
    canvas.drawPath(capPath, paint);

    // Lantern body shape
    final bodyPath = Path();
    bodyPath.moveTo(position.dx - 12, position.dy - 35);
    bodyPath.lineTo(position.dx + 12, position.dy - 35);
    bodyPath.lineTo(position.dx + 18, position.dy - 10);
    bodyPath.lineTo(position.dx + 8, position.dy + 12);
    bodyPath.lineTo(position.dx - 8, position.dy + 12);
    bodyPath.lineTo(position.dx - 18, position.dy - 10);
    bodyPath.close();

    // Fill lantern with a very soft semi-transparent color for glass look
    final fillPaint = Paint()
      ..color = paint.color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, paint);

    // Inner candle glow representation
    final glowPaint = Paint()
      ..color = paint.color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(position.dx, position.dy - 12), 4, glowPaint);

    // Bottom tassel
    final tasselPath = Path();
    tasselPath.moveTo(position.dx, position.dy + 12);
    tasselPath.lineTo(position.dx - 5, position.dy + 26);
    tasselPath.lineTo(position.dx + 5, position.dy + 26);
    tasselPath.close();
    canvas.drawPath(tasselPath, paint);
  }

  void _drawMandala(Canvas canvas, Offset center, Paint paint) {
    // Concentric circles with dashes or dots
    canvas.drawCircle(center, 155, paint);

    final thinPaint = Paint()
      ..color = paint.color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    // 16-point star
    final starPath = Path();
    const points = 16;
    for (int i = 0; i < points * 2; i++) {
      final angle = i * math.pi / points;
      final r = (i % 2 == 0) ? 145.0 : 110.0;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, thinPaint);

    // Outer octagram ring
    final starPath2 = Path();
    for (int i = 0; i < 16; i++) {
      final angle = i * math.pi / 8 + math.pi / 16;
      final r = (i % 2 == 0) ? 95.0 : 70.0;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        starPath2.moveTo(x, y);
      } else {
        starPath2.lineTo(x, y);
      }
    }
    starPath2.close();
    canvas.drawPath(starPath2, paint);

    // Inner concentric details
    final outerRingPaint = Paint()
      ..color = paint.color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = paint.strokeWidth;
    canvas.drawCircle(center, 180, outerRingPaint);
    canvas.drawCircle(center, 60, thinPaint);
  }

  @override
  bool shouldRepaint(IslamicPatternPainter old) => old.color != color;
}
