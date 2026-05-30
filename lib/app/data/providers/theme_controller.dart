import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'database_helper.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final isDarkMode = true.obs;

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
    } catch (e) {
      isDarkMode.value = true;
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

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
