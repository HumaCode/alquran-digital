import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';
import '../../../data/repositories/surah_repository.dart';
import '../../../data/providers/surah_provider.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure HomeController is registered if not already
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<SurahProvider>(() => SurahProvider());
      Get.lazyPut<SurahRepository>(() => SurahRepository(Get.find<SurahProvider>()));
      Get.lazyPut<HomeController>(() => HomeController(Get.find<SurahRepository>()));
    }
  }
}
