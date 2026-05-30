import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/theme_controller.dart';

class AppColor {
  const AppColor();

  bool get isDark {
    try {
      if (Get.isRegistered<ThemeController>()) {
        return Get.find<ThemeController>().isDarkMode.value;
      }
    } catch (_) {}
    return true; // default to dark mode
  }

  // global
  Color get bg1 => isDark ? const Color(0xFF0D1F17) : const Color(0xFFFAFDFB);
  Color get bg2 => isDark ? const Color(0xFF112B1E) : const Color(0xFFEDF5F1);
  Color get gold => const Color(0xFFD4A843);
  Color get goldLight => isDark ? const Color(0xFFF0CC7A) : const Color(0xFF705615);
  Color get goldDim => isDark ? const Color(0xFF8A6B2A) : const Color(0xFFAC8735);
  Color get textSoft => isDark ? const Color(0xFFD8E8D8) : const Color(0xFF193222);
  Color get textMuted => isDark ? const Color(0xFF6A8A6A) : const Color(0xFF3B4E41);
  Color get error => const Color(0xFFE57373);
  Color get red => const Color(0xFFE57373);

  // home
  Color get emerald => const Color(0xFF2E7D52);
  Color get emeraldDark => isDark ? const Color(0xFF1E4530) : const Color(0xFFD3EBE0);
  Color get emeraldMedium => isDark ? const Color(0xFF163828) : const Color(0xFFE5F3EC);
  Color get emeraldLight => const Color(0xFF4CAF82);

  // detail surah
  // (Menggunakan warna global / home)

  // jadwal sholat
  Color get bgJadwal => isDark ? const Color(0xFF090F0C) : const Color(0xFFFAFDFB);
  Color get surfaceJadwal => isDark ? const Color(0xFF0D1A12) : const Color(0xFFFFFFFF);
  Color get surface2Jadwal => isDark ? const Color(0xFF112018) : const Color(0xFFEDF5F1);
  Color get surface3Jadwal => isDark ? const Color(0xFF172A1E) : const Color(0xFFDCECE4);
  Color get goldFaint => isDark ? const Color(0xFF3A2D10) : const Color(0xFFFCF7EA);
  Color get teal => const Color(0xFF1B6B6B);
  Color get textJadwal => isDark ? const Color(0xFFD8E8D8) : const Color(0xFF193222);
  Color get textMutedJadwal => isDark ? const Color(0xFF5A7A5A) : const Color(0xFF5A7561);
  Color get textDimJadwal => isDark ? const Color(0xFF3A5A3A) : const Color(0xFF8CA393);
  Color get sky => const Color(0xFF1565C0);
  Color get orange => const Color(0xFFFFA726);
  Color get redAccent => const Color(0xFFFF5252);
}
