import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:alquran_digital/app/routes/app_pages.dart';
import '../../../../app/constants/r.dart';
import '../../../data/models/detail_surah_model.dart';
import '../../home/widgets/diamond_number_painter.dart';
import '../controllers/detail_surah_controller.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';
import '../../../data/providers/theme_controller.dart';

class DetailSurahView extends GetView<DetailSurahController> {
  const DetailSurahView({super.key});

  Color get _bg => R.color.bg1;
  Color get _gold => R.color.gold;
  Color get _goldLight => R.color.goldLight;
  Color get _goldDim => R.color.goldDim;
  Color get _textSoft => R.color.textSoft;
  Color get _bg2 => R.color.bg2;
  Color get _emeraldDark => R.color.emeraldDark;
  Color get _emeraldMedium => R.color.emeraldMedium;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Force dependency on isDarkMode so it rebuilds when theme changes
      ThemeController.to.isDarkMode.value;
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: _goldLight),
            onPressed: () => Get.back(),
          ),
          title: Text(
            controller.detailSurah.value?.data.namaLatin ?? R.string.loading,
            style: R.textStyle.large(
              color: _goldLight,
              fontWeight: FontWeight.bold,
            ).copyWith(fontSize: 20),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  ThemeController.to.isDarkMode.value ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey<bool>(ThemeController.to.isDarkMode.value),
                  color: _goldLight,
                ),
              ),
              tooltip: 'Ubah Tema',
              onPressed: () {
                ThemeController.to.toggleTheme();
              },
            ),
            IconButton(
              icon: Icon(Icons.tune_rounded, color: _goldLight),
              tooltip: 'Pengaturan Tampilan',
              onPressed: () => _showSettingsBottomSheet(context),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CustomLoader(size: 60),
            );
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: R.textStyle.medium(color: _textSoft),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => controller.fetchDetailSurah(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(R.string.tryAgain),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: _bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final detailResponse = controller.detailSurah.value;
          if (detailResponse == null) {
            return Center(
              child: Text(
                R.string.detailSurahNotFound,
                style: R.textStyle.medium(color: _textSoft),
              ),
            );
          }

          final detail = detailResponse.data;

          return ListView(
            controller: controller.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // ── Surah Card Header ──────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_emeraldDark, _emeraldMedium],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: _goldDim.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.08),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Islamic Pattern overlay
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.06,
                          child: CustomPaint(
                            painter: DetailCardPatternPainter(color: _gold),
                          ),
                        ),
                      ),
                      // Card Content
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              detail.namaLatin,
                              style: R.textStyle.large(
                                color: _goldLight,
                                fontWeight: FontWeight.bold,
                              ).copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              detail.arti,
                              style: R.textStyle.medium(
                                color: _textSoft.withValues(alpha: 0.7),
                              ).copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Divider(
                              color: _goldDim.withValues(alpha: 0.3),
                              thickness: 1,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  detail.tempatTurun.toUpperCase(),
                                  style: R.textStyle.small(
                                    color: _goldLight,
                                    fontWeight: FontWeight.w600,
                                  ).copyWith(letterSpacing: 1.5, fontSize: 12),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(Icons.circle, color: _goldDim, size: 6),
                                ),
                                Text(
                                  '${detail.jumlahAyat} AYAT',
                                  style: R.textStyle.small(
                                    color: _goldLight,
                                    fontWeight: FontWeight.w600,
                                  ).copyWith(letterSpacing: 1.5, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Full Surah Audio Player Controls (Gabungan)
                            Obx(() {
                              final isPlaying = controller.isPlayingFullSurah.value;
                              final currentAyat = controller.currentlyPlayingAyat.value;
                              return Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      controller.togglePlayFullSurah();
                                    },
                                    icon: Icon(
                                      isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                      color: const Color(0xFF0D1F17),
                                      size: 20,
                                    ),
                                    label: Text(
                                      isPlaying ? 'JEDA MURATTAL PENUH' : 'PUTAR MURATTAL PENUH',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D1F17),
                                        letterSpacing: 1.2,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _gold,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                  if (isPlaying && currentAyat != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Memutar ayat $currentAyat dari ${detail.jumlahAyat}',
                                      style: R.textStyle.small(
                                        color: _goldLight.withValues(alpha: 0.8),
                                      ).copyWith(fontStyle: FontStyle.italic, fontSize: 12),
                                    ),
                                  ]
                                ],
                              );
                            }),
                            // Beautiful Bismillah (except for Al-Fatihah which has it as verse 1 and At-Tawbah which does not have it)
                            if (detail.nomor != 1 && detail.nomor != 9) ...[
                              const SizedBox(height: 24),
                              Text(
                                R.string.bismillah,
                                textAlign: TextAlign.center,
                                style: R.textStyle.large(
                                  color: _goldLight,
                                ).copyWith(
                                  fontSize: 24,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Ayat List ──────────────────────────────────────────────────
              Obx(() {
                // Force GetX to track changes for settings variables
                final _ = controller.arabicFontSize.value;
                final __ = controller.showLatin.value;
                final ___ = controller.showTranslation.value;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.visibleAyat.length,
                  itemBuilder: (context, index) {
                    final ayat = controller.visibleAyat[index];
                    final key = controller.ayatKeys.putIfAbsent(ayat.nomorAyat, () => GlobalKey());
                    return Padding(
                      key: key,
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _bg2.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _goldDim.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Ayat Header (Number & Action Bar)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _bg2.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    alignment: Alignment.center,
                                    child: CustomPaint(
                                      size: const Size(36, 36),
                                      painter: DiamondNumberPainter(
                                        number: ayat.nomorAyat,
                                        color: _goldDim,
                                        textColor: _goldLight,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Play Audio Button
                                  IconButton(
                                    icon: Obx(() {
                                      final isPlaying = controller.currentlyPlayingAyat.value == ayat.nomorAyat &&
                                          controller.isAudioPlaying.value;
                                      return Icon(
                                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                        color: isPlaying ? _gold : _goldDim,
                                        size: 22,
                                      );
                                    }),
                                    onPressed: () {
                                      controller.togglePlayAudio(ayat);
                                    },
                                  ),
                                  // Tandai Terakhir Dibaca Button
                                  IconButton(
                                    icon: Obx(() => Icon(
                                          controller.lastReadAyatNomor.value == ayat.nomorAyat
                                              ? Icons.bookmark_added_rounded
                                              : Icons.bookmark_add_outlined,
                                          color: controller.lastReadAyatNomor.value == ayat.nomorAyat
                                              ? _gold
                                              : _goldDim,
                                          size: 20,
                                        )),
                                    onPressed: () {
                                      controller.markAsLastRead(
                                        detail.nomor,
                                        detail.namaLatin,
                                        ayat.nomorAyat,
                                      );
                                      CustomToast.show(
                                        context,
                                        message: 'Ayat ${ayat.nomorAyat} ditandai sebagai terakhir dibaca',
                                        type: ToastType.success,
                                      );
                                    },
                                  ),
                                  // Copy Button
                                  IconButton(
                                    icon: Icon(Icons.copy_rounded, color: _goldDim, size: 20),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                        text: '${ayat.teksArab}\n${ayat.teksLatin}\n${ayat.teksIndonesia}',
                                      ));
                                      CustomToast.show(
                                        context,
                                        message: 'Ayat ${ayat.nomorAyat} ${R.string.copySuccess.toLowerCase()}',
                                        type: ToastType.success,
                                      );
                                    },
                                  ),
                                  // Share Button
                                  IconButton(
                                    icon: Icon(Icons.share_rounded, color: _goldDim, size: 20),
                                    onPressed: () {
                                      // Share content (simple copy notification as fallback)
                                      Clipboard.setData(ClipboardData(
                                        text: 'QS. ${detail.namaLatin} [${detail.nomor}:${ayat.nomorAyat}]\n\n'
                                            '${ayat.teksArab}\n\n'
                                            'Artinya: "${ayat.teksIndonesia}"',
                                      ));
                                      CustomToast.show(
                                        context,
                                        message: R.string.shareText,
                                        type: ToastType.success,
                                      );
                                    },
                                  ),
                                  // Tafsir Button
                                  IconButton(
                                    icon: Icon(Icons.menu_book_rounded, color: _goldDim, size: 20),
                                    onPressed: () {
                                      _showTafsirBottomSheet(context, detail, ayat.nomorAyat);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Arabic Text
                            Text(
                              ayat.teksArab,
                              textAlign: TextAlign.right,
                              style: R.textStyle.large(
                                color: _goldLight,
                                fontWeight: FontWeight.w500,
                              ).copyWith(
                                fontFamily: 'Poppins',
                                fontSize: controller.arabicFontSize.value,
                                height: 1.8,
                              ),
                            ),
                            if (controller.showLatin.value || controller.showTranslation.value) ...[
                              const SizedBox(height: 18),
                            ],
                            if (controller.showLatin.value) ...[
                              Text(
                                ayat.teksLatin,
                                textAlign: TextAlign.left,
                                style: R.textStyle.medium(
                                  color: _goldLight.withValues(alpha: 0.9),
                                ).copyWith(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                              if (controller.showTranslation.value) ...[
                                const SizedBox(height: 10),
                              ],
                            ],
                            if (controller.showTranslation.value) ...[
                              Text(
                                ayat.teksIndonesia,
                                textAlign: TextAlign.left,
                                style: R.textStyle.small(
                                  color: _textSoft.withValues(alpha: 0.8),
                                ).copyWith(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),

              // Loading Indicator for Pagination
              Obx(() {
                if (controller.isMoreLoading.value) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(_gold),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 24),

              // ── Elegant Islamic Divider & Sadaqallahul 'Adzim ───────────────────
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: _goldDim.withValues(alpha: 0.2),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.brightness_7_rounded, // Islamic-style star/flower shape
                      color: _goldDim.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: _goldDim.withValues(alpha: 0.2),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'صَدَقَ اللهُ الْعَظِيْمُ',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _goldLight,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '"Maha benar Allah yang Maha Agung"',
                  style: R.textStyle.small(
                    color: _textSoft.withValues(alpha: 0.6),
                  ).copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          );
        }),
      );
    });
  }

  void _showTafsirBottomSheet(BuildContext context, Data detail, int nomorAyat) {
    final Future<String?> tafsirFuture = controller.getAyatTafsir(nomorAyat);

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: _goldDim.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Handle Bar for dragging indicator
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _goldDim.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tafsir QS. ${detail.namaLatin}',
                          style: R.textStyle.medium(
                            color: _goldLight,
                            fontWeight: FontWeight.bold,
                          ).copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ayat ke-$nomorAyat',
                          style: R.textStyle.small(
                            color: _textSoft.withValues(alpha: 0.6),
                          ).copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: _goldDim),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(
              color: _goldDim.withValues(alpha: 0.15),
              thickness: 1,
            ),
            // Content
            Expanded(
              child: FutureBuilder<String?>(
                future: tafsirFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: _gold,
                      ),
                    );
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                      child: Text(
                        'Gagal memuat tafsir ayat ini.',
                        style: R.textStyle.medium(color: _textSoft),
                      ),
                    );
                  }

                  final tafsirText = snapshot.data!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Decorative label and Font Size Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _gold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _goldDim.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Tafsir Wajiz (Kemenag)',
                                style: TextStyle(
                                  color: _goldLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            // Font Size Adjuster
                            Row(
                              children: [
                                Text(
                                  'Ukuran: ',
                                  style: TextStyle(
                                    color: _textSoft.withValues(alpha: 0.5),
                                    fontSize: 11,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(Icons.remove_circle_outline_rounded, color: _goldDim, size: 20),
                                  onPressed: () {
                                    if (controller.tafsirFontSize.value > 12.0) {
                                      controller.tafsirFontSize.value -= 1.0;
                                    }
                                  },
                                ),
                                const SizedBox(width: 6),
                                Obx(() => Text(
                                  '${controller.tafsirFontSize.value.toInt()}',
                                  style: TextStyle(
                                    color: _goldLight,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                )),
                                const SizedBox(width: 6),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(Icons.add_circle_outline_rounded, color: _goldDim, size: 20),
                                  onPressed: () {
                                    if (controller.tafsirFontSize.value < 26.0) {
                                      controller.tafsirFontSize.value += 1.0;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Tafsir Text
                        Obx(() => Text(
                          tafsirText,
                          style: TextStyle(
                            color: _textSoft.withValues(alpha: 0.9),
                            fontSize: controller.tafsirFontSize.value,
                            height: 1.8,
                            fontFamily: 'Poppins',
                          ),
                        )),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: _goldDim.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _goldDim.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pengaturan Tampilan',
                    style: R.textStyle.medium(
                      color: _goldLight,
                      fontWeight: FontWeight.bold,
                    ).copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: _goldDim),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(
                color: _goldDim.withValues(alpha: 0.15),
                thickness: 1,
              ),
              const SizedBox(height: 16),
              
              // Slider for Font Size
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ukuran Font Arab',
                    style: R.textStyle.small(color: _textSoft).copyWith(fontSize: 14),
                  ),
                  Text(
                    '${controller.arabicFontSize.value.toInt()} px',
                    style: TextStyle(
                      color: _goldLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: _gold,
                  inactiveTrackColor: _goldDim.withValues(alpha: 0.2),
                  thumbColor: _goldLight,
                  overlayColor: _goldLight.withValues(alpha: 0.2),
                  valueIndicatorColor: _emeraldDark,
                  valueIndicatorTextStyle: TextStyle(color: _goldLight),
                ),
                child: Slider(
                  value: controller.arabicFontSize.value,
                  min: 20.0,
                  max: 42.0,
                  divisions: 11,
                  label: '${controller.arabicFontSize.value.toInt()}px',
                  onChanged: (value) {
                    controller.arabicFontSize.value = value;
                  },
                ),
              ),
              const SizedBox(height: 12),
              
              // Toggle Latin Text
              SwitchListTile.adaptive(
                title: Text(
                  'Tampilkan Latin',
                  style: R.textStyle.small(color: _textSoft).copyWith(fontSize: 14),
                ),
                activeColor: _gold,
                activeTrackColor: _gold.withValues(alpha: 0.3),
                inactiveThumbColor: _textSoft.withValues(alpha: 0.5),
                inactiveTrackColor: _bg2.withValues(alpha: 0.5),
                value: controller.showLatin.value,
                onChanged: (value) {
                  controller.showLatin.value = value;
                },
              ),
              
              // Toggle Translation Text
              SwitchListTile.adaptive(
                title: Text(
                  'Tampilkan Terjemahan',
                  style: R.textStyle.small(color: _textSoft).copyWith(fontSize: 14),
                ),
                activeColor: _gold,
                activeTrackColor: _gold.withValues(alpha: 0.3),
                inactiveThumbColor: _textSoft.withValues(alpha: 0.5),
                inactiveTrackColor: _bg2.withValues(alpha: 0.5),
                value: controller.showTranslation.value,
                onChanged: (value) {
                  controller.showTranslation.value = value;
                },
              ),
              

              // Qori Selector for Verse Audio
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Qari Ayat',
                      style: R.textStyle.small(color: _textSoft).copyWith(fontSize: 14),
                    ),
                    Obx(() {
                      final currentQoriId = controller.selectedQori.value;
                      return Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: _bg2,
                        ),
                        child: DropdownButton<String>(
                          value: currentQoriId,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _gold),
                          underline: Container(),
                          style: TextStyle(
                            color: _goldLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                          items: controller.qoriList.map((qori) {
                            return DropdownMenuItem<String>(
                              value: qori['id'],
                              child: Text(qori['name'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedQori.value = val;
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      )),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

class DetailCardPatternPainter extends CustomPainter {
  final Color color;
  const DetailCardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final path = Path();
    const double sp = 40.0;

    // Draw intersecting diagonal lines to form diamond mesh
    for (double i = -size.height; i < size.width; i += sp) {
      path.moveTo(i, 0);
      path.lineTo(i + size.height, size.height);
    }
    for (double i = 0; i < size.width + size.height; i += sp) {
      path.moveTo(i, 0);
      path.lineTo(i - size.height, size.height);
    }
    canvas.drawPath(path, paint);

    // Draw small stars at intersection points
    final starPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += sp) {
      for (double y = 0; y < size.height; y += sp) {
        final starPath = Path()
          ..moveTo(x, y - 3)
          ..lineTo(x + 2, y - 1)
          ..lineTo(x + 4, y)
          ..lineTo(x + 2, y + 1)
          ..lineTo(x, y + 3)
          ..lineTo(x - 2, y + 1)
          ..lineTo(x - 4, y)
          ..lineTo(x - 2, y - 1)
          ..close();
        canvas.drawPath(starPath, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
