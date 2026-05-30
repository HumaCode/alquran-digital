import 'package:get/get.dart';
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
}
