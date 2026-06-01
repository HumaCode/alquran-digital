import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/routes/app_pages.dart';
import 'app/data/providers/notification_helper.dart';
import 'app/data/providers/theme_controller.dart';

import 'dart:ui' as ui;
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Size _getDesignSize() {
  final views = ui.PlatformDispatcher.instance.views;
  if (views.isNotEmpty) {
    final view = views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    // Standard tablet threshold is shortestSide >= 600 dp
    if (size.shortestSide >= 600) {
      return size;
    }
  }
  return const Size(360, 690);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.humacode.my.id.alquran_digital.channel.audio',
    androidNotificationChannelName: 'Murotal Playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/launcher_icon',
  );
  await NotificationHelper.init();
  
  // Register ThemeController before running the app
  Get.put(ThemeController());
  
  runApp(
    ScreenUtilInit(
      designSize: _getDesignSize(),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
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
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          defaultTransition: Transition.rightToLeftWithFade,
          transitionDuration: const Duration(milliseconds: 350),
        );
      },
    ),
  );
}

