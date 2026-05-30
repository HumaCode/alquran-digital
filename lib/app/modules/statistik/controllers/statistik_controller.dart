import 'package:get/get.dart';
import '../../../data/repositories/surah_repository.dart';

class TilawahBadge {
  final String id;
  final String title;
  final String description;
  final String icon; // Emoji or asset path
  final bool isUnlocked;
  final String progressString;
  final double progressPercent;

  TilawahBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.progressString,
    required this.progressPercent,
  });
}

class StatistikController extends GetxController {
  final SurahRepository _repository;

  StatistikController(this._repository);

  final isLoading = false.obs;
  
  // Stat values
  final totalAyat = 0.obs;
  final rataRata = 0.0.obs;
  final longestStreak = 0.obs;
  final currentStreak = 0.obs;
  final dailyTarget = 10.obs;

  // Monthly progress for 30 days
  final monthlyProgress = <Map<String, dynamic>>[].obs;
  
  // Badges list
  final badges = <TilawahBadge>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoading.value = true;
    try {
      // 1. Fetch statistics
      final stats = await _repository.getTilawahStats();
      totalAyat.value = stats['totalAyat'] as int? ?? 0;
      rataRata.value = stats['rataRata'] as double? ?? 0.0;
      longestStreak.value = stats['longestStreak'] as int? ?? 0;
      currentStreak.value = stats['currentStreak'] as int? ?? 0;

      // 2. Fetch daily target
      final target = await _repository.getDailyTarget();
      dailyTarget.value = target;

      // 3. Fetch monthly progress (last 30 days)
      final rawProgress = await _repository.getMonthlyProgress();
      _generate30DaysProgress(rawProgress);

      // 4. Update badges list
      _evaluateBadges();
    } catch (e) {
      Get.log('Gagal mengambil data statistik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _generate30DaysProgress(List<Map<String, dynamic>> rawProgress) {
    final now = DateTime.now();
    final progressMap = <String, int>{};
    for (var item in rawProgress) {
      progressMap[item['tanggal'] as String] = item['jumlahAyatDibaca'] as int;
    }

    final list = <Map<String, dynamic>>[];
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final count = progressMap[dateStr] ?? 0;
      list.add({
        'tanggal': dateStr,
        'jumlah': count,
        'date': date,
      });
    }
    monthlyProgress.assignAll(list);
  }

  void _evaluateBadges() {
    final total = totalAyat.value;
    final longest = longestStreak.value;

    final newList = <TilawahBadge>[
      TilawahBadge(
        id: 'mulai_langkahmu',
        title: 'Mulai Langkahmu 🌱',
        description: 'Membaca setidaknya 1 ayat Al-Quran.',
        icon: '🌱',
        isUnlocked: total >= 1,
        progressString: total >= 1 ? '1/1' : '$total/1',
        progressPercent: (total / 1).clamp(0.0, 1.0),
      ),
      TilawahBadge(
        id: 'streak_3_hari',
        title: 'Pembaca Konsisten ⚡',
        description: 'Mencapai streak membaca selama 3 hari berturut-turut.',
        icon: '⚡',
        isUnlocked: longest >= 3,
        progressString: longest >= 3 ? '3/3' : '$longest/3',
        progressPercent: (longest / 3).clamp(0.0, 1.0),
      ),
      TilawahBadge(
        id: 'streak_7_hari',
        title: 'Streak 7 Hari 🔥',
        description: 'Mencapai streak membaca selama 7 hari berturut-turut.',
        icon: '🔥',
        isUnlocked: longest >= 7,
        progressString: longest >= 7 ? '7/7' : '$longest/7',
        progressPercent: (longest / 7).clamp(0.0, 1.0),
      ),
      TilawahBadge(
        id: 'baca_100_ayat',
        title: 'Pembaca Tekun 🌟',
        description: 'Membaca total 100 ayat Al-Quran.',
        icon: '🌟',
        isUnlocked: total >= 100,
        progressString: total >= 100 ? '100/100' : '$total/100',
        progressPercent: (total / 100).clamp(0.0, 1.0),
      ),
      TilawahBadge(
        id: 'baca_1000_ayat',
        title: 'Baca 1000 Ayat ⭐',
        description: 'Membaca total 1.000 ayat Al-Quran.',
        icon: '⭐',
        isUnlocked: total >= 1000,
        progressString: total >= 1000 ? '1.000/1.000' : '$total/1.000',
        progressPercent: (total / 1000).clamp(0.0, 1.0),
      ),
      TilawahBadge(
        id: 'baca_5000_ayat',
        title: 'Pencinta Al-Quran 👑',
        description: 'Membaca total 5.000 ayat Al-Quran.',
        icon: '👑',
        isUnlocked: total >= 5000,
        progressString: total >= 5000 ? '5.000/5.000' : '$total/5.000',
        progressPercent: (total / 5000).clamp(0.0, 1.0),
      ),
      TilawahBadge(
        id: 'khatam_pertama',
        title: 'Khatam Pertama 🏆',
        description: 'Membaca total 6.236 ayat (setara dengan satu kali khatam Al-Quran).',
        icon: '🏆',
        isUnlocked: total >= 6236,
        progressString: total >= 6236 ? '6.236/6.236' : '$total/6.236',
        progressPercent: (total / 6236).clamp(0.0, 1.0),
      ),
    ];

    badges.assignAll(newList);
  }
}
