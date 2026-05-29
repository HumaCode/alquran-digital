import 'package:get/get.dart';
import '../../constants/api_url.dart';

class JadwalSholatProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  // 1. Ambil daftar Provinsi (GET)
  Future<Response> fetchProvinsi() => get(ApiUrl.getAllProvinsi);

  // 2. Ambil daftar Kabupaten/Kota berdasarkan Provinsi (POST)
  Future<Response> fetchKabKota(String provinsi) => post(
        ApiUrl.getDaftarKota,
        {'provinsi': provinsi},
      );

  // 3. Ambil Jadwal Sholat Bulanan (POST)
  Future<Response> fetchJadwalSholat({
    required String provinsi,
    required String kabkota,
    int? bulan,
    int? tahun,
  }) {
    final Map<String, dynamic> body = {
      'provinsi': provinsi,
      'kabkota': kabkota,
    };
    if (bulan != null) body['bulan'] = bulan;
    if (tahun != null) body['tahun'] = tahun;

    return post(ApiUrl.getJadwalSholatBulanan, body);
  }
}
