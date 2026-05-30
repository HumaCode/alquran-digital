import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/r.dart';
import '../controllers/arah_kiblat_controller.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';

class ArahKiblatView extends StatefulWidget {
  const ArahKiblatView({super.key});

  @override
  State<ArahKiblatView> createState() => _ArahKiblatViewState();
}

class _ArahKiblatViewState extends State<ArahKiblatView>
    with SingleTickerProviderStateMixin {
  final ArahKiblatController controller = Get.find<ArahKiblatController>();
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.bgJadwal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: R.color.goldLight),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Arah Kiblat',
          style: TextStyle(
            color: R.color.goldLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location_rounded, color: R.color.goldLight),
            onPressed: () => controller.refreshLocation(),
            tooltip: 'Segarkan Lokasi',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(child: _GeoBg()),

          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CustomLoader(size: 60),
              );
            }

            final hasCompass = controller.isCompassAvailable.value;
            final isFacing = controller.isFacingQibla;
            final deviation = controller.qiblaDeviation;

            // Manage pulse animation based on alignment
            if (hasCompass && isFacing) {
              if (!_pulseCtrl.isAnimating) {
                _pulseCtrl.repeat(reverse: true);
              }
            } else {
              if (_pulseCtrl.isAnimating) {
                _pulseCtrl.stop();
              }
            }

            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Status Bar Alignment
                      _buildStatusIndicator(hasCompass, isFacing, deviation),
                      const SizedBox(height: 32),

                      // Interactive Compass Display
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulsing green glow when aligned
                            if (hasCompass && isFacing)
                              AnimatedBuilder(
                                animation: _pulseCtrl,
                                builder: (context, child) {
                                  return Container(
                                    width: 250 + (_pulseCtrl.value * 25),
                                    height: 250 + (_pulseCtrl.value * 25),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: R.color.emeraldLight.withOpacity(0.12 * (1.0 - _pulseCtrl.value)),
                                      border: Border.all(
                                        color: R.color.emeraldLight.withOpacity(0.25 * (1.0 - _pulseCtrl.value)),
                                        width: 1.5,
                                      ),
                                    ),
                                  );
                                },
                              ),

                            // Main Compass
                            Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: R.color.surfaceJadwal,
                                border: Border.all(
                                  color: (hasCompass && isFacing)
                                      ? R.color.emeraldLight.withOpacity(0.6)
                                      : R.color.goldDim.withOpacity(0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (hasCompass && isFacing)
                                        ? R.color.emerald.withOpacity(0.15)
                                        : Colors.black.withOpacity(0.3),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CustomPaint(
                                painter: _QiblaCompassDetailedPainter(
                                  dialAngle: hasCompass ? -controller.deviceHeading.value * math.pi / 180.0 : 0.0,
                                  needleAngle: hasCompass
                                      ? (controller.qiblaDirection.value - controller.deviceHeading.value) * math.pi / 180.0
                                      : 0.0,
                                  isAligned: hasCompass && isFacing,
                                  goldColor: R.color.gold,
                                  goldDim: R.color.goldDim,
                                  emerald: R.color.emerald,
                                  emeraldLight: R.color.emeraldLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Orientation Guide Text
                      _buildGuideText(hasCompass, isFacing, deviation),
                      const SizedBox(height: 36),

                      // Location & Distance Cards
                      _buildInfoCards(),
                      const SizedBox(height: 24),

                      // Compass Calibration Notice
                      _buildCalibrationNotice(),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool hasCompass, bool isFacing, double deviation) {
    if (!hasCompass) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: R.color.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: R.color.error.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: R.color.error, size: 16),
            const SizedBox(width: 8),
            Text(
              'Sensor Kompas Tidak Tersedia',
              style: TextStyle(
                color: R.color.error,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (isFacing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: R.color.emerald.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: R.color.emeraldLight.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: R.color.emeraldLight, size: 16),
            const SizedBox(width: 8),
            Text(
              'Menghadap Kiblat',
              style: TextStyle(
                color: R.color.emeraldLight,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: R.color.gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: R.color.goldDim.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rotate_right_rounded, color: R.color.goldLight, size: 16),
          const SizedBox(width: 8),
          Text(
            'Mencari Kiblat...',
            style: TextStyle(
              color: R.color.goldLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideText(bool hasCompass, bool isFacing, double deviation) {
    if (!hasCompass) {
      return Text(
        'HP Anda tidak mendukung sensor orientasi kompas.\nGunakan derajat arah kiblat di bawah sebagai panduan visual.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: R.color.textMuted,
          fontSize: 12.5,
          height: 1.5,
        ),
      );
    }

    if (isFacing) {
      return Column(
        children: [
          Text(
            'Kiblat Sejajar!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: R.color.emeraldLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Perangkat Anda telah diarahkan dengan benar menuju Ka\'bah.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: R.color.textSoft,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    final devAbs = deviation.abs().toStringAsFixed(0);
    final directionStr = deviation > 0 ? 'Kanan' : 'Kiri';
    final arrowIcon = deviation > 0 ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(arrowIcon, color: R.color.goldLight, size: 18),
            const SizedBox(width: 8),
            Text(
              'Putar ke $directionStr $devAbs°',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: R.color.goldLight,
              ),
            ),
            const SizedBox(width: 8),
            Icon(arrowIcon, color: R.color.goldLight, size: 18),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Putar perlahan sampai indikator berubah menjadi hijau.',
          style: TextStyle(
            color: R.color.textMuted,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoDetailCard(
                icon: Icons.my_location_rounded,
                title: 'Lokasi Anda',
                subtitle: controller.cityName.value,
                desc: controller.provinceName.value,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoDetailCard(
                icon: Icons.mosque_rounded,
                title: 'Jarak ke Kakbah',
                subtitle: '${controller.distanceToKaaba.value.toStringAsFixed(0)} km',
                desc: 'Makkah Al-Mukarramah',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCoordCard(),
      ],
    );
  }

  Widget _buildInfoDetailCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: R.color.surfaceJadwal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: R.color.goldDim.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: R.color.goldLight, size: 20),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: R.color.textMuted, fontSize: 10, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: R.color.textSoft,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: TextStyle(color: R.color.textMuted, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCoordCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: R.color.surfaceJadwal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: R.color.goldDim.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.explore_outlined, color: R.color.goldLight, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sudut & Koordinat GPS',
                  style: TextStyle(color: R.color.textMuted, fontSize: 10, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Kiblat: ${controller.qiblaDirection.value.toStringAsFixed(1)}° N',
                      style: TextStyle(color: R.color.textSoft, fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    _buildDotSeparator(),
                    Text(
                      'Lat: ${controller.currentLatitude.value.toStringAsFixed(4)}',
                      style: TextStyle(color: R.color.textSoft, fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    _buildDotSeparator(),
                    Text(
                      'Lon: ${controller.currentLongitude.value.toStringAsFixed(4)}',
                      style: TextStyle(color: R.color.textSoft, fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotSeparator() {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: R.color.textMuted.withOpacity(0.5),
      ),
    );
  }

  Widget _buildCalibrationNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: R.color.surface2Jadwal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: R.color.goldDim.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: R.color.goldDim, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pegang HP secara datar/horizontal dan hindari benda logam atau magnetik di sekitar Anda. Jika arah kompas melenceng, lakukan kalibrasi kompas dengan memutar HP membentuk pola angka 8.',
              style: TextStyle(
                color: R.color.textMuted,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeoBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GeoBgPainter());
  }
}

class _GeoBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = R.color.goldDim.withOpacity(0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const sp = 60.0;
    const r = 20.0;
    for (double x = 0; x < size.width + sp; x += sp) {
      for (double y = 0; y < size.height + sp; y += sp) {
        final path = Path();
        for (int i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final px = x + r * math.cos(a);
          final py = y + r * math.sin(a);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _QiblaCompassDetailedPainter extends CustomPainter {
  final double dialAngle;
  final double needleAngle;
  final bool isAligned;
  final Color goldColor;
  final Color goldDim;
  final Color emerald;
  final Color emeraldLight;

  _QiblaCompassDetailedPainter({
    required this.dialAngle,
    required this.needleAngle,
    required this.isAligned,
    required this.goldColor,
    required this.goldDim,
    required this.emerald,
    required this.emeraldLight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 12;

    // 1. Draw Dial (rotates by dialAngle)
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(dialAngle);

    // Outer Dial Ring
    final dialRing = Paint()
      ..color = isAligned ? emeraldLight.withOpacity(0.4) : goldDim.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset.zero, r, dialRing);

    // Ticks (graduations)
    final tickPaint = Paint()
      ..color = isAligned ? emeraldLight.withOpacity(0.5) : goldDim.withOpacity(0.4)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 72; i++) {
      final a = i * math.pi / 36;
      final isMajor = i % 6 == 0;
      final len = isMajor ? 12.0 : 6.0;
      canvas.drawLine(
        Offset((r - len) * math.cos(a), (r - len) * math.sin(a)),
        Offset(r * math.cos(a), r * math.sin(a)),
        tickPaint,
      );
    }

    // Direction Cardinal Labels (U, S, B, T)
    final labels = ['U', 'T', 'S', 'B']; // N, E, S, W
    final angles = [math.pi * 3 / 2, 0.0, math.pi / 2, math.pi];
    for (int i = 0; i < 4; i++) {
      final labelAngle = angles[i];
      final labelDist = r - 26.0;
      final lx = labelDist * math.cos(labelAngle);
      final ly = labelDist * math.sin(labelAngle);

      final isNorth = i == 0;
      final labelStyle = TextStyle(
        color: isNorth 
            ? (isAligned ? emeraldLight : goldColor)
            : goldDim.withOpacity(0.7),
        fontWeight: FontWeight.bold,
        fontSize: isNorth ? 14 : 11,
      );

      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }

    // Secondary degree numbers (e.g. 30, 60, 120, etc.)
    for (int i = 1; i < 12; i++) {
      if (i % 3 == 0) continue; // Skip cardinal directions
      final a = (i * 30 - 90) * math.pi / 180.0;
      final numDist = r - 25.0;
      final nx = numDist * math.cos(a);
      final ny = numDist * math.sin(a);

      final tp = TextPainter(
        text: TextSpan(
          text: '${i * 30}',
          style: TextStyle(
            color: goldDim.withOpacity(0.35),
            fontSize: 7.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(nx - tp.width / 2, ny - tp.height / 2));
    }

    canvas.restore();

    // 2. Draw Needle (rotates by needleAngle)
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(needleAngle);

    // Glow needle shadow
    final needleGlow = Paint()
      ..color = isAligned ? emeraldLight.withOpacity(0.4) : goldColor.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final glowPath = Path()
      ..moveTo(0, -(r - 30))
      ..lineTo(-9, -15)
      ..lineTo(9, -15)
      ..close();
    canvas.drawPath(glowPath, needleGlow);

    // Qibla needle (North / Kaaba pointer)
    final needleColor = Paint()..color = isAligned ? emeraldLight : goldColor;
    final topNeedle = Path()
      ..moveTo(0, -(r - 28))
      ..lineTo(-7, -10)
      ..lineTo(7, -10)
      ..close();
    canvas.drawPath(topNeedle, needleColor);

    // Bottom pointer (South)
    final bottomPointer = Paint()..color = goldDim.withOpacity(0.35);
    final botNeedle = Path()
      ..moveTo(0, r - 28)
      ..lineTo(-5, 10)
      ..lineTo(5, 10)
      ..close();
    canvas.drawPath(botNeedle, bottomPointer);

    // Central joint rings
    canvas.drawCircle(Offset.zero, 12, Paint()..color = goldDim.withOpacity(0.2));
    canvas.drawCircle(Offset.zero, 7, Paint()..color = isAligned ? emeraldLight : goldColor);
    canvas.drawCircle(Offset.zero, 3, Paint()..color = const Color(0xFF090F0C));

    // Miniatur ikon Ka'bah hitam di ujung atas jarum kiblat
    final kabahPaint = Paint()
      ..color = const Color(0xFF0C0C0C)
      ..style = PaintingStyle.fill;
    final goldLine = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.save();
    canvas.translate(0, -(r - 20));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-9, -9, 18, 18),
        const Radius.circular(2),
      ),
      kabahPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-9, -9, 18, 18),
        const Radius.circular(2),
      ),
      goldLine,
    );

    // Gold Kiswah line on Kaaba icon
    final kiswahPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(-9, -3), const Offset(9, -3), kiswahPaint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(_QiblaCompassDetailedPainter old) =>
      old.dialAngle != dialAngle ||
      old.needleAngle != needleAngle ||
      old.isAligned != isAligned;
}
