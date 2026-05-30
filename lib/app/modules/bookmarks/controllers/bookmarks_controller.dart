import 'package:get/get.dart';
import '../../../data/repositories/surah_repository.dart';

class BookmarksController extends GetxController {
  final SurahRepository _repository;

  BookmarksController(this._repository);

  final bookmarksList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookmarks();
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

  Future<void> deleteBookmark(int nomorSurah, int nomorAyat) async {
    try {
      await _repository.deleteBookmark(nomorSurah, nomorAyat);
      bookmarksList.removeWhere((item) =>
          item['nomorSurah'] == nomorSurah && item['nomorAyat'] == nomorAyat);
    } catch (e) {
      print('Gagal menghapus bookmark: $e');
    }
  }
}
