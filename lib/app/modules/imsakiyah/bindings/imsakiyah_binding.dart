import 'package:get/get.dart';

import '../../../data/providers/jadwal_sholat_provider.dart';
import '../../../data/repositories/jadwal_sholat_repository.dart';
import '../controllers/imsakiyah_controller.dart';

class ImsakiyahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JadwalSholatProvider>(() => JadwalSholatProvider());
    Get.lazyPut<JadwalSholatRepository>(
      () => JadwalSholatRepository(Get.find<JadwalSholatProvider>()),
    );
    Get.lazyPut<ImsakiyahController>(
      () => ImsakiyahController(Get.find<JadwalSholatRepository>()),
    );
  }
}
