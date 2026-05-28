import 'package:get/get.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/repositories/surah_repository.dart';

class HomeController extends GetxController {
  final SurahRepository _repository;

  HomeController(this._repository);

  final isLoading = false.obs;
  final surahs = <DataSurah>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSurahs();
  }

  Future<void> fetchSurahs() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _repository.getSurahs();
      surahs.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
