import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../data/models/detail_surah_model.dart';
import '../../../data/repositories/surah_repository.dart';

class DetailSurahController extends GetxController {
  final SurahRepository _repository;

  DetailSurahController(this._repository);

  final isLoading = false.obs;
  final detailSurah = Rxn<DetailSurah>();
  final errorMessage = ''.obs;

  late final int nomorSurah;

  // Pagination states
  final visibleAyat = <Ayat>[].obs;
  final isMoreLoading = false.obs;
  final scrollController = ScrollController();

  List<Ayat> _allAyat = [];
  int _loadedCount = 0;
  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();

    // Get the Surah number from arguments
    final args = Get.arguments;
    if (args is int) {
      nomorSurah = args;
    } else if (args is Map && args['nomor'] is int) {
      nomorSurah = args['nomor'] as int;
    } else {
      nomorSurah = 1; // Fallback to Al-Fatihah
    }

    scrollController.addListener(_onScroll);
    fetchDetailSurah();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isMoreLoading.value && visibleAyat.length < _allAyat.length) {
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
    if (_loadedCount >= _allAyat.length) return;

    final nextBatchSize = (_allAyat.length - _loadedCount) < _pageSize
        ? (_allAyat.length - _loadedCount)
        : _pageSize;

    final nextBatch = _allAyat.sublist(_loadedCount, _loadedCount + nextBatchSize);
    visibleAyat.addAll(nextBatch);
    _loadedCount += nextBatchSize;
  }

  Future<void> fetchDetailSurah() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _repository.getDetailSurah(nomorSurah);
      detailSurah.value = data;

      // Initialize pagination
      _allAyat = data.data.ayat;
      visibleAyat.clear();
      _loadedCount = 0;
      loadNextPage();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
