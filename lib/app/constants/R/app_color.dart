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

  String get themeName {
    try {
      if (Get.isRegistered<ThemeController>()) {
        return Get.find<ThemeController>().currentThemeColor.value;
      }
    } catch (_) {}
    return 'emerald';
  }

  // global background and content colors
  Color get bg1 {
    if (isDark) {
      switch (themeName) {
        case 'sapphire': return const Color(0xFF0F172A);
        case 'amethyst': return const Color(0xFF120E1A);
        case 'copper': return const Color(0xFF1C130E);
        case 'emerald':
        default: return const Color(0xFF0D1F17);
      }
    } else {
      switch (themeName) {
        case 'sapphire': return const Color(0xFFF1F5F9);
        case 'amethyst': return const Color(0xFFFAF2FB);
        case 'copper': return const Color(0xFFFAF6F2);
        case 'emerald':
        default: return const Color(0xFFFAFDFB);
      }
    }
  }

  Color get bg2 {
    if (isDark) {
      switch (themeName) {
        case 'sapphire': return const Color(0xFF1E293B);
        case 'amethyst': return const Color(0xFF1C132B);
        case 'copper': return const Color(0xFF2B1D16);
        case 'emerald':
        default: return const Color(0xFF112B1E);
      }
    } else {
      switch (themeName) {
        case 'sapphire': return const Color(0xFFE2E8F0);
        case 'amethyst': return const Color(0xFFF3E5F5);
        case 'copper': return const Color(0xFFF5EBE0);
        case 'emerald':
        default: return const Color(0xFFEDF5F1);
      }
    }
  }

  Color get gold => const Color(0xFFD4A843);
  Color get goldLight => isDark ? const Color(0xFFF0CC7A) : const Color(0xFF705615);
  Color get goldDim => isDark ? const Color(0xFF8A6B2A) : const Color(0xFFAC8735);

  Color get textSoft {
    if (isDark) {
      switch (themeName) {
        case 'sapphire': return const Color(0xFFE2E8F0);
        case 'amethyst': return const Color(0xFFEDD2F3);
        case 'copper': return const Color(0xFFF3E2D6);
        case 'emerald':
        default: return const Color(0xFFD8E8D8);
      }
    } else {
      switch (themeName) {
        case 'sapphire': return const Color(0xFF1E293B);
        case 'amethyst': return const Color(0xFF3F0071);
        case 'copper': return const Color(0xFF4A2E1B);
        case 'emerald':
        default: return const Color(0xFF193222);
      }
    }
  }

  Color get textMuted {
    if (isDark) {
      switch (themeName) {
        case 'sapphire': return const Color(0xFF94A3B8);
        case 'amethyst': return const Color(0xFF9C8BB0);
        case 'copper': return const Color(0xFFB0988B);
        case 'emerald':
        default: return const Color(0xFF6A8A6A);
      }
    } else {
      switch (themeName) {
        case 'sapphire': return const Color(0xFF64748B);
        case 'amethyst': return const Color(0xFF7B52AB);
        case 'copper': return const Color(0xFF9E7356);
        case 'emerald':
        default: return const Color(0xFF3B4E41);
      }
    }
  }

  Color get error => const Color(0xFFE57373);
  Color get red => const Color(0xFFE57373);

  // Dynamic Primary Theme Colors
  Color get emerald {
    switch (themeName) {
      case 'sapphire': return const Color(0xFF0284C7);
      case 'amethyst': return const Color(0xFF9333EA);
      case 'copper': return const Color(0xFFD97706);
      case 'emerald':
      default: return const Color(0xFF2E7D52);
    }
  }

  Color get emeraldDark {
    if (isDark) {
      switch (themeName) {
        case 'sapphire': return const Color(0xFF0F325C);
        case 'amethyst': return const Color(0xFF4A1054);
        case 'copper': return const Color(0xFF4C271B);
        case 'emerald':
        default: return const Color(0xFF1E4530);
      }
    } else {
      switch (themeName) {
        case 'sapphire': return const Color(0xFFBAE6FD);
        case 'amethyst': return const Color(0xFFF3D2FC);
        case 'copper': return const Color(0xFFFDE6D2);
        case 'emerald':
        default: return const Color(0xFFD3EBE0);
      }
    }
  }

  Color get emeraldMedium {
    if (isDark) {
      switch (themeName) {
        case 'sapphire': return const Color(0xFF0C4A6E);
        case 'amethyst': return const Color(0xFF581C87);
        case 'copper': return const Color(0xFF78350F);
        case 'emerald':
        default: return const Color(0xFF163828);
      }
    } else {
      switch (themeName) {
        case 'sapphire': return const Color(0xFFE0F2FE);
        case 'amethyst': return const Color(0xFFF5E3FC);
        case 'copper': return const Color(0xFFFEF3C7);
        case 'emerald':
        default: return const Color(0xFFE5F3EC);
      }
    }
  }

  Color get emeraldLight {
    switch (themeName) {
      case 'sapphire': return const Color(0xFF38BDF8);
      case 'amethyst': return const Color(0xFFC084FC);
      case 'copper': return const Color(0xFFFBBF24);
      case 'emerald':
      default: return const Color(0xFF4CAF82);
    }
  }

  // jadwal sholat
  Color get bgJadwal => bg1;
  Color get surfaceJadwal => bg2;
  Color get surface2Jadwal => emeraldMedium;
  Color get surface3Jadwal => emeraldDark;
  Color get goldFaint => isDark ? const Color(0xFF3A2D10) : const Color(0xFFFCF7EA);
  Color get teal => const Color(0xFF1B6B6B);
  Color get textJadwal => textSoft;
  Color get textMutedJadwal => textMuted;
  Color get textDimJadwal => isDark ? const Color(0xFF3A5A3A) : const Color(0xFF8CA393);
  Color get sky => const Color(0xFF1565C0);
  Color get orange => const Color(0xFFFFA726);
  Color get redAccent => const Color(0xFFFF5252);
}
