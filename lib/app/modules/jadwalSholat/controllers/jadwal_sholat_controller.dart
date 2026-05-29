import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/repositories/jadwal_sholat_repository.dart';
import '../../../data/models/jadwal_sholat_model.dart';
import '../../../data/providers/database_helper.dart';

class JadwalSholatController extends GetxController {
  final JadwalSholatRepository _repository;

  JadwalSholatController(this._repository);

  final isLoading = false.obs;
  final isCitiesLoading = false.obs;
  final errorMessage = ''.obs;

  // Selected states (default fallbacks)
  final selectedProvinsi = 'Jawa Tengah'.obs;
  final selectedKabKota = 'Kota Pekalongan'.obs;

  // Dropdown lists
  final provinsiList = <String>[].obs;
  final kabKotaList = <String>[].obs;

  // Monthly schedule data
  final jadwalSholat = Rxn<JadwalSholat>();
  
  // Today's schedule data
  final todayJadwal = Rxn<Jadwal>();

  @override
  void onInit() {
    super.onInit();
    initLocationAndLoad();
  }

  Future<void> initLocationAndLoad() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Muat provinsi terlebih dahulu agar siap dicocokkan
      await fetchProvinsi();

      final dbHelper = DatabaseHelper.instance;
      final savedProv = await dbHelper.getMetadata('jadwal_sholat_selected_provinsi');
      final savedKab = await dbHelper.getMetadata('jadwal_sholat_selected_kabkota');

      if (savedProv != null && savedKab != null) {
        selectedProvinsi.value = savedProv;
        selectedKabKota.value = savedKab;
        await fetchKabKota(selectedProvinsi.value);
        await fetchSchedule();
      } else {
        // Deteksi lokasi jika tidak ada data tersimpan
        await detectLocation();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> detectLocation() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    double? latitude;
    double? longitude;

    try {
      // 1. Dapatkan lokasi GPS dari HP menggunakan geolocator
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 5),
          );
          latitude = position.latitude;
          longitude = position.longitude;
        }
      }
    } catch (e) {
      print('Gagal mendapatkan koordinat GPS: $e');
    }

    String? detectedCityName;
    String? detectedProvinceName;

    if (latitude != null && longitude != null) {
      // 2a. Gunakan reverse geocoding via OpenStreetMap Nominatim
      try {
        final client = GetConnect();
        final response = await client.get(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude',
          headers: {'User-Agent': 'AlquranDigitalApp'},
        );
        if (response.status.isOk && response.body != null) {
          final addr = response.body['address'];
          if (addr != null) {
            detectedCityName = addr['city'] ?? addr['municipality'] ?? addr['county'] ?? addr['town'] ?? addr['city_district'];
            detectedProvinceName = addr['state'];
          }
        }
      } catch (e) {
        print('Gagal reverse geocoding via Nominatim: $e');
      }
    }

    if (detectedCityName == null) {
      // 2b. Fallback: Gunakan IP Geolocation
      try {
        final client = GetConnect();
        final response = await client.get('http://ip-api.com/json');
        if (response.status.isOk && response.body != null && response.body['status'] == 'success') {
          detectedCityName = response.body['city'];
          detectedProvinceName = _translateEnglishProvince(response.body['regionName']);
        }
      } catch (e) {
        print('Gagal mendapatkan lokasi via IP: $e');
      }
    }

    // 3. Cocokkan hasil deteksi dengan daftar provinsi & kota yang ada di equran.id
    if (detectedCityName != null && detectedProvinceName != null) {
      if (provinsiList.isEmpty) {
        await fetchProvinsi();
      }

      // Cocokkan Provinsi
      String? matchedProvinsi;
      for (final prov in provinsiList) {
        if (prov.toLowerCase().contains(detectedProvinceName.toLowerCase()) ||
            detectedProvinceName.toLowerCase().contains(prov.toLowerCase())) {
          matchedProvinsi = prov;
          break;
        }
      }

      if (matchedProvinsi != null) {
        selectedProvinsi.value = matchedProvinsi;
        await DatabaseHelper.instance.updateMetadata('jadwal_sholat_selected_provinsi', matchedProvinsi);

        // Muat kota-kota untuk provinsi tersebut
        await fetchKabKota(matchedProvinsi);

        // Cocokkan Kota
        String? matchedKota;
        for (final city in kabKotaList) {
          if (city.toLowerCase().contains(detectedCityName.toLowerCase()) ||
              detectedCityName.toLowerCase().contains(city.toLowerCase())) {
            matchedKota = city;
            break;
          }
        }

        if (matchedKota != null) {
          selectedKabKota.value = matchedKota;
          await DatabaseHelper.instance.updateMetadata('jadwal_sholat_selected_kabkota', matchedKota);
        }
      }
    }

    // 4. Muat jadwal berdasarkan lokasi yang baru terdeteksi
    await fetchSchedule();
  }

  String _translateEnglishProvince(String englishName) {
    final map = {
      'aceh': 'Aceh',
      'bali': 'Bali',
      'banten': 'Banten',
      'bengkulu': 'Bengkulu',
      'gorontalo': 'Gorontalo',
      'jakarta': 'DKI Jakarta',
      'jambi': 'Jambi',
      'west java': 'Jawa Barat',
      'central java': 'Jawa Tengah',
      'east java': 'Jawa Timur',
      'west kalimantan': 'Kalimantan Barat',
      'east kalimantan': 'Kalimantan Timur',
      'south kalimantan': 'Kalimantan Selatan',
      'central kalimantan': 'Kalimantan Tengah',
      'north kalimantan': 'Kalimantan Utara',
      'lampung': 'Lampung',
      'maluku': 'Maluku',
      'north maluku': 'Maluku Utara',
      'west nusa tenggara': 'Nusa Tenggara Barat',
      'east nusa tenggara': 'Nusa Tenggara Timur',
      'papua': 'Papua',
      'west papua': 'Papua Barat',
      'riau': 'Riau',
      'riau islands': 'Kepulauan Riau',
      'west sulawesi': 'Sulawesi Barat',
      'south sulawesi': 'Sulawesi Selatan',
      'central sulawesi': 'Sulawesi Tengah',
      'southeast sulawesi': 'Sulawesi Tenggara',
      'north sulawesi': 'Sulawesi Utara',
      'west sumatra': 'Sumatera Barat',
      'south sumatra': 'Sumatera Selatan',
      'north sumatra': 'Sumatera Utara',
      'yogyakarta': 'DI Yogyakarta',
    };
    final lower = englishName.toLowerCase().trim();
    if (map.containsKey(lower)) return map[lower]!;
    return englishName;
  }

  Future<void> fetchProvinsi() async {
    try {
      final list = await _repository.getProvinsi();
      provinsiList.assignAll(list);
    } catch (e) {
      print('Gagal memuat daftar provinsi: $e');
    }
  }

  Future<void> fetchKabKota(String provinsi) async {
    isCitiesLoading.value = true;
    try {
      final list = await _repository.getKabKota(provinsi);
      kabKotaList.assignAll(list);
      
      // Auto-select the first city if current selection isn't available in new list
      if (list.isNotEmpty && !list.contains(selectedKabKota.value)) {
        selectedKabKota.value = list.first;
      }
    } catch (e) {
      print('Gagal memuat daftar kota: $e');
    } finally {
      isCitiesLoading.value = false;
    }
  }

  Future<void> updateProvince(String prov) async {
    if (selectedProvinsi.value == prov) return;
    selectedProvinsi.value = prov;
    
    // Simpan pilihan provinsi terakhir
    await DatabaseHelper.instance.updateMetadata('jadwal_sholat_selected_provinsi', prov);

    await fetchKabKota(prov);
    await fetchSchedule();
  }

  Future<void> updateCity(String city) async {
    if (selectedKabKota.value == city) return;
    selectedKabKota.value = city;

    // Simpan pilihan kota terakhir
    await DatabaseHelper.instance.updateMetadata('jadwal_sholat_selected_kabkota', city);

    await fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final now = DateTime.now();
      final schedule = await _repository.getJadwalSholat(
        provinsi: selectedProvinsi.value,
        kabkota: selectedKabKota.value,
        bulan: now.month,
        tahun: now.year,
      );
      jadwalSholat.value = schedule;

      // Update data hari ini
      updateTodayJadwal();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void updateTodayJadwal() {
    final schedule = jadwalSholat.value;
    if (schedule == null) {
      todayJadwal.value = null;
      return;
    }

    final now = DateTime.now();
    final today = schedule.data.jadwal.firstWhereOrNull(
      (j) => j.tanggalLengkap.day == now.day &&
             j.tanggalLengkap.month == now.month &&
             j.tanggalLengkap.year == now.year,
    );

    todayJadwal.value = today ?? (schedule.data.jadwal.isNotEmpty ? schedule.data.jadwal.first : null);
  }
}
