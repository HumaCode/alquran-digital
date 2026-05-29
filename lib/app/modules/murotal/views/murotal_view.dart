import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/r.dart';
import '../../../data/models/surah_model.dart';
import '../controllers/murotal_controller.dart';

class MurotalView extends StatefulWidget {
  const MurotalView({super.key});

  @override
  State<MurotalView> createState() => _MurotalViewState();
}

class _MurotalViewState extends State<MurotalView> with SingleTickerProviderStateMixin {
  late final MurotalController controller;
  late final AnimationController _rotationController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MurotalController>();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    // Infinite scroll listener
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 80) {
        controller.loadMoreSurahs();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.bg1,
      appBar: AppBar(
        title: Text(
          'Murotal Al-Quran',
          style: TextStyle(
            color: R.color.goldLight,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: R.color.bg1,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: R.color.goldLight),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: R.color.gold));
        }

        // Sync rotation with play state
        if (controller.isPlaying.value) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }

        return Column(
          children: [
            // ── Top Player Section ─────────────────────────────────────────
            Expanded(
              flex: 11,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  children: [
                    // Qori Selector
                    _buildQoriSelector(context),
                    const SizedBox(height: 20),

                    // Rotating Disk
                    _buildRotatingDisk(controller.selectedSurah.value),
                    const SizedBox(height: 16),

                    // Surah info
                    if (controller.selectedSurah.value != null) ...[
                      Text(
                        controller.selectedSurah.value!.namaLatin,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: R.color.textSoft,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Surah Ke-${controller.selectedSurah.value!.nomor} • ${controller.selectedSurah.value!.arti}',
                        style: TextStyle(fontSize: 13, color: R.color.textMuted),
                      ),
                      const SizedBox(height: 8),
                      // Offline indicator badge
                      _buildOfflineBadge(controller.selectedSurah.value!),
                    ],
                    const SizedBox(height: 16),

                    // Progress Slider
                    _buildProgressSlider(),
                    const SizedBox(height: 8),

                    // Player Controls
                    _buildPlayerControls(),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),

            // Divider
            Container(height: 1, color: R.color.goldDim.withOpacity(0.15)),

            // ── Bottom Surah List Section ──────────────────────────────────
            Expanded(
              flex: 9,
              child: Container(
                color: R.color.bg2.withOpacity(0.35),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                      child: TextField(
                        onChanged: controller.searchSurah,
                        style: TextStyle(color: R.color.textSoft, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Cari surah murotal...',
                          hintStyle: TextStyle(color: R.color.textMuted.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.search_rounded, color: R.color.goldLight, size: 20),
                          filled: true,
                          fillColor: R.color.bg1.withOpacity(0.6),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: R.color.goldDim.withOpacity(0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: R.color.goldLight.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),

                    // Surah count chip
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${controller.displayedSurahs.length} dari ${controller.filteredSurahList.length} surah',
                          style: TextStyle(color: R.color.textMuted, fontSize: 11),
                        ),
                      ),
                    ),

                    // Surah List with infinite scroll
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: controller.displayedSurahs.length + (controller.hasMore.value ? 1 : 0),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        itemBuilder: (context, idx) {
                          // Load more indicator at bottom
                          if (idx == controller.displayedSurahs.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: controller.isLoadingMore.value
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: R.color.gold,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : TextButton.icon(
                                        onPressed: controller.loadMoreSurahs,
                                        icon: Icon(Icons.expand_more_rounded, color: R.color.gold, size: 18),
                                        label: Text(
                                          'Muat Lebih Banyak',
                                          style: TextStyle(color: R.color.gold, fontSize: 12),
                                        ),
                                      ),
                              ),
                            );
                          }

                          final surah = controller.displayedSurahs[idx];
                          return _buildSurahListItem(surah);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOfflineBadge(DataSurah surah) {
    final cacheKey = '${surah.nomor}_${controller.selectedQori.value}';
    final isDownloaded = controller.downloadedTracks.contains(cacheKey);
    final isDownloading = controller.downloadingTracks.contains(cacheKey);

    if (isDownloading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: R.color.gold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: R.color.gold.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(color: R.color.gold, strokeWidth: 1.5),
            ),
            const SizedBox(width: 6),
            Text('Mengunduh...', style: TextStyle(color: R.color.gold, fontSize: 11)),
          ],
        ),
      );
    }

    if (isDownloaded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: R.color.emerald.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: R.color.emerald.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.offline_pin_rounded, color: R.color.emeraldLight, size: 12),
            const SizedBox(width: 6),
            Text('Tersedia Offline', style: TextStyle(color: R.color.emeraldLight, fontSize: 11)),
          ],
        ),
      );
    }

    // Not downloaded - show manual download button
    return GestureDetector(
      onTap: () => controller.downloadMurotalManual(surah, controller.selectedQori.value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: R.color.bg2.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: R.color.goldDim.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_rounded, color: R.color.goldDim, size: 12),
            const SizedBox(width: 6),
            Text('Unduh untuk Offline', style: TextStyle(color: R.color.goldDim, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahListItem(DataSurah surah) {
    final isCurrent = controller.selectedSurah.value?.nomor == surah.nomor;
    final cacheKey = '${surah.nomor}_${controller.selectedQori.value}';
    final isDownloaded = controller.downloadedTracks.contains(cacheKey);
    final isDownloading = controller.downloadingTracks.contains(cacheKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isCurrent ? R.color.gold.withOpacity(0.09) : Colors.transparent,
        border: Border.all(
          color: isCurrent ? R.color.gold.withOpacity(0.2) : R.color.goldDim.withOpacity(0.07),
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        onTap: () => controller.selectSurah(surah),
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent
                ? R.color.gold.withOpacity(0.2)
                : R.color.bg1.withOpacity(0.8),
          ),
          child: Center(
            child: isCurrent && controller.isPlaying.value
                ? Icon(Icons.volume_up_rounded, color: R.color.gold, size: 16)
                : Text(
                    '${surah.nomor}',
                    style: TextStyle(
                      color: isCurrent ? R.color.gold : R.color.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        title: Text(
          surah.namaLatin,
          style: TextStyle(
            color: isCurrent ? R.color.goldLight : R.color.textSoft,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          '${surah.jumlahAyat} Ayat • ${surah.tempatTurun}',
          style: TextStyle(color: R.color.textMuted, fontSize: 10),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Offline status icon
            if (isDownloading)
              SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(color: R.color.gold, strokeWidth: 1.5),
              )
            else if (isDownloaded)
              Icon(Icons.offline_pin_rounded, color: R.color.emeraldLight, size: 14)
            else
              GestureDetector(
                onTap: () => controller.downloadMurotalManual(surah, controller.selectedQori.value),
                child: Icon(Icons.download_for_offline_rounded, color: R.color.goldDim.withOpacity(0.4), size: 16),
              ),
            const SizedBox(width: 8),
            // Arabic surah name
            Text(
              surah.nama,
              style: TextStyle(
                color: R.color.goldLight,
                fontSize: 18,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQoriSelector(BuildContext context) {
    final currentQoriId = controller.selectedQori.value;
    final currentQoriName =
        controller.qoriList.firstWhere((q) => q['id'] == currentQoriId, orElse: () => {'name': '-'})['name'] ?? '';

    return GestureDetector(
      onTap: () => _showQoriSelectionSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: R.color.gold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: R.color.gold.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_external_on_rounded, color: R.color.goldLight, size: 16),
            const SizedBox(width: 8),
            Text(
              currentQoriName,
              style: TextStyle(color: R.color.goldLight, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: R.color.goldLight, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRotatingDisk(DataSurah? currentSurah) {
    return Center(
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationController.value * 2 * 3.14159,
            child: child,
          );
        },
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (controller.isPlaying.value ? R.color.gold : R.color.goldDim).withOpacity(0.12),
                blurRadius: 22,
                spreadRadius: 6,
              )
            ],
            gradient: SweepGradient(
              colors: [R.color.goldDim, R.color.goldLight, R.color.goldDim, R.color.bg1, R.color.goldDim],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0D1F17)),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [R.color.bg2, Color.lerp(R.color.bg2, Colors.black, 0.35)!],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: R.color.bg1,
                        border: Border.all(color: R.color.gold.withOpacity(0.3), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          currentSurah?.nama ?? 'القرآن',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: currentSurah != null && currentSurah.nama.length > 5 ? 16 : 20,
                            color: R.color.goldLight,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSlider() {
    final pos = controller.position.value;
    final dur = controller.duration.value;

    double value = 0.0;
    if (dur.inMilliseconds > 0) {
      value = (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);
    }

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: R.color.goldLight,
            inactiveTrackColor: R.color.goldDim.withOpacity(0.2),
            thumbColor: R.color.goldLight,
            overlayColor: R.color.goldLight.withOpacity(0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            onChanged: (val) {
              final destMs = (val * dur.inMilliseconds).toInt();
              controller.seekAudio(Duration(milliseconds: destMs));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(pos), style: TextStyle(color: R.color.textMuted, fontSize: 11)),
              Text(_formatDuration(dur), style: TextStyle(color: R.color.textMuted, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        IconButton(
          onPressed: controller.playPrevious,
          iconSize: 30,
          icon: Icon(Icons.skip_previous_rounded, color: R.color.textSoft),
        ),
        const SizedBox(width: 20),

        // Play/Pause
        GestureDetector(
          onTap: controller.togglePlay,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: R.color.goldLight,
              boxShadow: [
                BoxShadow(color: R.color.gold.withOpacity(0.3), blurRadius: 14, spreadRadius: 2)
              ],
            ),
            child: Center(
              child: Icon(
                controller.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: R.color.bg1,
                size: 34,
              ),
            ),
          ),
        ),

        const SizedBox(width: 20),

        // Next
        IconButton(
          onPressed: controller.playNext,
          iconSize: 30,
          icon: Icon(Icons.skip_next_rounded, color: R.color.textSoft),
        ),
      ],
    );
  }

  void _showQoriSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: R.color.bg2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: R.color.goldDim.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Pilih Qari Murotal',
                  style: TextStyle(color: R.color.goldLight, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...controller.qoriList.map((qori) {
                  final isSelected = controller.selectedQori.value == qori['id'];
                  return ListTile(
                    leading: Icon(
                      Icons.mic_external_on_rounded,
                      color: isSelected ? R.color.goldLight : R.color.textMuted,
                    ),
                    title: Text(
                      qori['name'] ?? '',
                      style: TextStyle(
                        color: isSelected ? R.color.goldLight : R.color.textSoft,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: R.color.goldLight)
                        : null,
                    onTap: () {
                      controller.changeQori(qori['id'] ?? '03');
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
