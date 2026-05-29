import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../../data/providers/database_helper.dart';

class ArahKiblatController extends GetxController {
  final isLoading = false.obs;
  final isCompassAvailable = false.obs;
  final deviceHeading = 0.0.obs;
  final qiblaDirection = 291.5.obs; // Default fallback for Indonesia
  final distanceToKaaba = 7900.0.obs; // in km
  final currentLatitude = (-6.2088).obs;
  final currentLongitude = (106.8456).obs;
  final cityName = 'Jakarta'.obs;
  final provinceName = 'DKI Jakarta'.obs;
  final compassError = ''.obs;

  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void onInit() {
    super.onInit();
    initCompassAndLocation();
  }

  @override
  void onClose() {
    _compassSubscription?.cancel();
    super.onClose();
  }

  double calculateQiblaDirection(double lat, double lon) {
    // Kaaba coordinates
    const double kaabaLat = 21.4225 * math.pi / 180.0;
    const double kaabaLon = 39.8262 * math.pi / 180.0;

    double userLat = lat * math.pi / 180.0;
    double userLon = lon * math.pi / 180.0;

    double dLon = kaabaLon - userLon;

    double y = math.sin(dLon);
    double x = math.cos(userLat) * math.tan(kaabaLat) - math.sin(userLat) * math.cos(dLon);

    double qiblaRad = math.atan2(y, x);
    double qiblaDeg = qiblaRad * 180.0 / math.pi;

    return (qiblaDeg + 360.0) % 360.0;
  }

  double calculateDistanceToKaaba(double lat, double lon) {
    const double R = 6371.0; // Earth radius in km
    const double kaabaLat = 21.4225 * math.pi / 180.0;
    const double kaabaLon = 39.8262 * math.pi / 180.0;

    double userLat = lat * math.pi / 180.0;
    double userLon = lon * math.pi / 180.0;

    double dLat = kaabaLat - userLat;
    double dLon = kaabaLon - userLon;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(userLat) * math.cos(kaabaLat) * math.sin(dLon / 2) * math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }

  double get qiblaDeviation {
    double dev = qiblaDirection.value - deviceHeading.value;
    dev = (dev + 180) % 360 - 180;
    return dev;
  }

  bool get isFacingQibla {
    return qiblaDeviation.abs() <= 4.0;
  }

  Future<void> initCompassAndLocation() async {
    isLoading.value = true;
    compassError.value = '';

    try {
      // 1. Muat nama kota yang disimpan di lokal sebagai nama tampilan
      final dbHelper = DatabaseHelper.instance;
      final savedProv = await dbHelper.getMetadata('jadwal_sholat_selected_provinsi');
      final savedKab = await dbHelper.getMetadata('jadwal_sholat_selected_kabkota');
      if (savedKab != null) cityName.value = savedKab;
      if (savedProv != null) provinceName.value = savedProv;

      // 2. Cek izin lokasi untuk koordinat GPS nyata
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      Position? position;
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 4),
          );
        }
      }

      double lat = -6.2088; // Default Jakarta
      double lon = 106.8456;

      if (position != null) {
        lat = position.latitude;
        lon = position.longitude;
        currentLatitude.value = lat;
        currentLongitude.value = lon;
      }

      qiblaDirection.value = calculateQiblaDirection(lat, lon);
      distanceToKaaba.value = calculateDistanceToKaaba(lat, lon);

      // 3. Langganan data kompas
      _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
        if (event.heading != null) {
          deviceHeading.value = event.heading!;
          isCompassAvailable.value = true;
        } else {
          isCompassAvailable.value = false;
        }
      }, onError: (e) {
        compassError.value = e.toString();
        isCompassAvailable.value = false;
      });
    } catch (e) {
      print('Error inisialisasi arah kiblat: $e');
      isCompassAvailable.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void refreshLocation() {
    _compassSubscription?.cancel();
    initCompassAndLocation();
  }
}
