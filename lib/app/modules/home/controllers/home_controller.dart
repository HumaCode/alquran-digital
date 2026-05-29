import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/repositories/surah_repository.dart';

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

  // Last Read states
  final lastReadSurahNomor = 0.obs;
  final lastReadSurahNama = ''.obs;
  final lastReadAyatNomor = 0.obs;
  final hasLastRead = false.obs;

  List<DataSurah> _allSurahs = [];
  List<DataSurah> get allSurahs => _allSurahs;
  int _loadedCount = 0;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchSurahs();
    fetchLastRead();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    // Show back to top button if scrolled past 300px
    showScrollToTop.value = scrollController.position.pixels > 300;

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
    if (query.trim().isEmpty) {
      surahs.clear();
      _loadedCount = 0;
      loadNextPage();
    } else {
      final normalizedQuery = query.toLowerCase();
      final filtered = _allSurahs.where((s) {
        return s.namaLatin.toLowerCase().contains(normalizedQuery) ||
            s.nama.toLowerCase().contains(normalizedQuery) ||
            s.arti.toLowerCase().contains(normalizedQuery);
      }).toList();
      surahs.assignAll(filtered);
    }
  }

  void clearSearch() {
    searchController.clear();
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
}
