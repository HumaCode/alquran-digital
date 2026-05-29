class JadwalSholat {
  int code;
  String message;
  Data data;

  JadwalSholat({required this.code, required this.message, required this.data});

  factory JadwalSholat.fromJson(Map<String, dynamic> json) {
    return JadwalSholat(
      code: json['code'] as int,
      message: json['message'] as String,
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class Data {
  String provinsi;
  String kabkota;
  int bulan;
  int tahun;
  String bulanNama;
  List<Jadwal> jadwal;

  Data({
    required this.provinsi,
    required this.kabkota,
    required this.bulan,
    required this.tahun,
    required this.bulanNama,
    required this.jadwal,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      provinsi: json['provinsi'] as String,
      kabkota: json['kabkota'] as String,
      bulan: json['bulan'] as int,
      tahun: json['tahun'] as int,
      bulanNama: json['bulanNama'] as String,
      jadwal: (json['jadwal'] as List)
          .map((item) => Jadwal.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provinsi': provinsi,
      'kabkota': kabkota,
      'bulan': bulan,
      'tahun': tahun,
      'bulanNama': bulanNama,
      'jadwal': jadwal.map((item) => item.toJson()).toList(),
    };
  }
}

class Jadwal {
  int tanggal;
  DateTime tanggalLengkap;
  String hari;
  String imsak;
  String subuh;
  String terbit;
  String dhuha;
  String dzuhur;
  String ashar;
  String maghrib;
  String isya;

  Jadwal({
    required this.tanggal,
    required this.tanggalLengkap,
    required this.hari,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      tanggal: json['tanggal'] is int ? json['tanggal'] as int : int.parse(json['tanggal'].toString()),
      tanggalLengkap: DateTime.parse(json['tanggalLengkap'] as String),
      hari: json['hari'] as String,
      imsak: json['imsak'] as String,
      subuh: json['subuh'] as String,
      terbit: json['terbit'] as String,
      dhuha: json['dhuha'] as String,
      dzuhur: json['dzuhur'] as String,
      ashar: json['ashar'] as String,
      maghrib: json['maghrib'] as String,
      isya: json['isya'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal,
      'tanggalLengkap': tanggalLengkap.toIso8601String().split('T')[0],
      'hari': hari,
      'imsak': imsak,
      'subuh': subuh,
      'terbit': terbit,
      'dhuha': dhuha,
      'dzuhur': dzuhur,
      'ashar': ashar,
      'maghrib': maghrib,
      'isya': isya,
    };
  }
}
