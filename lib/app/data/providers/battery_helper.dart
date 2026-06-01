import 'package:flutter/services.dart';

class BatteryHelper {
  static const _channel = MethodChannel('com.humacode.my.id.alquran_digital/battery_optimization');

  /// Memeriksa apakah aplikasi sudah dikecualikan dari optimasi baterai (Doze Mode)
  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool isIgnoring = await _channel.invokeMethod('isIgnoringBatteryOptimizations') ?? false;
      return isIgnoring;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Meminta pengecualian optimasi baterai melalui dialog sistem (jika didukung)
  static Future<bool> requestIgnoreBatteryOptimizations() async {
    try {
      final bool success = await _channel.invokeMethod('requestIgnoreBatteryOptimizations') ?? false;
      return success;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Membuka halaman pengaturan optimasi baterai sistem secara manual sebagai fallback
  static Future<bool> openBatteryOptimizationSettings() async {
    try {
      final bool success = await _channel.invokeMethod('openBatteryOptimizationSettings') ?? false;
      return success;
    } on PlatformException catch (_) {
      return false;
    }
  }
}
