import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/r.dart';
import 'package:alquran_digital/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../widgets/surah_tile.dart';
import '../widgets/home_pattern_painter.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';
import '../../../data/providers/theme_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  Color get _bg => R.color.bg1;
  Color get _gold => R.color.gold;
  Color get _goldLight => R.color.goldLight;
  Color get _goldDim => R.color.goldDim;
  Color get _textSoft => R.color.textSoft;
  Color get _bg2 => R.color.bg2;
  Color get _emeraldDark => R.color.emeraldDark;
  Color get _emeraldMedium => R.color.emeraldMedium;

  final HomeController _homeController = Get.find<HomeController>();

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  int _activeTab = 0;
  int _activeBookmarkSubTab = 0;
  final List<String> _tabs = [
    R.string.tabDaftarSurat,
    R.string.tabTerakhirDibaca,
    R.string.tabBookmark,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Obx(() {
        // Force dependency on isDarkMode so it rebuilds when theme changes
        ThemeController.to.isDarkMode.value;
        return Scaffold(
          backgroundColor: _bg,
          drawer: _buildDrawer(context),
          body: CustomScrollView(
            controller: _homeController.scrollController,
            slivers: [
              // ── App Bar ──────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: _bg,
                elevation: 0,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    color: _gold,
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.bookmark_rounded, color: _gold),
                    tooltip: 'Bookmark Ayat',
                    onPressed: () async {
                      await Get.toNamed(Routes.BOOKMARKS);
                      _homeController.fetchBookmarks();
                      _homeController.fetchBookmarkedAyats();
                    },
                  ),
                  Obx(() {
                    final isDark = ThemeController.to.isDarkMode.value;
                    return IconButton(
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
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          key: ValueKey<bool>(isDark),
                          color: _gold,
                        ),
                      ),
                      tooltip: 'Ubah Tema',
                      onPressed: () {
                        ThemeController.to.toggleTheme();
                      },
                    );
                  }),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_bg2, _bg],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.04,
                            child: CustomPaint(
                              painter: HomePatternPainter(color: _gold),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -25,
                          bottom: -25,
                          child: Opacity(
                            opacity: ThemeController.to.isDarkMode.value ? 0.09 : 0.06,
                            child: Transform.rotate(
                              angle: -0.2,
                              child: Icon(
                                Icons.menu_book_rounded,
                                size: 160,
                                color: _goldLight,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom: 20,
                            top: 60,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (b) => LinearGradient(
                                  colors: [_goldDim, _goldLight],
                                ).createShader(b),
                                child: Text(
                                  R.string.appTitle,
                                  style: R.textStyle
                                      .extraLarge(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      )
                                      .copyWith(
                                        fontSize: 34,
                                        letterSpacing: 1.5,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                R.string.homeSubtitle,
                                style: R.textStyle
                                    .small(color: _textSoft.withOpacity(0.5))
                                    .copyWith(fontSize: 13, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Last Read Banner ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Obx(() {
                  final hasLast = _homeController.hasLastRead.value;
                  final surahNama = _homeController.lastReadSurahNama.value;
                  final ayatNo = _homeController.lastReadAyatNomor.value;
                  final surahNo = _homeController.lastReadSurahNomor.value;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: GestureDetector(
                      onTap: () async {
                        if (hasLast) {
                          await Get.toNamed(
                            Routes.DETAIL_SURAH,
                            arguments: {'nomor': surahNo, 'ayat': ayatNo},
                          );
                        } else {
                          // Mulai dari Al-Fatihah jika belum ada riwayat
                          await Get.toNamed(Routes.DETAIL_SURAH, arguments: 1);
                        }
                        _homeController.fetchLastRead();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: R.color.isDark
                                ? [_emeraldDark, _emeraldMedium]
                                : [R.color.emerald.withValues(alpha: 0.85), R.color.emeraldLight.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _goldDim.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withValues(alpha: 0.08),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [_goldDim, _gold],
                                ),
                              ),
                              child: Icon(
                                Icons.bookmark_rounded,
                                color: _bg,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    R.string.lastRead,
                                    style: R.textStyle
                                        .small(
                                          color: _textSoft.withValues(
                                            alpha: 0.5,
                                          ),
                                        )
                                        .copyWith(
                                          fontSize: 11,
                                          letterSpacing: 1.5,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    hasLast
                                        ? '$surahNama • Ayat $ayatNo'
                                        : 'Mulai membaca',
                                    style: R.textStyle
                                        .medium(
                                          fontWeight: FontWeight.w600,
                                          color: _goldLight,
                                        )
                                        .copyWith(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: _goldDim,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // ── Tilawah Tracker Card ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _bg2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _gold.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row: Tracker target + Edit button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.track_changes_rounded, color: _gold, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                R.string.tilawahTargetTitle,
                                style: R.textStyle.medium(
                                  fontWeight: FontWeight.w600,
                                  color: _goldLight,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Statistik Detail Button
                              InkWell(
                                onTap: () async {
                                  await Get.toNamed(Routes.STATISTIK);
                                  _homeController.fetchTilawahTracker();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _emeraldLight.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _emeraldLight.withValues(alpha: 0.25)),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Detail",
                                        style: R.textStyle.small(color: _emeraldLight, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.bar_chart_rounded, color: _emeraldLight, size: 12),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Interactive target selector
                              InkWell(
                                onTap: () => _showTargetDialog(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _gold.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _gold.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Obx(() => Text(
                                        "${_homeController.tilawahTarget.value} ${R.string.tilawahAyatSuffix}",
                                        style: R.textStyle.small(color: _goldLight, fontWeight: FontWeight.bold),
                                      )),
                                      const SizedBox(width: 4),
                                      Icon(Icons.edit_rounded, color: _gold, size: 12),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Progress indicator & streak
                      Row(
                        children: [
                          // Circular Progress Indicator
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Obx(() {
                                final ratio = _homeController.tilawahTarget.value > 0
                                    ? (_homeController.tilawahToday.value / _homeController.tilawahTarget.value).clamp(0.0, 1.0)
                                    : 0.0;
                                return SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    value: ratio,
                                    backgroundColor: R.color.isDark ? _bg.withValues(alpha: 0.15) : Colors.black.withOpacity(0.06),
                                    color: R.color.emerald,
                                    strokeWidth: 6,
                                  ),
                                );
                              }),
                              Obx(() => Text(
                                "${_homeController.tilawahToday.value}",
                                style: R.textStyle.medium(
                                  fontWeight: FontWeight.bold,
                                  color: _goldLight,
                                ),
                              )),
                            ],
                          ),
                          const SizedBox(width: 16),
                          
                          // Streak and summary text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() {
                                  final streak = _homeController.tilawahStreak.value;
                                  return Text(
                                    streak > 0 ? R.string.tilawahStreakText(streak) : R.string.tilawahStreakEmpty,
                                    style: R.textStyle.medium(
                                      fontWeight: FontWeight.bold,
                                      color: streak > 0 ? R.color.orange : _goldLight,
                                    ),
                                  );
                                }),
                                const SizedBox(height: 4),
                                Obx(() {
                                  final left = _homeController.tilawahTarget.value - _homeController.tilawahToday.value;
                                  return Text(
                                    left > 0
                                        ? R.string.tilawahStatusPending(left)
                                        : R.string.tilawahStatusDone,
                                    style: R.textStyle.small(color: _textSoft.withValues(alpha: 0.7)),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // 7-day progress bar chart
                      Text(
                        R.string.tilawahWeeklyProgress,
                        style: R.textStyle.small(color: _textSoft.withValues(alpha: 0.6)).copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      
                      // The chart widget
                      _buildWeeklyChart(),
                    ],
                  ),
                ),
              ),

              // ── Tab Bar ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: R.color.isDark
                          ? R.color.bg2.withOpacity(0.5)
                          : Colors.black.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _goldDim.withOpacity(R.color.isDark ? 0.15 : 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: List.generate(_tabs.length, (index) {
                        final isSelected = _activeTab == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeTab = index;
                                if (_activeTab != 0) {
                                  _homeController.clearSearch();
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: isSelected
                                    ? LinearGradient(colors: [_goldDim, _gold])
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _tabs[index],
                                style: R.textStyle
                                    .medium(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? _bg
                                          : _textSoft.withOpacity(0.6),
                                    )
                                    .copyWith(fontSize: 13),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // ── Search Bar ───────────────────────────────────────────────
              if (_activeTab == 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _bg2.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _goldDim.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Obx(
                        () => TextField(
                          controller: _homeController.searchController,
                          onChanged: (val) =>
                              _homeController.onSearchChanged(val),
                          style: R.textStyle
                              .medium(color: _goldLight)
                              .copyWith(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: R.string.searchHint,
                            hintStyle: R.textStyle
                                .medium(color: _textSoft.withValues(alpha: 0.4))
                                .copyWith(fontSize: 14),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: _goldDim,
                              size: 20,
                            ),
                            suffixIcon: _homeController.searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: _goldDim,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _homeController.clearSearch(),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Search Type Selector ───────────────────────────────────────
              if (_activeTab == 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _bg2.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _goldDim.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildSearchTypeTab('surah', 'Cari Surah')),
                          const SizedBox(width: 4),
                          Expanded(child: _buildSearchTypeTab('ayat', 'Cari Ayat (Global)')),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Bookmark Sub-Tab Selector ──────────────────────────────────
              if (_activeTab == 2)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: R.color.isDark
                            ? _bg2.withValues(alpha: 0.3)
                            : Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _goldDim.withValues(alpha: R.color.isDark ? 0.15 : 0.30),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildBookmarkSubTab(0, 'Daftar Surah')),
                          const SizedBox(width: 4),
                          Expanded(child: _buildBookmarkSubTab(1, 'Daftar Ayat')),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Tab Content ──────────────────────────────────────────────
              if (_activeTab == 0) ...[
                // Daftar Surah (Dynamic from API) / Hasil Pencarian Ayat Global
                Obx(() {
                  final isAyatSearch = _homeController.searchType.value == 'ayat' && _homeController.searchQuery.value.isNotEmpty;

                  if (isAyatSearch) {
                    if (_homeController.isSearchLoading.value) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 80),
                          child: Center(child: CustomLoader(size: 44)),
                        ),
                      );
                    }

                    final results = _homeController.searchedAyats;
                    if (results.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 80),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: _goldDim.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Ayat tidak ditemukan',
                                  style: R.textStyle.medium(
                                    fontWeight: FontWeight.w600,
                                    color: _textSoft,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Coba cari kata kunci lain seperti "sabar" atau "sholat".',
                                  style: R.textStyle.small(
                                    color: _textSoft.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = results[index];
                        final nomorSurah = item['nomorSurah'] as int;
                        final namaSurah = item['namaSurah'] as String;
                        final nomorAyat = item['nomorAyat'] as int;
                        final teksArab = item['teksArab'] as String;
                        final teksLatin = item['teksLatin'] as String;
                        final teksIndonesia = item['teksIndonesia'] as String;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _bg2.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: _goldDim.withValues(alpha: 0.12)),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () async {
                                await Get.toNamed(
                                  Routes.DETAIL_SURAH,
                                  arguments: {
                                    'nomor': nomorSurah,
                                    'ayat': nomorAyat,
                                  },
                                );
                                _homeController.fetchLastRead();
                                _homeController.fetchBookmarks();
                                _homeController.fetchBookmarkedAyats();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _goldDim.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'QS. $namaSurah [$nomorSurah:$nomorAyat]',
                                          style: R.textStyle.smallBold.copyWith(color: _goldLight),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      teksArab,
                                      textAlign: TextAlign.right,
                                      style: R.textStyle.large(
                                        color: _goldLight,
                                        fontWeight: FontWeight.w500,
                                      ).copyWith(
                                        fontFamily: 'Poppins',
                                        fontSize: 20,
                                        height: 1.8,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildHighlightedText(
                                      teksLatin,
                                      _homeController.searchQuery.value,
                                      style: R.textStyle.medium(
                                        color: _goldLight.withValues(alpha: 0.8),
                                      ).copyWith(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 13,
                                      ),
                                      highlightStyle: R.textStyle.mediumBold.copyWith(
                                        color: _gold,
                                        backgroundColor: _gold.withValues(alpha: 0.2),
                                        fontStyle: FontStyle.italic,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildHighlightedText(
                                      teksIndonesia,
                                      _homeController.searchQuery.value,
                                      style: R.textStyle.medium(color: _textSoft),
                                      highlightStyle: R.textStyle.mediumBold.copyWith(
                                        color: _gold,
                                        backgroundColor: _gold.withValues(alpha: 0.2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: results.length),
                    );
                  }

                  if (_homeController.isLoading.value) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Center(child: CustomLoader(size: 50)),
                      ),
                    );
                  }

                  if (_homeController.errorMessage.isNotEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _homeController.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: R.textStyle.medium(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _homeController.fetchSurahs(),
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(R.string.tryAgain),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _gold,
                                foregroundColor: _bg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final surahList = _homeController.surahs;
                  if (surahList.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            R.string.noSurahFound,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => SurahTile(
                        item: surahList[i],
                        gold: _gold,
                        goldLight: _goldLight,
                        goldDim: _goldDim,
                        textSoft: _textSoft,
                        isBookmarked: _homeController.bookmarkedSurahIds
                            .contains(surahList[i].nomor),
                        onBookmarkTapped: () async {
                          final surah = surahList[i];
                          final added = await _homeController.toggleBookmark(
                            surah.nomor,
                          );
                          if (context.mounted) {
                            CustomToast.show(
                              context,
                              message: added
                                  ? 'Surah ${surah.namaLatin} ditambahkan ke bookmark'
                                  : 'Surah ${surah.namaLatin} dihapus dari bookmark',
                            );
                          }
                        },
                        onTap: () async {
                          await Get.toNamed(
                            Routes.DETAIL_SURAH,
                            arguments: surahList[i].nomor,
                          );
                          _homeController.fetchLastRead();
                          _homeController.fetchBookmarks();
                          _homeController.fetchBookmarkedAyats();
                        },
                      ),
                      childCount: surahList.length,
                    ),
                  );
                }),
              ] else if (_activeTab == 1) ...[
                // Terakhir Dibaca (History)
                Obx(() {
                  if (!_homeController.hasLastRead.value) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: Text(
                            'Belum ada riwayat membaca',
                            style: TextStyle(
                              color: _textSoft.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            await Get.toNamed(
                              Routes.DETAIL_SURAH,
                              arguments: {
                                'nomor':
                                    _homeController.lastReadSurahNomor.value,
                                'ayat': _homeController.lastReadAyatNomor.value,
                              },
                            );
                            _homeController.fetchLastRead();
                            _homeController.fetchBookmarks();
                            _homeController.fetchBookmarkedAyats();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: R.color.bg2.withValues(alpha: 0.6),
                              border: Border.all(
                                color: _goldDim.withValues(alpha: 0.12),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _goldDim.withValues(alpha: 0.15),
                                  ),
                                  child: Text(
                                    '1',
                                    style: R.textStyle
                                        .small(
                                          color: _goldLight,
                                          fontWeight: FontWeight.w700,
                                        )
                                        .copyWith(
                                          fontSize: 11,
                                          fontFamily: 'Poppins',
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _homeController.lastReadSurahNama.value,
                                        style: R.textStyle
                                            .medium(
                                              fontWeight: FontWeight.w600,
                                              color: _textSoft,
                                            )
                                            .copyWith(
                                              fontSize: 15,
                                              fontFamily: 'Poppins',
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Terakhir dibaca: Ayat ${_homeController.lastReadAyatNomor.value}',
                                        style: R.textStyle
                                            .small(
                                              color: _textSoft.withValues(
                                                alpha: 0.4,
                                              ),
                                            )
                                            .copyWith(fontFamily: 'Poppins'),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: _goldDim,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: 1),
                  );
                }),
              ] else ...[
                // Bookmarks
                Obx(() {
                  if (_activeBookmarkSubTab == 0) {
                    // Daftar Surah Bookmark
                    final listToUse = _homeController.allSurahs;
                    final bookmarkedList = listToUse
                        .where(
                          (s) => _homeController.bookmarkedSurahIds.contains(
                            s.nomor,
                          ),
                        )
                        .toList();

                    if (bookmarkedList.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Icon(
                                Icons.bookmark_outline_rounded,
                                size: 48,
                                color: _goldDim.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada bookmark surah',
                                style: R.textStyle.medium(
                                  fontWeight: FontWeight.w600,
                                  color: _textSoft,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ketuk ikon bookmark untuk menandai surah favorit.',
                                style: R.textStyle.small(
                                  color: _textSoft.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, i) {
                        final item = bookmarkedList[i];
                        return SurahTile(
                          item: item,
                          gold: _gold,
                          goldLight: _goldLight,
                          goldDim: _goldDim,
                          textSoft: _textSoft,
                          isBookmarked: true,
                          onBookmarkTapped: () async {
                            final added = await _homeController.toggleBookmark(
                              item.nomor,
                            );
                            if (context.mounted) {
                              CustomToast.show(
                                context,
                                message: added
                                    ? 'Surah ${item.namaLatin} ditambahkan ke bookmark'
                                    : 'Surah ${item.namaLatin} dihapus dari bookmark',
                              );
                            }
                          },
                          onTap: () async {
                            await Get.toNamed(
                              Routes.DETAIL_SURAH,
                              arguments: item.nomor,
                            );
                            _homeController.fetchLastRead();
                            _homeController.fetchBookmarks();
                            _homeController.fetchBookmarkedAyats();
                          },
                        );
                      }, childCount: bookmarkedList.length),
                    );
                  } else {
                    // Daftar Ayat Bookmark
                    final list = _homeController.bookmarkedAyats;
                    if (list.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Icon(
                                Icons.bookmark_outline_rounded,
                                size: 48,
                                color: _goldDim.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada bookmark ayat',
                                style: R.textStyle.medium(
                                  fontWeight: FontWeight.w600,
                                  color: _textSoft,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ketuk ikon bookmark di detail surah untuk menyimpan ayat.',
                                style: R.textStyle.small(
                                  color: _textSoft.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = list[index];
                        final nomorSurah = item['nomorSurah'] as int;
                        final namaSurah = item['namaSurah'] as String;
                        final nomorAyat = item['nomorAyat'] as int;
                        final teksArab = item['teksArab'] as String;
                        final teksIndonesia = item['teksIndonesia'] as String;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _bg2.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: _goldDim.withValues(alpha: 0.12)),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () async {
                                await Get.toNamed(
                                  Routes.DETAIL_SURAH,
                                  arguments: {
                                    'nomor': nomorSurah,
                                    'ayat': nomorAyat,
                                  },
                                );
                                _homeController.fetchLastRead();
                                _homeController.fetchBookmarks();
                                _homeController.fetchBookmarkedAyats();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _goldDim.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'QS. $namaSurah [$nomorSurah:$nomorAyat]',
                                            style: R.textStyle.smallBold.copyWith(color: _goldLight),
                                          ),
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(8),
                                            onTap: () {
                                              _showDeleteConfirmation(context, nomorSurah, namaSurah, nomorAyat);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Icon(Icons.delete_outline_rounded, color: R.color.red, size: 20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      teksArab,
                                      textAlign: TextAlign.right,
                                      style: R.textStyle.large(
                                        color: _goldLight,
                                        fontWeight: FontWeight.w500,
                                      ).copyWith(
                                        fontFamily: 'Poppins',
                                        fontSize: 20,
                                        height: 1.8,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      teksIndonesia,
                                      textAlign: TextAlign.left,
                                      style: R.textStyle.medium(color: _textSoft),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: list.length),
                    );
                  }
                }),
              ],

              SliverToBoxAdapter(
                child: Obx(() {
                  if (_homeController.isMoreLoading.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CustomLoader(size: 40)),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),

              SliverToBoxAdapter(
                child: Obx(() {
                  if (_homeController.showScrollToTop.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 40,
                      ),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: () => _homeController.scrollToTop(),
                          icon: Icon(Icons.arrow_upward_rounded, color: _gold),
                          label: Text(
                            R.string.backToTop,
                            style: R.textStyle.medium(
                              color: _goldLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: _bg2,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: _goldDim.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          floatingActionButton: Obx(() {
            return AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _homeController.showScrollToTop.value
                  ? Offset.zero
                  : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _homeController.showScrollToTop.value ? 1.0 : 0.0,
                child: FloatingActionButton(
                  onPressed: () => _homeController.scrollToTop(),
                  backgroundColor: _gold,
                  foregroundColor: _bg,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: const Icon(
                    Icons.keyboard_double_arrow_up_rounded,
                    size: 28,
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: _bg2.withOpacity(0.96),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          border: Border(
            right: BorderSide(color: _goldDim.withOpacity(0.15), width: 1),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _gold, width: 1.5),
                            gradient: LinearGradient(
                              colors: [_goldDim, _gold],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: _bg,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              R.string.appTitle,
                              style: R.textStyle.largeBold.copyWith(
                                color: _textSoft,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Fitur Islami Lengkap',
                              style: R.textStyle.small(
                                color: _textSoft.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(color: _goldDim.withOpacity(0.15), height: 1),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.menu_book_rounded,
                      title: R.string.sidebarPrayers,
                      subtitle: R.string.sidebarPrayersSubtitle,
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(Routes.DOA);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDrawerItem(
                      icon: Icons.access_time_rounded,
                      title: R.string.sidebarPrayerTimes,
                      subtitle: R.string.sidebarPrayerTimesSubtitle,
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(Routes.JADWAL_SHOLAT);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDrawerItem(
                      icon: Icons.nights_stay_rounded,
                      title: R.string.sidebarImsakiyah,
                      subtitle: R.string.sidebarImsakiyahSubtitle,
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(Routes.IMSAKIYAH);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDrawerItem(
                      icon: Icons.compass_calibration_rounded,
                      title: R.string.sidebarQibla,
                      subtitle: R.string.sidebarQiblaSubtitle,
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(Routes.ARAH_KIBLAT);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDrawerItem(
                      icon: Icons.library_music_rounded,
                      title: R.string.sidebarMurotal,
                      subtitle: R.string.sidebarMurotalSubtitle,
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(Routes.MUROTAL);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDrawerItem(
                      icon: Icons.bookmark_rounded,
                      title: R.string.sidebarBookmarks,
                      subtitle: R.string.sidebarBookmarksSubtitle,
                      onTap: () async {
                        Navigator.pop(context);
                        await Get.toNamed(Routes.BOOKMARKS);
                        _homeController.fetchBookmarks();
                        _homeController.fetchBookmarkedAyats();
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDrawerItem(
                      icon: Icons.bar_chart_rounded,
                      title: R.string.sidebarStatistik,
                      subtitle: R.string.sidebarStatistikSubtitle,
                      onTap: () async {
                        Navigator.pop(context);
                        await Get.toNamed(Routes.STATISTIK);
                        _homeController.fetchTilawahTracker();
                      },
                    ),
                  ],
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Divider(color: _goldDim.withOpacity(0.15), height: 1),
                    const SizedBox(height: 16),
                    Text(
                      'Al-Qur\'an Digital v1.0.0',
                      style: R.textStyle
                          .small(color: _textSoft.withOpacity(0.3))
                          .copyWith(letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkSubTab(int index, String label) {
    final isSelected = _activeBookmarkSubTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeBookmarkSubTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _gold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: R.textStyle.medium(
            color: isSelected ? _bg : _textSoft,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ).copyWith(fontSize: 12),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int nomorSurah, String namaSurah, int nomorAyat) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: _bg2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulseWaveIcon(
                icon: Icons.delete_forever_rounded,
                color: R.color.red,
              ),
              const SizedBox(height: 20),
              Text(
                'Hapus Bookmark',
                style: R.textStyle.largeBold.copyWith(color: _textSoft),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus QS. $namaSurah [$nomorSurah:$nomorAyat] dari daftar bookmark?',
                textAlign: TextAlign.center,
                style: R.textStyle.medium(color: _textSoft.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _goldDim.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        'Batal',
                        style: R.textStyle.medium(color: _textSoft.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: R.color.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _homeController.deleteAyatBookmark(nomorSurah, nomorAyat);
                        Get.back();
                        CustomToast.show(
                          context,
                          message: 'Bookmark QS. $namaSurah [$nomorSurah:$nomorAyat] berhasil dihapus',
                          type: ToastType.success,
                        );
                      },
                      child: Text(
                        'Hapus',
                        style: R.textStyle.mediumBold.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: _gold.withOpacity(0.08),
        highlightColor: _gold.withOpacity(0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _goldDim.withOpacity(0.08), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _goldDim.withOpacity(0.1),
                ),
                child: Icon(icon, color: _goldLight, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: R.textStyle.mediumBold.copyWith(
                        color: _textSoft,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: R.textStyle.small(
                        color: _textSoft.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: _goldDim.withOpacity(0.3),
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTypeTab(String type, String label) {
    return Obx(() {
      final isSelected = _homeController.searchType.value == type;
      return GestureDetector(
        onTap: () {
          _homeController.changeSearchType(type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _gold : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: R.textStyle.medium(
              color: isSelected ? _bg : _textSoft,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ).copyWith(fontSize: 12),
          ),
        ),
      );
    });
  }

  Widget _buildHighlightedText(
    String text,
    String highlightQuery, {
    required TextStyle style,
    required TextStyle highlightStyle,
  }) {
    if (highlightQuery.isEmpty) {
      return Text(text, style: style);
    }

    final String query = highlightQuery.toLowerCase();
    final String source = text;
    final List<TextSpan> spans = [];

    int start = 0;
    int index = source.toLowerCase().indexOf(query, start);

    while (index != -1) {
      // Add normal text before matched query
      if (index > start) {
        spans.add(TextSpan(
          text: source.substring(start, index),
          style: style,
        ));
      }

      // Add highlighted matched text
      spans.add(TextSpan(
        text: source.substring(index, index + query.length),
        style: highlightStyle,
      ));

      start = index + query.length;
      index = source.toLowerCase().indexOf(query, start);
    }

    // Add remaining text after last match
    if (start < source.length) {
      spans.add(TextSpan(
        text: source.substring(start),
        style: style,
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }

  Widget _buildWeeklyChart() {
    final now = DateTime.now();
    final dates = List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));

    return Obx(() {
      final progressList = _homeController.tilawahProgress;
      final target = _homeController.tilawahTarget.value;
      
      final progressMap = <String, int>{};
      for (var item in progressList) {
        progressMap[item['tanggal'] as String] = item['jumlahAyatDibaca'] as int;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: dates.map((date) {
          final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          final count = progressMap[dateStr] ?? 0;
          
          final double barHeight = target > 0 ? (count / target * 60.0).clamp(4.0, 60.0) : 4.0;
          final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
          final isTargetMet = count >= target;
          
          final dayName = _getDayName(date.weekday);

          return Column(
            children: [
              Text(
                count > 0 ? "$count" : "0",
                style: R.textStyle.small(color: _goldDim).copyWith(fontSize: 9),
              ),
              const SizedBox(height: 4),
              Container(
                width: 16,
                height: 60,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  color: R.color.isDark ? _bg.withValues(alpha: 0.15) : Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 16,
                  height: barHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: isTargetMet
                          ? [R.color.emerald, R.color.emeraldLight]
                          : (isToday ? [_gold, _goldLight] : [_textSoft.withValues(alpha: 0.3), _textSoft.withValues(alpha: 0.5)]),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dayName,
                style: R.textStyle.small(
                  color: isToday ? _gold : _textSoft.withValues(alpha: 0.5),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ).copyWith(fontSize: 10),
              ),
            ],
          );
        }).toList(),
      );
    });
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Sen';
      case DateTime.tuesday:
        return 'Sel';
      case DateTime.wednesday:
        return 'Rab';
      case DateTime.thursday:
        return 'Kam';
      case DateTime.friday:
        return 'Jum';
      case DateTime.saturday:
        return 'Sab';
      case DateTime.sunday:
      default:
        return 'Min';
    }
  }

  void _showTargetDialog(BuildContext context) {
    final controller = TextEditingController(
      text: _homeController.tilawahTarget.value.toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _bg2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _gold.withValues(alpha: 0.2)),
          ),
          title: Text(
            R.string.tilawahSetTargetTitle,
            style: R.textStyle.medium(fontWeight: FontWeight.bold, color: _goldLight),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                R.string.tilawahSetTargetSubtitle,
                style: R.textStyle.small(color: _textSoft),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: R.textStyle.medium(color: _goldLight),
                decoration: InputDecoration(
                  labelText: R.string.tilawahTargetLabel,
                  labelStyle: TextStyle(color: _goldDim),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _gold.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _gold),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(R.string.cancel, style: TextStyle(color: _textSoft)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final target = int.tryParse(controller.text) ?? 10;
                _homeController.updateDailyTarget(target);
                Navigator.of(context).pop();
              },
              child: Text(R.string.save, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
