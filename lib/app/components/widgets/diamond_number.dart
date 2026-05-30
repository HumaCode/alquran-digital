import 'package:flutter/material.dart';
import '../../constants/r.dart';

class DiamondNumberPainter extends CustomPainter {
  final int number;
  final Color color;
  final Color textColor;
  const DiamondNumberPainter({
    required this.number,
    required this.color,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.46;

    final path = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r, cy)
      ..lineTo(cx, cy + r)
      ..lineTo(cx - r, cy)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);

    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: R.textStyle.small(
          color: textColor,
          fontWeight: FontWeight.w700,
        ).copyWith(
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(DiamondNumberPainter old) => old.number != number;
}

class DiamondNumber extends StatelessWidget {
  final int number;
  final Color color;
  final Color textColor;
  final double size;

  const DiamondNumber({
    super.key,
    required this.number,
    required this.color,
    required this.textColor,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size, size),
        painter: DiamondNumberPainter(
          number: number,
          color: color,
          textColor: textColor,
        ),
      ),
    );
  }
}
