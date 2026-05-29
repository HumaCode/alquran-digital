import 'dart:ui';
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

  @override
  void initState() {
    super.initState();
    controller = Get.find<MurotalController>();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
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
          'Pemutar Murotal',
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
          return Center(
            child: CircularProgressIndicator(
              color: R.color.gold,
            ),
          );
        }

        // Trigger rotation animation based on playing state
        if (controller.isPlaying.value) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }

        final currentSurah = controller.selectedSurah.value;

        return Stack(
          children: [
            // Deep emerald background radial gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    R.color.bg1,
                    Color.lerp(R.color.bg1, R.color.bg2, 0.5)!,
                    R.color.bg2,
                  ],
                ),
              ),
            ),
            Column(
              children: [
                // Top Player Section
                Expanded(
                  flex: 11,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        // Qari Selector Badge
                        _buildQoriSelector(context),
                        const SizedBox(height: 24),

                        // Rotating Disk
                        _buildRotatingDisk(currentSurah),
                        const SizedBox(height: 24),

                        // Surah Info
                        if (currentSurah != null) ...[
                          Text(
                            currentSurah.namaLatin,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: R.color.textSoft,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Surah Ke-${currentSurah.nomor} • ${currentSurah.arti}',
                            style: TextStyle(
                              fontSize: 13,
                              color: R.color.textMuted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Audio Progress Slider
                        _buildProgressSlider(),
                        const SizedBox(height: 12),

                        // Player Control Row
                        _buildPlayerControls(),
                      ],
                    ),
                  ),
                ),

                // Divider line
                Container(
                  height: 1,
                  color: R.color.goldDim.withOpacity(0.15),
                ),

                // Bottom Surah List Section
                Expanded(
                  flex: 9,
                  child: Container(
                    color: R.color.bg2.withOpacity(0.4),
                    child: Column(
                      children: [
                        // Search bar
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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

                        // Surah List
                        Expanded(
                          child: ListView.builder(
                            itemCount: controller.filteredSurahList.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemBuilder: (context, idx) {
                              final surah = controller.filteredSurahList[idx];
                              final isCurrent = currentSurah?.nomor == surah.nomor;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: isCurrent
                                      ? R.color.gold.withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isCurrent
                                        ? R.color.gold.withOpacity(0.2)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () => controller.selectSurah(surah),
                                  leading: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCurrent
                                          ? R.color.gold.withOpacity(0.2)
                                          : R.color.bg1.withOpacity(0.8),
                                    ),
                                    child: Center(
                                      child: isCurrent && controller.isPlaying.value
                                          ? Icon(Icons.volume_up_rounded, color: R.color.gold, size: 18)
                                          : Text(
                                              '${surah.nomor}',
                                              style: TextStyle(
                                                color: isCurrent ? R.color.gold : R.color.textMuted,
                                                fontSize: 12,
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
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${surah.jumlahAyat} Ayat • ${surah.tempatTurun}',
                                    style: TextStyle(
                                      color: R.color.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Text(
                                    surah.nama,
                                    style: TextStyle(
                                      color: R.color.goldLight,
                                      fontSize: 18,
                                      fontFamily: 'serif',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildQoriSelector(BuildContext context) {
    final currentQoriId = controller.selectedQori.value;
    final currentQoriName = controller.qoriList.firstWhere((q) => q['id'] == currentQoriId)['name'] ?? '';

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
              style: TextStyle(
                color: R.color.goldLight,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
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
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (controller.isPlaying.value ? R.color.gold : R.color.goldDim).withOpacity(0.15),
                blurRadius: 25,
                spreadRadius: 8,
              )
            ],
            gradient: SweepGradient(
              colors: [
                R.color.goldDim,
                R.color.goldLight,
                R.color.goldDim,
                R.color.bg1,
                R.color.goldDim,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: R.color.bg1,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        R.color.bg2,
                        Color.lerp(R.color.bg2, Colors.black, 0.4)!,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
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
                            fontSize: currentSurah != null && currentSurah.nama.length > 5 ? 18 : 22,
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
      value = pos.inMilliseconds / dur.inMilliseconds;
    }
    value = value.clamp(0.0, 1.0);

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
            trackShape: const RoundedRectSliderTrackShape(),
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
              Text(
                _formatDuration(pos),
                style: TextStyle(color: R.color.textMuted, fontSize: 11),
              ),
              Text(
                _formatDuration(dur),
                style: TextStyle(color: R.color.textMuted, fontSize: 11),
              ),
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
        // Previous Button
        IconButton(
          onPressed: controller.playPrevious,
          iconSize: 32,
          icon: Icon(
            Icons.skip_previous_rounded,
            color: R.color.textSoft,
          ),
        ),
        const SizedBox(width: 24),

        // Play/Pause Button
        GestureDetector(
          onTap: controller.togglePlay,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: R.color.goldLight,
              boxShadow: [
                BoxShadow(
                  color: R.color.gold.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Center(
              child: Icon(
                controller.isPlaying.value
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: R.color.bg1,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),

        // Next Button
        IconButton(
          onPressed: controller.playNext,
          iconSize: 32,
          icon: Icon(
            Icons.skip_next_rounded,
            color: R.color.textSoft,
          ),
        ),
      ],
    );
  }

  void _showQoriSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: R.color.bg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Qari Murotal',
                  style: TextStyle(
                    color: R.color.goldLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
