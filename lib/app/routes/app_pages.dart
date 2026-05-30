import 'package:get/get.dart';

import '../modules/arahKiblat/bindings/arah_kiblat_binding.dart';
import '../modules/arahKiblat/views/arah_kiblat_view.dart';
import '../modules/detailSurah/bindings/detail_surah_binding.dart';
import '../modules/detailSurah/views/detail_surah_view.dart';
import '../modules/doa/bindings/doa_binding.dart';
import '../modules/doa/views/doa_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/imsakiyah/bindings/imsakiyah_binding.dart';
import '../modules/imsakiyah/views/imsakiyah_view.dart';
import '../modules/jadwalSholat/bindings/jadwal_sholat_binding.dart';
import '../modules/jadwalSholat/views/jadwal_sholat_view.dart';
import '../modules/murotal/bindings/murotal_binding.dart';
import '../modules/murotal/views/murotal_view.dart';
import '../modules/bookmarks/bindings/bookmarks_binding.dart';
import '../modules/bookmarks/views/bookmarks_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/statistik/bindings/statistik_binding.dart';
import '../modules/statistik/views/statistik_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.DOA,
      page: () => const DoaView(),
      binding: DoaBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: _Paths.DETAIL_SURAH,
      page: () => const DetailSurahView(),
      binding: DetailSurahBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: _Paths.JADWAL_SHOLAT,
      page: () => const JadwalSholatView(),
      binding: JadwalSholatBinding(),
    ),
    GetPage(
      name: _Paths.IMSAKIYAH,
      page: () => const ImsakiyahView(),
      binding: ImsakiyahBinding(),
    ),
    GetPage(
      name: _Paths.ARAH_KIBLAT,
      page: () => const ArahKiblatView(),
      binding: ArahKiblatBinding(),
    ),
    GetPage(
      name: _Paths.MUROTAL,
      page: () => const MurotalView(),
      binding: MurotalBinding(),
    ),
    GetPage(
      name: _Paths.BOOKMARKS,
      page: () => const BookmarksView(),
      binding: BookmarksBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: _Paths.STATISTIK,
      page: () => const StatistikView(),
      binding: StatistikBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
    ),
  ];
}
