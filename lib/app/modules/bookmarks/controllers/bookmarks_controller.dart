import 'dart:io';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/repositories/surah_repository.dart';

class BookmarksController extends GetxController {
  final SurahRepository _repository;

  BookmarksController(this._repository);

  final bookmarksList = <Map<String, dynamic>>[].obs;
  final notesList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookmarks();
    fetchNotes();
  }

  Future<void> fetchBookmarks() async {
    isLoading.value = true;
    try {
      final list = await _repository.getBookmarksList();
      bookmarksList.assignAll(list);
    } catch (e) {
      print('Gagal memuat daftar bookmark: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNotes() async {
    try {
      final list = await _repository.getNotesList();
      notesList.assignAll(list);
    } catch (e) {
      print('Gagal memuat daftar catatan: $e');
    }
  }

  Future<void> deleteBookmark(int nomorSurah, int nomorAyat) async {
    try {
      await _repository.deleteBookmark(nomorSurah, nomorAyat);
      bookmarksList.removeWhere((item) =>
          item['nomorSurah'] == nomorSurah && item['nomorAyat'] == nomorAyat);
    } catch (e) {
      print('Gagal menghapus bookmark: $e');
    }
  }

  Future<void> saveNote(int nomorSurah, String namaSurah, int nomorAyat, String teksCatatan) async {
    try {
      if (teksCatatan.trim().isEmpty) {
        await deleteNote(nomorSurah, nomorAyat);
        return;
      }
      await _repository.saveNote(nomorSurah, namaSurah, nomorAyat, teksCatatan);
      await fetchNotes();
    } catch (e) {
      print('Gagal menyimpan catatan: $e');
    }
  }

  Future<void> deleteNote(int nomorSurah, int nomorAyat) async {
    try {
      await _repository.deleteNote(nomorSurah, nomorAyat);
      notesList.removeWhere((item) =>
          item['nomorSurah'] == nomorSurah && item['nomorAyat'] == nomorAyat);
    } catch (e) {
      print('Gagal menghapus catatan: $e');
    }
  }

  Future<void> shareNote(Map<String, dynamic> note) async {
    try {
      final nomorSurah = note['nomorSurah'] as int;
      final namaSurah = note['namaSurah'] as String;
      final nomorAyat = note['nomorAyat'] as int;
      final teksCatatan = note['teksCatatan'] as String;

      final ayatMap = await _repository.getAyat(nomorSurah, nomorAyat);
      final teksArab = ayatMap?['teksArab'] ?? '';
      final teksIndonesia = ayatMap?['teksIndonesia'] ?? '';

      final formattedText = '📝 *Catatan Tadabbur Al-Quran*\n\n'
          '*QS. $namaSurah [$nomorSurah:$nomorAyat]*\n\n'
          '*Ayat Arab:*\n$teksArab\n\n'
          '*Terjemahan:*\n"$teksIndonesia"\n\n'
          '*Catatan Saya:*\n$teksCatatan\n\n'
          '_Dibagikan via Aplikasi Al-Quran Digital_';

      await Share.share(formattedText);
    } catch (e) {
      print('Gagal membagikan catatan: $e');
    }
  }

  Future<String?> exportNotesToTxt() async {
    try {
      if (notesList.isEmpty) return null;

      final buffer = StringBuffer();
      buffer.writeln('==================================================');
      buffer.writeln('          CATATAN TADABBUR AL-QURAN SAYA          ');
      buffer.writeln('==================================================\n');

      for (var note in notesList) {
        final nomorSurah = note['nomorSurah'] as int;
        final namaSurah = note['namaSurah'] as String;
        final nomorAyat = note['nomorAyat'] as int;
        final teksCatatan = note['teksCatatan'] as String;
        final updatedAt = note['updatedAt'] as String;

        final ayatMap = await _repository.getAyat(nomorSurah, nomorAyat);
        final teksArab = ayatMap?['teksArab'] ?? '';
        final teksIndonesia = ayatMap?['teksIndonesia'] ?? '';

        buffer.writeln('QS. $namaSurah [$nomorSurah:$nomorAyat]');
        buffer.writeln('Waktu Update: $updatedAt');
        buffer.writeln('--------------------------------------------------');
        buffer.writeln('Teks Arab:');
        buffer.writeln(teksArab);
        buffer.writeln('\nTerjemahan:');
        buffer.writeln(teksIndonesia);
        buffer.writeln('\nCatatan Tadabbur:');
        buffer.writeln(teksCatatan);
        buffer.writeln('\n==================================================\n');
      }

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/Catatan_Tadabbur_AlQuran.txt');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles([XFile(file.path)], text: 'Semua Catatan Tadabbur Al-Quran');
      return file.path;
    } catch (e) {
      print('Gagal mengekspor catatan: $e');
      return null;
    }
  }
}
