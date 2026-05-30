import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/imsakiyah_model.dart';
import '../../../data/providers/database_helper.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';
import 'package:alquran_digital/app/constants/r.dart';
import '../controllers/imsakiyah_controller.dart';

class ImsakiyahView extends GetView<ImsakiyahController> {
  const ImsakiyahView({super.key});

  void _showLocationBottomSheet(BuildContext context) {
    controller.searchQuery.value = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: R.color.bgJadwal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Obx(() {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: R.color.bgJadwal,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(color: R.color.goldDim.withOpacity(0.15)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: R.color.textMutedJadwal.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      R.string.selectLocation,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: R.color.goldLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close_rounded, color: R.color.textMutedJadwal, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await controller.detectLocation();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [R.color.emerald, R.color.emeraldLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: R.color.emerald.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          R.string.autoDetectLocation,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  R.string.province,
                  style: TextStyle(fontSize: 12, color: R.color.textMutedJadwal),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: R.color.surface2Jadwal,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: R.color.goldDim.withOpacity(0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.provinsiList.contains(controller.selectedProvinsi.value)
                          ? controller.selectedProvinsi.value
                          : null,
                      isExpanded: true,
                      dropdownColor: R.color.surface2Jadwal,
                      style: TextStyle(color: R.color.textJadwal, fontSize: 14),
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: R.color.goldLight),
                      items: controller.provinsiList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          controller.updateProvince(newVal);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  R.string.searchCity,
                  style: TextStyle(fontSize: 12, color: R.color.textMutedJadwal),
                ),
                const SizedBox(height: 6),
                TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  style: TextStyle(color: R.color.textJadwal, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: R.string.enterCityHint,
                    hintStyle: TextStyle(color: R.color.textMutedJadwal, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: R.color.goldLight, size: 20),
                    filled: true,
                    fillColor: R.color.surface2Jadwal,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: R.color.goldDim.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: R.color.goldDim.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: R.color.gold, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: controller.isCitiesLoading.value
                      ? const Center(child: CustomLoader(size: 40))
                      : Obx(() {
                          final list = controller.filteredKabKotaList;
                          if (list.isEmpty) {
                            return Center(
                              child: Text(
                                R.string.cityNotFound,
                                style: TextStyle(color: R.color.textMutedJadwal),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (context, idx) {
                              final city = list[idx];
                              final isSelected = controller.selectedKabKota.value == city;
                              return Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  dense: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  tileColor: isSelected ? R.color.emerald.withOpacity(0.1) : Colors.transparent,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  title: Text(
                                    city,
                                    style: TextStyle(
                                      color: isSelected ? R.color.emeraldLight : R.color.textJadwal,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle_rounded, color: R.color.emeraldLight, size: 16)
                                      : null,
                                  onTap: () {
                                    controller.updateCity(city);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          );
                        }),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.bgJadwal,
      body: Stack(
        children: [
          // Background ornaments
          Positioned.fill(child: _GeoBg()),

          SafeArea(
            child: Obx(() {
              final isDataLoading = controller.isLoading.value && controller.imsakiyahData.value == null;
              final errorMsg = controller.errorMessage.value;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_rounded, color: R.color.goldLight),
                            onPressed: () => Get.back(),
                          ),
                          Column(
                            children: [
                              Text(
                                R.string.imsakiyahTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: R.color.goldLight,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () => _showLocationBottomSheet(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on_rounded, color: R.color.emeraldLight, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      controller.selectedKabKota.value,
                                      style: TextStyle(
                                        color: R.color.textMutedJadwal,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_down_rounded, color: R.color.goldDim, size: 14),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.my_location_rounded, color: R.color.emeraldLight),
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              await controller.detectLocation();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isDataLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CustomLoader(size: 60),
                      ),
                    )
                  else if (errorMsg.isNotEmpty && controller.imsakiyahData.value == null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                errorMsg,
                                style: TextStyle(color: R.color.textMutedJadwal),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: R.color.emerald,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => controller.fetchImsakiyahData(),
                                child: Text(R.string.tryAgain, style: const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Hijri & Gregorian Year Banner
                            _YearBanner(data: controller.imsakiyahData.value!.data),
                            const SizedBox(height: 24),

                            // 2. Today's highlight cards
                            _TodayHighlight(data: controller.imsakiyahData.value!.data),
                            const SizedBox(height: 28),

                            // 3. Timetable title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  R.string.timetableMonth,
                                  style: TextStyle(
                                    color: R.color.goldLight,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.swipe_left_rounded, color: R.color.goldDim.withOpacity(0.6), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      R.string.swipeHorizontal,
                                      style: TextStyle(color: R.color.textMutedJadwal, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // 4. Monthly Timetable Table
                            _TimetableTable(data: controller.imsakiyahData.value!.data),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Widget Banner Tahun Hijriah & Masehi
class _YearBanner extends StatelessWidget {
  final Data data;
  const _YearBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: R.color.surfaceJadwal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: R.color.goldDim.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: R.color.emerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.calendar_month_rounded, color: R.color.emeraldLight, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahun Hijriah: ${data.hijriah}',
                  style: TextStyle(
                    color: R.color.goldLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tahun Masehi: ${data.masehi}',
                  style: TextStyle(
                    color: R.color.textMutedJadwal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Sorotan Waktu Imsak & Maghrib Hari Ini
class _TodayHighlight extends StatelessWidget {
  final Data data;
  const _TodayHighlight({required this.data});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayIndex = data.imsakiyah.indexWhere((e) => e.tanggal == now.day);
    final today = todayIndex != -1 ? data.imsakiyah[todayIndex] : data.imsakiyah.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fokus Utama Hari Ini (Tanggal ${today.tanggal})',
          style: TextStyle(
            color: R.color.textMutedJadwal,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _HighlightCard(
                title: R.string.imsak,
                waktu: today.imsak,
                subtitle: R.string.startFasting,
                icon: Icons.timer_rounded,
                startColor: R.color.emerald,
                endColor: R.color.emeraldLight,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _HighlightCard(
                title: R.string.breakFast,
                waktu: today.maghrib,
                subtitle: R.string.maghrib,
                icon: Icons.brightness_3_rounded,
                startColor: R.color.goldDim,
                endColor: R.color.goldLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String waktu;
  final String subtitle;
  final IconData icon;
  final Color startColor;
  final Color endColor;

  const _HighlightCard({
    required this.title,
    required this.waktu,
    required this.subtitle,
    required this.icon,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor.withOpacity(0.85), endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Icon(icon, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            waktu,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 26,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Tabel Imsakiyah Bulanan
class _TimetableTable extends StatelessWidget {
  final Data data;
  const _TimetableTable({required this.data});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: R.color.surfaceJadwal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: R.color.goldDim.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: IntrinsicWidth(
          child: Table(
            defaultColumnWidth: const FixedColumnWidth(68),
            columnWidths: const {
              0: FixedColumnWidth(44), // Tanggal
            },
            children: [
              // Header
              TableRow(
                decoration: BoxDecoration(
                  color: R.color.emerald.withOpacity(0.15),
                  border: Border(
                    bottom: BorderSide(color: R.color.goldDim.withOpacity(0.3), width: 1.5),
                  ),
                ),
                children: [
                  _TableHeaderCell(text: R.string.dateShort),
                  _TableHeaderCell(text: R.string.imsak),
                  _TableHeaderCell(text: R.string.subuh),
                  _TableHeaderCell(text: R.string.terbit),
                  _TableHeaderCell(text: R.string.dhuha),
                  _TableHeaderCell(text: R.string.dzuhur),
                  _TableHeaderCell(text: R.string.ashar),
                  _TableHeaderCell(text: R.string.maghrib),
                  _TableHeaderCell(text: R.string.isya),
                ],
              ),

              // Rows
              ...data.imsakiyah.map((element) {
                final isToday = element.tanggal == now.day;
                final rowBgColor = isToday
                    ? R.color.emerald.withOpacity(0.15)
                    : (element.tanggal % 2 == 0
                        ? R.color.surface2Jadwal.withOpacity(0.5)
                        : Colors.transparent);

                return TableRow(
                  decoration: BoxDecoration(
                    color: rowBgColor,
                    border: Border(
                      bottom: BorderSide(
                        color: isToday ? R.color.goldDim : R.color.goldDim.withOpacity(0.06),
                        width: isToday ? 1.5 : 0.8,
                      ),
                    ),
                  ),
                  children: [
                    _TableCell(text: element.tanggal.toString(), isBold: true, isToday: isToday),
                    _TableCell(text: element.imsak, isToday: isToday, isFeatured: true),
                    _TableCell(text: element.subuh, isToday: isToday),
                    _TableCell(text: element.terbit, isToday: isToday),
                    _TableCell(text: element.dhuha, isToday: isToday),
                    _TableCell(text: element.dzuhur, isToday: isToday),
                    _TableCell(text: element.ashar, isToday: isToday),
                    _TableCell(text: element.maghrib, isToday: isToday, isFeatured: true),
                    _TableCell(text: element.isya, isToday: isToday),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  const _TableHeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: R.color.goldLight,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isBold;
  final bool isToday;
  final bool isFeatured;

  const _TableCell({
    required this.text,
    this.isBold = false,
    required this.isToday,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    Color txtColor = R.color.textJadwal;
    if (isToday) {
      txtColor = R.color.isDark ? Colors.white : R.color.textJadwal;
    } else if (isFeatured) {
      txtColor = R.color.emeraldLight;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: txtColor,
            fontSize: 11.5,
            fontWeight: (isBold || isToday || isFeatured) ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
      ..color = R.color.goldDim.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    const sp = 70.0;
    const r = 24.0;
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

        final path2 = Path();
        for (int i = 0; i < 4; i++) {
          final a = i * math.pi / 2 + math.pi / 4;
          final px = x + r * 0.55 * math.cos(a);
          final py = y + r * 0.55 * math.sin(a);
          if (i == 0) {
            path2.moveTo(px, py);
          } else {
            path2.lineTo(px, py);
          }
        }
        path2.close();
        canvas.drawPath(path2, paint);

        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
