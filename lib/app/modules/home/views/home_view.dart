import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/r.dart';
import 'package:alquran_digital/app/routes/app_pages.dart';
import '../../../data/models/surah_model.dart';
import '../controllers/home_controller.dart';
import '../widgets/surah_tile.dart';
import '../widgets/home_pattern_painter.dart';

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
  final Set<int> _bookmarks = {1, 36, 67};
  final List<String> _tabs = ['Daftar Surah', 'Terakhir', 'Bookmark'];

  final List<DataSurah> _mockSurahs = [
    DataSurah(nomor: 1, nama: 'الفاتحة', namaLatin: 'Al-Fatihah', jumlahAyat: 7, tempatTurun: 'Mekah', arti: 'Pembukaan', deskripsi: '', audioFull: {}),
    DataSurah(nomor: 2, nama: 'البقرة', namaLatin: 'Al-Baqarah', jumlahAyat: 286, tempatTurun: 'Madinah', arti: 'Sapi Betina', deskripsi: '', audioFull: {}),
    DataSurah(nomor: 3, nama: 'آل عمران', namaLatin: 'Ali \'Imran', jumlahAyat: 200, tempatTurun: 'Madinah', arti: 'Keluarga Imran', deskripsi: '', audioFull: {}),
    DataSurah(nomor: 4, nama: 'النساء', namaLatin: 'An-Nisa\'', jumlahAyat: 176, tempatTurun: 'Madinah', arti: 'Wanita', deskripsi: '', audioFull: {}),
    DataSurah(nomor: 5, nama: 'المائدة', namaLatin: 'Al-Maidah', jumlahAyat: 120, tempatTurun: 'Madinah', arti: 'Hidangan', deskripsi: '', audioFull: {}),
    DataSurah(nomor: 36, nama: 'يس', namaLatin: 'Ya-Sin', jumlahAyat: 83, tempatTurun: 'Mekah', arti: 'Ya Sin', deskripsi: '', audioFull: {}),
    DataSurah(nomor: 55, nama: 'الرحمن', namaLatin: 'Ar-Rahman', jumlahAyat: 78, tempatTurun: 'Madinah', arti: 'Yang Maha Pemurah', deskripsi: '', audioFull: {}),
    DataSurah(nomor: 67, nama: 'الملك', namaLatin: 'Al-Mulk', jumlahAyat: 30, tempatTurun: 'Mekah', arti: 'Kerajaan', deskripsi: '', audioFull: {}),
    DataSurah(nomor: 112, nama: 'الإخلاص', namaLatin: 'Al-Ikhlas', jumlahAyat: 4, tempatTurun: 'Mekah', arti: 'Kemurnian Keesaan Allah', deskripsi: '', audioFull: {}),
    DataSurah(nomor: 113, nama: 'الفلق', namaLatin: 'Al-Falaq', jumlahAyat: 5, tempatTurun: 'Mekah', arti: 'Waktu Subuh', deskripsi: '', audioFull: {}),
    DataSurah(nomor: 114, nama: 'الناس', namaLatin: 'An-Nas', jumlahAyat: 6, tempatTurun: 'Mekah', arti: 'Manusia', deskripsi: '', audioFull: {}),
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
      child: Scaffold(
        backgroundColor: _bg,
        drawer: _buildDrawer(context),
        body: CustomScrollView(
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
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
                      color: _goldDim.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withOpacity(0.08),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            R.string.lastRead,
                            style: R.textStyle.small(
                              color: _textSoft.withOpacity(0.5),
                            ).copyWith(
                              fontSize: 11,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Al-Baqarah • Ayat 255',
                            style: R.textStyle.medium(
                              fontWeight: FontWeight.w600,
                              color: _goldLight,
                            ).copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _goldDim,
                        size: 16,
                      ),
                    ],
                  ),
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

            // ── Tab Content ──────────────────────────────────────────────
            if (_activeTab == 0) ...[
              // Daftar Surah (Dynamic from API)
              Obx(() {
                if (_homeController.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                        ),
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
                            label: const Text('Coba Lagi'),
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
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Tidak ada surah ditemukan',
                          style: TextStyle(color: Colors.white),
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
                      isBookmarked: _bookmarks.contains(surahList[i].nomor),
                      onBookmarkTapped: () {
                        setState(() {
                          if (_bookmarks.contains(surahList[i].nomor)) {
                            _bookmarks.remove(surahList[i].nomor);
                          } else {
                            _bookmarks.add(surahList[i].nomor);
                          }
                        });
                      },
                      onTap: () {
                        Get.toNamed(Routes.DETAIL_SURAH, arguments: surahList[i].nomor);
                      },
                    ),
                    childCount: surahList.length,
                  ),
                );
              }),
            ] else if (_activeTab == 1) ...[
              // Terakhir Dibaca (History)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final history = [
                      DataSurah(nomor: 2, nama: 'البقرة', namaLatin: 'Al-Baqarah', jumlahAyat: 286, tempatTurun: 'Madinah', arti: 'Sapi Betina', deskripsi: '', audioFull: {}),
                      DataSurah(nomor: 1, nama: 'الفاتحة', namaLatin: 'Al-Fatihah', jumlahAyat: 7, tempatTurun: 'Mekah', arti: 'Pembukaan', deskripsi: '', audioFull: {}),
                    ];
                    final lastAyat = [255, 7];
                    final item = history[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.DETAIL_SURAH, arguments: item.nomor);
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
                                  '${i + 1}',
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
                                      item.namaLatin,
                                      style: R.textStyle.medium(
                                        fontWeight: FontWeight.w600,
                                        color: _textSoft,
                                      ).copyWith(fontSize: 15, fontFamily: 'Poppins'),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Terakhir dibaca: Ayat ${lastAyat[i]}',
                                      style: R.textStyle.small(
                                        color: _textSoft.withValues(alpha: 0.4),
                                      ).copyWith(fontFamily: 'Poppins'),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                item.nama,
                                style: R.textStyle.large(
                                  color: _goldLight,
                                  fontWeight: FontWeight.w500,
                                ).copyWith(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: 2,
                ),
              ),
            ] else ...[
              // Bookmarks
              Obx(() {
                final listToUse = _homeController.surahs.isNotEmpty 
                    ? _homeController.surahs 
                    : _mockSurahs;
                final bookmarkedList = listToUse
                    .where((s) => _bookmarks.contains(s.nomor))
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
                        onBookmarkTapped: () {
                          setState(() {
                            _bookmarks.remove(item.nomor);
                          });
                        },
                        onTap: () {
                          Get.toNamed(Routes.DETAIL_SURAH, arguments: item.nomor);
                        },
                      );
                    },
                    childCount: bookmarkedList.length,
                  ),
                );
              }),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
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
                        Get.snackbar(
                          'Jadwal Sholat',
                          'Fitur Jadwal Sholat akan segera hadir!',
                          backgroundColor: _bg2,
                          colorText: _textSoft,
                          borderColor: _goldDim.withOpacity(0.3),
                          borderWidth: 1,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
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
                        Get.snackbar(
                          'Jadwal Imsakiyah',
                          'Fitur Jadwal Imsakiyah akan segera hadir!',
                          backgroundColor: _bg2,
                          colorText: _textSoft,
                          borderColor: _goldDim.withOpacity(0.3),
                          borderWidth: 1,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
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
                        Get.snackbar(
                          'Arah Kiblat',
                          'Fitur Arah Kiblat akan segera hadir!',
                          backgroundColor: _bg2,
                          colorText: _textSoft,
                          borderColor: _goldDim.withOpacity(0.3),
                          borderWidth: 1,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
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
