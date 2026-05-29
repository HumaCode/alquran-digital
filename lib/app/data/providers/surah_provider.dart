import 'package:get/get.dart';
import '../../constants/api_url.dart';

class SurahProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  Future<Response> fetchSurahs() => get(ApiUrl.getAllSurah);

  Future<Response> fetchDetailSurah(int nomor) => get('${ApiUrl.getDetailSurah}/$nomor');

  Future<Response> fetchTafsirSurah(int nomor) => get('${ApiUrl.getTafsirSurah}/$nomor');
}
