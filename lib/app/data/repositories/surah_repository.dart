import '../models/surah_model.dart';
import '../providers/surah_provider.dart';

class SurahRepository {
  final SurahProvider _provider;

  SurahRepository(this._provider);

  Future<List<DataSurah>> getSurahs() async {
    final response = await _provider.fetchSurahs();
    if (response.status.hasError) {
      throw Exception('Gagal memuat daftar surah: ${response.statusText}');
    }

    final data = response.body;
    if (data != null) {
      final surahResponse = Surah.fromJson(data as Map<String, dynamic>);
      return surahResponse.data;
    } else {
      throw Exception('Data surah kosong');
    }
  }
}
