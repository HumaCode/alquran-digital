import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'database_helper.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final isDarkMode = true.obs;
  final currentThemeColor = 'emerald'.obs; // 'emerald', 'sapphire', 'amethyst', 'copper'

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  Future<void> loadTheme() async {
    try {
      final savedTheme = await DatabaseHelper.instance.getMetadata('is_dark_mode');
      if (savedTheme != null) {
        isDarkMode.value = savedTheme == 'true';
      } else {
        isDarkMode.value = true; // default to dark theme
      }

      final savedThemeColor = await DatabaseHelper.instance.getMetadata('theme_color');
      if (savedThemeColor != null) {
        currentThemeColor.value = savedThemeColor;
      } else {
        currentThemeColor.value = 'emerald';
      }
    } catch (e) {
      isDarkMode.value = true;
      currentThemeColor.value = 'emerald';
    }
    _applyTheme();
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    try {
      await DatabaseHelper.instance.updateMetadata('is_dark_mode', isDarkMode.value.toString());
    } catch (_) {}
    _applyTheme();
  }

  Future<void> setThemeColor(String colorName) async {
    currentThemeColor.value = colorName;
    try {
      await DatabaseHelper.instance.updateMetadata('theme_color', colorName);
    } catch (_) {}
    _applyTheme();
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
