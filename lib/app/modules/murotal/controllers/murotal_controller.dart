import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/repositories/surah_repository.dart';

class MurotalController extends GetxController {
  final SurahRepository _repository;

  MurotalController(this._repository);

  final isLoading = false.obs;
  final surahList = <DataSurah>[].obs;
  final filteredSurahList = <DataSurah>[].obs;
  final searchQuery = ''.obs;

  final selectedSurah = Rxn<DataSurah>();
  final selectedQori = '03'.obs; // Default to Mishary Rashid
  final isPlaying = false.obs;
  
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;

  late final AudioPlayer _audioPlayer;

  final qoriList = const [
    {'id': '01', 'name': 'Abdullah Al-Juhany'},
    {'id': '02', 'name': 'Abdul Basit'},
    {'id': '03', 'name': 'Misyari Rasyid Al-Afasi'},
    {'id': '04', 'name': 'Hani ar-Rifai'},
    {'id': '05', 'name': 'Abdurrahman as-Sudais'},
  ];

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();

    // Bind audio player streams to Rx variables
    _audioPlayer.onPositionChanged.listen((p) {
      position.value = p;
    });
    _audioPlayer.onDurationChanged.listen((d) {
      duration.value = d;
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      playNext();
    });

    loadSurahs();
  }

  Future<void> loadSurahs() async {
    isLoading.value = true;
    try {
      final list = await _repository.getSurahs();
      surahList.assignAll(list);
      filteredSurahList.assignAll(list);
      
      // Auto select first surah if nothing is selected yet
      if (list.isNotEmpty && selectedSurah.value == null) {
        selectedSurah.value = list.first;
      }
    } catch (e) {
      print('Gagal memuat surah untuk murotal: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchSurah(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredSurahList.assignAll(surahList);
    } else {
      filteredSurahList.assignAll(
        surahList.where((s) =>
          s.namaLatin.toLowerCase().contains(query.toLowerCase()) ||
          s.arti.toLowerCase().contains(query.toLowerCase()) ||
          s.nomor.toString() == query
        ).toList(),
      );
    }
  }

  Future<void> playAudio() async {
    final surah = selectedSurah.value;
    if (surah == null) return;

    final audioUrl = surah.audioFull[selectedQori.value];
    if (audioUrl == null || audioUrl.isEmpty) {
      Get.snackbar('Informasi', 'Audio tidak tersedia untuk Qori ini');
      return;
    }

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      Get.snackbar('Error', 'Gagal memutar audio: $e');
    }
  }

  Future<void> togglePlay() async {
    if (isPlaying.value) {
      await _audioPlayer.pause();
    } else {
      // If duration is zero or player stopped, start playing from URL
      if (position.value == Duration.zero) {
        await playAudio();
      } else {
        await _audioPlayer.resume();
      }
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    position.value = Duration.zero;
  }

  Future<void> seekAudio(Duration dest) async {
    await _audioPlayer.seek(dest);
  }

  void selectSurah(DataSurah surah, {bool autoPlay = true}) {
    selectedSurah.value = surah;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    if (autoPlay) {
      playAudio();
    }
  }

  void changeQori(String qoriId) {
    selectedQori.value = qoriId;
    if (isPlaying.value) {
      playAudio();
    }
  }

  void playNext() {
    final cur = selectedSurah.value;
    if (cur == null || surahList.isEmpty) return;

    final index = surahList.indexWhere((s) => s.nomor == cur.nomor);
    if (index != -1 && index < surahList.length - 1) {
      selectSurah(surahList[index + 1], autoPlay: true);
    } else {
      // Loop back to first surah
      selectSurah(surahList.first, autoPlay: true);
    }
  }

  void playPrevious() {
    final cur = selectedSurah.value;
    if (cur == null || surahList.isEmpty) return;

    final index = surahList.indexWhere((s) => s.nomor == cur.nomor);
    if (index > 0) {
      selectSurah(surahList[index - 1], autoPlay: true);
    } else {
      // Loop to last surah
      selectSurah(surahList.last, autoPlay: true);
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
