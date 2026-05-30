import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/repositories/surah_repository.dart';
import '../../../data/providers/database_helper.dart';

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

  // Last Read states
  final lastReadSurahNomor = 0.obs;
  final lastReadSurahNama = ''.obs;
  final lastReadAyatNomor = 0.obs;
  final hasLastRead = false.obs;

  // Bookmark states
  final bookmarkedSurahIds = <int>[].obs;
  final bookmarkedAyats = <Map<String, dynamic>>[].obs;

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

    if (query.trim().isEmpty) {
      searchedAyats.clear();
      surahs.clear();
      _loadedCount = 0;
      loadNextPage();
    } else {
      if (searchType.value == 'surah') {
        final normalizedQuery = query.toLowerCase();
        final filtered = _allSurahs.where((s) {
          return s.namaLatin.toLowerCase().contains(normalizedQuery) ||
              s.nama.toLowerCase().contains(normalizedQuery) ||
              s.arti.toLowerCase().contains(normalizedQuery);
        }).toList();
        surahs.assignAll(filtered);
      } else {
        isSearchLoading.value = true;
        _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
          try {
            final results = await DatabaseHelper.instance.searchAyat(query);
            searchedAyats.assignAll(results);
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
}
