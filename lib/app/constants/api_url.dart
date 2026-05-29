class ApiUrl {
  ApiUrl._();

  static const String baseUrl = 'https://equran.id/api';

  static const String getAllSurah = '$baseUrl/v2/surat';
  static const String getDetailSurah =
      '$baseUrl/v2/surat'; // Gunakan: ${ApiUrl.getDetailSurah}/$nomor
  static const String getTafsirSurah =
      '$baseUrl/v2/tafsir'; // Gunakan: ${ApiUrl.getTafsirSurah}/$nomor

  static const String getAllDoa = '$baseUrl/doa';
  static const String getDetailDoa =
      '$baseUrl/doa'; // Gunakan: ${ApiUrl.getDetailDoa}/$id

  static const String getAllProvinsi = '$baseUrl/v2/shalat/provinsi';
  static const String getDaftarKota =
      '$baseUrl/v2/shalat/kabkota'; // Request Body = "provinsi": "Jawa Barat"  contoh
  static const String getJadwalSholatBulanan =
      '$baseUrl/v2/shalat'; // Request Body: "provinsi": "Jawa Barat", "kabkota": "Kota Bogor", "bulan": 1,      // 1-12 (optional, default: bulan sekarang) "tahun": 2026    // (optional, default: tahun sekarang)

  static const String getImsakiyah = '$baseUrl/v2/imsakiyah';
}
