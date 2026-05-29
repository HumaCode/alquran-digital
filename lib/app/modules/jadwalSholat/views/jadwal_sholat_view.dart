import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';
import '../controllers/jadwal_sholat_controller.dart';
import '../../../data/models/jadwal_sholat_model.dart';
import 'package:alquran_digital/app/constants/r.dart';
import 'package:alquran_digital/app/routes/app_pages.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MODEL WAKTU SHOLAT
// ═══════════════════════════════════════════════════════════════════════════
// Model kelas untuk menyimpan data setiap jadwal sholat
class WaktuSholat {
  final String nama;
  final String arabNama;
  final TimeOfDay waktu;
  final String icon;
  final Color accent;
  final String deskripsi;

  const WaktuSholat({
    required this.nama,
    required this.arabNama,
    required this.waktu,
    required this.icon,
    required this.accent,
    required this.deskripsi,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// VIEW / SCREEN UTAMA
// ═══════════════════════════════════════════════════════════════════════════
// Widget utama halaman Jadwal Sholat (Stateful untuk timer & animasi)
class JadwalSholatView extends StatefulWidget {
  const JadwalSholatView({super.key});

  @override
  State<JadwalSholatView> createState() => _JadwalSholatViewState();
}

class _JadwalSholatViewState extends State<JadwalSholatView>
    with TickerProviderStateMixin {
  final _controller = Get.find<JadwalSholatController>();
  StreamSubscription? _todayJadwalSubscription;
  late AudioPlayer _audioPlayer;
  
  // Timer dan penanggalan
  late Timer _ticker;
  late DateTime _now;
  Duration _countdown = Duration.zero;
  int _sholatBerikutIdx = 0;

  // Controllers untuk berbagai jenis animasi transisi dan ornamen
  late AnimationController _entranceCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _compassCtrl;
  late AnimationController _ringCtrl;
  late List<AnimationController> _cardCtrls;

  // State local UI
  int? _expandedCard;
  bool _notifEnabled = true;
  String _tanggal = '';
  String _hijri = '';

  // Data statis jadwal sholat harian
  final List<WaktuSholat> _sholat = [
    WaktuSholat(
      nama: 'Subuh',
      arabNama: 'الصبح',
      waktu: const TimeOfDay(hour: 4, minute: 28),
      icon: '🌄',
      accent: const Color(0xFF4A90D9),
      deskripsi: 'Sebelum terbit matahari',
    ),
    WaktuSholat(
      nama: 'Dzuhur',
      arabNama: 'الظهر',
      waktu: const TimeOfDay(hour: 11, minute: 52),
      icon: '☀️',
      accent: const Color(0xFFE8A020),
      deskripsi: 'Setelah matahari tergelincir',
    ),
    WaktuSholat(
      nama: 'Ashar',
      arabNama: 'العصر',
      waktu: const TimeOfDay(hour: 15, minute: 10),
      icon: '🌤️',
      accent: const Color(0xFFD4612A),
      deskripsi: 'Sore hari menjelang petang',
    ),
    WaktuSholat(
      nama: 'Maghrib',
      arabNama: 'المغرب',
      waktu: const TimeOfDay(hour: 17, minute: 55),
      icon: '🌇',
      accent: const Color(0xFFBF3A5A),
      deskripsi: 'Setelah matahari terbenam',
    ),
    WaktuSholat(
      nama: 'Isya',
      arabNama: 'العشاء',
      waktu: const TimeOfDay(hour: 19, minute: 10),
      icon: '🌙',
      accent: const Color(0xFF5E35B1),
      deskripsi: 'Ketika langit gelap sempurna',
    ),
  ];

  // Daftar nama bulan dalam Kalender Hijriah
  static const _hijriMonths = [
    'Muharram',
    'Shafar',
    'Rabiul Awal',
    'Rabiul Akhir',
    'Jumadal Ula',
    'Jumadal Akhirah',
    'Rajab',
    'Syakban',
    'Ramadhan',
    'Syawal',
    'Dzulqadah',
    'Dzulhijjah',
  ];

  void _updateSholatTimes(Jadwal today) {
    TimeOfDay parseTime(String timeStr) {
      try {
        final parts = timeStr.trim().split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        return const TimeOfDay(hour: 0, minute: 0);
      }
    }

    _sholat[0] = WaktuSholat(
      nama: 'Subuh',
      arabNama: 'الصبح',
      waktu: parseTime(today.subuh),
      icon: '🌄',
      accent: const Color(0xFF4A90D9),
      deskripsi: 'Sebelum terbit matahari',
    );
    _sholat[1] = WaktuSholat(
      nama: 'Dzuhur',
      arabNama: 'الظهر',
      waktu: parseTime(today.dzuhur),
      icon: '☀️',
      accent: const Color(0xFFE8A020),
      deskripsi: 'Setelah matahari tergelincir',
    );
    _sholat[2] = WaktuSholat(
      nama: 'Ashar',
      arabNama: 'العصر',
      waktu: parseTime(today.ashar),
      icon: '🌤️',
      accent: const Color(0xFFD4612A),
      deskripsi: 'Sore hari menjelang petang',
    );
    _sholat[3] = WaktuSholat(
      nama: 'Maghrib',
      arabNama: 'المغرب',
      waktu: parseTime(today.maghrib),
      icon: '🌇',
      accent: const Color(0xFFBF3A5A),
      deskripsi: 'Setelah matahari terbenam',
    );
    _sholat[4] = WaktuSholat(
      nama: 'Isya',
      arabNama: 'العشاء',
      waktu: parseTime(today.isya),
      icon: '🌙',
      accent: const Color(0xFF5E35B1),
      deskripsi: 'Ketika langit gelap sempurna',
    );
  }

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _audioPlayer = AudioPlayer();
    
    // Set initial times if already available
    final initialToday = _controller.todayJadwal.value;
    if (initialToday != null) {
      _updateSholatTimes(initialToday);
    }
    
    _buildDates();
    _calcSholatBerikut();

    // Listen to changes in todayJadwal reactively
    _todayJadwalSubscription = _controller.todayJadwal.listen((today) {
      if (today != null && mounted) {
        setState(() {
          _updateSholatTimes(today);
          _calcSholatBerikut();
        });
      }
    });

    // Ticker untuk memperbarui countdown setiap 1 detik secara realtime
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
          _calcSholatBerikut();
          _checkAndPlayPrayerTime();
        });
      }
    });

    // Animasi muncul (entrance fade in) saat halaman dibuka
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    // Animasi pulse / denyut redup-terang pada teks countdown sisa waktu
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Animasi putaran lambat jarum kompas
    _compassCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Animasi rotasi lingkaran background kiblat
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Staggered animation untuk loading kartu-kartu sholat secara bertahap
    _cardCtrls = List.generate(
      5,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: 300 + (i * 100)), () {
        if (mounted) _cardCtrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _todayJadwalSubscription?.cancel();
    _ticker.cancel();
    _audioPlayer.dispose();
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    _compassCtrl.dispose();
    _ringCtrl.dispose();
    for (final c in _cardCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // Membangun teks format tanggal masehi dan hijriah
  void _buildDates() {
    const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    _tanggal = '${hari[_now.weekday - 1]}, ${_now.day} ${bulan[_now.month - 1]} ${_now.year}';

    // Konversi penanggalan masehi saat ini ke format Hijriah
    final jd = _toJulian(_now);
    final h = _fromJulianToHijri(jd);
    _hijri = '${h[2]} ${_hijriMonths[h[1] - 1]} ${h[0]} H';
  }

  // Rumus konversi tanggal masehi ke sistem bilangan Julian
  int _toJulian(DateTime d) {
    int y = d.year, m = d.month, day = d.day;
    if (m <= 2) {
      y--;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524;
  }

  // Rumus konversi Julian day ke penanggalan Hijriah
  List<int> _fromJulianToHijri(int jd) {
    final l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final ll = l - 10631 * n + 354;
    final j =
        ((10985 - ll) / 5316).floor() * ((50 * ll) / 17719).floor() +
        (ll / 5670).floor() * ((43 * ll) / 15238).floor();
    final lll =
        ll -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final m = (24 * lll) ~/ 709;
    final day = lll - (709 * m) ~/ 24;
    final y = 30 * n + j - 30;
    return [y, m, day];
  }

  // Menentukan index jadwal sholat terdekat berikutnya & durasi hitung mundurnya
  void _calcSholatBerikut() {
    final nowMin = _now.hour * 60 + _now.minute;
    int idx = -1;
    for (int i = 0; i < _sholat.length; i++) {
      final s = _sholat[i];
      final sMin = s.waktu.hour * 60 + s.waktu.minute;
      if (sMin > nowMin) {
        idx = i;
        break;
      }
    }
    if (idx == -1) idx = 0; // Jika waktu sudah melewati Isya, sholat berikutnya adalah Subuh esok hari

    _sholatBerikutIdx = idx;

    final target = _sholat[idx];
    var targetDt = DateTime(
      _now.year,
      _now.month,
      _now.day,
      target.waktu.hour,
      target.waktu.minute,
    );
    if (targetDt.isBefore(_now)) {
      targetDt = targetDt.add(const Duration(days: 1));
    }
    _countdown = targetDt.difference(_now);
  }

  void _checkAndPlayPrayerTime() {
    for (final s in _sholat) {
      if (_now.hour == s.waktu.hour && _now.minute == s.waktu.minute && _now.second == 0) {
        _playAdhanDialog(s.nama);
        break;
      }
    }
  }

  Future<void> _playAdhan() async {
    if (!_notifEnabled) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(R.audio.adzhan));
    } catch (e) {
      print('Gagal memutar adzan: $e');
    }
  }

  void _playAdhanDialog(String sholatNama) {
    if (!_notifEnabled) return;
    _playAdhan();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: R.color.surfaceJadwal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: R.color.goldDim.withOpacity(0.3)),
            ),
            title: Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: R.color.goldLight),
                const SizedBox(width: 10),
                Text(
                  'Waktu $sholatNama',
                  style: TextStyle(color: R.color.goldLight, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'Waktu sholat $sholatNama telah tiba. Mengumandangkan adzan...',
              style: TextStyle(color: R.color.textJadwal),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _audioPlayer.stop();
                  Navigator.pop(context);
                },
                child: Text(
                  'Matikan Suara',
                  style: TextStyle(color: R.color.error, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Format jam menit (HH:mm)
  String _fmt(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Format countdown jam:menit:detik (HH:mm:ss)
  String get _countdownStr {
    final h = _countdown.inHours;
    final m = _countdown.inMinutes % 60;
    final s = _countdown.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // Mengecek status apakah sholat tersebut sudah lewat waktunya
  bool _isSholatLalu(int idx) {
    final nowMin = _now.hour * 60 + _now.minute;
    final sMin = _sholat[idx].waktu.hour * 60 + _sholat[idx].waktu.minute;
    return sMin < nowMin;
  }

  void _showLocationBottomSheet(BuildContext context) {
    _controller.searchQuery.value = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: R.color.bgJadwal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Obx(() {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: R.color.bgJadwal,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(color: R.color.goldDim.withOpacity(0.15)),
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
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: R.color.textMutedJadwal.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Lokasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: R.color.goldLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close_rounded, color: R.color.textMutedJadwal, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await _controller.detectLocation();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [R.color.emerald, R.color.emeraldLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: R.color.emerald.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Deteksi Lokasi Otomatis (GPS / IP)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Provinsi',
                  style: TextStyle(fontSize: 12, color: R.color.textMutedJadwal),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: R.color.surface2Jadwal,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: R.color.goldDim.withOpacity(0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _controller.provinsiList.contains(_controller.selectedProvinsi.value)
                          ? _controller.selectedProvinsi.value
                          : null,
                      isExpanded: true,
                      dropdownColor: R.color.surface2Jadwal,
                      style: TextStyle(color: R.color.textJadwal, fontSize: 14),
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: R.color.goldLight),
                      items: _controller.provinsiList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          _controller.updateProvince(newVal);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cari Kabupaten / Kota',
                  style: TextStyle(fontSize: 12, color: R.color.textMutedJadwal),
                ),
                const SizedBox(height: 6),
                TextField(
                  onChanged: (val) => _controller.searchQuery.value = val,
                  style: TextStyle(color: R.color.textJadwal, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama kota...',
                    hintStyle: TextStyle(color: R.color.textMutedJadwal, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: R.color.goldLight, size: 20),
                    filled: true,
                    fillColor: R.color.surface2Jadwal,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: R.color.goldDim.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: R.color.goldDim.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: R.color.gold, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: _controller.isCitiesLoading.value
                      ? const Center(child: CustomLoader(size: 40))
                      : Obx(() {
                          final list = _controller.filteredKabKotaList;
                          if (list.isEmpty) {
                            return Center(
                              child: Text(
                                'Kota tidak ditemukan',
                                style: TextStyle(color: R.color.textMutedJadwal),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (context, idx) {
                              final city = list[idx];
                              final isSelected = _controller.selectedKabKota.value == city;
                              return Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  dense: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  tileColor: isSelected ? R.color.emerald.withOpacity(0.1) : Colors.transparent,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  title: Text(
                                    city,
                                    style: TextStyle(
                                      color: isSelected ? R.color.emeraldLight : R.color.textJadwal,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle_rounded, color: R.color.emeraldLight, size: 16)
                                      : null,
                                  onTap: () {
                                    _controller.updateCity(city);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          );
                        }),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.bgJadwal,
      body: Stack(
        children: [
          // Ornamen geometris latar belakang khas Islami
          Positioned.fill(child: _GeoBg()),
          
          SafeArea(
            child: Obx(() {
              final isDataLoading = _controller.isLoading.value && _controller.todayJadwal.value == null;
              final errorMsg = _controller.errorMessage.value;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. Header & App Bar
                  SliverToBoxAdapter(
                    child: _JadwalSholatAppBar(
                      kota: _controller.selectedKabKota.value,
                      notifEnabled: _notifEnabled,
                      onNotifToggle: () {
                        setState(() => _notifEnabled = !_notifEnabled);
                        HapticFeedback.lightImpact();
                      },
                      onLocationTap: () => _showLocationBottomSheet(context),
                      entranceCtrl: _entranceCtrl,
                    ),
                  ),
                  
                  if (isDataLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CustomLoader(size: 60),
                      ),
                    )
                  else if (errorMsg.isNotEmpty && _controller.todayJadwal.value == null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                errorMsg,
                                style: TextStyle(color: R.color.textMutedJadwal),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _controller.fetchSchedule(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: R.color.emerald,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    // 2. Tampilan Utama Countdown Sholat Terdekat
                    SliverToBoxAdapter(
                      child: _HeroCountdown(
                        sholat: _sholat[_sholatBerikutIdx],
                        countdownStr: _countdownStr,
                        pulseCtrl: _pulseCtrl,
                        entranceCtrl: _entranceCtrl,
                      ),
                    ),
                    // 3. Penanggalan Masehi & Hijriah
                    SliverToBoxAdapter(
                      child: _TanggalHijriRow(
                        tanggal: _tanggal,
                        hijri: _hijri,
                      ),
                    ),
                    // 4. Progress Tracker pelaksanaan sholat harian
                    SliverToBoxAdapter(
                      child: _SholatProgressBar(
                        now: _now,
                        sholat: _sholat,
                      ),
                    ),
                    // 5. Label Section Pembatas
                    SliverToBoxAdapter(
                      child: _buildSectionLabel(R.string.prayerTitleSection),
                    ),
                    // 6. Kartu daftar waktu sholat stagger
                    ..._buildSholatCards(),
                    // 7. Seksi tambahan di bagian bawah (Kompas Kiblat & Waktu Tambahan)
                    SliverToBoxAdapter(
                      child: _JadwalSholatBottomRow(
                        ringCtrl: _ringCtrl,
                        compassCtrl: _compassCtrl,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Render label pembatas ornamen diamond
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          CustomPaint(
            size: const Size(12, 16),
            painter: _DiamondPainter(color: R.color.gold),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: R.color.textJadwal,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [R.color.goldDim.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Render daftar kartu waktu sholat harian dengan staggered animation
  List<Widget> _buildSholatCards() {
    return List.generate(_sholat.length, (i) {
      return SliverToBoxAdapter(
        child: AnimatedBuilder(
          animation: _cardCtrls[i],
          builder: (_, child) {
            final t = Curves.easeOutCubic.transform(_cardCtrls[i].value);
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(24 * (1 - t), 0),
                child: child,
              ),
            );
          },
          child: _SholatCard(
            sholat: _sholat[i],
            index: i,
            isBerikutnya: i == _sholatBerikutIdx,
            isSudahLewat: _isSholatLalu(i),
            isExpanded: _expandedCard == i,
            fmt: _fmt,
            onTap: () {
              setState(() {
                _expandedCard = _expandedCard == i ? null : i;
              });
              HapticFeedback.selectionClick();
            },
            notifEnabled: _notifEnabled,
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET KOMPONEN TERPISAH
// ═══════════════════════════════════════════════════════════════════════════

// Komponen Widget AppBar Kustom halaman Jadwal Sholat
class _JadwalSholatAppBar extends StatelessWidget {
  final String kota;
  final bool notifEnabled;
  final VoidCallback onNotifToggle;
  final VoidCallback onLocationTap;
  final AnimationController entranceCtrl;

  const _JadwalSholatAppBar({
    required this.kota,
    required this.notifEnabled,
    required this.onNotifToggle,
    required this.onLocationTap,
    required this.entranceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: entranceCtrl, curve: Curves.easeOut),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            // Tombol kembali (Back Button)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: R.color.surface2Jadwal,
                  border: Border.all(color: R.color.goldDim.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: R.color.goldLight,
                  size: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Teks judul dan lokasi saat ini
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                      colors: [R.color.goldDim, R.color.goldLight],
                    ).createShader(b),
                    child: Text(
                      R.string.jadwalSholatTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onLocationTap,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: R.color.emeraldLight,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          kota,
                          style: TextStyle(fontSize: 12, color: R.color.textMutedJadwal),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: R.color.goldLight,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Toggle aktifkan/matikan notifikasi suara adzan
            GestureDetector(
              onTap: onNotifToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notifEnabled
                      ? R.color.emerald.withOpacity(0.2)
                      : R.color.surface2Jadwal,
                  border: Border.all(
                    color: notifEnabled
                        ? R.color.emeraldLight.withOpacity(0.5)
                        : R.color.goldDim.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  notifEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_outlined,
                  color: notifEnabled ? R.color.emeraldLight : R.color.textMutedJadwal,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Komponen Widget Hero Card Countdown Sholat Terdekat
class _HeroCountdown extends StatelessWidget {
  final WaktuSholat sholat;
  final String countdownStr;
  final AnimationController pulseCtrl;
  final AnimationController entranceCtrl;

  const _HeroCountdown({
    required this.sholat,
    required this.countdownStr,
    required this.pulseCtrl,
    required this.entranceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: entranceCtrl,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: R.color.surfaceJadwal,
          border: Border.all(color: R.color.goldDim.withOpacity(0.15)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Latar belakang ornamen glow berdenyut
              Positioned.fill(child: _HeroOrnamen(accent: sholat.accent)),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    // Informasi status sholat terdekat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sholat.accent,
                            boxShadow: [
                              BoxShadow(
                                color: sholat.accent.withOpacity(0.6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          R.string.nextPrayer,
                          style: TextStyle(
                            fontSize: 12,
                            color: R.color.textMutedJadwal,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Baris nama sholat, kaligrafi, dan jam masuk waktu sholat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(sholat.icon, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sholat.arabNama,
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 22,
                                color: R.color.goldLight,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              sholat.nama,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: R.color.textJadwal,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: sholat.accent.withOpacity(0.15),
                            border: Border.all(
                              color: sholat.accent.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            '${sholat.waktu.hour.toString().padLeft(2, '0')}:${sholat.waktu.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color.lerp(sholat.accent, Colors.white, 0.4),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Container(height: 1, color: R.color.goldDim.withOpacity(0.15)),
                    const SizedBox(height: 20),

                    // Countdown timer tersisa sebelum masuk adzan berikutnya
                    Column(
                      children: [
                        Text(
                          R.string.timeRemaining,
                          style: TextStyle(
                            fontSize: 11,
                            color: R.color.textMutedJadwal,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: pulseCtrl,
                          builder: (_, __) => ShaderMask(
                            shaderCallback: (b) => LinearGradient(
                              colors: [
                                Color.lerp(
                                  R.color.goldDim,
                                  R.color.goldLight,
                                  pulseCtrl.value,
                                )!,
                                R.color.goldLight,
                              ],
                            ).createShader(b),
                            child: Text(
                              countdownStr,
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 4,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final label in [
                              R.string.hourLabel,
                              R.string.minuteLabel,
                              R.string.secondLabel
                            ]) ...[
                              SizedBox(
                                width: 72,
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: R.color.textDimJadwal,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              if (label != R.string.secondLabel) const SizedBox(width: 12),
                            ],
                          ],
                        ),
                      ],
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
}

// Komponen Widget Baris Informasi Kalender Masehi & Hijriah
class _TanggalHijriRow extends StatelessWidget {
  final String tanggal;
  final String hijri;

  const _TanggalHijriRow({
    required this.tanggal,
    required this.hijri,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Widget informasi kalender Masehi
          Expanded(
            child: _InfoTile(
              topLabel: R.string.masehi,
              value: tanggal.split(', ')[0],
              subValue: tanggal.split(', ').skip(1).join(', '),
              accent: R.color.emerald,
              icon: Icons.calendar_today_rounded,
            ),
          ),
          const SizedBox(width: 10),
          // Widget informasi kalender Hijriah
          Expanded(
            child: _InfoTile(
              topLabel: R.string.hijriah,
              value: hijri.split(' ').take(2).join(' '),
              subValue: hijri.split(' ').skip(2).join(' '),
              accent: R.color.goldDim,
              icon: Icons.nights_stay_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

// Komponen Widget Progress Tracker pelaksanaan ibadah harian
class _SholatProgressBar extends StatelessWidget {
  final DateTime now;
  final List<WaktuSholat> sholat;

  const _SholatProgressBar({
    required this.now,
    required this.sholat,
  });

  @override
  Widget build(BuildContext context) {
    final nowMin = now.hour * 60 + now.minute;
    final passed = sholat
        .where((s) => s.waktu.hour * 60 + s.waktu.minute <= nowMin)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: R.color.surfaceJadwal,
          border: Border.all(color: R.color.goldDim.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.checklist_rounded, color: R.color.goldDim, size: 16),
                const SizedBox(width: 6),
                Text(
                  R.string.progressToday,
                  style: TextStyle(
                    fontSize: 12,
                    color: R.color.textMutedJadwal,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '$passed / 5 sholat',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: R.color.emeraldLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                // Background abu-abu tipis untuk progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: R.color.surface2Jadwal,
                  ),
                ),
                // Progress utama bergradasi warna Emerald
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  widthFactor: passed / 5,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [R.color.emerald, R.color.emeraldLight],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: R.color.emeraldLight.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                // Penanda bulatan (dot markers) di setiap waktu sholat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (i) {
                    final done = i < passed;
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? R.color.emeraldLight : R.color.surface3Jadwal,
                        border: Border.all(
                          color: done
                              ? R.color.emeraldLight
                              : R.color.goldDim.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Teks singkatan nama waktu sholat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: sholat
                  .map(
                    (s) => Text(
                      s.nama.substring(0, 3),
                      style: TextStyle(fontSize: 9, color: R.color.textDimJadwal),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Komponen Widget Baris Informasi Tambahan (Kiblat, Imsakiyah, dan Hadits)
class _JadwalSholatBottomRow extends StatelessWidget {
  final AnimationController ringCtrl;
  final AnimationController compassCtrl;

  const _JadwalSholatBottomRow({
    required this.ringCtrl,
    required this.compassCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          // Pembatas bagian Informasi Tambahan
          _buildSectionLabel(R.string.additionalInfo),
          Row(
            children: [
              // Card Kompas Arah Kiblat
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(Routes.ARAH_KIBLAT),
                  child: _buildQiblaCard(),
                ),
              ),
              const SizedBox(width: 10),
              // Card Waktu Tambahan (Imsak, Syuruq, dll)
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(Routes.IMSAKIYAH),
                  child: _buildImsakCard(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Hadits / Ayat pengingat sholat
          _buildHadisCard(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Row(
        children: [
          CustomPaint(
            size: const Size(12, 16),
            painter: _DiamondPainter(color: R.color.gold),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: R.color.textJadwal,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [R.color.goldDim.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaCard() {
    final controller = Get.find<JadwalSholatController>();

    return Obx(() {
      final hasCompass = controller.isCompassAvailable.value;

      double bgAngle;
      double compassAngle;
      double qiblaAngle;

      if (hasCompass) {
        // Real compass values (heading is degrees, convert to radians)
        final headingRad = -controller.deviceHeading.value * math.pi / 180.0;
        bgAngle = headingRad;
        compassAngle = headingRad; // dial rotation
        qiblaAngle = (controller.qiblaDirection.value - controller.deviceHeading.value) * math.pi / 180.0; // needle rotation
      } else {
        // Fallback animations
        bgAngle = ringCtrl.value * 2 * math.pi;
        compassAngle = 0.0; // dial stays still
        qiblaAngle = math.sin(compassCtrl.value * 2 * math.pi) * 0.04; // needle oscillates
      }

      final qiblaDegStr = hasCompass 
          ? '${controller.qiblaDirection.value.toStringAsFixed(1)}°'
          : '291.5° NW';

      return Container(
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: R.color.surfaceJadwal,
          border: Border.all(color: R.color.goldDim.withOpacity(0.15)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ornamen kiblat
              Positioned.fill(
                child: CustomPaint(
                  painter: _CompassBgPainter(
                    angle: bgAngle,
                    color: R.color.goldDim,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hasCompass ? 'KOMPAS KIBLAT AKTIF' : R.string.qiblaDirection,
                    style: TextStyle(
                      fontSize: 10,
                      color: hasCompass ? R.color.emeraldLight : R.color.textMutedJadwal,
                      fontWeight: hasCompass ? FontWeight.bold : FontWeight.normal,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Kompas Kiblat dinamis
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CustomPaint(
                      painter: _QiblaCompassPainter(
                        dialAngle: compassAngle,
                        needleAngle: qiblaAngle,
                        goldColor: R.color.gold,
                        goldDim: R.color.goldDim,
                        emerald: R.color.emerald,
                        textColor: R.color.textJadwal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    qiblaDegStr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: R.color.goldLight,
                    ),
                  ),
                  Text(
                    R.string.makkahKabah,
                    style: TextStyle(fontSize: 9, color: R.color.textMutedJadwal),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  String _hitungTengahMalam(String maghribStr, String subuhStr) {
    try {
      final maghribParts = maghribStr.split(':');
      final subuhParts = subuhStr.split(':');
      if (maghribParts.length < 2 || subuhParts.length < 2) return '--:--';

      final mHour = int.parse(maghribParts[0]);
      final mMin = int.parse(maghribParts[1]);
      final sHour = int.parse(subuhParts[0]);
      final sMin = int.parse(subuhParts[1]);

      final maghribMinutes = mHour * 60 + mMin;
      final subuhMinutes = (sHour + 24) * 60 + sMin;

      final middleMinutes = (maghribMinutes + (subuhMinutes - maghribMinutes) / 2).round();
      final finalMinutes = middleMinutes % 1440;

      final hour = finalMinutes ~/ 60;
      final minute = finalMinutes % 60;

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  Widget _buildImsakCard() {
    final controller = Get.find<JadwalSholatController>();

    return Obx(() {
      final today = controller.todayJadwal.value;
      final String imsakWaktu = today?.imsak ?? '--:--';
      final String syuruqWaktu = today?.terbit ?? '--:--';
      final String dhuhaWaktu = today?.dhuha ?? '--:--';
      final String tengahMalamWaktu = (today != null)
          ? _hitungTengahMalam(today.maghrib, today.subuh)
          : '--:--';

      final extras = [
        {'label': 'Imsak', 'waktu': imsakWaktu, 'icon': Icons.wb_twilight_rounded},
        {'label': 'Syuruq', 'waktu': syuruqWaktu, 'icon': Icons.wb_sunny_rounded},
        {'label': 'Dhuha', 'waktu': dhuhaWaktu, 'icon': Icons.light_mode_rounded},
        {'label': 'Tengah Malam', 'waktu': tengahMalamWaktu, 'icon': Icons.bedtime_rounded},
      ];

      return Container(
        height: 190,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: R.color.surfaceJadwal,
          border: Border.all(color: R.color.goldDim.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              R.string.otherTimes,
              style: TextStyle(
                fontSize: 10,
                color: R.color.textMutedJadwal,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: extras.map((e) {
                  return Row(
                    children: [
                      Icon(e['icon'] as IconData, color: R.color.goldDim, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        e['label'] as String,
                        style: TextStyle(fontSize: 11, color: R.color.textMutedJadwal),
                      ),
                      const Spacer(),
                      Text(
                        e['waktu'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: R.color.goldLight,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHadisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: R.color.surfaceJadwal,
        border: Border.all(color: R.color.goldDim.withOpacity(0.12)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Text(
              '❝',
              style: TextStyle(
                fontSize: 40,
                color: R.color.goldDim.withOpacity(0.15),
                height: 0.8,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                R.string.haditsArabic,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 15,
                  color: R.color.goldLight,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                R.string.haditsTranslation,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: R.color.textJadwal.withOpacity(0.7),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  R.string.haditsReference,
                  style: TextStyle(
                    fontSize: 10,
                    color: R.color.textMutedJadwal,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget Kustom untuk Kartu Waktu Sholat Staggered
class _SholatCard extends StatelessWidget {
  final WaktuSholat sholat;
  final int index;
  final bool isBerikutnya;
  final bool isSudahLewat;
  final bool isExpanded;
  final String Function(TimeOfDay) fmt;
  final VoidCallback onTap;
  final bool notifEnabled;

  const _SholatCard({
    required this.sholat,
    required this.index,
    required this.isBerikutnya,
    required this.isSudahLewat,
    required this.isExpanded,
    required this.fmt,
    required this.onTap,
    required this.notifEnabled,
  });

  // Jumlah rakaat masing-masing sholat fardhu
  static const _rakaat = [2, 4, 4, 3, 4];
  
  // Teks keutamaan masing-masing sholat
  static const _keutamaan = [
    'Dikerjakan sebelum fajar menyingsing. Dua rakaat sholat sunnah fajar lebih baik dari dunia dan seisinya.',
    'Sholat wajib di siang hari. Segera laksanakan saat waktu tiba agar tidak terlambat dan terhindar dari dosa.',
    'Sholat sore hari. Jangan sampai terlewat — ini adalah sholat wustha yang Allah khususkan perintahnya.',
    'Dikerjakan setelah matahari terbenam. Waktunya sempit, segera tunaikan begitu adzan berkumandang.',
    'Sholat malam penutup hari. Sangat dianjurkan untuk menambah sholat sunnah rawatib setelahnya.',
  ];

  @override
  Widget build(BuildContext context) {
    final accent = sholat.accent;
    final opacity = isSudahLewat && !isBerikutnya ? 0.5 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: opacity,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: R.color.surfaceJadwal,
            border: Border.all(
              color: isBerikutnya
                  ? accent.withOpacity(0.5)
                  : R.color.goldDim.withOpacity(0.12),
              width: isBerikutnya ? 1.5 : 1,
            ),
            boxShadow: isBerikutnya
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: [
                _buildMain(accent),
                AnimatedCrossFade(
                  firstChild: _buildExpanded(),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMain(Color accent) {
    return Stack(
      children: [
        // Aksen garis berwarna di paling kiri kartu
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
          ),
        ),
        // Gradasi kilau lembut untuk waktu sholat terdekat berikutnya
        if (isBerikutnya)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [accent.withOpacity(0.08), Colors.transparent],
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
          child: Row(
            children: [
              // Icon & info rakaat
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: accent.withOpacity(0.12),
                      border: Border.all(color: accent.withOpacity(0.25)),
                    ),
                    child: Center(
                      child: Text(
                        sholat.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_rakaat[index]}x',
                    style: TextStyle(fontSize: 9, color: R.color.textMutedJadwal),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Nama sholat, deskripsi, dan badge status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          sholat.arabNama,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 16,
                            color: R.color.goldLight,
                          ),
                        ),
                        if (isBerikutnya) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: accent.withOpacity(0.2),
                              border: Border.all(
                                color: accent.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              R.string.nextLabel,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color.lerp(accent, Colors.white, 0.5),
                              ),
                            ),
                          ),
                        ],
                        if (isSudahLewat && !isBerikutnya) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle_rounded,
                            color: R.color.emeraldLight.withOpacity(0.6),
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sholat.nama,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: R.color.textJadwal,
                      ),
                    ),
                    Text(
                      sholat.deskripsi,
                      style: TextStyle(fontSize: 11, color: R.color.textMutedJadwal),
                    ),
                  ],
                ),
              ),
              // Waktu pelaksanaan & tombol expand detail
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmt(sholat.waktu),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isSudahLewat && !isBerikutnya
                          ? R.color.textMutedJadwal
                          : Color.lerp(accent, Colors.white, 0.35),
                      letterSpacing: 1.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: R.color.textMutedJadwal,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpanded() {
    final accent = sholat.accent;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: R.color.goldDim.withOpacity(0.12))),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withOpacity(0.05), R.color.surface2Jadwal],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teks keutamaan ibadah
          Text(
            _keutamaan[index],
            style: TextStyle(
              fontSize: 12,
              color: R.color.textJadwal.withOpacity(0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          // Badges informasi detail
          Row(
            children: [
              _InfoBadge(
                icon: Icons.format_list_numbered_rounded,
                label: '${_rakaat[index]} Rakaat',
                color: accent,
              ),
              const SizedBox(width: 8),
              _InfoBadge(
                icon: notifEnabled ? Icons.notifications_rounded : Icons.notifications_off_rounded,
                label: notifEnabled ? 'Notif Aktif' : 'Notif Mati',
                color: notifEnabled ? R.color.emerald : R.color.textMutedJadwal,
              ),
              const SizedBox(width: 8),
              _InfoBadge(
                icon: Icons.access_time_rounded,
                label: fmt(sholat.waktu),
                color: R.color.goldDim,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget Kustom berbentuk Tile Informasi pendukung
class _InfoTile extends StatelessWidget {
  final String topLabel;
  final String value;
  final String subValue;
  final Color accent;
  final IconData icon;

  const _InfoTile({
    required this.topLabel,
    required this.value,
    required this.subValue,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: R.color.surfaceJadwal,
        border: Border.all(color: R.color.goldDim.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.15),
              border: Border.all(color: accent.withOpacity(0.3)),
            ),
            child: Icon(icon, color: accent, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topLabel,
                  style: TextStyle(
                    fontSize: 9,
                    color: R.color.textMutedJadwal,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: R.color.textJadwal,
                    height: 1.2,
                  ),
                ),
                Text(
                  subValue,
                  style: TextStyle(fontSize: 9, color: R.color.textMutedJadwal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Kustom Badge Mini bulat lonjong
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Color.lerp(color, Colors.white, 0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS & ORNAMEN DINAMIS
// ═══════════════════════════════════════════════════════════════════════════

// Widget Gambar latar belakang ornamen geometris Islami
class _GeoBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GeoBgPainter());
  }
}

// Menggambar pola bintang segi delapan berulang di latar belakang
class _GeoBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = R.color.goldDim.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    const sp = 70.0;
    const r = 24.0;
    for (double x = 0; x < size.width + sp; x += sp) {
      for (double y = 0; y < size.height + sp; y += sp) {
        // Pola bintang segi delapan luar
        final path = Path();
        for (int i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final px = x + r * math.cos(a);
          final py = y + r * math.sin(a);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);

        // Pola berlian dalam (inner diamond)
        final path2 = Path();
        for (int i = 0; i < 4; i++) {
          final a = i * math.pi / 2 + math.pi / 4;
          final px = x + r * 0.55 * math.cos(a);
          final py = y + r * 0.55 * math.sin(a);
          if (i == 0) {
            path2.moveTo(px, py);
          } else {
            path2.lineTo(px, py);
          }
        }
        path2.close();
        canvas.drawPath(path2, paint);

        // Titik pusat ornamen
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }

    // Menggambar ornamen busur di pojok kanan atas
    _drawCornerOrnamen(canvas, Offset(size.width + 10, -10), 120, paint);
    // Menggambar ornamen busur di pojok kiri bawah
    _drawCornerOrnamen(canvas, Offset(-10, size.height + 10), 100, paint);
  }

  void _drawCornerOrnamen(Canvas c, Offset center, double r, Paint p) {
    final rings = [r * 0.4, r * 0.7, r];
    for (final ri in rings) {
      c.drawCircle(center, ri, p);
    }
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      c.drawLine(
        center + Offset(math.cos(a) * r * 0.3, math.sin(a) * r * 0.3),
        center + Offset(math.cos(a) * r, math.sin(a) * r),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// Widget ornamen berputar dekoratif di belakang Hero Card
class _HeroOrnamen extends StatefulWidget {
  final Color accent;
  const _HeroOrnamen({required this.accent});

  @override
  State<_HeroOrnamen> createState() => _HeroOrnamenState();
}

class _HeroOrnamenState extends State<_HeroOrnamen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _HeroOrnamenPainter(
          angle: _ctrl.value * 2 * math.pi,
          accent: widget.accent,
        ),
      ),
    );
  }
}

// Menggambar garis-garis halus ornamen yang berotasi lambat
class _HeroOrnamenPainter extends CustomPainter {
  final double angle;
  final Color accent;
  const _HeroOrnamenPainter({required this.angle, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width;
    final cy = 0.0;
    final paint = Paint()
      ..color = accent.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    for (int i = 0; i < 12; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 6);
      for (double r = 30; r <= 160; r += 30) {
        canvas.drawLine(Offset(r * 0.6, 0), Offset(r, 0), paint);
      }
      canvas.restore();
    }

    for (double r = 40; r <= 160; r += 40) {
      canvas.drawCircle(
        Offset.zero,
        r,
        paint..color = accent.withOpacity(0.04),
      );
    }

    canvas.restore();

    final paint2 = Paint()
      ..color = R.color.goldDim.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.save();
    canvas.translate(0, size.height);
    canvas.rotate(-angle * 0.5);
    for (double r = 20; r <= 100; r += 20) {
      canvas.drawCircle(Offset.zero, r, paint2);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeroOrnamenPainter old) =>
      old.angle != angle || old.accent != accent;
}

// Menggambar garis penunjuk kompas kiblat di sekeliling piringan kompas
class _CompassBgPainter extends CustomPainter {
  final double angle;
  final Color color;
  const _CompassBgPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    for (int i = 0; i < 8; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 4);
      for (double r = 20; r <= 100; r += 20) {
        canvas.drawLine(Offset(r * 0.7, 0), Offset(r, 0), paint);
      }
      canvas.restore();
    }

    for (double r = 30; r <= 110; r += 25) {
      canvas.drawCircle(Offset.zero, r, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CompassBgPainter old) => old.angle != angle;
}

// Menggambar detail jarum Kompas Kiblat dan lambang Ka'bah
class _QiblaCompassPainter extends CustomPainter {
  final double dialAngle; // Rotasi piringan arah mata angin
  final double needleAngle; // Rotasi jarum penunjuk ka'bah
  final Color goldColor, goldDim, emerald, textColor;

  const _QiblaCompassPainter({
    required this.dialAngle,
    required this.needleAngle,
    required this.goldColor,
    required this.goldDim,
    required this.emerald,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 4;

    // Lingkaran luar kompas
    final ringPaint = Paint()
      ..color = goldDim.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 1. Gambar piringan arah mata angin (berputar sesuai dialAngle)
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(dialAngle);

    canvas.drawCircle(Offset.zero, r, ringPaint);

    // Garis-garis kecil derajat arah mata angin
    final tickPaint = Paint()
      ..color = goldDim.withOpacity(0.4)
      ..strokeWidth = 1;
    for (int i = 0; i < 32; i++) {
      final a = i * math.pi / 16;
      final len = i % 4 == 0 ? 8.0 : 4.0;
      canvas.drawLine(
        Offset((r - len) * math.cos(a), (r - len) * math.sin(a)),
        Offset(r * math.cos(a), r * math.sin(a)),
        tickPaint,
      );
    }

    // Inisial arah mata angin (U, S, B, T)
    final labels = ['U', 'S', 'B', 'T'];
    final angles = [math.pi * 3 / 2, math.pi / 2, math.pi, 0];
    for (int i = 0; i < 4; i++) {
      final tx = (r - 16) * math.cos(angles[i]);
      final ty = (r - 16) * math.sin(angles[i]);
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: i == 0 ? goldColor : goldDim.withOpacity(0.5),
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(tx - tp.width / 2, ty - tp.height / 2));
    }
    canvas.restore();

    // 2. Gambar jarum kompas dinamis (berputar sesuai needleAngle)
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(needleAngle);

    final needleColor = Paint()..color = goldColor;
    final needleShadow = Paint()..color = goldDim.withOpacity(0.5);

    // Jarum atas penunjuk arah kiblat
    final top = Path()
      ..moveTo(0, -(r - 18))
      ..lineTo(-5, -8)
      ..lineTo(5, -8)
      ..close();
    canvas.drawPath(top, needleColor);

    // Jarum bawah kompas
    final bot = Paint()..color = goldDim.withOpacity(0.4);
    final botPath = Path()
      ..moveTo(0, r - 18)
      ..lineTo(-5, 8)
      ..lineTo(5, 8)
      ..close();
    canvas.drawPath(botPath, bot);

    canvas.drawCircle(Offset.zero, 6, needleShadow);
    canvas.drawCircle(Offset.zero, 4, needleColor);

    // Miniatur ikon Ka'bah hitam di ujung atas jarum kiblat
    final kabahPaint = Paint()
      ..color = const Color(0xFF0A0A0A)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-4, -(r - 14), 8, 8),
        const Radius.circular(1),
      ),
      kabahPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_QiblaCompassPainter old) =>
      old.dialAngle != dialAngle || old.needleAngle != needleAngle;
}

// Menggambar aksen berlian (diamond) kecil pembatas seksi
class _DiamondPainter extends CustomPainter {
  final Color color;
  const _DiamondPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
