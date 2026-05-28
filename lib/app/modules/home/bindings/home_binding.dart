import 'package:get/get.dart';
import '../../../data/providers/surah_provider.dart';
import '../../../data/repositories/surah_repository.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SurahProvider>(() => SurahProvider());
    Get.lazyPut<SurahRepository>(() => SurahRepository(Get.find<SurahProvider>()));
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<SurahRepository>()),
    );
  }
}
