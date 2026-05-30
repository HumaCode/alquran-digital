import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/jadwal_sholat_model.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.actionId == 'mute_adzhan') {
    if (notificationResponse.id != null) {
      FlutterLocalNotificationsPlugin().cancel(id: notificationResponse.id!);
      print('Adzan dimatikan untuk ID: ${notificationResponse.id}');
    }
  }
}

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    
    final String timeZoneName = DateTime.now().timeZoneName;
    String locationName = 'Asia/Jakarta';
    if (timeZoneName == 'WIB' || timeZoneName.contains('+07') || timeZoneName.contains('7')) {
      locationName = 'Asia/Jakarta';
    } else if (timeZoneName == 'WITA' || timeZoneName.contains('+08') || timeZoneName.contains('8')) {
      locationName = 'Asia/Makassar';
    } else if (timeZoneName == 'WIT' || timeZoneName.contains('+09') || timeZoneName.contains('9')) {
      locationName = 'Asia/Jayapura';
    } else {
      try {
        tz.getLocation(timeZoneName);
        locationName = timeZoneName;
      } catch (_) {
        locationName = 'Asia/Jakarta';
      }
    }
    
    try {
      tz.setLocalLocation(tz.getLocation(locationName));
    } catch (e) {
      print('Gagal mengatur lokasi timezone: $e. Fallback ke Asia/Jakarta.');
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle click if needed
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Request permissions for Android 13+
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  static Future<void> schedulePrayerNotifications(JadwalSholat schedule) async {
    // 1. Batalkan semua alarm lama terlebih dahulu
    await cancelAll();

    final now = DateTime.now();
    final androidDetails = AndroidNotificationDetails(
      'sholat_channel_v3', // Diubah ke v3 untuk memaksa registrasi ulang custom sound adzan
      'Notifikasi Adzan',
      channelDescription: 'Mengumandangkan adzan ketika masuk waktu sholat',
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('adzhan'),
      playSound: true,
      enableVibration: true,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'mute_adzhan',
          'Matikan Adzan',
          showsUserInterface: false,
        ),
      ],
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    int count = 0;
    // Loop jadwal sholat untuk hari-hari tersisa di bulan ini
    for (final j in schedule.data.jadwal) {
      final date = j.tanggalLengkap;
      // Hanya jadwalkan untuk hari ini dan hari berikutnya
      if (date.day < now.day && date.month == now.month && date.year == now.year) {
        continue;
      }

      // Daftar waktu sholat harian
      final prayers = {
        'Subuh': j.subuh,
        'Dzuhur': j.dzuhur,
        'Ashar': j.ashar,
        'Maghrib': j.maghrib,
        'Isya': j.isya,
      };

      int prayerIdx = 1;
      prayers.forEach((name, timeStr) async {
        try {
          final parts = timeStr.trim().split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          final scheduledTime = DateTime(
            date.year,
            date.month,
            date.day,
            hour,
            minute,
          );

          if (scheduledTime.isAfter(now)) {
            // Gunakan ID unik: day * 100 + prayerIdx (misal hari 5, Subuh (1) -> 501)
            final id = date.day * 100 + prayerIdx;
            
            await _localNotifications.zonedSchedule(
              id: id,
              title: 'Waktu $name',
              body: 'Telah memasuki waktu sholat $name untuk wilayah ${schedule.data.kabkota} dan sekitarnya.',
              scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
              notificationDetails: notificationDetails,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
            count++;
          }
        } catch (e) {
          print('Gagal menjadwalkan sholat $name pada tanggal ${date.day}: $e');
        }
        prayerIdx++;
      });

      // Batasi maksimal menjadwalkan 7 hari ke depan (35 alarm) agar tidak membebani sistem
      if (date.difference(now).inDays > 7) {
        break;
      }
    }
    print('Berhasil menjadwalkan $count notifikasi waktu sholat.');
  }

  static Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
    print('Semua notifikasi waktu sholat dibatalkan.');
  }
}
