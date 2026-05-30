import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/constants/r.dart';
import '../../../data/models/detail_surah_model.dart';
import '../../home/widgets/diamond_number_painter.dart';
import '../controllers/detail_surah_controller.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';
import '../../../data/providers/theme_controller.dart';

class DetailSurahView extends GetView<DetailSurahController> {
  const DetailSurahView({super.key});

  Color get _bg =>
      controller.isNightMode.value ? const Color(0xFF0A0A0A) : R.color.bg1;
  Color get _gold =>
      controller.isNightMode.value ? const Color(0xFFB89E67) : R.color.gold;
  Color get _goldLight => controller.isNightMode.value
      ? const Color(0xFFB89E67)
      : R.color.goldLight;
  Color get _goldDim =>
      controller.isNightMode.value ? const Color(0xFF444444) : R.color.goldDim;
  Color get _textSoft =>
      controller.isNightMode.value ? const Color(0xFF999999) : R.color.textSoft;
  Color get _bg2 =>
      controller.isNightMode.value ? const Color(0xFF0A0A0A) : R.color.bg2;
  Color get _emeraldDark => controller.isNightMode.value
      ? const Color(0xFF101010)
      : R.color.emeraldDark;
  Color get _emeraldMedium => controller.isNightMode.value
      ? const Color(0xFF161616)
      : R.color.emeraldMedium;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Force dependency on isDarkMode and isNightMode so it rebuilds when theme/mode changes
      ThemeController.to.isDarkMode.value;
      controller.isNightMode.value;
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
            style: R.textStyle
                .large(color: _goldLight, fontWeight: FontWeight.bold)
                .copyWith(fontSize: 20),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                controller.isNightMode.value
                    ? Icons.nightlight_round
                    : Icons.nightlight_outlined,
                color: controller.isNightMode.value ? _gold : _goldLight,
              ),
              tooltip: 'Mode Malam',
              onPressed: () {
                controller.toggleNightMode();
              },
            ),
            IconButton(
              icon: AnimatedSwitcher(
                duration: controller.isNightMode.value
                    ? Duration.zero
                    : const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  if (controller.isNightMode.value) return child;
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Icon(
                  ThemeController.to.isDarkMode.value
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
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
            return Center(child: CustomLoader(size: 60));
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: R.color.redAccent,
                      size: 60,
                    ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            Text(
                              detail.namaLatin,
                              style: R.textStyle
                                  .large(
                                    color: _goldLight,
                                    fontWeight: FontWeight.bold,
                                  )
                                  .copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              detail.arti,
                              style: R.textStyle
                                  .medium(
                                    color: _textSoft.withValues(alpha: 0.7),
                                  )
                                  .copyWith(fontSize: 14),
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
                                  style: R.textStyle
                                      .small(
                                        color: _goldLight,
                                        fontWeight: FontWeight.w600,
                                      )
                                      .copyWith(
                                        letterSpacing: 1.5,
                                        fontSize: 12,
                                      ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Icon(
                                    Icons.circle,
                                    color: _goldDim,
                                    size: 6,
                                  ),
                                ),
                                Text(
                                  '${detail.jumlahAyat} AYAT',
                                  style: R.textStyle
                                      .small(
                                        color: _goldLight,
                                        fontWeight: FontWeight.w600,
                                      )
                                      .copyWith(
                                        letterSpacing: 1.5,
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Full Surah Audio Player Controls (Gabungan)
                            Obx(() {
                              final isPlaying =
                                  controller.isPlayingFullSurah.value;
                              final currentAyat =
                                  controller.currentlyPlayingAyat.value;
                              final isComp = controller.isCompleted.value;
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          controller.togglePlayFullSurah();
                                        },
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.pause_circle_filled_rounded
                                              : Icons.play_circle_fill_rounded,
                                          color: const Color(0xFF0D1F17),
                                          size: 16,
                                        ),
                                        label: Text(
                                          isPlaying ? 'JEDA' : 'PUTAR',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0D1F17),
                                            letterSpacing: 1.0,
                                            fontSize: 11,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _gold,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          controller.toggleCompleted();
                                        },
                                        icon: Icon(
                                          isComp
                                              ? Icons.check_circle_rounded
                                              : Icons.check_circle_outline_rounded,
                                          color: isComp ? Colors.white : const Color(0xFF0D1F17),
                                          size: 16,
                                        ),
                                        label: Text(
                                          isComp ? 'SELESAI' : 'TANDAI SELESAI',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isComp ? Colors.white : const Color(0xFF0D1F17),
                                            letterSpacing: 1.0,
                                            fontSize: 11,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isComp ? R.color.emerald : _gold,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Divider(color: _goldDim.withValues(alpha: 0.15), thickness: 1),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Mode Hafalan Toggle Button
                                      Obx(() {
                                        final isHafalan = controller.isMemorizationMode.value;
                                        return TextButton.icon(
                                          onPressed: () {
                                            controller.toggleMemorizationMode();
                                            CustomToast.show(
                                              context,
                                              message: isHafalan 
                                                  ? 'Mode Hafalan dinonaktifkan' 
                                                  : 'Mode Hafalan diaktifkan. Ketuk tanda tanya (?) untuk melihat kata.',
                                              type: ToastType.info,
                                            );
                                          },
                                          icon: Icon(
                                            isHafalan ? Icons.psychology_rounded : Icons.psychology_outlined,
                                            color: isHafalan ? _gold : _goldLight.withValues(alpha: 0.6),
                                            size: 18,
                                          ),
                                          label: Text(
                                            'Mode Hafalan',
                                            style: TextStyle(
                                              color: isHafalan ? _gold : _goldLight.withValues(alpha: 0.6),
                                              fontWeight: isHafalan ? FontWeight.bold : FontWeight.normal,
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            backgroundColor: isHafalan ? _gold.withValues(alpha: 0.1) : Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              side: BorderSide(
                                                color: isHafalan ? _gold.withValues(alpha: 0.3) : Colors.white10,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      
                                      // Audio Repeat Selector
                                      Obx(() {
                                        final repeat = controller.audioRepeatCount.value;
                                        return TextButton.icon(
                                          onPressed: () => controller.cycleRepeatCount(),
                                          icon: Icon(
                                            Icons.repeat_one_rounded,
                                            color: repeat > 1 ? _gold : _goldLight.withValues(alpha: 0.6),
                                            size: 18,
                                          ),
                                          label: Text(
                                            'Ulang: ${repeat}x',
                                            style: TextStyle(
                                              color: repeat > 1 ? _gold : _goldLight.withValues(alpha: 0.6),
                                              fontWeight: repeat > 1 ? FontWeight.bold : FontWeight.normal,
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            backgroundColor: repeat > 1 ? _gold.withValues(alpha: 0.1) : Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              side: BorderSide(
                                                color: repeat > 1 ? _gold.withValues(alpha: 0.3) : Colors.white10,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  if (isPlaying && currentAyat != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Memutar ayat $currentAyat dari ${detail.jumlahAyat}',
                                      style: R.textStyle
                                          .small(
                                            color: _goldLight.withValues(
                                              alpha: 0.8,
                                            ),
                                          )
                                          .copyWith(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
                                ],
                              );
                            }),
                            // Beautiful Bismillah (except for Al-Fatihah which has it as verse 1 and At-Tawbah which does not have it)
                            if (detail.nomor != 1 && detail.nomor != 9) ...[
                              const SizedBox(height: 24),
                              Text(
                                R.string.bismillah,
                                textAlign: TextAlign.center,
                                style: R.textStyle
                                    .large(color: _goldLight)
                                    .copyWith(fontSize: 24, letterSpacing: 1),
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
                    final key = controller.ayatKeys.putIfAbsent(
                      ayat.nomorAyat,
                      () => GlobalKey(),
                    );
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
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
                                  Obx(() {
                                    final status = controller.hafalanProgress[ayat.nomorAyat];
                                    if (status == null) return const SizedBox.shrink();
                                    final isSudah = status == 'sudah';
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSudah
                                              ? R.color.emerald.withValues(alpha: 0.15)
                                              : Colors.blue.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isSudah ? R.color.emerald : Colors.blue,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          isSudah ? 'Hafal' : 'Menghafal',
                                          style: TextStyle(
                                            color: isSudah ? R.color.emeraldLight : Colors.blueAccent,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  const Spacer(),
                                  // Play Audio Button
                                  Obx(() {
                                    final isPlaying =
                                        controller.currentlyPlayingAyat.value ==
                                            ayat.nomorAyat &&
                                        controller.isAudioPlaying.value;
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () =>
                                            controller.togglePlayAudio(ayat),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Icon(
                                            isPlaying
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            color: isPlaying ? _gold : _goldDim,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  // Tandai Terakhir Dibaca Button
                                  Obx(
                                    () => Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          controller.markAsLastRead(
                                            detail.nomor,
                                            detail.namaLatin,
                                            ayat.nomorAyat,
                                          );
                                          CustomToast.show(
                                            context,
                                            message:
                                                'Ayat ${ayat.nomorAyat} ditandai sebagai terakhir dibaca',
                                            type: ToastType.success,
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Icon(
                                            controller
                                                        .lastReadAyatNomor
                                                        .value ==
                                                    ayat.nomorAyat
                                                ? Icons.bookmark_added_rounded
                                                : Icons.bookmark_add_outlined,
                                            color:
                                                controller
                                                        .lastReadAyatNomor
                                                        .value ==
                                                    ayat.nomorAyat
                                                ? _gold
                                                : _goldDim,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Simpan Bookmark Button
                                  Obx(
                                    () => Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () async {
                                          await controller.toggleBookmark(ayat);
                                          final isAdded = controller
                                              .bookmarkedAyats
                                              .contains(ayat.nomorAyat);
                                          CustomToast.show(
                                            context,
                                            message: isAdded
                                                ? 'Ayat ${ayat.nomorAyat} disimpan ke Bookmark'
                                                : 'Ayat ${ayat.nomorAyat} dihapus dari Bookmark',
                                            type: ToastType.success,
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Icon(
                                            controller.bookmarkedAyats.contains(
                                                  ayat.nomorAyat,
                                                )
                                                ? Icons.bookmark_rounded
                                                : Icons.bookmark_border_rounded,
                                            color:
                                                controller.bookmarkedAyats
                                                    .contains(ayat.nomorAyat)
                                                ? _gold
                                                : _goldDim,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Hafalan Status Popup Menu Button
                                  Obx(() {
                                    final status = controller.hafalanProgress[ayat.nomorAyat];
                                    IconData icon;
                                    Color iconColor;
                                    if (status == 'sudah') {
                                      icon = Icons.psychology_rounded;
                                      iconColor = R.color.emerald;
                                    } else if (status == 'sedang') {
                                      icon = Icons.psychology_rounded;
                                      iconColor = Colors.blue;
                                    } else {
                                      icon = Icons.psychology_outlined;
                                      iconColor = _goldDim;
                                    }
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        cardColor: _bg2,
                                      ),
                                      child: PopupMenuButton<String>(
                                        icon: Icon(icon, color: iconColor, size: 20),
                                        tooltip: 'Status Hafalan',
                                        onSelected: (val) {
                                          controller.updateHafalanStatus(ayat.nomorAyat, val);
                                          CustomToast.show(
                                            context,
                                            message: val == 'none'
                                                ? 'Progress hafalan ayat ${ayat.nomorAyat} dihapus'
                                                : 'Ayat ${ayat.nomorAyat} ditandai sebagai ${val == 'sudah' ? 'Sudah Dihafal' : 'Sedang Dihafal'}',
                                            type: ToastType.success,
                                          );
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'none',
                                            child: Text('Belum Dihafal', style: TextStyle(color: _textSoft)),
                                          ),
                                          PopupMenuItem(
                                            value: 'sedang',
                                            child: Text('Sedang Dihafal', style: const TextStyle(color: Colors.blueAccent)),
                                          ),
                                          PopupMenuItem(
                                            value: 'sudah',
                                            child: Text('Sudah Dihafal', style: TextStyle(color: R.color.emeraldLight)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  // Catatan Ayat (Tadabbur) Button
                                  Obx(() {
                                    final hasNote = controller.versesWithNotes
                                        .contains(ayat.nomorAyat);
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          _showAddNoteBottomSheet(
                                            context,
                                            detail,
                                            ayat,
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Icon(
                                            hasNote
                                                ? Icons.edit_note_rounded
                                                : Icons.note_add_outlined,
                                            color: hasNote ? _gold : _goldDim,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  // Opsi Lainnya (Salin, Bagikan, Tafsir)
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      cardColor: _bg2,
                                    ),
                                    child: PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert_rounded, color: _goldDim, size: 20),
                                      tooltip: 'Opsi Lainnya',
                                      onSelected: (val) {
                                        if (val == 'copy') {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text: '${ayat.teksArab}\n${ayat.teksLatin}\n${ayat.teksIndonesia}',
                                            ),
                                          );
                                          CustomToast.show(
                                            context,
                                            message: 'Ayat ${ayat.nomorAyat} ${R.string.copySuccess.toLowerCase()}',
                                            type: ToastType.success,
                                          );
                                        } else if (val == 'share') {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text: 'QS. ${detail.namaLatin} [${detail.nomor}:${ayat.nomorAyat}]\n\n'
                                                  '${ayat.teksArab}\n\n'
                                                  'Artinya: "${ayat.teksIndonesia}"',
                                            ),
                                          );
                                          CustomToast.show(
                                            context,
                                            message: R.string.shareText,
                                            type: ToastType.success,
                                          );
                                        } else if (val == 'tafsir') {
                                          _showTafsirBottomSheet(
                                            context,
                                            detail,
                                            ayat.nomorAyat,
                                          );
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'copy',
                                          child: Row(
                                            children: [
                                              Icon(Icons.copy_rounded, color: _goldDim, size: 18),
                                              const SizedBox(width: 8),
                                              Text('Salin Ayat', style: TextStyle(color: _textSoft, fontFamily: 'Poppins', fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'share',
                                          child: Row(
                                            children: [
                                              Icon(Icons.share_rounded, color: _goldDim, size: 18),
                                              const SizedBox(width: 8),
                                              Text('Bagikan', style: TextStyle(color: _textSoft, fontFamily: 'Poppins', fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'tafsir',
                                          child: Row(
                                            children: [
                                              Icon(Icons.menu_book_rounded, color: _goldDim, size: 18),
                                              const SizedBox(width: 8),
                                              Text('Lihat Tafsir', style: TextStyle(color: _textSoft, fontFamily: 'Poppins', fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Arabic Text
                            _buildArabicText(context, ayat),
                            if (controller.showLatin.value ||
                                controller.showTranslation.value) ...[
                              const SizedBox(height: 18),
                            ],
                            if (controller.showLatin.value) ...[
                              Text(
                                ayat.teksLatin,
                                textAlign: TextAlign.left,
                                style: R.textStyle
                                    .medium(
                                      color: _goldLight.withValues(alpha: 0.9),
                                    )
                                    .copyWith(
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
                                style: R.textStyle
                                    .small(
                                      color: _textSoft.withValues(alpha: 0.8),
                                    )
                                    .copyWith(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                              ),
                            ],

                            // Teks Catatan Tadabbur jika ada
                            Obx(() {
                              final noteText =
                                  controller.verseNotes[ayat.nomorAyat];
                              if (noteText == null || noteText.trim().isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _goldDim.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _goldDim.withValues(alpha: 0.15),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.edit_note_rounded,
                                          color: _goldLight,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          R.string.notesTadabburSaya,
                                          style: R.textStyle
                                              .small(
                                                color: _goldLight,
                                                fontWeight: FontWeight.bold,
                                              )
                                              .copyWith(fontFamily: 'Poppins'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      noteText,
                                      style: R.textStyle
                                          .small(color: _textSoft)
                                          .copyWith(
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }),
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
                      Icons
                          .brightness_7_rounded, // Islamic-style star/flower shape
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
                  style: R.textStyle
                      .small(color: _textSoft.withValues(alpha: 0.6))
                      .copyWith(fontStyle: FontStyle.italic, fontSize: 13),
                ),
              ),
              const SizedBox(height: 48),
            ],
          );
        }),
      );
    });
  }

  void _showTafsirBottomSheet(
    BuildContext context,
    Data detail,
    int nomorAyat,
  ) {
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
                          style: R.textStyle
                              .medium(
                                color: _goldLight,
                                fontWeight: FontWeight.bold,
                              )
                              .copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ayat ke-$nomorAyat',
                          style: R.textStyle
                              .small(color: _textSoft.withValues(alpha: 0.6))
                              .copyWith(fontSize: 13),
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
            Divider(color: _goldDim.withValues(alpha: 0.15), thickness: 1),
            // Content
            Expanded(
              child: FutureBuilder<String?>(
                future: tafsirFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: _gold),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Decorative label and Font Size Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
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
                                  icon: Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: _goldDim,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (controller.tafsirFontSize.value >
                                        12.0) {
                                      controller.tafsirFontSize.value -= 1.0;
                                    }
                                  },
                                ),
                                const SizedBox(width: 6),
                                Obx(
                                  () => Text(
                                    '${controller.tafsirFontSize.value.toInt()}',
                                    style: TextStyle(
                                      color: _goldLight,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.add_circle_outline_rounded,
                                    color: _goldDim,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (controller.tafsirFontSize.value <
                                        26.0) {
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
                        Obx(
                          () => Text(
                            tafsirText,
                            style: TextStyle(
                              color: _textSoft.withValues(alpha: 0.9),
                              fontSize: controller.tafsirFontSize.value,
                              height: 1.8,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
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
      Obx(
        () => Container(
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
                      style: R.textStyle
                          .medium(
                            color: _goldLight,
                            fontWeight: FontWeight.bold,
                          )
                          .copyWith(fontSize: 18),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: _goldDim),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(color: _goldDim.withValues(alpha: 0.15), thickness: 1),
                const SizedBox(height: 16),

                // Slider for Font Size
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ukuran Font Arab',
                      style: R.textStyle
                          .small(color: _textSoft)
                          .copyWith(fontSize: 14),
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
                    style: R.textStyle
                        .small(color: _textSoft)
                        .copyWith(fontSize: 14),
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
                    style: R.textStyle
                        .small(color: _textSoft)
                        .copyWith(fontSize: 14),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Qari Ayat',
                        style: R.textStyle
                            .small(color: _textSoft)
                            .copyWith(fontSize: 14),
                      ),
                      Obx(() {
                        final currentQoriId = controller.selectedQori.value;
                        return Theme(
                          data: Theme.of(context).copyWith(canvasColor: _bg2),
                          child: DropdownButton<String>(
                            value: currentQoriId,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: _gold,
                            ),
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
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showAddNoteBottomSheet(BuildContext context, Data detail, Ayat ayat) {
    final textCtrl = TextEditingController(
      text: controller.verseNotes[ayat.nomorAyat] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(color: _goldDim.withValues(alpha: 0.15)),
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
                  decoration: BoxDecoration(
                    color: _goldDim.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: _goldLight, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    R.string.notesAyatTitleWithNo(ayat.nomorAyat),
                    style: R.textStyle
                        .medium(color: _goldLight, fontWeight: FontWeight.bold)
                        .copyWith(fontFamily: 'Poppins'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'QS. ${detail.namaLatin} : Ayat ${ayat.nomorAyat}',
                style: R.textStyle
                    .small(color: _textSoft)
                    .copyWith(fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: textCtrl,
                maxLines: 4,
                style: TextStyle(
                  color: _textSoft,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  hintText: R.string.notesHintText,
                  hintStyle: TextStyle(
                    color: _textSoft.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: _bg2.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _goldDim.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _gold),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _goldDim.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (controller.versesWithNotes.contains(ayat.nomorAyat))
                    TextButton.icon(
                      onPressed: () async {
                        await controller.deleteVerseNote(ayat.nomorAyat);
                        Get.back();
                        CustomToast.show(
                          context,
                          message: R.string.notesDeleteSuccessMsg(
                            ayat.nomorAyat,
                          ),
                          type: ToastType.success,
                        );
                      },
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: R.color.redAccent,
                        size: 18,
                      ),
                      label: Text(
                        'Hapus',
                        style: TextStyle(
                          color: R.color.redAccent,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Batal',
                      style: TextStyle(color: _textSoft, fontFamily: 'Poppins'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await controller.saveVerseNote(
                        ayat.nomorAyat,
                        textCtrl.text,
                      );
                      Get.back();
                      CustomToast.show(
                        context,
                        message: R.string.notesSaveSuccessMsg(ayat.nomorAyat),
                        type: ToastType.success,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'Simpan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArabicText(BuildContext context, Ayat ayat) {
    return Obx(() {
      if (!controller.isMemorizationMode.value) {
        return Text(
          ayat.teksArab,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: R.textStyle
              .large(
                color: _goldLight,
                fontWeight: FontWeight.w500,
              )
              .copyWith(
                fontFamily: 'Poppins',
                fontSize: controller.isNightMode.value
                    ? controller.arabicFontSize.value + 4
                    : controller.arabicFontSize.value,
                height: 1.8,
              ),
        );
      }

      final words = ayat.teksArab.split(' ');
      final fontSize = controller.isNightMode.value
          ? controller.arabicFontSize.value + 4
          : controller.arabicFontSize.value;

      return Container(
        width: double.infinity,
        alignment: Alignment.topRight,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 10,
            children: List.generate(words.length, (idx) {
              final word = words[idx];
              final isWordHidden = (idx + ayat.nomorAyat) % 3 == 0;
              final key = "${ayat.nomorAyat}-$idx";
              final isRevealed = controller.revealedWords.contains(key);

              if (isWordHidden && !isRevealed) {
                return GestureDetector(
                  onTap: () => controller.revealWord(key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: _goldDim.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _goldDim.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      ' ? ',
                      style: R.textStyle
                          .large(color: _gold)
                          .copyWith(
                            fontFamily: 'Poppins',
                            fontSize: fontSize * 0.75,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                );
              }

              return Text(
                word,
                style: R.textStyle
                    .large(
                      color: (isWordHidden && isRevealed) ? _gold : _goldLight,
                      fontWeight: FontWeight.w500,
                    )
                    .copyWith(
                      fontFamily: 'Poppins',
                      fontSize: fontSize,
                    ),
              );
            }),
          ),
        ),
      );
    });
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
