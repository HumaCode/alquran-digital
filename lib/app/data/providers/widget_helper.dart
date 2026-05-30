import 'package:home_widget/home_widget.dart';

class WidgetHelper {
  static Future<void> updateSholatWidget({
    required String location,
    required String nextPrayerName,
    required String nextPrayerTime,
    required String countdown,
    required String subuh,
    required String dzuhur,
    required String ashar,
    required String maghrib,
    required String isya,
  }) async {
    try {
      await HomeWidget.saveWidgetData('location', location);
      await HomeWidget.saveWidgetData('next_prayer_name', nextPrayerName);
      await HomeWidget.saveWidgetData('next_prayer_time', nextPrayerTime);
      await HomeWidget.saveWidgetData('countdown', countdown);
      
      await HomeWidget.saveWidgetData('time_subuh', subuh);
      await HomeWidget.saveWidgetData('time_dzuhur', dzuhur);
      await HomeWidget.saveWidgetData('time_ashar', ashar);
      await HomeWidget.saveWidgetData('time_maghrib', maghrib);
      await HomeWidget.saveWidgetData('time_isya', isya);
      
      await HomeWidget.updateWidget(
        name: 'SholatWidgetProvider',
        androidName: 'SholatWidgetProvider',
      );
      print('Widget sholat berhasil diperbarui.');
    } catch (e) {
      print('Gagal memperbarui widget sholat: $e');
    }
  }

  static Future<void> updateAyatWidget({
    required String arab,
    required String indo,
    required String ref,
  }) async {
    try {
      await HomeWidget.saveWidgetData('ayat_arab', arab);
      await HomeWidget.saveWidgetData('ayat_indo', indo);
      await HomeWidget.saveWidgetData('ayat_ref', ref);
      
      await HomeWidget.updateWidget(
        name: 'AyatWidgetProvider',
        androidName: 'AyatWidgetProvider',
      );
      print('Widget ayat harian berhasil diperbarui.');
    } catch (e) {
      print('Gagal memperbarui widget ayat harian: $e');
    }
  }

  static Future<void> updateProgressWidget({
    required int today,
    required int target,
    required int streak,
  }) async {
    try {
      await HomeWidget.saveWidgetData('tilawah_today', today);
      await HomeWidget.saveWidgetData('tilawah_target', target);
      await HomeWidget.saveWidgetData('tilawah_streak', streak);
      
      await HomeWidget.updateWidget(
        name: 'ProgressWidgetProvider',
        androidName: 'ProgressWidgetProvider',
      );
      print('Widget progress tilawah berhasil diperbarui.');
    } catch (e) {
      print('Gagal memperbarui widget progress tilawah: $e');
    }
  }
}

