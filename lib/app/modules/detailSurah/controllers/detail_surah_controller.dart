import 'package:get/get.dart';
import '../../../data/models/detail_surah_model.dart';
import '../../../data/repositories/surah_repository.dart';

class DetailSurahController extends GetxController {
  final SurahRepository _repository;

  DetailSurahController(this._repository);

  final isLoading = false.obs;
  final detailSurah = Rxn<DetailSurah>();
  final errorMessage = ''.obs;

  late final int nomorSurah;

  @override
  void onInit() {
    super.onInit();

    // Get the Surah number from arguments
    final args = Get.arguments;
    if (args is int) {
      nomorSurah = args;
    } else if (args is Map && args['nomor'] is int) {
      nomorSurah = args['nomor'] as int;
    } else {
      nomorSurah = 1; // Fallback to Al-Fatihah
    }

    fetchDetailSurah();
  }

  Future<void> fetchDetailSurah() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _repository.getDetailSurah(nomorSurah);
      detailSurah.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
