import 'package:get/get.dart';

import '../controllers/arah_kiblat_controller.dart';

class ArahKiblatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArahKiblatController>(
      () => ArahKiblatController(),
    );
  }
}
