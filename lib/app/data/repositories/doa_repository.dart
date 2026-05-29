import 'dart:convert';
import '../models/doa_model.dart';
import '../providers/doa_provider.dart';
import '../providers/database_helper.dart';

class DoaRepository {
  final DoaProvider _provider;

  DoaRepository(this._provider);

  Future<List<DataDoa>> getDoas() async {
    final dbHelper = DatabaseHelper.instance;

    // 1. Coba ambil data dari cache lokal terlebih dahulu
    try {
      final cachedJson = await dbHelper.getMetadata('doa_cached_data');
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson);
        final doaResponse = Doa.fromJson(decoded as Map<String, dynamic>);
        
        // Jalankan sinkronisasi data di background agar cache tetap terupdate
        _syncDoasInBackground();
        
        return doaResponse.data;
      }
    } catch (e) {
      print('Gagal mengambil cache doa lokal: $e');
    }

    // 2. Jika cache kosong, ambil dari API (blocking untuk pertama kali)
    final response = await _provider.fetchDoas();
    if (response.status.hasError) {
      throw Exception('Gagal memuat daftar doa: ${response.statusText}');
    }

    final data = response.body;
    if (data != null) {
      // Simpan ke cache lokal
      try {
        await dbHelper.updateMetadata('doa_cached_data', jsonEncode(data));
      } catch (e) {
        print('Gagal menyimpan cache doa: $e');
      }

      final doaResponse = Doa.fromJson(data as Map<String, dynamic>);
      return doaResponse.data;
    } else {
      throw Exception('Data doa kosong');
    }
  }

  // Melakukan update database/cache secara silent di background
  void _syncDoasInBackground() async {
    try {
      final response = await _provider.fetchDoas();
      if (!response.status.hasError && response.body != null) {
        final dbHelper = DatabaseHelper.instance;
        await dbHelper.updateMetadata('doa_cached_data', jsonEncode(response.body));
        print('Berhasil memperbarui cache doa di background');
      }
    } catch (e) {
      print('Gagal sinkronisasi background doa: $e');
    }
  }
}
