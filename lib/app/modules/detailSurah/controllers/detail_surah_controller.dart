import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../data/models/detail_surah_model.dart';
import '../../../data/models/tafsir_model.dart';
import '../../../data/repositories/surah_repository.dart';

class DetailSurahController extends GetxController {
  final SurahRepository _repository;

  DetailSurahController(this._repository);

  final isLoading = false.obs;
  final detailSurah = Rxn<DetailSurah>();
  final errorMessage = ''.obs;
  final tafsirSurah = Rxn<TafsirSurah>();

  // View Settings states
  final arabicFontSize = 26.0.obs;
  final showLatin = true.obs;
  final showTranslation = true.obs;
  final tafsirFontSize = 15.0.obs;

  late final int nomorSurah;
  int? targetAyat;
  final lastReadAyatNomor = 0.obs;

  // Qori Selection for verses
  final selectedQori = '05'.obs; // Default to Misyari Rasyid Al-Afasy
  final qoriList = const [
    {'id': '01', 'name': 'Abdullah Al-Juhany'},
    {'id': '02', 'name': 'Abdul Muhsin Al-Qasim'},
    {'id': '03', 'name': 'Abdurrahman As-Sudais'},
    {'id': '04', 'name': 'Ibrahim Al-Dossari'},
    {'id': '05', 'name': 'Misyari Rasyid Al-Afasy'},
    {'id': '06', 'name': 'Yasser Al-Dosari'},
  ];

  // Pagination states
  final visibleAyat = <Ayat>[].obs;
  final isMoreLoading = false.obs;
  final scrollController = ScrollController();
  final Map<int, GlobalKey> ayatKeys = {};

  // Audio Player states
  final AudioPlayer _audioPlayer = AudioPlayer();
  final currentlyPlayingAyat = RxnInt();
  final isAudioPlaying = false.obs;
  final isPlayingFullSurah = false.obs;
  int _currentFullSurahIndex = 0;

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

    // Listen to audio player completion
    _audioPlayer.onPlayerComplete.listen((event) {
      if (isPlayingFullSurah.value) {
        _currentFullSurahIndex++;
        if (_currentFullSurahIndex < _allAyat.length) {
          _playFullSurahAyat(_currentFullSurahIndex);
        } else {
          // Finished playing all verses
          isPlayingFullSurah.value = false;
          currentlyPlayingAyat.value = null;
          isAudioPlaying.value = false;
        }
      } else {
        currentlyPlayingAyat.value = null;
        isAudioPlaying.value = false;
      }
    });

    scrollController.addListener(_onScroll);
    fetchDetailSurah();
  }

  @override
  void onClose() {
    scrollController.dispose();
    _audioPlayer.dispose();
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

  Future<void> togglePlayAudio(Ayat ayat) async {
    if (isPlayingFullSurah.value) {
      isPlayingFullSurah.value = false;
    }

    final qoriName = qoriList.firstWhere((q) => q['id'] == selectedQori.value, orElse: () => {'name': 'Qari'})['name'];
    final audioUrl = ayat.audio[selectedQori.value];
    if (audioUrl == null) {
      Get.snackbar(
        'Audio Tidak Tersedia',
        'Audio $qoriName tidak tersedia untuk ayat ini.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (currentlyPlayingAyat.value == ayat.nomorAyat) {
        if (isAudioPlaying.value) {
          await _audioPlayer.pause();
          isAudioPlaying.value = false;
        } else {
          await _audioPlayer.resume();
          isAudioPlaying.value = true;
        }
      } else {
        await _audioPlayer.stop();
        currentlyPlayingAyat.value = ayat.nomorAyat;
        isAudioPlaying.value = true;
        await _audioPlayer.play(UrlSource(audioUrl));
      }
    } catch (e) {
      isAudioPlaying.value = false;
      currentlyPlayingAyat.value = null;
      print('Gagal memutar audio: $e');
    }
  }

  Future<void> togglePlayFullSurah() async {
    if (isPlayingFullSurah.value) {
      await _audioPlayer.stop();
      isPlayingFullSurah.value = false;
      currentlyPlayingAyat.value = null;
      isAudioPlaying.value = false;
    } else {
      if (_allAyat.isEmpty) return;
      isPlayingFullSurah.value = true;
      _currentFullSurahIndex = 0;
      await _playFullSurahAyat(0);
    }
  }

  Future<void> _playFullSurahAyat(int index) async {
    if (index >= _allAyat.length) return;
    final ayat = _allAyat[index];
    final audioUrl = ayat.audio[selectedQori.value];
    if (audioUrl == null) {
      _currentFullSurahIndex++;
      if (_currentFullSurahIndex < _allAyat.length) {
        await _playFullSurahAyat(_currentFullSurahIndex);
      } else {
        isPlayingFullSurah.value = false;
        currentlyPlayingAyat.value = null;
        isAudioPlaying.value = false;
      }
      return;
    }

    try {
      currentlyPlayingAyat.value = ayat.nomorAyat;
      isAudioPlaying.value = true;

      // Auto-scroll ke ayat yang sedang diputar
      final key = ayatKeys[ayat.nomorAyat];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }

      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      print('Gagal memutar audio ayat ke-${index + 1}: $e');
      _currentFullSurahIndex++;
      if (_currentFullSurahIndex < _allAyat.length) {
        await _playFullSurahAyat(_currentFullSurahIndex);
      } else {
        isPlayingFullSurah.value = false;
        currentlyPlayingAyat.value = null;
        isAudioPlaying.value = false;
      }
    }
  }

  Future<String?> getAyatTafsir(int nomorAyat) async {
    if (tafsirSurah.value == null || tafsirSurah.value!.data.nomor != nomorSurah) {
      try {
        final tafsir = await _repository.getTafsirSurah(nomorSurah);
        tafsirSurah.value = tafsir;
      } catch (e) {
        print('Gagal mengambil tafsir: $e');
        return null;
      }
    }

    final list = tafsirSurah.value?.data.tafsir;
    if (list != null) {
      final match = list.firstWhereOrNull((element) => element.ayat == nomorAyat);
      return match?.teks;
    }
    return null;
  }
}
