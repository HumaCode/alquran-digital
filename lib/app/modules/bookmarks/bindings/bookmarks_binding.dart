import 'package:get/get.dart';
import '../../../data/providers/surah_provider.dart';
import '../../../data/repositories/surah_repository.dart';
import '../controllers/bookmarks_controller.dart';

class BookmarksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SurahProvider>(() => SurahProvider());
    Get.lazyPut<SurahRepository>(() => SurahRepository(Get.find<SurahProvider>()));
    Get.lazyPut<BookmarksController>(
      () => BookmarksController(Get.find<SurahRepository>()),
    );
  }
}
