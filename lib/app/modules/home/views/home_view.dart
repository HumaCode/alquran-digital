import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/r.dart';
import 'package:alquran_digital/app/routes/app_pages.dart';
import '../../../data/models/surah_model.dart';
import '../controllers/home_controller.dart';
import '../widgets/surah_tile.dart';
import '../widgets/home_pattern_painter.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  static final Color _bg = R.color.bg1;
  static final Color _gold = R.color.gold;
  static final Color _goldLight = R.color.goldLight;
  static final Color _goldDim = R.color.goldDim;
  static final Color _textSoft = R.color.textSoft;
  static final Color _bg2 = R.color.bg2;
  static final Color _emeraldDark = R.color.emeraldDark;
  static final Color _emeraldMedium = R.color.emeraldMedium;

  final HomeController _homeController = Get.find<HomeController>();

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  int _activeTab = 0;
  final List<String> _tabs = [R.string.tabDaftarSurat, R.string.tabTerakhirDibaca, R.string.tabBookmark];

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
      child: Scaffold(
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
                                style: R.textStyle.extraLarge(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ).copyWith(
                                  fontSize: 34,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              R.string.homeSubtitle,
                              style: R.textStyle.small(
                                color: _textSoft.withOpacity(0.5),
                              ).copyWith(
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
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
                          arguments: {
                            'nomor': surahNo,
                            'ayat': ayatNo,
                          },
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
                          colors: [
                            _emeraldDark,
                            _emeraldMedium,
                          ],
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
                              gradient: LinearGradient(colors: [_goldDim, _gold]),
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
                                  style: R.textStyle.small(
                                    color: _textSoft.withValues(alpha: 0.5),
                                  ).copyWith(
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hasLast ? '$surahNama • Ayat $ayatNo' : 'Mulai membaca',
                                  style: R.textStyle.medium(
                                    fontWeight: FontWeight.w600,
                                    color: _goldLight,
                                  ).copyWith(
                                    fontSize: 16,
                                  ),
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

            // ── Tab Bar ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: R.color.bg2.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _goldDim.withOpacity(0.15),
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
                                  ? LinearGradient(
                                      colors: [_goldDim, _gold],
                                    )
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _tabs[index],
                              style: R.textStyle.medium(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? _bg : _textSoft.withOpacity(0.6),
                              ).copyWith(
                                fontSize: 13,
                              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _bg2.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _goldDim.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Obx(() => TextField(
                      controller: _homeController.searchController,
                      onChanged: (val) => _homeController.onSearchChanged(val),
                      style: R.textStyle.medium(color: _goldLight).copyWith(
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: R.string.searchHint,
                        hintStyle: R.textStyle.medium(
                          color: _textSoft.withValues(alpha: 0.4),
                        ).copyWith(fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: _goldDim, size: 20),
                        suffixIcon: _homeController.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: _goldDim, size: 20),
                                onPressed: () => _homeController.clearSearch(),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    )),
                  ),
                ),
              ),

            // ── Tab Content ──────────────────────────────────────────────
            if (_activeTab == 0) ...[
              // Daftar Surah (Dynamic from API)
              Obx(() {
                if (_homeController.isLoading.value) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: CustomLoader(size: 50),
                      ),
                    ),
                  );
                }

                if (_homeController.errorMessage.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
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
                      isBookmarked: _homeController.bookmarkedSurahIds.contains(surahList[i].nomor),
                      onBookmarkTapped: () async {
                        final surah = surahList[i];
                        final added = await _homeController.toggleBookmark(surah.nomor);
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
                        await Get.toNamed(Routes.DETAIL_SURAH, arguments: surahList[i].nomor);
                        _homeController.fetchLastRead();
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
                          style: TextStyle(color: _textSoft.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: GestureDetector(
                          onTap: () async {
                            await Get.toNamed(
                              Routes.DETAIL_SURAH,
                              arguments: {
                                'nomor': _homeController.lastReadSurahNomor.value,
                                'ayat': _homeController.lastReadAyatNomor.value,
                              },
                            );
                            _homeController.fetchLastRead();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: R.color.bg2.withValues(alpha: 0.6),
                              border: Border.all(color: _goldDim.withValues(alpha: 0.12), width: 1),
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
                                    style: R.textStyle.small(
                                      color: _goldLight,
                                      fontWeight: FontWeight.w700,
                                    ).copyWith(fontSize: 11, fontFamily: 'Poppins'),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _homeController.lastReadSurahNama.value,
                                        style: R.textStyle.medium(
                                          fontWeight: FontWeight.w600,
                                          color: _textSoft,
                                        ).copyWith(fontSize: 15, fontFamily: 'Poppins'),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Terakhir dibaca: Ayat ${_homeController.lastReadAyatNomor.value}',
                                        style: R.textStyle.small(
                                          color: _textSoft.withValues(alpha: 0.4),
                                        ).copyWith(fontFamily: 'Poppins'),
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
                    },
                    childCount: 1,
                  ),
                );
              }),
            ] else ...[
              // Bookmarks
              Obx(() {
                final listToUse = _homeController.allSurahs;
                final bookmarkedList = listToUse
                    .where((s) => _homeController.bookmarkedSurahIds.contains(s.nomor))
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
                            'Belum ada bookmark',
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
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final item = bookmarkedList[i];
                      return SurahTile(
                        item: item,
                        gold: _gold,
                        goldLight: _goldLight,
                        goldDim: _goldDim,
                        textSoft: _textSoft,
                        isBookmarked: true,
                        onBookmarkTapped: () async {
                          final added = await _homeController.toggleBookmark(item.nomor);
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
                          await Get.toNamed(Routes.DETAIL_SURAH, arguments: item.nomor);
                          _homeController.fetchLastRead();
                        },
                      );
                    },
                    childCount: bookmarkedList.length,
                  ),
                );
              }),
            ],

            SliverToBoxAdapter(
              child: Obx(() {
                if (_homeController.isMoreLoading.value) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CustomLoader(size: 40),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
            
            SliverToBoxAdapter(
              child: Obx(() {
                if (_homeController.showScrollToTop.value) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: _goldDim.withValues(alpha: 0.3)),
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
            offset: _homeController.showScrollToTop.value ? Offset.zero : const Offset(0, 2),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _homeController.showScrollToTop.value ? 1.0 : 0.0,
              child: FloatingActionButton(
                onPressed: () => _homeController.scrollToTop(),
                backgroundColor: _gold,
                foregroundColor: _bg,
                shape: const CircleBorder(),
                elevation: 4,
                child: const Icon(Icons.keyboard_double_arrow_up_rounded, size: 28),
              ),
            ),
          );
        }),
      ),
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
            right: BorderSide(
              color: _goldDim.withOpacity(0.15),
              width: 1,
            ),
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
                                color: Colors.white,
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
                      title: 'Kumpulan Doa',
                      subtitle: 'Doa harian & pilihan syar\'i',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(Routes.DOA);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDrawerItem(
                      icon: Icons.access_time_rounded,
                      title: 'Jadwal Sholat',
                      subtitle: 'Waktu sholat 5 waktu akurat',
                      onTap: () {
                        Navigator.pop(context);
                        CustomAlert.show(
                          context,
                          title: 'Jadwal Sholat',
                          message: 'Fitur Jadwal Sholat akan segera hadir!',
                          confirmText: 'OK',
                          icon: Icons.access_time_rounded,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDrawerItem(
                      icon: Icons.nights_stay_rounded,
                      title: 'Jadwal Imsakiyah',
                      subtitle: 'Panduan waktu imsak & buka',
                      onTap: () {
                        Navigator.pop(context);
                        CustomAlert.show(
                          context,
                          title: 'Jadwal Imsakiyah',
                          message: 'Fitur Jadwal Imsakiyah akan segera hadir!',
                          confirmText: 'OK',
                          icon: Icons.nights_stay_rounded,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDrawerItem(
                      icon: Icons.compass_calibration_rounded,
                      title: 'Arah Kiblat',
                      subtitle: 'Kompas penunjuk arah Ka\'bah',
                      onTap: () {
                        Navigator.pop(context);
                        CustomAlert.show(
                          context,
                          title: 'Arah Kiblat',
                          message: 'Fitur Arah Kiblat akan segera hadir!',
                          confirmText: 'OK',
                          icon: Icons.compass_calibration_rounded,
                        );
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
                      style: R.textStyle.small(
                        color: _textSoft.withOpacity(0.3),
                      ).copyWith(letterSpacing: 0.5),
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
            border: Border.all(
              color: _goldDim.withOpacity(0.08),
              width: 1,
            ),
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
                child: Icon(
                  icon,
                  color: _goldLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: R.textStyle.mediumBold.copyWith(
                        color: Colors.white,
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
}
