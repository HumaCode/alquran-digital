class TafsirSurah {
  int code;
  String message;
  TafsirData data;

  TafsirSurah({required this.code, required this.message, required this.data});

  factory TafsirSurah.fromJson(Map<String, dynamic> json) {
    return TafsirSurah(
      code: json['code'] as int,
      message: json['message'] as String,
      data: TafsirData.fromJson(json['data'] as Map<String, dynamic>),
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

class TafsirData {
  int nomor;
  String nama;
  String namaLatin;
  int jumlahAyat;
  String tempatTurun;
  String arti;
  String deskripsi;
  List<TafsirAyat> tafsir;

  TafsirData({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.tafsir,
  });

  factory TafsirData.fromJson(Map<String, dynamic> json) {
    return TafsirData(
      nomor: json['nomor'] as int,
      nama: json['nama'] as String,
      namaLatin: json['namaLatin'] as String,
      jumlahAyat: json['jumlahAyat'] as int,
      tempatTurun: json['tempatTurun'] as String,
      arti: json['arti'] as String,
      deskripsi: json['deskripsi'] as String,
      tafsir: (json['tafsir'] as List<dynamic>)
          .map((e) => TafsirAyat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'nama': nama,
      'namaLatin': namaLatin,
      'jumlahAyat': jumlahAyat,
      'tempatTurun': tempatTurun,
      'arti': arti,
      'deskripsi': deskripsi,
      'tafsir': tafsir.map((e) => e.toJson()).toList(),
    };
  }
}

class TafsirAyat {
  int ayat;
  String teks;

  TafsirAyat({required this.ayat, required this.teks});

  factory TafsirAyat.fromJson(Map<String, dynamic> json) {
    return TafsirAyat(
      ayat: json['ayat'] as int,
      teks: json['teks'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayat': ayat,
      'teks': teks,
    };
  }
}
