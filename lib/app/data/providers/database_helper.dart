import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/detail_surah_model.dart';
import '../models/surah_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alquran.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS downloaded_murotal (
            surah_nomor INTEGER,
            qori_id TEXT,
            local_path TEXT NOT NULL,
            PRIMARY KEY (surah_nomor, qori_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS bookmarks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nomorSurah INTEGER NOT NULL,
            namaSurah TEXT NOT NULL,
            nomorAyat INTEGER NOT NULL,
            teksArab TEXT NOT NULL,
            teksIndonesia TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tabel Surah
    await db.execute('''
      CREATE TABLE surahs (
        nomor INTEGER PRIMARY KEY,
        nama TEXT NOT NULL,
        namaLatin TEXT NOT NULL,
        jumlahAyat INTEGER NOT NULL,
        tempatTurun TEXT NOT NULL,
        arti TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        audioFull TEXT NOT NULL
      )
    ''');

    // 2. Tabel Ayat
    await db.execute('''
      CREATE TABLE ayats (
        nomorSurah INTEGER NOT NULL,
        nomorAyat INTEGER NOT NULL,
        teksArab TEXT NOT NULL,
        teksLatin TEXT NOT NULL,
        teksIndonesia TEXT NOT NULL,
        audio TEXT NOT NULL,
        PRIMARY KEY (nomorSurah, nomorAyat),
        FOREIGN KEY (nomorSurah) REFERENCES surahs (nomor) ON DELETE CASCADE
      )
    ''');

    // 3. Tabel Metadata untuk sync info
    await db.execute('''
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // 4. Tabel Bookmarks baru
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomorSurah INTEGER NOT NULL,
        namaSurah TEXT NOT NULL,
        nomorAyat INTEGER NOT NULL,
        teksArab TEXT NOT NULL,
        teksIndonesia TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // ── Operations for Surahs ──────────────────────────────────────────────────

  Future<void> insertSurahs(List<DataSurah> surahList) async {
    final db = await instance.database;
    final batch = db.batch();

    for (var surah in surahList) {
      batch.insert(
        'surahs',
        {
          'nomor': surah.nomor,
          'nama': surah.nama,
          'namaLatin': surah.namaLatin,
          'jumlahAyat': surah.jumlahAyat,
          'tempatTurun': surah.tempatTurun,
          'arti': surah.arti,
          'deskripsi': surah.deskripsi,
          'audioFull': jsonEncode(surah.audioFull),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<DataSurah>> getSurahs() async {
    final db = await instance.database;
    final result = await db.query('surahs', orderBy: 'nomor ASC');

    return result.map((json) {
      // Decode audioFull from JSON string
      final audioFullMap = Map<String, String>.from(
        jsonDecode(json['audioFull'] as String) as Map,
      );

      return DataSurah(
        nomor: json['nomor'] as int,
        nama: json['nama'] as String,
        namaLatin: json['namaLatin'] as String,
        jumlahAyat: json['jumlahAyat'] as int,
        tempatTurun: json['tempatTurun'] as String,
        arti: json['arti'] as String,
        deskripsi: json['deskripsi'] as String,
        audioFull: audioFullMap,
      );
    }).toList();
  }

  // ── Operations for Detail Surah & Ayats ────────────────────────────────────

  Future<void> insertAyats(int nomorSurah, List<Ayat> ayatList) async {
    final db = await instance.database;
    final batch = db.batch();

    for (var ayat in ayatList) {
      batch.insert(
        'ayats',
        {
          'nomorSurah': nomorSurah,
          'nomorAyat': ayat.nomorAyat,
          'teksArab': ayat.teksArab,
          'teksLatin': ayat.teksLatin,
          'teksIndonesia': ayat.teksIndonesia,
          'audio': jsonEncode(ayat.audio),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<bool> hasAyats(int nomorSurah) async {
    final db = await instance.database;
    final result = await db.query(
      'ayats',
      columns: ['nomorAyat'],
      where: 'nomorSurah = ?',
      whereArgs: [nomorSurah],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<DetailSurah?> getDetailSurah(int nomorSurah) async {
    final db = await instance.database;

    // 1. Get current surah info
    final surahResult = await db.query(
      'surahs',
      where: 'nomor = ?',
      whereArgs: [nomorSurah],
    );

    if (surahResult.isEmpty) return null;
    final surahMap = surahResult.first;

    // 2. Get all verses for this surah
    final ayatResult = await db.query(
      'ayats',
      where: 'nomorSurah = ?',
      whereArgs: [nomorSurah],
      orderBy: 'nomorAyat ASC',
    );

    final ayatList = ayatResult.map((json) {
      final audioMap = Map<String, String>.from(
        jsonDecode(json['audio'] as String) as Map,
      );
      return Ayat(
        nomorAyat: json['nomorAyat'] as int,
        teksArab: json['teksArab'] as String,
        teksLatin: json['teksLatin'] as String,
        teksIndonesia: json['teksIndonesia'] as String,
        audio: audioMap,
      );
    }).toList();

    // 3. Query previous surah
    SuratSebelumnya? suratSebelumnya;
    if (nomorSurah > 1) {
      final prevResult = await db.query(
        'surahs',
        columns: ['nomor', 'nama', 'namaLatin', 'jumlahAyat'],
        where: 'nomor = ?',
        whereArgs: [nomorSurah - 1],
      );
      if (prevResult.isNotEmpty) {
        final prevMap = prevResult.first;
        suratSebelumnya = SuratSebelumnya(
          nomor: prevMap['nomor'] as int,
          nama: prevMap['nama'] as String,
          namaLatin: prevMap['namaLatin'] as String,
          jumlahAyat: prevMap['jumlahAyat'] as int,
        );
      }
    }

    // 4. Query next surah
    SuratSelanjutnya? suratSelanjutnya;
    if (nomorSurah < 114) {
      final nextResult = await db.query(
        'surahs',
        columns: ['nomor', 'nama', 'namaLatin', 'jumlahAyat'],
        where: 'nomor = ?',
        whereArgs: [nomorSurah + 1],
      );
      if (nextResult.isNotEmpty) {
        final nextMap = nextResult.first;
        suratSelanjutnya = SuratSelanjutnya(
          nomor: nextMap['nomor'] as int,
          nama: nextMap['nama'] as String,
          namaLatin: nextMap['namaLatin'] as String,
          jumlahAyat: nextMap['jumlahAyat'] as int,
        );
      }
    }

    final audioFullMap = Map<String, String>.from(
      jsonDecode(surahMap['audioFull'] as String) as Map,
    );

    return DetailSurah(
      code: 200,
      message: 'success',
      data: Data(
        nomor: surahMap['nomor'] as int,
        nama: surahMap['nama'] as String,
        namaLatin: surahMap['namaLatin'] as String,
        jumlahAyat: surahMap['jumlahAyat'] as int,
        tempatTurun: surahMap['tempatTurun'] as String,
        arti: surahMap['arti'] as String,
        deskripsi: surahMap['deskripsi'] as String,
        audioFull: audioFullMap,
        ayat: ayatList,
        suratSebelumnya: suratSebelumnya,
        suratSelanjutnya: suratSelanjutnya,
      ),
    );
  }

  // ── Metadata operations for sync ──────────────────────────────────────────

  Future<void> updateMetadata(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'metadata',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getMetadata(String key) async {
    final db = await instance.database;
    final result = await db.query(
      'metadata',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  Future<void> saveLastRead(int nomorSurah, String namaLatin, int nomorAyat) async {
    await updateMetadata('last_read_surah_nomor', nomorSurah.toString());
    await updateMetadata('last_read_surah_nama_latin', namaLatin);
    await updateMetadata('last_read_ayat_nomor', nomorAyat.toString());
  }

  Future<Map<String, dynamic>?> getLastRead() async {
    final nomorSurahStr = await getMetadata('last_read_surah_nomor');
    final namaLatin = await getMetadata('last_read_surah_nama_latin');
    final nomorAyatStr = await getMetadata('last_read_ayat_nomor');

    if (nomorSurahStr == null || namaLatin == null || nomorAyatStr == null) {
      return null;
    }

    return {
      'nomorSurah': int.parse(nomorSurahStr),
      'namaLatin': namaLatin,
      'nomorAyat': int.parse(nomorAyatStr),
    };
  }

  Future<void> saveBookmarks(List<int> bookmarks) async {
    final bookmarksJson = jsonEncode(bookmarks);
    await updateMetadata('bookmarks', bookmarksJson);
  }

  Future<List<int>> getBookmarks() async {
    final bookmarksJson = await getMetadata('bookmarks');
    if (bookmarksJson == null) return [1, 36, 67]; // default bookmarks
    try {
      final decoded = jsonDecode(bookmarksJson);
      if (decoded is List) {
        return decoded.map((e) => e as int).toList();
      }
    } catch (e) {
      print('Gagal mengurai bookmark JSON: $e');
    }
    return [1, 36, 67];
  }

  // ── Operations for New Bookmarks Table ──────────────────────────────────────

  Future<int> insertBookmark(Map<String, dynamic> bookmark) async {
    final db = await instance.database;
    return await db.insert(
      'bookmarks',
      bookmark,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getBookmarksList() async {
    final db = await instance.database;
    return await db.query('bookmarks', orderBy: 'createdAt DESC');
  }

  Future<int> deleteBookmark(int nomorSurah, int nomorAyat) async {
    final db = await instance.database;
    return await db.delete(
      'bookmarks',
      where: 'nomorSurah = ? AND nomorAyat = ?',
      whereArgs: [nomorSurah, nomorAyat],
    );
  }

  Future<bool> isBookmarked(int nomorSurah, int nomorAyat) async {
    final db = await instance.database;
    final result = await db.query(
      'bookmarks',
      where: 'nomorSurah = ? AND nomorAyat = ?',
      whereArgs: [nomorSurah, nomorAyat],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('ayats');
    await db.delete('surahs');
    await db.delete('metadata');
    await db.delete('downloaded_murotal');
  }

  // ── Operations for Downloaded Murotal ─────────────────────────────────────

  Future<void> insertDownloadedMurotal(int surahNomor, String qoriId, String localPath) async {
    final db = await instance.database;
    await db.insert(
      'downloaded_murotal',
      {
        'surah_nomor': surahNomor,
        'qori_id': qoriId,
        'local_path': localPath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getDownloadedMurotalPath(int surahNomor, String qoriId) async {
    final db = await instance.database;
    final result = await db.query(
      'downloaded_murotal',
      columns: ['local_path'],
      where: 'surah_nomor = ? AND qori_id = ?',
      whereArgs: [surahNomor, qoriId],
    );
    if (result.isEmpty) return null;
    return result.first['local_path'] as String?;
  }

  Future<List<Map<String, dynamic>>> getAllDownloadedMurotal() async {
    final db = await instance.database;
    return await db.query('downloaded_murotal');
  }

  Future<void> deleteDownloadedMurotal(int surahNomor, String qoriId) async {
    final db = await instance.database;
    await db.delete(
      'downloaded_murotal',
      where: 'surah_nomor = ? AND qori_id = ?',
      whereArgs: [surahNomor, qoriId],
    );
  }

  // ── Global Search for Ayats ────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> searchAyat(String query) async {
    final db = await instance.database;
    final likeQuery = '%$query%';
    return await db.rawQuery('''
      SELECT 
        a.nomorSurah, 
        a.nomorAyat, 
        a.teksArab, 
        a.teksLatin, 
        a.teksIndonesia, 
        s.namaLatin AS namaSurah 
      FROM ayats a 
      JOIN surahs s ON a.nomorSurah = s.nomor 
      WHERE a.teksLatin LIKE ? OR a.teksIndonesia LIKE ?
      ORDER BY a.nomorSurah ASC, a.nomorAyat ASC
    ''', [likeQuery, likeQuery]);
  }
}
