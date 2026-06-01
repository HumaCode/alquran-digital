import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/detail_surah_model.dart';
import '../../../data/models/tafsir_model.dart';
import '../../../data/repositories/surah_repository.dart';
import '../../home/controllers/home_controller.dart';
import '../../statistik/controllers/statistik_controller.dart';
import '../../../constants/r.dart';

class DetailSurahController extends GetxController {
  final SurahRepository _repository;

  DetailSurahController(this._repository);

  final isLoading = false.obs;
  final detailSurah = Rxn<DetailSurah>();
  final errorMessage = ''.obs;
  final tafsirSurah = Rxn<TafsirSurah>();
  final isCompleted = false.obs;

  // View Settings states
  final arabicFontSize = 26.0.obs;
  final showLatin = true.obs;
  final showTranslation = true.obs;
  final tafsirFontSize = 15.0.obs;
  final isNightMode = false.obs;

  late final int nomorSurah;
  int? targetAyat;
  final lastReadAyatNomor = 0.obs;
  final bookmarkedAyats = <int>{}.obs;
  final versesWithNotes = <int>{}.obs;
  final verseNotes = <int, String>{}.obs;

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

  // Hafalan Mode & Audio loop states
  final isMemorizationMode = false.obs;
  final revealedWords = <String>{}.obs;
  final audioRepeatCount = 1.obs;
  final hafalanProgress = <int, String>{}.obs;
  int _remainingRepeats = 0;
  Ayat? _currentlyPlayingAyatObj;

  List<Ayat> _allAyat = [];
  int _loadedCount = 0;
  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    _loadNightMode();

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
    _audioPlayer.onPlayerComplete.listen((event) async {
      if (_remainingRepeats > 0) {
        _remainingRepeats--;
        final audioUrl = _currentlyPlayingAyatObj?.audio[selectedQori.value];
        if (audioUrl != null) {
          try {
            await _audioPlayer.play(UrlSource(audioUrl));
            isAudioPlaying.value = true;
            return;
          } catch (e) {
            print('Gagal mengulang audio: $e');
          }
        }
      }

      if (isPlayingFullSurah.value) {
        _currentFullSurahIndex++;
        if (_currentFullSurahIndex < _allAyat.length) {
          _remainingRepeats = audioRepeatCount.value - 1;
          _playFullSurahAyat(_currentFullSurahIndex);
        } else {
          // Finished playing all verses
          isPlayingFullSurah.value = false;
          currentlyPlayingAyat.value = null;
          isAudioPlaying.value = false;
          _currentlyPlayingAyatObj = null;
        }
      } else {
        currentlyPlayingAyat.value = null;
        isAudioPlaying.value = false;
        _currentlyPlayingAyatObj = null;
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
                  duration: isNightMode.value ? Duration.zero : const Duration(milliseconds: 800),
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

      // Ambil data bookmark untuk surah ini
      await loadBookmarkedAyats();

      // Ambil data catatan ayat untuk surah ini
      await loadVerseNotes();

      // Ambil status khatam untuk surah ini
      await checkIfCompleted();

      // Ambil progress hafalan untuk surah ini
      await loadHafalanProgress();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsLastRead(int nomorSurah, String namaLatin, int nomorAyat) async {
    try {
      final prevAyat = lastReadAyatNomor.value;
      await _repository.saveLastRead(nomorSurah, namaLatin, nomorAyat);
      lastReadAyatNomor.value = nomorAyat;

      // Log progress tilawah secara dinamis berdasarkan selisih ayat dibaca
      int diff = nomorAyat - prevAyat;
      if (diff > 0) {
        await _logTilawahCount(diff);
      } else if (prevAyat == 0) {
        await _logTilawahCount(nomorAyat);
      }
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
        _currentlyPlayingAyatObj = ayat;
        _remainingRepeats = audioRepeatCount.value - 1;
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
      _currentlyPlayingAyatObj = null;
    } else {
      if (_allAyat.isEmpty) return;
      isPlayingFullSurah.value = true;
      _currentFullSurahIndex = 0;
      _remainingRepeats = audioRepeatCount.value - 1;
      await _playFullSurahAyat(0);
    }
  }

  Future<void> _playFullSurahAyat(int index) async {
    if (index >= _allAyat.length) return;
    final ayat = _allAyat[index];
    _currentlyPlayingAyatObj = ayat;
    final audioUrl = ayat.audio[selectedQori.value];
    if (audioUrl == null) {
      _currentFullSurahIndex++;
      if (_currentFullSurahIndex < _allAyat.length) {
        _remainingRepeats = audioRepeatCount.value - 1;
        await _playFullSurahAyat(_currentFullSurahIndex);
      } else {
        isPlayingFullSurah.value = false;
        currentlyPlayingAyat.value = null;
        isAudioPlaying.value = false;
        _currentlyPlayingAyatObj = null;
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
          duration: isNightMode.value ? Duration.zero : const Duration(milliseconds: 600),
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

  Future<void> loadBookmarkedAyats() async {
    try {
      final list = await _repository.getBookmarksList();
      final currentBookmarks = list
          .where((element) => element['nomorSurah'] == nomorSurah)
          .map((element) => element['nomorAyat'] as int)
          .toSet();
      bookmarkedAyats.assignAll(currentBookmarks);
    } catch (e) {
      print('Gagal memuat bookmark: $e');
    }
  }

  Future<void> toggleBookmark(Ayat ayat) async {
    final isAlreadyBookmarked = bookmarkedAyats.contains(ayat.nomorAyat);
    try {
      if (isAlreadyBookmarked) {
        await _repository.deleteBookmark(nomorSurah, ayat.nomorAyat);
        bookmarkedAyats.remove(ayat.nomorAyat);
      } else {
        final detail = detailSurah.value?.data;
        if (detail == null) return;
        await _repository.insertBookmark({
          'nomorSurah': nomorSurah,
          'namaSurah': detail.namaLatin,
          'nomorAyat': ayat.nomorAyat,
          'teksArab': ayat.teksArab,
          'teksIndonesia': ayat.teksIndonesia,
          'createdAt': DateTime.now().toIso8601String(),
        });
        bookmarkedAyats.add(ayat.nomorAyat);
      }
    } catch (e) {
      print('Gagal mengubah status bookmark: $e');
    }
  }

  Future<void> loadVerseNotes() async {
    try {
      final list = await _repository.getNotesList();
      final currentNotes = list.where((element) => element['nomorSurah'] == nomorSurah);
      
      versesWithNotes.clear();
      verseNotes.clear();
      for (var item in currentNotes) {
        final ayatNo = item['nomorAyat'] as int;
        final noteText = item['teksCatatan'] as String;
        versesWithNotes.add(ayatNo);
        verseNotes[ayatNo] = noteText;
      }
    } catch (e) {
      print('Gagal memuat catatan ayat: $e');
    }
  }

  Future<void> saveVerseNote(int nomorAyat, String noteText) async {
    try {
      final detail = detailSurah.value?.data;
      if (detail == null) return;
      if (noteText.trim().isEmpty) {
        await deleteVerseNote(nomorAyat);
        return;
      }
      await _repository.saveNote(nomorSurah, detail.namaLatin, nomorAyat, noteText);
      versesWithNotes.add(nomorAyat);
      verseNotes[nomorAyat] = noteText;
    } catch (e) {
      print('Gagal menyimpan catatan ayat: $e');
    }
  }

  Future<void> deleteVerseNote(int nomorAyat) async {
    try {
      await _repository.deleteNote(nomorSurah, nomorAyat);
      versesWithNotes.remove(nomorAyat);
      verseNotes.remove(nomorAyat);
    } catch (e) {
      print('Gagal menghapus catatan ayat: $e');
    }
  }

  Future<void> _logTilawahCount(int count) async {
    try {
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      await _repository.logTilawah(dateStr, count);
      
      // Trigger update pada HomeController jika aktif
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchTilawahTracker();
        Get.find<HomeController>().fetchLastRead();
      }
      
      // Trigger update pada StatistikController jika aktif
      if (Get.isRegistered<StatistikController>()) {
        Get.find<StatistikController>().fetchStats();
      }
    } catch (e) {
      print('Gagal mencatat tilawah otomatis: $e');
    }
  }

  Future<void> _loadNightMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isNightMode.value = prefs.getBool('night_mode_enabled') ?? false;
    } catch (e) {
      print('Gagal memuat preferensi Mode Malam: $e');
    }
  }

  Future<void> toggleNightMode() async {
    try {
      isNightMode.value = !isNightMode.value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('night_mode_enabled', isNightMode.value);
    } catch (e) {
      print('Gagal menyimpan preferensi Mode Malam: $e');
    }
  }

  Future<void> checkIfCompleted() async {
    try {
      final status = await _repository.isSurahCompleted(nomorSurah);
      isCompleted.value = status;
    } catch (e) {
      print('Gagal memuat status khatam surah: $e');
    }
  }

  Future<void> toggleCompleted() async {
    try {
      final detail = detailSurah.value?.data;
      if (detail == null) return;
      
      final nextStatus = !isCompleted.value;
      await _repository.markSurahAsCompleted(nomorSurah, detail.namaLatin, nextStatus);
      isCompleted.value = nextStatus;

      // Jika ditandai selesai, tandai juga ayat terakhir sebagai terakhir dibaca (otomatis mencatat sisa progress tilawah)
      if (nextStatus) {
        final prevAyat = lastReadAyatNomor.value;
        await _repository.saveLastRead(nomorSurah, detail.namaLatin, detail.jumlahAyat);
        lastReadAyatNomor.value = detail.jumlahAyat;
        
        int diff = detail.jumlahAyat - prevAyat;
        if (diff > 0) {
          await _logTilawahCount(diff);
        } else if (prevAyat == 0) {
          await _logTilawahCount(detail.jumlahAyat);
        }
      } else {
        // Batal tandai selesai: reset terakhir dibaca ke 0 dan kurangi progres tilawah sebanyak jumlah ayat surah ini
        await _repository.saveLastRead(nomorSurah, detail.namaLatin, 0);
        lastReadAyatNomor.value = 0;
        await _logTilawahCount(-detail.jumlahAyat);
      }
      
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchKhatamProgress();
        Get.find<HomeController>().fetchLastRead();
      }

      Get.snackbar(
        nextStatus ? 'Surah Selesai Dibaca 🎉' : 'Batal Tandai Selesai',
        nextStatus 
            ? 'Alhamdulillah, Anda telah menyelesaikan Surah ${detail.namaLatin}.'
            : 'Surah ${detail.namaLatin} kembali ditandai belum selesai.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: nextStatus ? R.color.emerald.withValues(alpha: 0.9) : R.color.gold.withValues(alpha: 0.9),
        colorText: Colors.black,
      );
    } catch (e) {
      print('Gagal mengubah status khatam surah: $e');
    }
  }

  // ── Hafalan Mode Methods ───────────────────────────────────────────────────
  void toggleMemorizationMode() {
    isMemorizationMode.value = !isMemorizationMode.value;
    if (!isMemorizationMode.value) {
      revealedWords.clear();
    }
  }

  void revealWord(String key) {
    revealedWords.add(key);
  }

  void cycleRepeatCount() {
    switch (audioRepeatCount.value) {
      case 1:
        audioRepeatCount.value = 2;
        break;
      case 2:
        audioRepeatCount.value = 3;
        break;
      case 3:
        audioRepeatCount.value = 5;
        break;
      case 5:
        audioRepeatCount.value = 10;
        break;
      default:
        audioRepeatCount.value = 1;
    }
  }

  Future<void> loadHafalanProgress() async {
    try {
      final list = await _repository.getHafalanProgressBySurah(nomorSurah);
      final map = <int, String>{};
      for (var item in list) {
        final ayatNum = item['nomorAyat'] as int;
        final status = item['status'] as String;
        map[ayatNum] = status;
      }
      hafalanProgress.assignAll(map);
    } catch (e) {
      print('Gagal memuat progress hafalan: $e');
    }
  }

  Future<void> updateHafalanStatus(int nomorAyat, String status) async {
    try {
      if (status == 'none') {
        await _repository.deleteHafalanProgress(nomorSurah, nomorAyat);
        hafalanProgress.remove(nomorAyat);
      } else {
        await _repository.saveHafalanProgress(nomorSurah, nomorAyat, status);
        hafalanProgress[nomorAyat] = status;
      }
    } catch (e) {
      print('Gagal memperbarui status hafalan: $e');
    }
  }
}
