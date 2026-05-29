import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/repositories/surah_repository.dart';
import '../../../data/providers/database_helper.dart';

class MurotalController extends GetxController {
  final SurahRepository _repository;

  MurotalController(this._repository);

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final surahList = <DataSurah>[].obs;
  final filteredSurahList = <DataSurah>[].obs;
  final displayedSurahs = <DataSurah>[].obs;
  final searchQuery = ''.obs;

  final selectedSurah = Rxn<DataSurah>();
  final selectedQori = '03'.obs; // Default to Mishary Rashid
  final isPlaying = false.obs;
  
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;

  // Track downloaded key combinations: "surahNomor_qoriId"
  final downloadedTracks = <String>{}.obs;
  final downloadingTracks = <String>{}.obs;

  late final AudioPlayer _audioPlayer;
  final int _pageSize = 10;
  final hasMore = true.obs;

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
    checkDownloadedStatus();
  }

  Future<void> checkDownloadedStatus() async {
    try {
      final list = await DatabaseHelper.instance.getAllDownloadedMurotal();
      final keys = list.map((item) => '${item['surah_nomor']}_${item['qori_id']}').toSet();
      downloadedTracks.assignAll(keys);
    } catch (e) {
      print('Gagal mengecek status download: $e');
    }
  }

  Future<void> loadSurahs() async {
    isLoading.value = true;
    try {
      final list = await _repository.getSurahs();
      surahList.assignAll(list);
      
      applyFilterAndResetPagination();
      
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
    applyFilterAndResetPagination();
  }

  void applyFilterAndResetPagination() {
    final query = searchQuery.value.trim();
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

    displayedSurahs.clear();
    hasMore.value = filteredSurahList.length > _pageSize;
    final int end = _pageSize.clamp(0, filteredSurahList.length);
    displayedSurahs.assignAll(filteredSurahList.sublist(0, end));
  }

  void loadMoreSurahs() {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    Future.delayed(const Duration(milliseconds: 150), () {
      final int currentLength = displayedSurahs.length;
      final int nextLength = currentLength + _pageSize;
      final int end = nextLength.clamp(0, filteredSurahList.length);

      displayedSurahs.addAll(filteredSurahList.sublist(currentLength, end));
      hasMore.value = displayedSurahs.length < filteredSurahList.length;
      isLoadingMore.value = false;
    });
  }

  Future<void> playAudio() async {
    final surah = selectedSurah.value;
    if (surah == null) return;

    final qori = selectedQori.value;

    // 1. Coba cari path file lokal dari SQLite
    final localPath = await DatabaseHelper.instance.getDownloadedMurotalPath(surah.nomor, qori);

    if (localPath != null && await File(localPath).exists()) {
      // Play local file - Zero Delay!
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(localPath));
        print('Memutar file lokal offline: $localPath');
      } catch (e) {
        print('Gagal memutar file lokal, fallback ke URL: $e');
        _playFromUrl(surah, qori);
      }
    } else {
      // Play online URL
      _playFromUrl(surah, qori);
      
      // Auto download in background so next play is zero-delay offline!
      _autoDownloadInBackground(surah, qori);
    }
  }

  Future<void> _playFromUrl(DataSurah surah, String qori) async {
    final audioUrl = surah.audioFull[qori];
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

  // Melakukan download secara silent di background
  void _autoDownloadInBackground(DataSurah surah, String qoriId) async {
    final cacheKey = '${surah.nomor}_$qoriId';
    if (downloadedTracks.contains(cacheKey) || downloadingTracks.contains(cacheKey)) return;

    final url = surah.audioFull[qoriId];
    if (url == null || url.isEmpty) return;

    downloadingTracks.add(cacheKey);
    try {
      final localPath = await _downloadFileToLocal(url, surah.nomor, qoriId);
      if (localPath != null) {
        await DatabaseHelper.instance.insertDownloadedMurotal(surah.nomor, qoriId, localPath);
        await checkDownloadedStatus();
        print('Auto-download background murotal ${surah.namaLatin} sukses.');
      }
    } catch (e) {
      print('Auto-download background gagal: $e');
    } finally {
      downloadingTracks.remove(cacheKey);
    }
  }

  // Download manual via UI button
  Future<void> downloadMurotalManual(DataSurah surah, String qoriId) async {
    final cacheKey = '${surah.nomor}_$qoriId';
    if (downloadedTracks.contains(cacheKey)) {
      Get.snackbar('Informasi', 'Murotal ini sudah diunduh.');
      return;
    }

    if (downloadingTracks.contains(cacheKey)) return;

    final url = surah.audioFull[qoriId];
    if (url == null || url.isEmpty) {
      Get.snackbar('Gagal', 'Tautan audio tidak valid.');
      return;
    }

    downloadingTracks.add(cacheKey);
    Get.snackbar('Mengunduh', 'Memulai pengunduhan Murotal ${surah.namaLatin}...',
      duration: const Duration(seconds: 2));

    try {
      final localPath = await _downloadFileToLocal(url, surah.nomor, qoriId);
      if (localPath != null) {
        await DatabaseHelper.instance.insertDownloadedMurotal(surah.nomor, qoriId, localPath);
        await checkDownloadedStatus();
        Get.snackbar('Sukses', 'Murotal ${surah.namaLatin} siap diputar offline!');
      } else {
        throw Exception('File kosong setelah download');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal mengunduh audio: $e');
    } finally {
      downloadingTracks.remove(cacheKey);
    }
  }

  // Helper: Download file from URL dan simpan ke folder lokal
  Future<String?> _downloadFileToLocal(String url, int surahNomor, String qoriId) async {
    final httpClient = HttpClient();
    try {
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/murotal');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final file = File('${folder.path}/${surahNomor}_$qoriId.mp3');
      final raf = file.openSync(mode: FileMode.write);
      await response.forEach((chunk) => raf.writeFromSync(chunk));
      await raf.close();

      return file.path;
    } catch (e) {
      print('_downloadFileToLocal error: $e');
      return null;
    } finally {
      httpClient.close();
    }
  }

  Future<void> deleteDownloadedManual(DataSurah surah, String qoriId) async {
    try {
      final path = await DatabaseHelper.instance.getDownloadedMurotalPath(surah.nomor, qoriId);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await DatabaseHelper.instance.deleteDownloadedMurotal(surah.nomor, qoriId);
      await checkDownloadedStatus();
      Get.snackbar('Dihapus', 'File offline Murotal ${surah.namaLatin} telah dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus file: $e');
    }
  }

  Future<void> togglePlay() async {
    if (isPlaying.value) {
      await _audioPlayer.pause();
    } else {
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
      selectSurah(surahList.last, autoPlay: true);
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
