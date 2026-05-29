import 'package:get/get.dart';

import '../../../data/providers/jadwal_sholat_provider.dart';
import '../../../data/repositories/jadwal_sholat_repository.dart';
import '../controllers/jadwal_sholat_controller.dart';

class JadwalSholatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JadwalSholatProvider>(() => JadwalSholatProvider());
    Get.lazyPut<JadwalSholatRepository>(
      () => JadwalSholatRepository(Get.find<JadwalSholatProvider>()),
    );
    Get.lazyPut<JadwalSholatController>(
      () => JadwalSholatController(Get.find<JadwalSholatRepository>()),
    );
  }
}
