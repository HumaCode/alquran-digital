import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/models/jadwal_sholat_model.dart';
import '../../../data/repositories/surah_repository.dart';
import '../../../data/providers/database_helper.dart';
import '../../../data/providers/notification_helper.dart';
import '../../../data/providers/widget_helper.dart';

class HomeController extends GetxController {
  final SurahRepository _repository;

  HomeController(this._repository);

  final isLoading = false.obs;
  final surahs = <DataSurah>[].obs;
  final errorMessage = ''.obs;

  // Pagination & Scroll states
  final isMoreLoading = false.obs;
  final showScrollToTop = false.obs;
  final scrollController = ScrollController();
  
  // Search states
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  final searchType = 'surah'.obs; // 'surah' or 'ayat'
  final searchedAyats = <Map<String, dynamic>>[].obs;
  final isSearchLoading = false.obs;
  Timer? _searchDebounce;

  // Advanced Search & Filters states
  final filterPlace = 'all'.obs; // 'all', 'Makkiyah', 'Madaniyah'
  final filterLength = 'all'.obs; // 'all', 'short', 'medium', 'long'
  final searchHistory = <String>[].obs;
  final _rawSearchedAyats = <Map<String, dynamic>>[];
  static const String _historyKey = 'search_history_queries';

  // Last Read states
  final lastReadSurahNomor = 0.obs;
  final lastReadSurahNama = ''.obs;
  final lastReadAyatNomor = 0.obs;
  final hasLastRead = false.obs;

  // Bookmark states
  final bookmarkedSurahIds = <int>[].obs;
  final bookmarkedAyats = <Map<String, dynamic>>[].obs;

  // Tilawah Tracker states
  final tilawahStreak = 0.obs;
  final tilawahToday = 0.obs;
  final tilawahTarget = 10.obs;
  final tilawahProgress = <Map<String, dynamic>>[].obs;

  // Khatam Tracker states
  final completedSurahsCount = 0.obs;
  final khatamProgressPercent = 0.0.obs;
  final khatamEstimationDate = ''.obs;
  final averageDailyTilawah = 0.0.obs;

  // Tilawah Reminder states
  final tilawahReminderEnabled = false.obs;
  final tilawahReminderHour = 20.obs;   // default 20:00
  final tilawahReminderMinute = 0.obs;

  int _loadedCount = 0;
  final int _pageSize = 10;
  List<DataSurah> _allSurahs = [];
  List<DataSurah> get allSurahs => _allSurahs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchSurahs();
    fetchLastRead();
    fetchBookmarks();
    fetchBookmarkedAyats();
    fetchTilawahTracker();
    fetchKhatamProgress();
    _loadReminderSettings();
    loadSearchHistory();
    fetchAndSetDailyAyat();
    updateSholatWidgetFromCache();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    // Show back-to-top button
    if (scrollController.offset > 400 && !showScrollToTop.value) {
      showScrollToTop.value = true;
    } else if (scrollController.offset <= 400 && showScrollToTop.value) {
      showScrollToTop.value = false;
    }

    // Load more when scrolled near bottom (only if not searching)
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (searchQuery.value.trim().isEmpty && !isMoreLoading.value && surahs.length < _allSurahs.length) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    isMoreLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 200));
    loadNextPage();
    isMoreLoading.value = false;
  }

  void loadNextPage() {
    if (_loadedCount >= _allSurahs.length) return;

    final nextBatchSize = (_allSurahs.length - _loadedCount) < _pageSize
        ? (_allSurahs.length - _loadedCount)
        : _pageSize;

    final nextBatch = _allSurahs.sublist(_loadedCount, _loadedCount + nextBatchSize);
    surahs.addAll(nextBatch);
    _loadedCount += nextBatchSize;
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();

    if (query.trim().isEmpty && filterPlace.value == 'all' && filterLength.value == 'all') {
      searchedAyats.clear();
      _rawSearchedAyats.clear();
      surahs.clear();
      _loadedCount = 0;
      loadNextPage();
    } else {
      if (searchType.value == 'surah') {
        applyFilters();
        if (query.trim().length >= 2) {
          _searchDebounce = Timer(const Duration(milliseconds: 1000), () {
            addSearchHistory(query.trim());
          });
        }
      } else {
        if (query.trim().isEmpty) {
          searchedAyats.clear();
          _rawSearchedAyats.clear();
          return;
        }
        isSearchLoading.value = true;
        _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
          try {
            final results = await DatabaseHelper.instance.searchAyat(query);
            _rawSearchedAyats.clear();
            _rawSearchedAyats.addAll(results);
            applyFilters();
            if (query.trim().length >= 2) {
              addSearchHistory(query.trim());
            }
          } catch (e) {
            debugPrint('Error searching ayat: $e');
          } finally {
            isSearchLoading.value = false;
          }
        });
      }
    }
  }

  void changeSearchType(String type) {
    searchType.value = type;
    onSearchChanged(searchQuery.value);
  }

  void clearSearch() {
    searchController.clear();
    _searchDebounce?.cancel();
    onSearchChanged('');
  }

  void applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    
    if (searchType.value == 'surah') {
      Iterable<DataSurah> filtered = _allSurahs;
      
      // Filter by search query
      if (query.isNotEmpty) {
        filtered = filtered.where((s) =>
            s.namaLatin.toLowerCase().contains(query) ||
            s.nama.toLowerCase().contains(query) ||
            s.arti.toLowerCase().contains(query));
      }
      
      // Filter by tempatTurun (Makkiyah / Madaniyah)
      if (filterPlace.value != 'all') {
        final isMekah = filterPlace.value == 'Makkiyah';
        filtered = filtered.where((s) {
          final tempat = s.tempatTurun.toLowerCase();
          return isMekah 
              ? (tempat == 'mekah' || tempat.contains('makki') || tempat.contains('mekki')) 
              : (tempat == 'madinah' || tempat.contains('mada'));
        });
      }
      
      // Filter by length
      if (filterLength.value != 'all') {
        filtered = filtered.where((s) {
          final count = s.jumlahAyat;
          if (filterLength.value == 'short') return count < 20;
          if (filterLength.value == 'medium') return count >= 20 && count <= 100;
          return count > 100; // 'long'
        });
      }
      
      surahs.assignAll(filtered.toList());
    } else {
      Iterable<Map<String, dynamic>> filtered = _rawSearchedAyats;
      
      // Filter by tempatTurun
      if (filterPlace.value != 'all') {
        final isMekah = filterPlace.value == 'Makkiyah';
        filtered = filtered.where((item) {
          final tempat = (item['tempatTurun'] as String? ?? '').toLowerCase();
          return isMekah 
              ? (tempat == 'mekah' || tempat.contains('makki') || tempat.contains('mekki')) 
              : (tempat == 'madinah' || tempat.contains('mada'));
        });
      }
      
      // Filter by length
      if (filterLength.value != 'all') {
        filtered = filtered.where((item) {
          final count = item['jumlahAyat'] as int? ?? 0;
          if (filterLength.value == 'short') return count < 20;
          if (filterLength.value == 'medium') return count >= 20 && count <= 100;
          return count > 100; // 'long'
        });
      }
      
      searchedAyats.assignAll(filtered.toList());
    }
  }

  void setFilterPlace(String place) {
    filterPlace.value = place;
    applyFilters();
  }

  void setFilterLength(String length) {
    filterLength.value = length;
    applyFilters();
  }

  void clearFilters() {
    filterPlace.value = 'all';
    filterLength.value = 'all';
    applyFilters();
  }

  Future<void> loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_historyKey);
      if (list != null) {
        searchHistory.assignAll(list);
      }
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  Future<void> addSearchHistory(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    searchHistory.remove(trimmed);
    searchHistory.insert(0, trimmed);
    if (searchHistory.length > 10) {
      searchHistory.removeLast();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, searchHistory);
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  Future<void> deleteHistoryItem(String query) async {
    searchHistory.remove(query);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, searchHistory);
    } catch (e) {
      debugPrint('Error deleting history item: $e');
    }
  }

  Future<void> clearSearchHistory() async {
    searchHistory.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      debugPrint('Error clearing search history: $e');
    }
  }

  Future<void> fetchSurahs() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _repository.getSurahs();
      _allSurahs = data;
      surahs.clear();
      _loadedCount = 0;
      loadNextPage();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLastRead() async {
    try {
      final lastRead = await _repository.getLastRead();
      if (lastRead != null) {
        lastReadSurahNomor.value = lastRead['nomorSurah'] as int;
        lastReadSurahNama.value = lastRead['namaLatin'] as String;
        lastReadAyatNomor.value = lastRead['nomorAyat'] as int;
        hasLastRead.value = true;
      } else {
        hasLastRead.value = false;
      }
    } catch (e) {
      print('Gagal mengambil data terakhir dibaca: $e');
    }
  }

  Future<void> fetchBookmarks() async {
    try {
      final list = await _repository.getBookmarks();
      bookmarkedSurahIds.assignAll(list);
    } catch (e) {
      print('Gagal mengambil bookmark: $e');
    }
  }

  Future<void> fetchBookmarkedAyats() async {
    try {
      final list = await _repository.getBookmarksList();
      bookmarkedAyats.assignAll(list);
    } catch (e) {
      print('Gagal mengambil bookmark ayat: $e');
    }
  }

  Future<void> deleteAyatBookmark(int nomorSurah, int nomorAyat) async {
    try {
      await _repository.deleteBookmark(nomorSurah, nomorAyat);
      await fetchBookmarkedAyats();
    } catch (e) {
      print('Gagal menghapus bookmark ayat: $e');
    }
  }

  Future<bool> toggleBookmark(int nomorSurah) async {
    try {
      bool added = false;
      if (bookmarkedSurahIds.contains(nomorSurah)) {
        bookmarkedSurahIds.remove(nomorSurah);
        added = false;
      } else {
        bookmarkedSurahIds.add(nomorSurah);
        added = true;
      }
      await _repository.saveBookmarks(bookmarkedSurahIds.toList());
      return added;
    } catch (e) {
      print('Gagal menyimpan bookmark: $e');
      return false;
    }
  }

  Future<void> fetchTilawahTracker() async {
    try {
      final streak = await _repository.getTilawahStreak();
      tilawahStreak.value = streak;

      final target = await _repository.getDailyTarget();
      tilawahTarget.value = target;

      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      final list = await _repository.getTilawahProgressList(7);
      tilawahProgress.assignAll(list);

      // Find today's progress in list
      int todayCount = 0;
      for (var item in list) {
        if (item['tanggal'] == todayStr) {
          todayCount = item['jumlahAyatDibaca'] as int;
          break;
        }
      }
      tilawahToday.value = todayCount;
      // Perbarui body notifikasi reminder agar selalu menampilkan sisa ayat terkini
      _rescheduleReminderIfNeeded();

      // Perbarui widget progress
      await WidgetHelper.updateProgressWidget(
        today: todayCount,
        target: target,
        streak: streak,
      );
    } catch (e) {
      print('Gagal mengambil data tilawah tracker: $e');
    }
  }

  Future<void> fetchAndSetDailyAyat() async {
    try {
      final ayatData = await _repository.getRandomAyat();
      await WidgetHelper.updateAyatWidget(
        arab: ayatData['arab'] ?? '',
        indo: ayatData['indo'] ?? '',
        ref: ayatData['ref'] ?? '',
      );
    } catch (e) {
      print('Gagal memuat ayat harian untuk widget: $e');
    }
  }

  Future<void> updateDailyTarget(int target) async {
    try {
      await _repository.saveDailyTarget(target);
      await fetchTilawahTracker();
    } catch (e) {
      print('Gagal memperbarui target tilawah: $e');
    }
  }

  // ── Tilawah Reminder ──────────────────────────────────────────────────────

  Future<void> _loadReminderSettings() async {
    final db = DatabaseHelper.instance;
    final enabled = await db.getMetadata('tilawah_reminder_enabled');
    final hour = await db.getMetadata('tilawah_reminder_hour');
    final minute = await db.getMetadata('tilawah_reminder_minute');
    tilawahReminderEnabled.value = enabled == '1';
    tilawahReminderHour.value = int.tryParse(hour ?? '20') ?? 20;
    tilawahReminderMinute.value = int.tryParse(minute ?? '0') ?? 0;
  }

  Future<void> updateTilawahReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    tilawahReminderEnabled.value = enabled;
    tilawahReminderHour.value = hour;
    tilawahReminderMinute.value = minute;
    final db = DatabaseHelper.instance;
    await db.updateMetadata('tilawah_reminder_enabled', enabled ? '1' : '0');
    await db.updateMetadata('tilawah_reminder_hour', hour.toString());
    await db.updateMetadata('tilawah_reminder_minute', minute.toString());
    if (enabled) {
      await NotificationHelper.scheduleTilawahReminder(
        hour: hour,
        minute: minute,
        target: tilawahTarget.value,
        todayCount: tilawahToday.value,
      );
    } else {
      await NotificationHelper.cancelTilawahReminder();
    }
  }

  Future<void> toggleTilawahReminder(bool enabled) async {
    await updateTilawahReminder(
      enabled: enabled,
      hour: tilawahReminderHour.value,
      minute: tilawahReminderMinute.value,
    );
  }

  Future<void> updateTilawahReminderTime(int hour, int minute) async {
    await updateTilawahReminder(
      enabled: tilawahReminderEnabled.value,
      hour: hour,
      minute: minute,
    );
  }

  /// Dipanggil setelah fetchTilawahTracker agar body notif selalu fresh.
  Future<void> _rescheduleReminderIfNeeded() async {
    if (!tilawahReminderEnabled.value) return;
    await NotificationHelper.scheduleTilawahReminder(
      hour: tilawahReminderHour.value,
      minute: tilawahReminderMinute.value,
      target: tilawahTarget.value,
      todayCount: tilawahToday.value,
    );
  }

  Future<void> fetchKhatamProgress() async {
    try {
      final count = await _repository.getCompletedSurahsCount();
      completedSurahsCount.value = count;
      khatamProgressPercent.value = (count / 114.0).clamp(0.0, 1.0);

      final stats = await _repository.getTilawahStats();
      final totalAyatRead = stats['totalAyat'] as int? ?? 0;
      final avg = stats['rataRata'] as double? ?? 0.0;
      averageDailyTilawah.value = avg;

      const totalQuranAyats = 6236;
      final remainingAyats = (totalQuranAyats - totalAyatRead).clamp(0, totalQuranAyats);

      if (remainingAyats == 0) {
        khatamEstimationDate.value = "Sudah Khatam! 🎉";
      } else {
        final double dailyRate = avg > 0.5 ? avg : tilawahTarget.value.toDouble();
        final double doubleDays = remainingAyats / dailyRate;
        final int daysNeeded = doubleDays.ceil().clamp(1, 9999);
        
        final estimationDate = DateTime.now().add(Duration(days: daysNeeded));
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
          'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
        ];
        khatamEstimationDate.value = "${estimationDate.day} ${months[estimationDate.month - 1]} ${estimationDate.year}";
      }
    } catch (e) {
      print('Gagal memuat progres khatam: $e');
    }
  }

  Future<void> updateSholatWidgetFromCache() async {
    try {
      final db = DatabaseHelper.instance;
      final cachedJson = await db.getMetadata('jadwal_sholat_cached');
      if (cachedJson == null) {
        print('Widget sholat: Tidak ada cache jadwal sholat.');
        return;
      }

      final decoded = jsonDecode(cachedJson);
      final schedule = JadwalSholat.fromJson(decoded as Map<String, dynamic>);
      
      final now = DateTime.now();
      print('Widget sholat: now is $now');
      final today = schedule.data.jadwal.firstWhereOrNull(
        (j) =>
            j.tanggalLengkap.day == now.day &&
            j.tanggalLengkap.month == now.month &&
            j.tanggalLengkap.year == now.year,
      );

      if (today == null) {
        print('Widget sholat: Tidak ditemukan jadwal sholat untuk hari ini. Jadwal count: ${schedule.data.jadwal.length}');
        for (var item in schedule.data.jadwal.take(3)) {
          print('Widget sholat: Available date in cache: ${item.tanggalLengkap}');
        }
        return;
      }

      print('Widget sholat: found today: ${today.tanggalLengkap}, subuh: ${today.subuh}, dzuhur: ${today.dzuhur}, ashar: ${today.ashar}, maghrib: ${today.maghrib}, isya: ${today.isya}');

      // Hitung jadwal sholat berikutnya
      final prayers = [
        {'nama': 'Subuh', 'waktu': today.subuh},
        {'nama': 'Dzuhur', 'waktu': today.dzuhur},
        {'nama': 'Ashar', 'waktu': today.ashar},
        {'nama': 'Maghrib', 'waktu': today.maghrib},
        {'nama': 'Isya', 'waktu': today.isya},
      ];

      final nowMin = now.hour * 60 + now.minute;
      var nextPrayerName = 'Subuh';
      var nextPrayerTime = today.subuh;
      var found = false;

      for (var p in prayers) {
        final timeStr = p['waktu']!;
        final parts = timeStr.trim().split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final sMin = hour * 60 + minute;
        
        if (sMin > nowMin) {
          nextPrayerName = p['nama']!;
          nextPrayerTime = timeStr;
          found = true;
          break;
        }
      }

      var targetDt = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(nextPrayerTime.split(':')[0]),
        int.parse(nextPrayerTime.split(':')[1]),
      );
      if (!found) {
        // Jika sudah lewat Isya, jadwal berikutnya adalah Subuh esok hari
        targetDt = targetDt.add(const Duration(days: 1));
      }

      final countdownDuration = targetDt.difference(now);
      final remainingMinutes = countdownDuration.inMinutes;
      String countStr = '';
      if (remainingMinutes > 60) {
        final hours = remainingMinutes ~/ 60;
        final mins = remainingMinutes % 60;
        countStr = '$hours jam $mins mnt lagi';
      } else {
        countStr = '$remainingMinutes mnt lagi';
      }

      await WidgetHelper.updateSholatWidget(
        location: schedule.data.kabkota,
        nextPrayerName: nextPrayerName,
        nextPrayerTime: nextPrayerTime,
        countdown: countStr,
        subuh: today.subuh,
        dzuhur: today.dzuhur,
        ashar: today.ashar,
        maghrib: today.maghrib,
        isya: today.isya,
      );
      print('Widget sholat berhasil diperbarui dari cache di HomeController.');
    } catch (e) {
      print('Gagal memperbarui widget sholat dari cache: $e');
    }
  }
}
