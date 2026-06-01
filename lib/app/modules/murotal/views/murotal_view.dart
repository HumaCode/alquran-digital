import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  late final Worker _playStateWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MurotalController>();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    // Sync rotation with play state reactively
    _playStateWorker = ever(controller.isPlaying, (bool playing) {
      if (playing) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });

    if (controller.isPlaying.value) {
      _rotationController.repeat();
    }

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
    _playStateWorker.dispose();
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
            fontSize: 20.sp,
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
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.playlist_play_rounded, color: R.color.goldLight, size: 28.r),
                tooltip: 'Daftar Surah',
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: _buildSurahListDrawer(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: R.color.gold));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return Obx(() {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(flex: 1),
                          // Qori Selector
                          _buildQoriSelector(context),
                          const Spacer(flex: 2),

                          // Rotating Disk
                          _buildRotatingDisk(),
                          const Spacer(flex: 2),

                          // Surah info
                          if (controller.selectedSurah.value != null) ...[
                            Text(
                              controller.selectedSurah.value!.namaLatin,
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w800,
                                color: R.color.textSoft,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Surah Ke-${controller.selectedSurah.value!.nomor} • ${controller.selectedSurah.value!.arti}',
                              style: TextStyle(fontSize: 14.sp, color: R.color.textMuted),
                            ),
                            const SizedBox(height: 12),
                            // Offline indicator badge
                            _buildOfflineBadge(controller.selectedSurah.value!),
                          ],
                          const Spacer(flex: 2),

                          // Progress Slider
                          _buildProgressSlider(),
                          const SizedBox(height: 12),

                          // Player Controls
                          _buildPlayerControls(context),
                          const Spacer(flex: 3),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildSurahListDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: R.color.bg2,
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              // Drawer Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Surah',
                      style: TextStyle(
                        color: R.color.goldLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: R.color.goldDim),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(color: R.color.goldDim.withValues(alpha: 0.15), height: 1),

              // Search Bar
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                child: TextField(
                  onChanged: controller.searchSurah,
                  style: TextStyle(color: R.color.textSoft, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari surah murotal...',
                    hintStyle: TextStyle(color: R.color.textMuted.withValues(alpha: 0.7)),
                    prefixIcon: Icon(Icons.search_rounded, color: R.color.goldLight, size: 20.r),
                    filled: true,
                    fillColor: R.color.bg1.withValues(alpha: 0.6),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide(color: R.color.goldDim.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide(color: R.color.goldLight.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ),

              // Surah count chip
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 6.h),
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
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                  itemBuilder: (context, idx) {
                    // Load more indicator at bottom
                    if (idx == controller.displayedSurahs.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
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
                                  icon: Icon(Icons.expand_more_rounded, color: R.color.gold, size: 18.r),
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
          );
        }),
      ),
    );
  }

  Widget _buildOfflineBadge(DataSurah surah) {
    final cacheKey = '${surah.nomor}_${controller.selectedQori.value}';
    final isDownloaded = controller.downloadedTracks.contains(cacheKey);
    final isDownloading = controller.downloadingTracks.contains(cacheKey);

    if (isDownloading) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: R.color.gold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: R.color.gold.withValues(alpha: 0.3)),
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: R.color.emerald.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: R.color.emerald.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.offline_pin_rounded, color: R.color.emeraldLight, size: 12.r),
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: R.color.bg2.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: R.color.goldDim.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_rounded, color: R.color.goldDim, size: 12.r),
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
      margin: EdgeInsets.only(bottom: 7.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: isCurrent ? R.color.gold.withValues(alpha: 0.09) : Colors.transparent,
        border: Border.all(
          color: isCurrent ? R.color.gold.withValues(alpha: 0.2) : R.color.goldDim.withValues(alpha: 0.07),
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        onTap: () {
          controller.selectSurah(surah);
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent
                ? R.color.gold.withValues(alpha: 0.2)
                : R.color.bg1.withValues(alpha: 0.8),
          ),
          child: Center(
            child: isCurrent && controller.isPlaying.value
                ? Icon(Icons.volume_up_rounded, color: R.color.gold, size: 16.r)
                : Text(
                    '${surah.nomor}',
                    style: TextStyle(
                      color: isCurrent ? R.color.gold : R.color.textMuted,
                      fontSize: 11.sp,
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
            fontSize: 13.sp,
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
              Icon(Icons.offline_pin_rounded, color: R.color.emeraldLight, size: 14.r)
            else
              GestureDetector(
                onTap: () => controller.downloadMurotalManual(surah, controller.selectedQori.value),
                child: Icon(Icons.download_for_offline_rounded, color: R.color.goldDim.withValues(alpha: 0.4), size: 16.r),
              ),
            const SizedBox(width: 8),
            // Arabic surah name
            Text(
              surah.nama,
              style: TextStyle(
                color: R.color.goldLight,
                fontSize: 18.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: R.color.gold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: R.color.gold.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_external_on_rounded, color: R.color.goldLight, size: 16.r),
            const SizedBox(width: 8),
            Text(
              currentQoriName,
              style: TextStyle(color: R.color.goldLight, fontSize: 12.5.sp, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: R.color.goldLight, size: 16.r),
          ],
        ),
      ),
    );
  }

  Widget _buildRotatingDisk() {
    return Obx(() {
      final isPlaying = controller.isPlaying.value;
      final currentSurah = controller.selectedSurah.value;
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
            width: 180.w,
            height: 180.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isPlaying ? R.color.gold : R.color.goldDim).withValues(alpha: 0.12),
                  blurRadius: 22,
                  spreadRadius: 6,
                )
              ],
              gradient: SweepGradient(
                colors: [R.color.goldDim, R.color.goldLight, R.color.goldDim, R.color.bg1, R.color.goldDim],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(5.r),
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0D1F17)),
                child: Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [R.color.bg2, Color.lerp(R.color.bg2, Colors.black, 0.35)!],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 72.w,
                        height: 72.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: R.color.bg1,
                          border: Border.all(color: R.color.gold.withValues(alpha: 0.3), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            currentSurah?.nama ?? 'القرآن',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: currentSurah != null && currentSurah.nama.length > 5 ? 16.sp : 20.sp,
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
    });
  }

  Widget _buildProgressSlider() {
    return Obx(() {
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
              inactiveTrackColor: R.color.goldDim.withValues(alpha: 0.2),
              thumbColor: R.color.goldLight,
              overlayColor: R.color.goldLight.withValues(alpha: 0.1),
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
            padding: EdgeInsets.symmetric(horizontal: 16.w),
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
    });
  }

  Widget _buildPlayerControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Repeat Button
        Obx(() {
          IconData iconData;
          Color color;
          String label;

          switch (controller.repeatMode.value) {
            case 'surah':
              iconData = Icons.repeat_one_rounded;
              color = R.color.goldLight;
              label = 'Surah';
              break;
            case 'juz':
              iconData = Icons.repeat_on_rounded;
              color = R.color.goldLight;
              label = 'Juz';
              break;
            case 'all':
              iconData = Icons.repeat_rounded;
              color = R.color.goldLight;
              label = 'Semua';
              break;
            case 'off':
            default:
              iconData = Icons.repeat_rounded;
              color = R.color.textMuted;
              label = 'Off';
              break;
          }

          return InkWell(
            onTap: () => controller.cycleRepeatMode(context),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(iconData, color: color, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(width: 16),

        // Previous
        IconButton(
          onPressed: () => controller.playPrevious(),
          iconSize: 30.r,
          icon: Icon(Icons.skip_previous_rounded, color: R.color.textSoft),
        ),
        const SizedBox(width: 16),

        // Play/Pause
        Obx(() {
          final isPlaying = controller.isPlaying.value;
          return GestureDetector(
            onTap: controller.togglePlay,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: R.color.goldLight,
                boxShadow: [
                  BoxShadow(color: R.color.gold.withValues(alpha: 0.3), blurRadius: 14, spreadRadius: 2)
                ],
              ),
              child: Center(
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: R.color.bg1,
                  size: 34.r,
                ),
              ),
            ),
          );
        }),

        const SizedBox(width: 16),

        // Next
        IconButton(
          onPressed: () => controller.playNext(isAuto: false),
          iconSize: 30.r,
          icon: Icon(Icons.skip_next_rounded, color: R.color.textSoft),
        ),

        // Spacer placeholder on right to balance the repeat button
        const SizedBox(width: 16),
        Opacity(
          opacity: 0,
          child: IgnorePointer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.repeat_rounded, size: 24),
                const SizedBox(height: 2),
                Text('Off', style: TextStyle(fontSize: 9)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showQoriSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: R.color.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
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
                    color: R.color.goldDim.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Text(
                  'Pilih Qari Murotal',
                  style: TextStyle(color: R.color.goldLight, fontSize: 16.sp, fontWeight: FontWeight.bold),
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
