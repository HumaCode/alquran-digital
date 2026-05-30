import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/r.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';
import '../controllers/statistik_controller.dart';

class StatistikView extends StatefulWidget {
  const StatistikView({super.key});

  @override
  State<StatistikView> createState() => _StatistikViewState();
}

class _StatistikViewState extends State<StatistikView> {
  final StatistikController _controller = Get.find<StatistikController>();
  final ScrollController _chartScrollController = ScrollController();

  Color get _bg => R.color.bg1;
  Color get _bg2 => R.color.bg2;
  Color get _gold => R.color.gold;
  Color get _goldLight => R.color.goldLight;
  Color get _goldDim => R.color.goldDim;
  Color get _textSoft => R.color.textSoft;
  Color get _emerald => R.color.emerald;
  Color get _emeraldLight => R.color.emeraldLight;

  @override
  void initState() {
    super.initState();
    // Scroll chart to the end (today) after data is rendered
    ever(_controller.monthlyProgress, (_) {
      if (_controller.monthlyProgress.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_chartScrollController.hasClients) {
            _chartScrollController.animateTo(
              _chartScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutQuad,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _chartScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: _gold),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Statistik & Riwayat',
          style: R.textStyle.largeBold.copyWith(color: _goldLight),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(child: CustomLoader(size: 50));
        }

        return RefreshIndicator(
          color: _gold,
          backgroundColor: _bg2,
          onRefresh: () => _controller.fetchStats(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Overview Row
                  _buildOverviewGrid(),
                  const SizedBox(height: 24),

                  // 2. 30 Days Monthly Chart
                  _buildMonthlyChartSection(),
                  const SizedBox(height: 24),

                  // 3. Achievements/Badges
                  _buildBadgesSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOverviewGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Aktivitas',
          style: R.textStyle.mediumBold.copyWith(color: _goldLight),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _buildStatCard(
              icon: Icons.menu_book_rounded,
              title: 'Total Ayat',
              value: '${_controller.totalAyat.value}',
              subtitle: 'Dibaca sepanjang masa',
              iconColor: _gold,
            ),
            _buildStatCard(
              icon: Icons.analytics_rounded,
              title: 'Rata-rata',
              value: _controller.rataRata.value.toStringAsFixed(1),
              subtitle: 'Ayat per hari aktif',
              iconColor: Colors.blueAccent,
            ),
            _buildStatCard(
              icon: Icons.local_fire_department_rounded,
              title: 'Streak Terbaik',
              value: '${_controller.longestStreak.value} Hari',
              subtitle: 'Rekor streak terpanjang',
              iconColor: R.color.orange,
            ),
            _buildStatCard(
              icon: Icons.bolt_rounded,
              title: 'Streak Saat Ini',
              value: '${_controller.currentStreak.value} Hari',
              subtitle: 'Konsistensi berturut-turut',
              iconColor: Colors.amber,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _gold.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: R.textStyle.small(color: _textSoft.withValues(alpha: 0.6)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: R.textStyle.extraLargeBold.copyWith(color: _goldLight, fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: R.textStyle.small(color: _textSoft.withValues(alpha: 0.4)).copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChartSection() {
    final progress = _controller.monthlyProgress;
    final target = _controller.dailyTarget.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat 30 Hari Terakhir',
              style: R.textStyle.mediumBold.copyWith(color: _goldLight),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _emerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Target: $target Ayat/Hari',
                style: R.textStyle.small(color: _emeraldLight, fontWeight: FontWeight.bold).copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 195,
          decoration: BoxDecoration(
            color: _bg2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _gold.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: progress.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada data tilawah',
                          style: TextStyle(color: _textSoft.withValues(alpha: 0.4)),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _chartScrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: progress.map((item) {
                            final date = item['date'] as DateTime;
                            final count = item['jumlah'] as int;
                            final isTargetMet = count >= target;
                            
                            // Hitung tinggi batang
                            // Maksimum 100px tinggi, target dipetakan ke 50px
                            final double barMaxHeight = 90.0;
                            double barHeight = 4.0;
                            if (target > 0) {
                              barHeight = (count / target * 50.0).clamp(4.0, barMaxHeight);
                            }

                            final isToday = date.day == DateTime.now().day &&
                                date.month == DateTime.now().month &&
                                date.year == DateTime.now().year;

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 22,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Tooltip jumlah ayat
                                  Text(
                                    count > 0 ? '$count' : '',
                                    style: R.textStyle.small(color: _goldLight).copyWith(fontSize: 8, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.visible,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: barMaxHeight,
                                    alignment: Alignment.bottomCenter,
                                    decoration: BoxDecoration(
                                      color: R.color.isDark
                                          ? _bg.withValues(alpha: 0.25)
                                          : Colors.black.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 500),
                                      height: barHeight,
                                      width: 22,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: isTargetMet
                                              ? [_emerald, _emeraldLight]
                                              : (isToday
                                                  ? [_gold, _goldLight]
                                                  : [_textSoft.withValues(alpha: 0.2), _textSoft.withValues(alpha: 0.4)]),
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${date.day}',
                                    style: R.textStyle.small(
                                      color: isToday ? _gold : _textSoft.withValues(alpha: 0.4),
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                    ).copyWith(fontSize: 9),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
              if (progress.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Target Tercapai', [_emerald, _emeraldLight]),
                    const SizedBox(width: 14),
                    _buildLegendItem('Hari Ini', [_gold, _goldLight]),
                    const SizedBox(width: 14),
                    _buildLegendItem('Membaca', [_textSoft.withValues(alpha: 0.2), _textSoft.withValues(alpha: 0.4)]),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, List<Color> colors) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: R.textStyle.small(color: _textSoft.withValues(alpha: 0.5)).copyWith(fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    final badgeList = _controller.badges;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lencana & Pencapaian',
              style: R.textStyle.mediumBold.copyWith(color: _goldLight),
            ),
            Obx(() {
              final unlockedCount = badgeList.where((b) => b.isUnlocked).length;
              return Text(
                '$unlockedCount/${badgeList.length} Terbuka',
                style: R.textStyle.small(color: _gold, fontWeight: FontWeight.bold),
              );
            }),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: badgeList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final badge = badgeList[index];
            return GestureDetector(
              onTap: () => _showBadgeDetail(context, badge),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: badge.isUnlocked
                      ? _emerald.withValues(alpha: 0.1)
                      : _bg2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: badge.isUnlocked
                        ? _emerald.withValues(alpha: 0.4)
                        : _gold.withValues(alpha: 0.1),
                    width: 1.2,
                  ),
                  boxShadow: badge.isUnlocked
                      ? [
                          BoxShadow(
                            color: _emerald.withValues(alpha: 0.08),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge Icon Circle
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: badge.isUnlocked
                                ? _emerald.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.15),
                            border: Border.all(
                              color: badge.isUnlocked ? _emerald : Colors.grey.shade700,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            badge.icon,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        if (!badge.isUnlocked)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                size: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Badge Title
                    Expanded(
                      child: Text(
                        badge.title.split(' ')[0], // Tampilkan teks utama
                        textAlign: TextAlign.center,
                        style: R.textStyle.smallBold.copyWith(
                          fontSize: 11,
                          color: badge.isUnlocked ? _textSoft : _textSoft.withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 5,
                        width: double.infinity,
                        child: LinearProgressIndicator(
                          value: badge.progressPercent,
                          backgroundColor: R.color.isDark
                              ? _bg.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.06),
                          color: badge.isUnlocked ? _emeraldLight : _goldDim,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge.progressString,
                      style: R.textStyle.small(
                        color: badge.isUnlocked ? _emeraldLight : _textSoft.withValues(alpha: 0.4),
                      ).copyWith(fontSize: 8, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showBadgeDetail(BuildContext context, TilawahBadge badge) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: _bg2,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Circle for Badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: badge.isUnlocked
                        ? _emerald.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.2),
                    border: Border.all(
                      color: badge.isUnlocked ? _emerald : Colors.grey,
                      width: 2,
                    ),
                    boxShadow: badge.isUnlocked
                        ? [
                            BoxShadow(
                              color: _emerald.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badge.icon,
                    style: const TextStyle(fontSize: 42),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  badge.title,
                  textAlign: TextAlign.center,
                  style: R.textStyle.largeBold.copyWith(color: _goldLight),
                ),
                const SizedBox(height: 10),
                Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  style: R.textStyle.medium(color: _textSoft.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 20),
                // Progress
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _bg.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status Pencapaian',
                        style: R.textStyle.small(color: _textSoft.withValues(alpha: 0.5)),
                      ),
                      Text(
                        badge.isUnlocked ? 'Terbuka 🎉' : 'Terkunci 🔒 (${badge.progressString})',
                        style: R.textStyle.smallBold.copyWith(
                          color: badge.isUnlocked ? _emeraldLight : R.color.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    badge.isUnlocked ? 'Luar Biasa!' : 'Tutup',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
