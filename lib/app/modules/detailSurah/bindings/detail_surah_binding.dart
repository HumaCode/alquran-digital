import 'package:get/get.dart';
import '../../../data/providers/surah_provider.dart';
import '../../../data/repositories/surah_repository.dart';
import '../controllers/detail_surah_controller.dart';

class DetailSurahBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SurahProvider>()) {
      Get.lazyPut<SurahProvider>(() => SurahProvider());
    }
    if (!Get.isRegistered<SurahRepository>()) {
      Get.lazyPut<SurahRepository>(() => SurahRepository(Get.find<SurahProvider>()));
    }
    Get.lazyPut<DetailSurahController>(
      () => DetailSurahController(Get.find<SurahRepository>()),
    );
  }
}
