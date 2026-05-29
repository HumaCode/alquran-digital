import 'package:get/get.dart';

import '../controllers/jadwal_sholat_controller.dart';

class JadwalSholatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JadwalSholatController>(
      () => JadwalSholatController(),
    );
  }
}
