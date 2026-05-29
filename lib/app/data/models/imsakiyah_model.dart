class Imsakiyah {
  int code;
  String message;
  Data data;

  Imsakiyah({required this.code, required this.message, required this.data});

  factory Imsakiyah.fromJson(Map<String, dynamic> json) {
    return Imsakiyah(
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
  String hijriah;
  String masehi;
  List<ImsakiyahElement> imsakiyah;

  Data({
    required this.provinsi,
    required this.kabkota,
    required this.hijriah,
    required this.masehi,
    required this.imsakiyah,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      provinsi: json['provinsi'] as String,
      kabkota: json['kabkota'] as String,
      hijriah: json['hijriah'] as String,
      masehi: json['masehi'] as String,
      imsakiyah: (json['imsakiyah'] as List)
          .map((item) => ImsakiyahElement.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provinsi': provinsi,
      'kabkota': kabkota,
      'hijriah': hijriah,
      'masehi': masehi,
      'imsakiyah': imsakiyah.map((item) => item.toJson()).toList(),
    };
  }
}

class ImsakiyahElement {
  int tanggal;
  String imsak;
  String subuh;
  String terbit;
  String dhuha;
  String dzuhur;
  String ashar;
  String maghrib;
  String isya;

  ImsakiyahElement({
    required this.tanggal,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory ImsakiyahElement.fromJson(Map<String, dynamic> json) {
    return ImsakiyahElement(
      tanggal: json['tanggal'] is int ? json['tanggal'] as int : int.parse(json['tanggal'].toString()),
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
