import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants/r.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
class DoaModel {
  final int id;
  final String judul;
  final String arab;
  final String latin;
  final String arti;
  final String kategori;
  final String sumber;
  final String emoji;
  bool isFavorit;

  DoaModel({
    required this.id,
    required this.judul,
    required this.arab,
    required this.latin,
    required this.arti,
    required this.kategori,
    required this.sumber,
    required this.emoji,
    this.isFavorit = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────────────────────
final List<DoaModel> semuaDoa = [
  DoaModel(
    id: 1,
    judul: 'Doa Sebelum Makan',
    arab: 'اللَّهُمَّ بَارِكْ لَنَا فِيمَا رَزَقْتَنَا وَقِنَا عَذَابَ النَّارِ',
    latin: "Allahumma baarik lanaa fiimaa razaqtanaa wa qinaa 'adzaaban naar",
    arti: 'Ya Allah, berkahilah kami dalam rezeki yang Engkau berikan kepada kami dan peliharalah kami dari siksa api neraka.',
    kategori: 'Harian',
    sumber: 'HR. Ibnu Sunni',
    emoji: '🍽️',
  ),
  DoaModel(
    id: 2,
    judul: 'Doa Setelah Makan',
    arab: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
    latin: "Alhamdulillahilladzi ath'amanaa wa saqaanaa wa ja'alanaa muslimiin",
    arti: 'Segala puji bagi Allah yang telah memberi kami makan, minum, dan menjadikan kami sebagai orang-orang Muslim.',
    kategori: 'Harian',
    sumber: 'HR. Abu Dawud',
    emoji: '🙏',
  ),
  DoaModel(
    id: 3,
    judul: 'Doa Sebelum Tidur',
    arab: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    latin: 'Bismikallaahumma amuutu wa ahyaa',
    arti: 'Dengan nama-Mu ya Allah, aku mati dan aku hidup.',
    kategori: 'Harian',
    sumber: 'HR. Bukhari',
    emoji: '🌙',
  ),
  DoaModel(
    id: 4,
    judul: 'Doa Bangun Tidur',
    arab: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    latin: "Alhamdulillahilladzi ahyaanaa ba'da maa amaatanaa wa ilaihinnusyuur",
    arti: 'Segala puji bagi Allah yang telah menghidupkan kami setelah mematikan kami, dan hanya kepada-Nya lah tempat kembali.',
    kategori: 'Harian',
    sumber: 'HR. Bukhari',
    emoji: '🌅',
  ),
  DoaModel(
    id: 5,
    judul: 'Doa Masuk Rumah',
    arab: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ',
    latin: 'Allaahumma innii as-aluka khoirol mawlaji wa khoirol makhroji',
    arti: 'Ya Allah, sesungguhnya aku memohon kepada-Mu kebaikan tempat masuk dan kebaikan tempat keluar.',
    kategori: 'Harian',
    sumber: 'HR. Abu Dawud',
    emoji: '🏠',
  ),
  DoaModel(
    id: 6,
    judul: 'Doa Keluar Rumah',
    arab: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    latin: "Bismillaahi tawakkaltu 'alallahi wa laa hawla wa laa quwwata illaa billaah",
    arti: 'Dengan nama Allah, aku bertawakkal kepada Allah. Tiada daya dan kekuatan kecuali dengan pertolongan Allah.',
    kategori: 'Harian',
    sumber: 'HR. Abu Dawud & Tirmidzi',
    emoji: '🚪',
  ),
  DoaModel(
    id: 7,
    judul: 'Doa Masuk Masjid',
    arab: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
    latin: 'Allaahumaftah lii abwaaba rahmatik',
    arti: 'Ya Allah, bukakanlah untukku pintu-pintu rahmat-Mu.',
    kategori: 'Ibadah',
    sumber: 'HR. Muslim',
    emoji: '🕌',
  ),
  DoaModel(
    id: 8,
    judul: 'Doa Keluar Masjid',
    arab: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
    latin: 'Allaahumma innii as-aluka min fadhlika',
    arti: 'Ya Allah, sesungguhnya aku memohon kepada-Mu dari karunia-Mu.',
    kategori: 'Ibadah',
    sumber: 'HR. Muslim',
    emoji: '✨',
  ),
  DoaModel(
    id: 9,
    judul: 'Doa Sebelum Wudhu',
    arab: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
    latin: 'Bismillaahirrahmaanirrahiim',
    arti: 'Dengan menyebut nama Allah Yang Maha Pengasih lagi Maha Penyayang.',
    kategori: 'Ibadah',
    sumber: 'HR. Abu Dawud',
    emoji: '💧',
  ),
  DoaModel(
    id: 10,
    judul: 'Doa Setelah Wudhu',
    arab: 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
    latin: "Asyhadu allaa ilaaha illallahu wahdahu laa syariika lahu wa asyhadu anna muhammadan 'abduhu wa rasuuluh",
    arti: 'Aku bersaksi bahwa tiada Tuhan selain Allah, Yang Maha Esa, tiada sekutu bagi-Nya. Dan aku bersaksi bahwa Muhammad adalah hamba dan utusan-Nya.',
    kategori: 'Ibadah',
    sumber: 'HR. Muslim',
    emoji: '🌊',
  ),
  DoaModel(
    id: 11,
    judul: 'Doa Naik Kendaraan',
    arab: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
    latin: 'Subhaanalladzi sakhkhara lanaa haadzaa wa maa kunnaa lahu muqriniin wa innaa ilaa rabbinaa lamunqalibuun',
    arti: 'Maha Suci Allah yang telah menundukkan semua ini bagi kami, padahal kami sebelumnya tidak mampu menguasainya. Dan sesungguhnya kami akan kembali kepada Tuhan kami.',
    kategori: 'Perjalanan',
    sumber: 'QS. Az-Zukhruf: 13-14',
    emoji: '🚗',
  ),
  DoaModel(
    id: 12,
    judul: 'Doa Bepergian',
    arab: 'اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى',
    latin: 'Allaahumma innaa nas-aluka fii safarina haadzal birra wat-taqwaa',
    arti: 'Ya Allah, sesungguhnya kami memohon kepada-Mu dalam perjalanan kami ini kebaikan dan ketakwaan.',
    kategori: 'Perjalanan',
    sumber: 'HR. Muslim',
    emoji: '✈️',
  ),
  DoaModel(
    id: 13,
    judul: 'Doa Mohon Kesehatan',
    arab: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي',
    latin: "Allaahumma 'aafinii fii badanii, allaahumma 'aafinii fii sam'ii, allaahumma 'aafinii fii bashorii",
    arti: 'Ya Allah, sehatkanlah badanku. Ya Allah, sehatkanlah pendengaranku. Ya Allah, sehatkanlah penglihatanku.',
    kategori: 'Kesehatan',
    sumber: 'HR. Abu Dawud',
    emoji: '💚',
  ),
  DoaModel(
    id: 14,
    judul: 'Doa Menjenguk Orang Sakit',
    arab: 'اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ اشْفِهِ وَأَنْتَ الشَّافِي',
    latin: 'Allaahumma rabban naasi adzhibil ba-sa isyfihi wa antasy syaafii',
    arti: 'Ya Allah, Tuhan manusia, hilangkanlah penyakit ini, sembuhkanlah ia, Engkaulah Yang Maha Menyembuhkan.',
    kategori: 'Kesehatan',
    sumber: 'HR. Bukhari & Muslim',
    emoji: '❤️‍🩹',
  ),
  DoaModel(
    id: 15,
    judul: 'Doa Mohon Rezeki',
    arab: 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
    latin: "Allaahummakfinii bihalaalika 'an haraamika wa aghninii bifadhlika 'amman siwaak",
    arti: 'Ya Allah, cukupkanlah aku dengan yang halal dari-Mu sehingga tidak membutuhkan yang haram, dan kayakanlah aku dengan karunia-Mu sehingga tidak membutuhkan selain-Mu.',
    kategori: 'Rezeki',
    sumber: 'HR. Tirmidzi',
    emoji: '💰',
  ),
  DoaModel(
    id: 16,
    judul: 'Doa Mohon Ilmu',
    arab: 'رَبِّ زِدْنِي عِلْمًا',
    latin: "Rabbi zidnii 'ilmaa",
    arti: 'Ya Tuhanku, tambahkanlah ilmu kepadaku.',
    kategori: 'Pendidikan',
    sumber: 'QS. Taha: 114',
    emoji: '📚',
  ),
  DoaModel(
    id: 17,
    judul: 'Doa Sebelum Belajar',
    arab: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي يَفْقَهُوا قَوْلِي',
    latin: 'Rabbisy rahli sadrii wa yassir lii amrii wahlul uqdatam millisaani yafqahu qaulii',
    arti: 'Ya Tuhanku, lapangkanlah dadaku, mudahkanlah urusanku, dan lepaskanlah kekakuan lidahku agar mereka memahami perkataanku.',
    kategori: 'Pendidikan',
    sumber: 'QS. Taha: 25-28',
    emoji: '🎓',
  ),
  DoaModel(
    id: 18,
    judul: 'Doa Masuk Kamar Mandi',
    arab: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
    latin: "Allaahumma innii a'uudzubika minal khubutsi wal khabaa-its",
    arti: 'Ya Allah, sesungguhnya aku berlindung kepada-Mu dari setan laki-laki dan setan perempuan.',
    kategori: 'Harian',
    sumber: 'HR. Bukhari & Muslim',
    emoji: '🚿',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// WARNA
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static Color get bg => R.color.bg1;
  static Color get surface => R.color.bg2;
  static Color get surface2 => R.color.emeraldMedium;
  static Color get gold => R.color.gold;
  static Color get goldLight => R.color.goldLight;
  static Color get goldDim => R.color.goldDim;
  static Color get emerald => R.color.emerald;
  static Color get emeraldLight => R.color.emeraldLight;
  static Color get text => R.color.textSoft;
  static Color get textMuted => R.color.textMuted;
  static Color get red => R.color.red;

  static final Map<String, Color> kategoriColor = {
    'Harian': R.color.emerald,
    'Ibadah': R.color.goldDim,
    'Perjalanan': const Color(0xFF1565C0),
    'Kesehatan': const Color(0xFFB71C1C),
    'Rezeki': const Color(0xFF4A148C),
    'Pendidikan': const Color(0xFF006064),
  };

  static Color ofKategori(String k) =>
      kategoriColor[k] ?? R.color.emerald;
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class DoaView extends StatefulWidget {
  const DoaView({super.key});

  @override
  State<DoaView> createState() => _DoaViewState();
}

class _DoaViewState extends State<DoaView> with TickerProviderStateMixin {
  late AnimationController _headerAnim;
  late AnimationController _listAnim;

  String _filterKategori = 'Semua';
  String _query = '';
  bool _showFavoritOnly = false;
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ScrollController _chipScroll = ScrollController();

  bool _searchActive = false;

  final List<String> _kategoriList = [
    'Semua', 'Harian', 'Ibadah', 'Perjalanan', 'Kesehatan', 'Rezeki', 'Pendidikan',
  ];

  List<DoaModel> get _filtered {
    return semuaDoa.where((d) {
      final matchKat = _filterKategori == 'Semua' || d.kategori == _filterKategori;
      final matchFav = !_showFavoritOnly || d.isFavorit;
      final matchQ = _query.isEmpty ||
          d.judul.toLowerCase().contains(_query.toLowerCase()) ||
          d.arti.toLowerCase().contains(_query.toLowerCase());
      return matchKat && matchFav && matchQ;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    )..forward();
    _listAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _listAnim.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _chipScroll.dispose();
    super.dispose();
  }

  void _onFilterChange(String kat) {
    setState(() => _filterKategori = kat);
    _listAnim.forward(from: 0);
  }

  void _toggleFavorit(int id) {
    setState(() {
      final d = semuaDoa.firstWhere((e) => e.id == id);
      d.isFavorit = !d.isFavorit;
    });
    HapticFeedback.lightImpact();
  }

  void _openDetail(DoaModel doa) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => DoaDetailScreen(doa: doa, onFavorit: () => _toggleFavorit(doa.id)),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: _C.bg,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildChips(),
          _buildStats(filtered.length),
          Expanded(
            child: AnimatedBuilder(
              animation: _listAnim,
              builder: (_, __) => filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final delay = (i * 0.06).clamp(0.0, 0.6);
                        return _DoaCard(
                          doa: filtered[i],
                          index: i,
                          animDelay: delay,
                          listAnim: _listAnim,
                          onTap: () => _openDetail(filtered[i]),
                          onFavorit: () => _toggleFavorit(filtered[i].id),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerAnim,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20, right: 16, bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2A1A), Color(0xFF0A1A12)],
          ),
          border: Border(
            bottom: BorderSide(color: _C.goldDim.withValues(alpha: 0.12)),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _C.goldDim.withValues(alpha: 0.3)),
                  color: _C.surface2,
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: _C.goldLight, size: 16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                      colors: [_C.goldDim, _C.goldLight],
                    ).createShader(b),
                    child: Text(
                      'Kumpulan Doa',
                      style: R.textStyle.extraLargeBold.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    '${semuaDoa.length} doa tersedia',
                    style: R.textStyle.small(color: _C.textMuted),
                  ),
                ],
              ),
            ),
            // Favorit toggle
            _AnimPressButton(
              onTap: () {
                setState(() => _showFavoritOnly = !_showFavoritOnly);
                _listAnim.forward(from: 0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _showFavoritOnly
                      ? _C.red.withValues(alpha: 0.15)
                      : _C.surface2,
                  border: Border.all(
                    color: _showFavoritOnly
                        ? _C.red.withValues(alpha: 0.4)
                        : _C.goldDim.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showFavoritOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _showFavoritOnly ? _C.red : _C.textMuted,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Favorit',
                      style: R.textStyle.small(
                        color: _showFavoritOnly ? _C.red : _C.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _C.surface2,
          border: Border.all(
            color: _searchActive
                ? _C.goldDim.withValues(alpha: 0.5)
                : _C.goldDim.withValues(alpha: 0.15),
          ),
          boxShadow: _searchActive
              ? [BoxShadow(color: _C.gold.withValues(alpha: 0.08), blurRadius: 12)]
              : null,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Icon(Icons.search_rounded, color: _C.textMuted, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: R.textStyle.medium(color: _C.text),
                onChanged: (v) => setState(() => _query = v),
                onTap: () => setState(() => _searchActive = true),
                onEditingComplete: () => setState(() => _searchActive = false),
                decoration: InputDecoration(
                  hintText: 'Cari doa...',
                  hintStyle: R.textStyle.medium(color: _C.textMuted),
                  border: InputBorder.none,
                  isDense: true,
                ),
                cursorColor: _C.gold,
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() { _query = ''; _searchActive = false; });
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.close_rounded, color: _C.textMuted, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Category Chips ────────────────────────────────────────────────────────
  Widget _buildChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        controller: _chipScroll,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: _kategoriList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final kat = _kategoriList[i];
          final active = kat == _filterKategori;
          final color = kat == 'Semua' ? _C.emerald : _C.ofKategori(kat);
          return _AnimPressButton(
            onTap: () => _onFilterChange(kat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: active ? color.withValues(alpha: 0.2) : _C.surface2,
                border: Border.all(
                  color: active ? color.withValues(alpha: 0.7) : _C.goldDim.withValues(alpha: 0.15),
                  width: active ? 1.2 : 1,
                ),
              ),
              child: Text(
                kat,
                style: R.textStyle.small(
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? Color.lerp(color, Colors.white, 0.5) : _C.textMuted,
                ).copyWith(letterSpacing: 0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Stats bar ─────────────────────────────────────────────────────────────
  Widget _buildStats(int count) {
    final favCount = semuaDoa.where((d) => d.isFavorit).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: [
          Text(
            '$count doa ditemukan',
            style: R.textStyle.small(color: _C.textMuted).copyWith(fontSize: 11),
          ),
          const Spacer(),
          if (favCount > 0) ...[
            Icon(Icons.favorite_rounded, color: _C.red, size: 12),
            const SizedBox(width: 4),
            Text(
              '$favCount favorit',
              style: R.textStyle.small(color: _C.red).copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔍', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            _showFavoritOnly ? 'Belum ada doa favorit' : 'Doa tidak ditemukan',
            style: R.textStyle.medium(color: _C.textMuted),
          ),
          if (_showFavoritOnly)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Tekan ♡ pada doa untuk menyimpannya',
                style: R.textStyle.small(color: _C.textMuted.withValues(alpha: 0.6)),
              ),
            ),
        ],
      ),
    );
  }

  // ── FAB scroll to top ─────────────────────────────────────────────────────
  Widget _buildFab() {
    return FloatingActionButton(
      mini: true,
      onPressed: () => _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      ),
      backgroundColor: _C.surface2,
      elevation: 4,
      child: Icon(Icons.keyboard_arrow_up_rounded, color: _C.gold),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DOA CARD
// ─────────────────────────────────────────────────────────────────────────────
class _DoaCard extends StatefulWidget {
  final DoaModel doa;
  final int index;
  final double animDelay;
  final AnimationController listAnim;
  final VoidCallback onTap;
  final VoidCallback onFavorit;

  const _DoaCard({
    required this.doa,
    required this.index,
    required this.animDelay,
    required this.listAnim,
    required this.onTap,
    required this.onFavorit,
  });

  @override
  State<_DoaCard> createState() => _DoaCardState();
}

class _DoaCardState extends State<_DoaCard> with SingleTickerProviderStateMixin {
  late AnimationController _favAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _favAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _favAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doa = widget.doa;
    final catColor = _C.ofKategori(doa.kategori);

    return AnimatedBuilder(
      animation: widget.listAnim,
      builder: (_, child) {
        final t = ((widget.listAnim.value - widget.animDelay) / (1 - widget.animDelay))
            .clamp(0.0, 1.0);
        final curve = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curve,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - curve)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: _C.surface,
              border: Border.all(color: _C.goldDim.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Left accent bar
                  Positioned(
                    left: 0, top: 0, bottom: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: catColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  // Subtle inner glow at top
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            catColor.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Emoji badge
                            Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: catColor.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: catColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Center(
                                child: Text(doa.emoji,
                                    style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doa.judul,
                                    style: R.textStyle.mediumBold.copyWith(
                                      color: _C.text,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _Chip(label: doa.kategori, color: catColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        doa.sumber,
                                        style: R.textStyle.small(
                                          color: _C.textMuted,
                                        ).copyWith(fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Favorit button
                            GestureDetector(
                              onTap: () {
                                widget.onFavorit();
                                if (!doa.isFavorit) {
                                  _favAnim.forward(from: 0);
                                }
                              },
                              child: AnimatedBuilder(
                                animation: _favAnim,
                                builder: (_, __) {
                                  final scale = _favAnim.isAnimating
                                      ? Tween<double>(begin: 1, end: 1.4)
                                          .chain(CurveTween(curve: Curves.elasticOut))
                                          .evaluate(_favAnim)
                                      : 1.0;
                                  return Transform.scale(
                                    scale: scale,
                                    child: Icon(
                                      doa.isFavorit
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: doa.isFavorit ? _C.red : _C.textMuted,
                                      size: 22,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Arabic text preview
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _C.surface2,
                            border: Border.all(
                              color: _C.goldDim.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            doa.arab,
                            textAlign: TextAlign.right,
                            style: R.textStyle.largeNormal.copyWith(
                              fontFamily: 'Poppins',
                              color: _C.goldLight,
                              height: 1.7,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Arti preview
                        Text(
                          doa.arti,
                          style: R.textStyle.small(
                            color: _C.textMuted,
                          ).copyWith(height: 1.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Baca selengkapnya',
                              style: R.textStyle.small(
                                color: _C.emeraldLight,
                              ).copyWith(fontSize: 11, letterSpacing: 0.3),
                            ),
                            const SizedBox(width: 3),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: _C.emeraldLight, size: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class DoaDetailScreen extends StatefulWidget {
  final DoaModel doa;
  final VoidCallback onFavorit;

  const DoaDetailScreen({
    super.key,
    required this.doa,
    required this.onFavorit,
  });

  @override
  State<DoaDetailScreen> createState() => _DoaDetailScreenState();
}

class _DoaDetailScreenState extends State<DoaDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  bool _copied = false;
  bool _latinVisible = true;
  bool _artiVisible = true;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _copyAll() {
    final text = '${widget.doa.arab}\n\n${widget.doa.latin}\n\n${widget.doa.arti}';
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final doa = widget.doa;
    final catColor = _C.ofKategori(doa.kategori);

    return Scaffold(
      backgroundColor: _C.bg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _C.bg,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26,
                  border: Border.all(color: _C.goldDim.withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: _C.goldLight, size: 16),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  widget.onFavorit();
                  setState(() {});
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black26,
                    border: Border.all(
                      color: doa.isFavorit
                          ? _C.red.withValues(alpha: 0.4)
                          : _C.goldDim.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    doa.isFavorit
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: doa.isFavorit ? _C.red : _C.goldLight,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildDetailHeader(doa, catColor),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic text box
                  _buildSection(
                    label: 'Arab',
                    icon: '✦',
                    delay: 0.1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _C.surface,
                        border: Border.all(color: _C.goldDim.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: _C.gold.withValues(alpha: 0.05),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Text(
                        doa.arab,
                        textAlign: TextAlign.right,
                        style: R.textStyle.extraLargeNormal.copyWith(
                          fontFamily: 'Poppins',
                          color: _C.goldLight,
                          height: 2.0,
                          shadows: [
                            Shadow(
                              color: _C.gold.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Latin
                  _buildToggleSection(
                    label: 'Latin',
                    visible: _latinVisible,
                    onToggle: () => setState(() => _latinVisible = !_latinVisible),
                    delay: 0.2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: _C.surface,
                        border: Border.all(color: _C.emerald.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        doa.latin,
                        style: R.textStyle.mediumNormal.copyWith(
                          fontStyle: FontStyle.italic,
                          color: _C.emeraldLight,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Arti
                  _buildToggleSection(
                    label: 'Artinya',
                    visible: _artiVisible,
                    onToggle: () => setState(() => _artiVisible = !_artiVisible),
                    delay: 0.3,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: _C.surface,
                        border: Border.all(color: _C.goldDim.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 3,
                            height: 60,
                            margin: const EdgeInsets.only(right: 12, top: 2),
                            decoration: BoxDecoration(
                              color: _C.gold,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '"${doa.arti}"',
                              style: R.textStyle.mediumNormal.copyWith(
                                color: _C.text,
                                height: 1.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sumber
                  _buildSection(
                    label: 'Sumber',
                    icon: '📖',
                    delay: 0.4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _C.surface2,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.menu_book_rounded,
                              color: _C.goldDim, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            doa.sumber,
                            style: R.textStyle.small(
                              color: _C.textMuted,
                            ).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Copy button
                  _AnimPressButton(
                    onTap: _copyAll,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: _copied
                              ? [_C.emerald, _C.emeraldLight]
                              : [_C.goldDim, _C.gold],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_copied ? _C.emerald : _C.gold)
                                .withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _copied ? Icons.check_rounded : Icons.copy_rounded,
                            color: const Color(0xFF0A1A12),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _copied ? 'Tersalin!' : 'Salin Doa',
                            style: R.textStyle.mediumBold.copyWith(
                              color: const Color(0xFF0A1A12),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader(DoaModel doa, Color catColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            catColor.withValues(alpha: 0.4),
            _C.bg,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: CustomPaint(
                painter: _DiamondPatternPainter(color: _C.gold),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 56,
              left: 20, right: 20, bottom: 16,
            ),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: catColor.withValues(alpha: 0.2),
                    border: Border.all(color: catColor.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(doa.emoji,
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        doa.judul,
                        style: R.textStyle.largeBold.copyWith(
                          color: _C.text,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _Chip(label: doa.kategori, color: catColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required String icon,
    required double delay,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, c) {
        final t = (((_anim.value - delay) / (1 - delay)).clamp(0.0, 1.0));
        final curve = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curve,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curve)),
            child: c,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: R.textStyle.smallBold.copyWith(
                    color: _C.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildToggleSection({
    required String label,
    required bool visible,
    required VoidCallback onToggle,
    required double delay,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, c) {
        final t = (((_anim.value - delay) / (1 - delay)).clamp(0.0, 1.0));
        final curve = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curve,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curve)),
            child: c,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 2),
              child: Row(
                children: [
                  Text(
                    label,
                    style: R.textStyle.smallBold.copyWith(
                      color: _C.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: visible ? 0 : -0.25,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _C.textMuted,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: child,
            secondChild: const SizedBox.shrink(),
            crossFadeState: visible
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: R.textStyle.smallBold.copyWith(
          fontSize: 10,
          color: Color.lerp(color, Colors.white, 0.5),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _AnimPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _AnimPressButton({required this.child, required this.onTap});

  @override
  State<_AnimPressButton> createState() => _AnimPressButtonState();
}

class _AnimPressButtonState extends State<_AnimPressButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTERS
// ─────────────────────────────────────────────────────────────────────────────
class _DiamondPatternPainter extends CustomPainter {
  final Color color;
  const _DiamondPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    const sp = 50.0;
    const r = 18.0;

    for (double x = 0; x < size.width + sp; x += sp) {
      for (double y = 0; y < size.height + sp; y += sp) {
        final path = Path()
          ..moveTo(x, y - r)
          ..lineTo(x + r, y)
          ..lineTo(x, y + r)
          ..lineTo(x - r, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}