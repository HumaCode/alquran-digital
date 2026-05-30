import 'package:get/get.dart';
import '../../../data/providers/surah_provider.dart';
import '../../../data/repositories/surah_repository.dart';
import '../controllers/statistik_controller.dart';

class StatistikBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SurahProvider>(() => SurahProvider());
    Get.lazyPut<SurahRepository>(() => SurahRepository(Get.find<SurahProvider>()));
    Get.lazyPut<StatistikController>(
      () => StatistikController(Get.find<SurahRepository>()),
    );
  }
}
