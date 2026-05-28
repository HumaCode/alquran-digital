import 'package:flutter/material.dart';

class HomePatternPainter extends CustomPainter {
  final Color color;
  const HomePatternPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    const sp = 60.0;
    for (double x = 0; x < size.width + sp; x += sp) {
      for (double y = 0; y < size.height + sp; y += sp) {
        canvas.drawCircle(Offset(x, y), 20, paint);
        canvas.drawCircle(Offset(x, y), 28, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
