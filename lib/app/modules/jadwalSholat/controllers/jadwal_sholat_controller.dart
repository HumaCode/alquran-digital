import 'package:get/get.dart';
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
      final dbHelper = DatabaseHelper.instance;
      final savedProv = await dbHelper.getMetadata('jadwal_sholat_selected_provinsi');
      final savedKab = await dbHelper.getMetadata('jadwal_sholat_selected_kabkota');

      if (savedProv != null) selectedProvinsi.value = savedProv;
      if (savedKab != null) selectedKabKota.value = savedKab;

      // Load provinces first
      await fetchProvinsi();

      // Load cities for the province
      await fetchKabKota(selectedProvinsi.value);

      // Load prayer schedule
      await fetchSchedule();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
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
