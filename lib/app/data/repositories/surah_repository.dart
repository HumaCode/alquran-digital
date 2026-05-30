import '../models/detail_surah_model.dart';
import '../models/surah_model.dart';
import '../models/tafsir_model.dart';
import '../providers/database_helper.dart';
import '../providers/surah_provider.dart';

class SurahRepository {
  final SurahProvider _provider;

  SurahRepository(this._provider);

  Future<List<DataSurah>> getSurahs() async {
    final dbHelper = DatabaseHelper.instance;

    // 1. Coba ambil dari database lokal terlebih dahulu
    try {
      final localSurahs = await dbHelper.getSurahs();
      if (localSurahs.isNotEmpty) {
        // Jalankan sinkronisasi background secara asinkron (Silent Update)
        _checkAndSyncSurahsInBackground();
        return localSurahs;
      }
    } catch (e) {
      print('Gagal mengambil surah lokal: $e');
    }

    // 2. Jika database lokal kosong, ambil dari API (Blocking untuk pertama kali)
    final response = await _provider.fetchSurahs();
    if (response.status.hasError) {
      throw Exception('Gagal memuat daftar surah: ${response.statusText}');
    }

    final data = response.body;
    if (data != null) {
      final surahResponse = Surah.fromJson(data as Map<String, dynamic>);

      // Simpan ke SQLite
      try {
        await dbHelper.insertSurahs(surahResponse.data);
        await dbHelper.updateMetadata('last_sync_date', DateTime.now().toIso8601String());
      } catch (e) {
        print('Gagal menyimpan surah ke database lokal: $e');
      }

      return surahResponse.data;
    } else {
      throw Exception('Data surah kosong');
    }
  }

  Future<DetailSurah> getDetailSurah(int nomor) async {
    final dbHelper = DatabaseHelper.instance;

    // 1. Cek apakah ayat surah ini sudah tersimpan di database lokal
    try {
      final hasLocalAyats = await dbHelper.hasAyats(nomor);
      if (hasLocalAyats) {
        final localDetail = await dbHelper.getDetailSurah(nomor);
        if (localDetail != null) {
          return localDetail;
        }
      }
    } catch (e) {
      print('Gagal mengecek detail surah lokal: $e');
    }

    // 2. Jika belum tersimpan di lokal, ambil dari API
    final response = await _provider.fetchDetailSurah(nomor);
    if (response.status.hasError) {
      throw Exception('Gagal memuat detail surah: ${response.statusText}');
    }

    final data = response.body;
    if (data != null) {
      final detailSurah = DetailSurah.fromJson(data as Map<String, dynamic>);

      // Simpan ayat dan surah ke SQLite secara asinkron agar tidak memblokir UI
      try {
        await dbHelper.insertAyats(nomor, detailSurah.data.ayat);
      } catch (e) {
        print('Gagal menyimpan ayat ke database lokal: $e');
      }

      return detailSurah;
    } else {
      throw Exception('Data detail surah kosong');
    }
  }

  Future<TafsirSurah> getTafsirSurah(int nomor) async {
    final response = await _provider.fetchTafsirSurah(nomor);
    if (response.status.hasError) {
      throw Exception('Gagal memuat tafsir surah: ${response.statusText}');
    }

    final data = response.body;
    if (data != null) {
      return TafsirSurah.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Data tafsir surah kosong');
    }
  }

  // Pengecekan sinkronisasi asinkron di latar belakang
  Future<void> _checkAndSyncSurahsInBackground() async {
    final dbHelper = DatabaseHelper.instance;
    try {
      final lastSyncStr = await dbHelper.getMetadata('last_sync_date');
      if (lastSyncStr != null) {
        final lastSync = DateTime.parse(lastSyncStr);
        final difference = DateTime.now().difference(lastSync).inDays;

        // Hanya sinkronisasi ulang jika data lokal sudah lebih dari 7 hari
        if (difference < 7) {
          return;
        }
      }

      // Ambil data terbaru dari API secara silent
      final response = await _provider.fetchSurahs();
      if (!response.status.hasError && response.body != null) {
        final surahResponse = Surah.fromJson(response.body as Map<String, dynamic>);
        
        // Simpan pembaruan ke database lokal
        await dbHelper.insertSurahs(surahResponse.data);
        await dbHelper.updateMetadata('last_sync_date', DateTime.now().toIso8601String());
        print('Sinkronisasi database surah lokal berhasil (Silent Update)');
      }
    } catch (e) {
      print('Gagal sinkronisasi data di background: $e');
    }
  }

  Future<void> saveLastRead(int nomorSurah, String namaLatin, int nomorAyat) async {
    await DatabaseHelper.instance.saveLastRead(nomorSurah, namaLatin, nomorAyat);
  }

  Future<Map<String, dynamic>?> getLastRead() async {
    return await DatabaseHelper.instance.getLastRead();
  }

  Future<void> saveBookmarks(List<int> bookmarks) async {
    await DatabaseHelper.instance.saveBookmarks(bookmarks);
  }

  Future<List<int>> getBookmarks() async {
    return await DatabaseHelper.instance.getBookmarks();
  }

  Future<int> insertBookmark(Map<String, dynamic> bookmark) async {
    return await DatabaseHelper.instance.insertBookmark(bookmark);
  }

  Future<List<Map<String, dynamic>>> getBookmarksList() async {
    return await DatabaseHelper.instance.getBookmarksList();
  }

  Future<int> deleteBookmark(int nomorSurah, int nomorAyat) async {
    return await DatabaseHelper.instance.deleteBookmark(nomorSurah, nomorAyat);
  }

  Future<bool> isBookmarked(int nomorSurah, int nomorAyat) async {
    return await DatabaseHelper.instance.isBookmarked(nomorSurah, nomorAyat);
  }

  Future<int> saveNote(int nomorSurah, String namaSurah, int nomorAyat, String teksCatatan) async {
    return await DatabaseHelper.instance.saveNote(nomorSurah, namaSurah, nomorAyat, teksCatatan);
  }

  Future<List<Map<String, dynamic>>> getNotesList() async {
    return await DatabaseHelper.instance.getNotesList();
  }

  Future<String?> getNoteText(int nomorSurah, int nomorAyat) async {
    return await DatabaseHelper.instance.getNoteText(nomorSurah, nomorAyat);
  }

  Future<int> deleteNote(int nomorSurah, int nomorAyat) async {
    return await DatabaseHelper.instance.deleteNote(nomorSurah, nomorAyat);
  }

  Future<Map<String, dynamic>?> getAyat(int nomorSurah, int nomorAyat) async {
    return await DatabaseHelper.instance.getAyat(nomorSurah, nomorAyat);
  }

  // ── Hafalan Progress ───────────────────────────────────────────────────────
  Future<void> saveHafalanProgress(int nomorSurah, int nomorAyat, String status) async {
    await DatabaseHelper.instance.saveHafalanProgress(nomorSurah, nomorAyat, status);
  }

  Future<void> deleteHafalanProgress(int nomorSurah, int nomorAyat) async {
    await DatabaseHelper.instance.deleteHafalanProgress(nomorSurah, nomorAyat);
  }

  Future<String?> getHafalanStatus(int nomorSurah, int nomorAyat) async {
    return await DatabaseHelper.instance.getHafalanStatus(nomorSurah, nomorAyat);
  }

  Future<List<Map<String, dynamic>>> getHafalanProgressBySurah(int nomorSurah) async {
    return await DatabaseHelper.instance.getHafalanProgressBySurah(nomorSurah);
  }

  // ── Tilawah Progress ───────────────────────────────────────────────────────
  Future<void> logTilawah(String tanggal, int count) async {
    await DatabaseHelper.instance.logTilawah(tanggal, count);
  }

  Future<List<Map<String, dynamic>>> getTilawahProgressList(int limit) async {
    return await DatabaseHelper.instance.getTilawahProgressList(limit);
  }

  Future<int> getDailyTarget() async {
    return await DatabaseHelper.instance.getDailyTarget();
  }

  Future<void> saveDailyTarget(int target) async {
    await DatabaseHelper.instance.saveDailyTarget(target);
  }

  Future<int> getTilawahStreak() async {
    return await DatabaseHelper.instance.getTilawahStreak();
  }

  Future<Map<String, dynamic>> getTilawahStats() async {
    return await DatabaseHelper.instance.getTilawahStats();
  }

  Future<List<Map<String, dynamic>>> getMonthlyProgress() async {
    return await DatabaseHelper.instance.getMonthlyProgress();
  }

  Future<void> markSurahAsCompleted(int nomorSurah, String namaSurah, bool completed) async {
    await DatabaseHelper.instance.markSurahAsCompleted(nomorSurah, namaSurah, completed);
  }

  Future<bool> isSurahCompleted(int nomorSurah) async {
    return await DatabaseHelper.instance.isSurahCompleted(nomorSurah);
  }

  Future<List<Map<String, dynamic>>> getCompletedSurahs() async {
    return await DatabaseHelper.instance.getCompletedSurahs();
  }

  Future<int> getCompletedSurahsCount() async {
    return await DatabaseHelper.instance.getCompletedSurahsCount();
  }

  Future<Map<String, String>> getRandomAyat() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final rawAyat = await dbHelper.getRandomAyat();
      if (rawAyat != null) {
        final surahNo = rawAyat['nomorSurah'] as int;
        final ayatNo = rawAyat['nomorAyat'] as int;
        final teksArab = rawAyat['teksArab'] as String;
        final teksIndo = rawAyat['teksIndonesia'] as String;
        
        final db = await dbHelper.database;
        final surahResult = await db.query('surahs', where: 'nomor = ?', whereArgs: [surahNo], limit: 1);
        String surahName = "Al-Quran";
        if (surahResult.isNotEmpty) {
          surahName = surahResult.first['namaLatin'] as String;
        }
        
        return {
          'arab': teksArab,
          'indo': teksIndo,
          'ref': 'QS. $surahName: $ayatNo',
        };
      }
    } catch (e) {
      print('Gagal mengambil ayat acak dari DB: $e');
    }
    
    // Predefined fallback verses
    final fallbacks = [
      {
        'arab': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
        'indo': 'Allah, tidak ada tuhan selain Dia. Yang Maha Hidup, yang terus-menerus mengurus (makhluk-Nya)...',
        'ref': 'QS. Al-Baqarah: 255'
      },
      {
        'arab': 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُتِبَ عَلَيْكُمُ الصِّيَامُ',
        'indo': 'Wahai orang-orang yang beriman! Diwajibkan atas kamu berpuasa sebagaimana diwajibkan atas orang sebelum kamu...',
        'ref': 'QS. Al-Baqarah: 183'
      },
      {
        'arab': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
        'indo': 'Sesungguhnya bersama kesulitan ada kemudahan.',
        'ref': 'QS. Al-Insyirah: 6'
      },
      {
        'arab': 'ادْعُونِي أَسْتَجِبْ لَكُمْ',
        'indo': 'Berdoalah kepada-Ku, niscaya akan Aku perkenankan bagimu.',
        'ref': 'QS. Ghafir: 60'
      }
    ];
    final index = DateTime.now().day % fallbacks.length;
    return fallbacks[index];
  }
}

