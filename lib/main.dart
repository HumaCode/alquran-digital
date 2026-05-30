import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'app/routes/app_pages.dart';
import 'app/data/providers/notification_helper.dart';
import 'app/data/providers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.humacode.my.id.alquran_digital.channel.audio',
    androidNotificationChannelName: 'Murotal Playback',
    androidNotificationOngoing: true,
  );
  await NotificationHelper.init();
  
  // Register ThemeController before running the app
  Get.put(ThemeController());
  
  runApp(
    GetMaterialApp(
      title: "Al-Quran Digital",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
      ),
      themeMode: ThemeMode.dark, // Default will be managed by ThemeController onInit
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
    ),
  );
}

