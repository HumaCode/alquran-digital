import 'dart:convert';
import '../models/provinsi_model.dart';
import '../models/kab_kota_model.dart';
import '../models/jadwal_sholat_model.dart';
import '../providers/jadwal_sholat_provider.dart';
import '../providers/database_helper.dart';

class JadwalSholatRepository {
  final JadwalSholatProvider _provider;

  JadwalSholatRepository(this._provider);

  // Ambil daftar Provinsi
  Future<List<String>> getProvinsi() async {
    final response = await _provider.fetchProvinsi();
    if (response.status.hasError) {
      throw Exception('Gagal memuat provinsi: ${response.statusText}');
    }
    if (response.body != null) {
      final res = Provinsi.fromJson(response.body as Map<String, dynamic>);
      return res.data;
    }
    return [];
  }

  // Ambil daftar Kabupaten/Kota berdasarkan Provinsi
  Future<List<String>> getKabKota(String provinsi) async {
    final response = await _provider.fetchKabKota(provinsi);
    if (response.status.hasError) {
      throw Exception('Gagal memuat kabupaten/kota: ${response.statusText}');
    }
    if (response.body != null) {
      final res = KabKota.fromJson(response.body as Map<String, dynamic>);
      return res.data;
    }
    return [];
  }

  // Ambil Jadwal Sholat Bulanan
  Future<JadwalSholat> getJadwalSholat({
    required String provinsi,
    required String kabkota,
    int? bulan,
    int? tahun,
  }) async {
    final dbHelper = DatabaseHelper.instance;

    // 1. Coba ambil dari cache lokal jika parameter cocok
    try {
      final cachedJson = await dbHelper.getMetadata('jadwal_sholat_cached');
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson);
        final cachedData = JadwalSholat.fromJson(decoded as Map<String, dynamic>);
        
        final now = DateTime.now();
        final targetBulan = bulan ?? now.month;
        final targetTahun = tahun ?? now.year;

        if (cachedData.data.provinsi.toLowerCase() == provinsi.toLowerCase() &&
            cachedData.data.kabkota.toLowerCase() == kabkota.toLowerCase() &&
            cachedData.data.bulan == targetBulan &&
            cachedData.data.tahun == targetTahun) {
          
          // Sinkronisasi background asinkron (silent)
          _syncJadwalInBackground(
            provinsi: provinsi,
            kabkota: kabkota,
            bulan: targetBulan,
            tahun: targetTahun,
          );
          
          return cachedData;
        }
      }
    } catch (e) {
      print('Gagal mengambil cache jadwal sholat: $e');
    }

    // 2. Jika cache kosong atau tidak cocok, fetch dari API
    final response = await _provider.fetchJadwalSholat(
      provinsi: provinsi,
      kabkota: kabkota,
      bulan: bulan,
      tahun: tahun,
    );

    if (response.status.hasError) {
      throw Exception('Gagal memuat jadwal sholat: ${response.statusText}');
    }

    final data = response.body;
    if (data != null) {
      // Simpan ke cache
      try {
        await dbHelper.updateMetadata('jadwal_sholat_cached', jsonEncode(data));
      } catch (e) {
        print('Gagal menyimpan cache jadwal sholat: $e');
      }
      return JadwalSholat.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Jadwal sholat kosong');
    }
  }

  void _syncJadwalInBackground({
    required String provinsi,
    required String kabkota,
    required int bulan,
    required int tahun,
  }) async {
    try {
      final response = await _provider.fetchJadwalSholat(
        provinsi: provinsi,
        kabkota: kabkota,
        bulan: bulan,
        tahun: tahun,
      );
      if (!response.status.hasError && response.body != null) {
        final dbHelper = DatabaseHelper.instance;
        await dbHelper.updateMetadata('jadwal_sholat_cached', jsonEncode(response.body));
        print('Berhasil sinkronisasi jadwal sholat di background');
      }
    } catch (e) {
      print('Gagal sinkronisasi background jadwal sholat: $e');
    }
  }
}
