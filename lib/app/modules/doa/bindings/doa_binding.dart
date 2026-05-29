import 'package:get/get.dart';

import '../../../data/providers/doa_provider.dart';
import '../../../data/repositories/doa_repository.dart';
import '../controllers/doa_controller.dart';

class DoaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoaProvider>(() => DoaProvider());
    Get.lazyPut<DoaRepository>(() => DoaRepository(Get.find<DoaProvider>()));
    Get.lazyPut<DoaController>(
      () => DoaController(Get.find<DoaRepository>()),
    );
  }
}
