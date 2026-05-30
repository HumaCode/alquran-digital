import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/repositories/surah_repository.dart';
import '../../../data/providers/database_helper.dart';
import '../../../components/widgets/custom_toast.dart';

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
  final selectedQori = '05'.obs; // Default to Misyari Rasyid Al-Afasy
  final isPlaying = false.obs;
  
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;

  // Track downloaded key combinations: "surahNomor_qoriId"
  final downloadedTracks = <String>{}.obs;
  final downloadingTracks = <String>{}.obs;

  late final AudioPlayer _audioPlayer;
  final int _pageSize = 10;
  final hasMore = true.obs;
  final repeatMode = 'off'.obs; // 'off', 'surah', 'juz', 'all'

  final qoriList = const [
    {'id': '01', 'name': 'Abdullah Al-Juhany'},
    {'id': '02', 'name': 'Abdul Muhsin Al-Qasim'},
    {'id': '03', 'name': 'Abdurrahman As-Sudais'},
    {'id': '04', 'name': 'Ibrahim Al-Dossari'},
    {'id': '05', 'name': 'Misyari Rasyid Al-Afasy'},
    {'id': '06', 'name': 'Yasser Al-Dosari'},
  ];

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();

    // Bind audio player streams to Rx variables
    _audioPlayer.positionStream.listen((p) {
      position.value = p;
    });
    _audioPlayer.durationStream.listen((d) {
      duration.value = d ?? Duration.zero;
    });
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        playNext(isAuto: true);
      }
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
        final qoriName = qoriList.firstWhere((q) => q['id'] == qori)['name'] ?? 'Unknown Qori';
        await _audioPlayer.setAudioSource(
          AudioSource.file(
            localPath,
            tag: MediaItem(
              id: 'murotal_${surah.nomor}_$qori',
              album: 'Murotal Al-Qur\'an',
              title: 'Surah ${surah.namaLatin}',
              artist: qoriName,
              artUri: Uri.parse('https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Gilded_Quran_Cover.jpg/430px-Gilded_Quran_Cover.jpg'),
            ),
          ),
        );
        _audioPlayer.play();
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
      final qoriName = qoriList.firstWhere((q) => q['id'] == qori)['name'] ?? 'Unknown Qori';
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioUrl),
          tag: MediaItem(
            id: 'murotal_${surah.nomor}_$qori',
            album: 'Murotal Al-Qur\'an',
            title: 'Surah ${surah.namaLatin}',
            artist: qoriName,
            artUri: Uri.parse('https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Gilded_Quran_Cover.jpg/430px-Gilded_Quran_Cover.jpg'),
          ),
        ),
      );
      _audioPlayer.play();
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
        await _audioPlayer.play();
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

  void cycleRepeatMode(BuildContext context) {
    switch (repeatMode.value) {
      case 'off':
        repeatMode.value = 'surah';
        CustomToast.show(
          context,
          message: 'Mengulang Surah yang sama',
          type: ToastType.info,
        );
        break;
      case 'surah':
        repeatMode.value = 'juz';
        CustomToast.show(
          context,
          message: 'Mengulang Surah dalam Juz yang sama',
          type: ToastType.info,
        );
        break;
      case 'juz':
        repeatMode.value = 'all';
        CustomToast.show(
          context,
          message: 'Mengulang Semua Surah (Juz 1 s/d 30)',
          type: ToastType.info,
        );
        break;
      case 'all':
      default:
        repeatMode.value = 'off';
        CustomToast.show(
          context,
          message: 'Repeat Dinonaktifkan',
          type: ToastType.info,
        );
        break;
    }
  }

  int getStartingJuzForSurah(int surahNomor) {
    if (surahNomor == 1 || surahNomor == 2) return 1;
    if (surahNomor == 3) return 3;
    if (surahNomor == 4) return 4;
    if (surahNomor == 5) return 6;
    if (surahNomor == 6) return 7;
    if (surahNomor == 7) return 8;
    if (surahNomor == 8) return 9;
    if (surahNomor == 9) return 10;
    if (surahNomor >= 10 && surahNomor <= 11) return 11;
    if (surahNomor == 12) return 12;
    if (surahNomor >= 13 && surahNomor <= 14) return 13;
    if (surahNomor >= 15 && surahNomor <= 16) return 14;
    if (surahNomor >= 17 && surahNomor <= 18) return 15;
    if (surahNomor >= 19 && surahNomor <= 20) return 16;
    if (surahNomor >= 21 && surahNomor <= 22) return 17;
    if (surahNomor >= 23 && surahNomor <= 25) return 18;
    if (surahNomor >= 26 && surahNomor <= 27) return 19;
    if (surahNomor >= 28 && surahNomor <= 29) return 20;
    if (surahNomor >= 30 && surahNomor <= 33) return 21;
    if (surahNomor >= 34 && surahNomor <= 36) return 22;
    if (surahNomor >= 37 && surahNomor <= 39) return 23;
    if (surahNomor >= 40 && surahNomor <= 41) return 24;
    if (surahNomor >= 42 && surahNomor <= 45) return 25;
    if (surahNomor >= 46 && surahNomor <= 51) return 26;
    if (surahNomor >= 52 && surahNomor <= 57) return 27;
    if (surahNomor >= 58 && surahNomor <= 66) return 28;
    if (surahNomor >= 67 && surahNomor <= 77) return 29;
    return 30;
  }

  List<int> getSurahsForJuz(int juz) {
    switch (juz) {
      case 1: return [1, 2];
      case 2: return [2];
      case 3: return [2, 3];
      case 4: return [3, 4];
      case 5: return [4];
      case 6: return [4, 5];
      case 7: return [5, 6];
      case 8: return [6, 7];
      case 9: return [7, 8];
      case 10: return [8, 9];
      case 11: return [9, 10, 11];
      case 12: return [11, 12];
      case 13: return [12, 13, 14];
      case 14: return [15, 16];
      case 15: return [17, 18];
      case 16: return [18, 19, 20];
      case 17: return [21, 22];
      case 18: return [23, 24, 25];
      case 19: return [25, 26, 27];
      case 20: return [27, 28, 29];
      case 21: return [29, 30, 31, 32, 33];
      case 22: return [33, 34, 35, 36];
      case 23: return [36, 37, 38, 39];
      case 24: return [39, 40, 41];
      case 25: return [41, 42, 43, 44, 45];
      case 26: return [46, 47, 48, 49, 50, 51];
      case 27: return [51, 52, 53, 54, 55, 56, 57];
      case 28: return [58, 59, 60, 61, 62, 63, 64, 65, 66];
      case 29: return [67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77];
      case 30: return List.generate(37, (index) => 78 + index);
      default: return [];
    }
  }

  void playNext({bool isAuto = false}) {
    final cur = selectedSurah.value;
    if (cur == null || surahList.isEmpty) return;

    if (isAuto) {
      if (repeatMode.value == 'surah') {
        selectSurah(cur, autoPlay: true);
        return;
      } else if (repeatMode.value == 'juz') {
        final currentJuz = getStartingJuzForSurah(cur.nomor);
        final surahIds = getSurahsForJuz(currentJuz);
        if (surahIds.isNotEmpty) {
          final idxInJuz = surahIds.indexOf(cur.nomor);
          if (idxInJuz != -1 && idxInJuz < surahIds.length - 1) {
            final nextSurahNomor = surahIds[idxInJuz + 1];
            DataSurah? nextSurah;
            try {
              nextSurah = surahList.firstWhere((s) => s.nomor == nextSurahNomor);
            } catch (_) {}
            if (nextSurah != null) {
              selectSurah(nextSurah, autoPlay: true);
              return;
            }
          } else {
            final firstSurahNomor = surahIds.first;
            DataSurah? firstSurah;
            try {
              firstSurah = surahList.firstWhere((s) => s.nomor == firstSurahNomor);
            } catch (_) {}
            if (firstSurah != null) {
              selectSurah(firstSurah, autoPlay: true);
              return;
            }
          }
        }
      } else if (repeatMode.value == 'all') {
        final index = surahList.indexWhere((s) => s.nomor == cur.nomor);
        if (index != -1 && index < surahList.length - 1) {
          selectSurah(surahList[index + 1], autoPlay: true);
        } else {
          selectSurah(surahList.first, autoPlay: true);
        }
        return;
      }
    }

    final index = surahList.indexWhere((s) => s.nomor == cur.nomor);
    if (index != -1 && index < surahList.length - 1) {
      selectSurah(surahList[index + 1], autoPlay: true);
    } else {
      if (isAuto) {
        stopAudio();
      } else {
        selectSurah(surahList.first, autoPlay: true);
      }
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
