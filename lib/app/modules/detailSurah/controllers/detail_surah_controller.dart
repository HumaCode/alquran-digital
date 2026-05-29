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
  int? targetAyat;
  final lastReadAyatNomor = 0.obs;

  // Pagination states
  final visibleAyat = <Ayat>[].obs;
  final isMoreLoading = false.obs;
  final scrollController = ScrollController();
  final Map<int, GlobalKey> ayatKeys = {};

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
    } else if (args is Map) {
      nomorSurah = args['nomor'] as int;
      if (args['ayat'] is int) {
        targetAyat = args['ayat'] as int;
      }
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

      if (targetAyat != null) {
        final index = _allAyat.indexWhere((element) => element.nomorAyat == targetAyat);
        if (index != -1) {
          while (_loadedCount <= index && _loadedCount < _allAyat.length) {
            loadNextPage();
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 300), () {
              final key = ayatKeys[targetAyat];
              if (key != null && key.currentContext != null) {
                Scrollable.ensureVisible(
                  key.currentContext!,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                );
              }
            });
          });
        }
      }

      // Ambil data terakhir dibaca untuk di-highlight di UI
      final lastRead = await _repository.getLastRead();
      if (lastRead != null && lastRead['nomorSurah'] == nomorSurah) {
        lastReadAyatNomor.value = lastRead['nomorAyat'] as int;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsLastRead(int nomorSurah, String namaLatin, int nomorAyat) async {
    try {
      await _repository.saveLastRead(nomorSurah, namaLatin, nomorAyat);
      lastReadAyatNomor.value = nomorAyat;
    } catch (e) {
      print('Gagal menyimpan ayat terakhir dibaca: $e');
    }
  }
}
