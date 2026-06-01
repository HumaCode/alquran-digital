import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeOrnamentPainter extends CustomPainter {
  final Color color;
  final bool isDarkMode;

  const HomeOrnamentPainter({
    required this.color,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Gambar Bulan Sabit & Bintang yang Anggun di tengah atas
    final moonCenter = Offset(size.width * 0.48, size.height * 0.35);
    final moonRadius = 24.r;
    
    // Glow di belakang bulan sabit
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(isDarkMode ? 0.15 : 0.08),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius * 2.5))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(moonCenter, moonRadius * 2.5, glowPaint);

    final moonPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Path bulan sabit
    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    final cutPath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(moonCenter.dx - 8.w, moonCenter.dy - 4.h),
        radius: moonRadius - 1.r,
      ));
    
    final finalMoonPath = Path.combine(PathOperation.difference, moonPath, cutPath);
    canvas.drawPath(finalMoonPath, moonPaint);

    // Bintang kecil di dekat bulan sabit
    final starCenter = Offset(moonCenter.dx - 12.w, moonCenter.dy + 4.h);
    _drawStar(canvas, starCenter, 5, 5.r, 2.r, color.withOpacity(0.6));

    // 2. Gambar Lentera Gantung (Hanging Lanterns)
    // Lentera Kiri
    _drawLantern(
      canvas,
      Offset(size.width * 0.26, 45.h), // Posisi gantungan di batas atas
      25.h, // Panjang tali gantungan
      18.w, // Lebar lentera
      28.h, // Tinggi lentera
    );

    // Lentera Kanan
    _drawLantern(
      canvas,
      Offset(size.width * 0.68, 45.h),
      32.h,
      20.w,
      32.h,
    );

    // 3. Gambar Bintang-Bintang Kecil yang Bertebaran
    final stars = [
      Offset(size.width * 0.14, size.height * 0.32),
      Offset(size.width * 0.38, size.height * 0.22),
      Offset(size.width * 0.62, size.height * 0.38),
      Offset(size.width * 0.88, size.height * 0.26),
    ];
    for (final pos in stars) {
      _drawStar(canvas, pos, 4, 3.r, 1.r, color.withOpacity(0.25));
    }
  }

  void _drawLantern(Canvas canvas, Offset topConnection, double lineLength, double w, double h) {
    final cx = topConnection.dx;
    final cy = topConnection.dy + lineLength + (h / 2);

    // Tali gantungan
    final linePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8.w;
    canvas.drawLine(topConnection, Offset(cx, topConnection.dy + lineLength), linePaint);

    // Glow lentera
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.15),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: w * 1.5))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), w * 1.5, glowPaint);

    // Frame lentera
    final framePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0.w;

    // Path lentera
    final path = Path()
      ..moveTo(cx, cy - h / 2) // Pucuk atas
      ..lineTo(cx + w / 4, cy - h / 3) // Bahu kanan atas
      ..lineTo(cx + w / 2, cy) // Pinggang kanan
      ..lineTo(cx + w / 4, cy + h / 3) // Kaki kanan bawah
      ..lineTo(cx, cy + h / 2) // Ujung bawah
      ..lineTo(cx - w / 4, cy + h / 3)
      ..lineTo(cx - w / 2, cy)
      ..lineTo(cx - w / 4, cy - h / 3)
      ..close();

    canvas.drawPath(path, framePaint);

    // Pembatas horizontal
    canvas.drawLine(Offset(cx - w / 4, cy - h / 3), Offset(cx + w / 4, cy - h / 3), framePaint);
    canvas.drawLine(Offset(cx - w / 4, cy + h / 3), Offset(cx + w / 4, cy + h / 3), framePaint);

    // Detail garis vertikal (leaded glass)
    canvas.drawLine(Offset(cx - w / 6, cy - h / 3), Offset(cx - w / 6, cy + h / 3), framePaint);
    canvas.drawLine(Offset(cx + w / 6, cy - h / 3), Offset(cx + w / 6, cy + h / 3), framePaint);
    canvas.drawLine(Offset(cx, cy - h / 3), Offset(cx, cy + h / 3), framePaint);

    // Manik gantungan kecil di bawah lentera
    final beadPaint = Paint()
      ..color = color.withOpacity(0.55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy + h / 2 + 4.h), 1.5.r, beadPaint);
  }

  void _drawStar(Canvas canvas, Offset center, int points, double outerRadius, double innerRadius, Color starColor) {
    final paint = Paint()
      ..color = starColor
      ..style = PaintingStyle.fill;

    var angle = math.pi / points;
    final path = Path();

    for (var i = 0; i < 2 * points; i++) {
      var r = (i % 2 == 0) ? outerRadius : innerRadius;
      var currAngle = i * angle - math.pi / 2;
      var x = center.dx + r * math.cos(currAngle);
      var y = center.dy + r * math.sin(currAngle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HomeOrnamentPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDarkMode != isDarkMode;
  }
}
