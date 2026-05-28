import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../constants/r.dart';

class CustomLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const CustomLoader({
    super.key,
    this.size = 80.0,
    this.color,
  });

  @override
  State<CustomLoader> createState() => _CustomLoaderState();

  // Full-screen loader display helpers
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, {String? message}) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Semi-transparent backdrop with blur
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: R.color.bg2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: R.color.goldDim.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: R.color.gold.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomLoader(size: 70),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: R.textStyle.medium(
                          color: R.color.goldLight,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _CustomLoaderState extends State<CustomLoader> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? R.color.gold;
    final size = widget.size;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating outer ring with gradient dots
          RotationTransition(
            turns: _rotationController,
            child: CustomPaint(
              size: Size(size, size),
              painter: _OuterRingPainter(color: activeColor),
            ),
          ),
          // Pulsing Rub el Hizb (Islamic 8-pointed star) in the center
          ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.05).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              width: size * 0.45,
              height: size * 0.45,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _RubElHizbPainter(color: activeColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OuterRingPainter extends CustomPainter {
  final Color color;

  _OuterRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - paint.strokeWidth) / 2;

    // Draw three arcs forming an elegant spinning pattern
    for (int i = 0; i < 3; i++) {
      final startAngle = (i * 120) * math.pi / 180;
      const sweepAngle = 70 * math.pi / 180;
      
      paint.color = color.withValues(alpha: (1.0 - (i * 0.25)));
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RubElHizbPainter extends CustomPainter {
  final Color color;

  _RubElHizbPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;
    final double cx = width / 2;
    final double cy = height / 2;

    final path = Path();
    
    // Draw an Islamic 8-pointed star (Rub el Hizb)
    // It consists of two overlapping squares, one rotated 45 degrees.
    // We can generate the 8 vertices of the star.
    final double r1 = width / 2; // Outer radius
    final double r2 = r1 * 0.707; // Inner radius (for points indentation if drawing star path)
    
    // An elegant way is to draw the overlapping squares or draw the polygon
    for (int i = 0; i < 8; i++) {
      double angle = i * math.pi / 4;
      double x = cx + r1 * math.cos(angle);
      double y = cy + r1 * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // Indent point between vertices to make it look like a Rub el Hizb star
      double midAngle = angle + math.pi / 8;
      double mx = cx + r2 * math.cos(midAngle);
      double my = cy + r2 * math.sin(midAngle);
      path.lineTo(mx, my);
    }
    path.close();
    canvas.drawPath(path, paint);

    // Draw inner gold-accented circle
    final innerPaint = Paint()
      ..color = R.color.bg2
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r1 * 0.45, innerPaint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r1 * 0.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
