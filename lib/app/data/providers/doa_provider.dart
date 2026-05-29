import 'package:get/get.dart';
import '../../constants/api_url.dart';

class DoaProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  Future<Response> fetchDoas() => get(ApiUrl.getAllDoa);
  Future<Response> fetchDetailDoa(int id) => get('${ApiUrl.getDetailDoa}/$id');
}
