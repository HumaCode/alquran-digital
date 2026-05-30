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
}

