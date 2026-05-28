class ApiUrl {
  ApiUrl._();

  static const String baseUrl = 'https://equran.id/api';
  
  static const String doa = '$baseUrl/doa';
  static const String getAllSurah = '$baseUrl/v2/surat';
  static const String getDetailSurah = '$baseUrl/v2/surat'; // Gunakan: ${ApiUrl.getDetailSurah}/$nomor
  static const String getTafsirSurah = '$baseUrl/v2/tafsir'; // Gunakan: ${ApiUrl.getTafsirSurah}/$nomor
}
